import 'dart:async';
import 'dart:convert';

import 'package:bockaire/services/ai_optimizer_interfaces.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class OllamaPackingOptimizer implements PackingOptimizerAI {
  final String baseUrl;
  final String model;
  final http.Client _httpClient;
  final Logger _logger = Logger();

  OllamaPackingOptimizer({
    required this.baseUrl,
    required this.model,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  @override
  String get name => 'Ollama ($model)';

  @override
  bool get isAvailable => baseUrl.isNotEmpty && model.isNotEmpty;

  @override
  Future<PackingRecommendation> getRecommendations({
    required OptimizationContext context,
  }) async {
    try {
      _logger.i('Getting AI packing recommendations from Ollama');

      final prompt = _buildPrompt(context);

      final response = await _httpClient
          .post(
            Uri.parse('$baseUrl/api/generate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': model,
              'prompt': prompt,
              'stream': true,
              'format': 'json',
              'options': {'temperature': 0.3, 'num_predict': 1024},
            }),
          )
          .timeout(const Duration(seconds: 120));

      if (response.statusCode != 200) {
        throw Exception('Ollama API error: ${response.statusCode}');
      }

      // Parse streaming response
      final buffer = StringBuffer();
      final lines = response.body.split('\n');

      for (final line in lines) {
        if (line.trim().isEmpty) continue;

        final json = jsonDecode(line) as Map<String, dynamic>;
        if (json['response'] != null) {
          buffer.write(json['response']);
        }

        if (json['done'] == true) break;
      }

      final text = buffer.toString().trim();
      _logger.d('Ollama response: $text');

      final jsonResponse = jsonDecode(text);
      return PackingRecommendation.fromJson(jsonResponse);
    } catch (e, stackTrace) {
      _logger.e('Ollama optimization error', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  String _buildPrompt(OptimizationContext context) {
    final totalCartons = context.cartons.fold<int>(0, (sum, c) => sum + c.qty);
    final totalWeight = context.cartons.fold<double>(
      0,
      (sum, c) => sum + (c.weightKg * c.qty),
    );
    final cartonsSummary = context.cartons
        .map((c) {
          return '- ${c.qty}x ${c.itemType}: ${c.lengthCm}×${c.widthCm}×${c.heightCm} cm, ${c.weightKg} kg each';
        })
        .join('\n');

    return '''
You are an expert shipping logistics consultant specializing in clothing and textiles shipment optimization from China to Germany.

CURRENT PACKING:
$cartonsSummary

TOTALS:
- Total cartons: $totalCartons
- Total weight: ${totalWeight.toStringAsFixed(1)} kg
- Item type: ${context.itemDescription ?? 'general items'}
- Material: ${context.materialType ?? 'unknown'}

Analyze and provide optimization recommendations in this EXACT JSON format:
{
  "recommendedBoxCount": 12,
  "compressionAdvice": "Cotton t-shirts can be compressed by 50% using vacuum bags",
  "estimatedSavingsPercent": 35,
  "warnings": ["Don't compress for more than 30 days"],
  "tips": ["Use vacuum bags", "Separate by item type"],
  "explanation": "By compressing cotton items and repacking, you can reduce from 20 to 12 boxes, saving 35% on shipping costs.",
  "structuredData": {
    "compressionRatio": 0.5,
    "suggestedBoxDimensions": [50, 40, 40],
    "itemsPerBox": 50
  }
}
''';
  }

  /// Check if Ollama server is available
  Future<bool> isServerAvailable() async {
    try {
      final response = await _httpClient
          .get(Uri.parse('$baseUrl/api/tags'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get list of available models
  Future<List<String>> getAvailableModels() async {
    try {
      final response = await _httpClient.get(Uri.parse('$baseUrl/api/tags'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models =
            (data['models'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        return models.map((m) => m['name'] as String).toList();
      }
      return [];
    } catch (e) {
      _logger.e('Failed to get Ollama models', error: e);
      return [];
    }
  }
}
