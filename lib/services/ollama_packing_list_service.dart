import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:bockaire/services/ai_provider_interfaces.dart';

class ModelNotInstalledException implements Exception {
  final String modelName;
  ModelNotInstalledException(this.modelName);

  @override
  String toString() =>
      'Model "$modelName" not installed. Please install it first.';
}

class OllamaPackingListService implements AiImageAnalyzer {
  final String baseUrl;
  final String model;
  final http.Client _httpClient;
  final Logger _logger = Logger();

  OllamaPackingListService({
    required this.baseUrl,
    required this.model,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  @override
  String get name => 'Ollama Vision ($model)';

  @override
  bool get isAvailable => baseUrl.isNotEmpty && model.isNotEmpty;

  @override
  Future<List<CartonData>> extractCartonsFromImage(File imageFile) async {
    try {
      _logger.i('Analyzing packing list with Ollama ($model)');

      // Read and encode image to base64
      final imageBytes = await imageFile.readAsBytes();
      final imageBase64 = base64Encode(imageBytes);

      // Build request for /api/chat endpoint
      final requestBody = {
        'model': model,
        'messages': [
          {
            'role': 'user',
            'content': _packingListPrompt,
            'images': [imageBase64],
          },
        ],
        'stream': true,
        'format': 'json',
        'options': {
          'temperature': 0.1,
          'num_predict': 2048, // Max tokens for response
        },
      };

      // Send POST request with streaming
      final response = await _retryWithBackoff(() async {
        final request = http.Request('POST', Uri.parse('$baseUrl/api/chat'));
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode(requestBody);
        return await _httpClient
            .send(request)
            .timeout(const Duration(seconds: 120));
      });

      // Handle response status
      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        if (response.statusCode == 404 && body.contains('model')) {
          throw ModelNotInstalledException(model);
        }
        throw Exception('Ollama API error: ${response.statusCode} - $body');
      }

      // Stream and collect response chunks
      final buffer = StringBuffer();
      await for (final chunk
          in response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
        if (chunk.isEmpty) continue;

        final json = jsonDecode(chunk) as Map<String, dynamic>;
        final message = json['message'] as Map<String, dynamic>?;

        if (message != null && message['content'] != null) {
          buffer.write(message['content']);
        }

        if (json['done'] == true) break;
      }

      // Parse JSON response
      final text = buffer.toString().trim();

      if (text.isEmpty) {
        throw Exception('No response from Ollama');
      }

      _logger.d('Ollama response: $text');

      // Parse JSON - handle both array and object responses
      final decoded = jsonDecode(text);
      List<dynamic> cartonsJson;

      if (decoded is List) {
        // Direct array response
        cartonsJson = decoded;
      } else if (decoded is Map<String, dynamic>) {
        // Object response - try common keys
        if (decoded.containsKey('cartons')) {
          cartonsJson = decoded['cartons'] as List;
        } else if (decoded.containsKey('items')) {
          cartonsJson = decoded['items'] as List;
        } else if (decoded.containsKey('data')) {
          cartonsJson = decoded['data'] as List;
        } else {
          // If no common key, treat the whole object as a single item
          _logger.w('Unexpected JSON structure, wrapping in array: $decoded');
          cartonsJson = [decoded];
        }
      } else {
        throw Exception('Unexpected JSON type: ${decoded.runtimeType}');
      }

      final cartons = cartonsJson
          .map((json) => CartonData.fromJson(json as Map<String, dynamic>))
          .toList();

      _logger.i('Extracted ${cartons.length} cartons from image');
      return cartons;
    } on SocketException {
      _logger.e('Network error - Ollama server not reachable');
      throw Exception(
        'Cannot connect to Ollama server at $baseUrl.\n'
        'Please ensure Ollama is running.',
      );
    } on TimeoutException {
      _logger.e('Request timed out');
      throw Exception(
        'Request timed out after 120 seconds.\n'
        'Vision models may take longer on first run.',
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Error analyzing image with Ollama',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<T> _retryWithBackoff<T>(Future<T> Function() operation) async {
    int attempt = 0;
    while (attempt < 3) {
      try {
        return await operation();
      } on TimeoutException {
        attempt++;
        if (attempt >= 3) {
          rethrow;
        }
        _logger.w('Timeout on attempt $attempt, retrying...');
        await Future.delayed(Duration(seconds: 2 * (1 << attempt)));
      } on SocketException {
        attempt++;
        if (attempt >= 3) {
          rethrow;
        }
        _logger.w('Network error on attempt $attempt, retrying...');
        await Future.delayed(Duration(seconds: 2 * (1 << attempt)));
      }
    }
    throw Exception('Unexpected retry failure');
  }

  String get _packingListPrompt => '''
You are analyzing a shipping packing list image. Extract ALL carton/box entries from the image.

For each carton, extract:
- Dimensions (length × width × height in centimeters)
- Weight (in kilograms)
- Quantity/count
- Item type/description

IMPORTANT:
- Look for table rows or list items
- Convert all dimensions to centimeters (from inches/cm/mm)
- Convert all weights to kilograms (from kg/lbs/g)
- If multiple cartons have same dimensions, create separate entries
- Ignore headers, totals, and non-carton data

Return ONLY valid JSON array:
[
  {
    "lengthCm": number,
    "widthCm": number,
    "heightCm": number,
    "weightKg": number,
    "qty": number,
    "itemType": "string"
  }
]

Example packing list:
| Dims (cm) | Weight | Qty | Item |
| 50×30×20  | 5 kg   | 10  | Laptops |
| 40×40×30  | 8.5 kg | 5   | Monitors |

Returns:
[
  {"lengthCm": 50, "widthCm": 30, "heightCm": 20, "weightKg": 5, "qty": 10, "itemType": "Laptops"},
  {"lengthCm": 40, "widthCm": 40, "heightCm": 30, "weightKg": 8.5, "qty": 5, "itemType": "Monitors"}
]
''';
}
