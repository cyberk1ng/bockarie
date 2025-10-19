import 'dart:convert';
import 'dart:io';
import 'package:bockaire/classes/carton.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:logger/logger.dart';

/// Base interface for AI providers
abstract class AiProvider {
  String get name;
  bool get isAvailable;
}

/// Interface for image-to-cartons extraction
abstract class AiImageAnalyzer extends AiProvider {
  /// Extract carton data from a packing list image
  Future<List<CartonData>> extractCartonsFromImage(File imageFile);
}

/// Interface for voice-to-text transcription
abstract class AiTranscriber extends AiProvider {
  /// Transcribe audio to text
  Future<String> transcribe(File audioFile);

  /// Parse transcribed text into carton commands
  Future<List<CartonData>> parseCartonCommands(String text);
}

/// Interface for cost explanation generation
abstract class AiCostExplainer extends AiProvider {
  /// Generate explanation for shipping cost
  Future<String> explainCost({
    required double totalCost,
    required double chargeableKg,
    required String carrier,
    required String service,
    required Map<String, dynamic> breakdown,
  });
}

/// Carton data extracted from AI
class CartonData {
  final double? lengthCm;
  final double? widthCm;
  final double? heightCm;
  final double? weightKg;
  final int? qty;
  final String? itemType;

  const CartonData({
    this.lengthCm,
    this.widthCm,
    this.heightCm,
    this.weightKg,
    this.qty,
    this.itemType,
  });

  bool get isComplete =>
      lengthCm != null &&
      widthCm != null &&
      heightCm != null &&
      weightKg != null &&
      qty != null &&
      itemType != null;

  factory CartonData.fromJson(Map<String, dynamic> json) => CartonData(
    lengthCm: json['lengthCm'] != null
        ? (json['lengthCm'] as num).toDouble()
        : null,
    widthCm: json['widthCm'] != null
        ? (json['widthCm'] as num).toDouble()
        : null,
    heightCm: json['heightCm'] != null
        ? (json['heightCm'] as num).toDouble()
        : null,
    weightKg: json['weightKg'] != null
        ? (json['weightKg'] as num).toDouble()
        : null,
    qty: json['qty'] != null ? (json['qty'] as num).toInt() : null,
    itemType: json['itemType'] as String?,
  );

  Carton toCarton({required String id, required String shipmentId}) {
    return Carton(
      id: id,
      shipmentId: shipmentId,
      lengthCm: lengthCm ?? 0,
      widthCm: widthCm ?? 0,
      heightCm: heightCm ?? 0,
      weightKg: weightKg ?? 0,
      qty: qty ?? 1,
      itemType: itemType ?? 'Unknown',
    );
  }

  @override
  String toString() {
    return 'CartonData($lengthCm×$widthCm×$heightCm cm, $weightKg kg, qty:$qty, type:$itemType)';
  }
}

/// Shipment location data extracted from voice
class ShipmentLocationData {
  final String? originCity;
  final String? destinationCity;

  const ShipmentLocationData({this.originCity, this.destinationCity});

  bool get isComplete => originCity != null && destinationCity != null;

  @override
  String toString() {
    return 'ShipmentLocationData(from: $originCity, to: $destinationCity)';
  }
}

/// Complete voice input result with location and carton data
class VoiceInputResult {
  final String? originCity;
  final String? originPostal;
  final String? originCountry;
  final String? originState;
  final String? destCity;
  final String? destPostal;
  final String? destCountry;
  final String? destState;
  final CartonData? cartonData;

  const VoiceInputResult({
    this.originCity,
    this.originPostal,
    this.originCountry,
    this.originState,
    this.destCity,
    this.destPostal,
    this.destCountry,
    this.destState,
    this.cartonData,
  });

  bool get hasLocation =>
      originCity != null &&
      originPostal != null &&
      destCity != null &&
      destPostal != null;

  bool get hasCarton => cartonData != null && cartonData!.isComplete;

  @override
  String toString() {
    return 'VoiceInputResult(from: $originCity to $destCity, carton: $cartonData)';
  }
}

/// Gemini implementation of image analyzer
class GeminiImageAnalyzer implements AiImageAnalyzer {
  final String apiKey;
  final String model;
  final Logger _logger = Logger();
  late final GenerativeModel _model;

  GeminiImageAnalyzer({
    required this.apiKey,
    this.model = 'gemini-2.0-flash-exp',
  }) {
    _model = GenerativeModel(model: model, apiKey: apiKey);
  }

  @override
  String get name => 'Gemini Vision ($model)';

  @override
  bool get isAvailable => apiKey.isNotEmpty;

  @override
  Future<List<CartonData>> extractCartonsFromImage(File imageFile) async {
    try {
      _logger.i('Analyzing packing list image with Gemini Vision');

      // Read image file
      final imageBytes = await imageFile.readAsBytes();

      // Create multimodal content
      final content = [
        Content.multi([
          TextPart(_packingListPrompt),
          DataPart('image/jpeg', imageBytes),
        ]),
      ];

      // Generate with JSON mode
      final response = await _model.generateContent(
        content,
        generationConfig: GenerationConfig(
          temperature: 0.1,
          responseMimeType: 'application/json',
        ),
      );

      if (response.text == null || response.text!.isEmpty) {
        _logger.w('Gemini returned empty response');
        throw Exception('No response from Gemini');
      }

      _logger.d('Gemini response: ${response.text}');

      // Parse JSON response
      final jsonResponse = jsonDecode(response.text!);
      final cartonsList = jsonResponse is List ? jsonResponse : [];

      final cartons = cartonsList
          .map((json) => CartonData.fromJson(json as Map<String, dynamic>))
          .toList();

      _logger.i('Extracted ${cartons.length} cartons from image');
      return cartons;
    } catch (e, stackTrace) {
      _logger.e(
        'Error analyzing image with Gemini',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
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

/// Gemini implementation of transcriber
class GeminiTranscriber implements AiTranscriber {
  final String apiKey;

  GeminiTranscriber({required this.apiKey});

  @override
  String get name => 'Gemini Audio';

  @override
  bool get isAvailable => apiKey.isNotEmpty;

  @override
  Future<String> transcribe(File audioFile) async {
    // TODO: Implement Gemini audio transcription
    throw UnimplementedError('Gemini transcription not yet implemented');
  }

  @override
  Future<List<CartonData>> parseCartonCommands(String text) async {
    // TODO: Implement parsing logic using Gemini
    throw UnimplementedError('Carton parsing not yet implemented');
  }
}

/// Gemini implementation of cost explainer
class GeminiCostExplainer implements AiCostExplainer {
  final String apiKey;

  GeminiCostExplainer({required this.apiKey});

  @override
  String get name => 'Gemini Text';

  @override
  bool get isAvailable => apiKey.isNotEmpty;

  @override
  Future<String> explainCost({
    required double totalCost,
    required double chargeableKg,
    required String carrier,
    required String service,
    required Map<String, dynamic> breakdown,
  }) async {
    // TODO: Implement Gemini-based explanation
    // Fallback template for now
    return _generateFallbackExplanation(
      totalCost: totalCost,
      chargeableKg: chargeableKg,
      carrier: carrier,
      service: service,
      breakdown: breakdown,
    );
  }

  String _generateFallbackExplanation({
    required double totalCost,
    required double chargeableKg,
    required String carrier,
    required String service,
    required Map<String, dynamic> breakdown,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Cost Breakdown for $carrier $service:');
    buffer.writeln();
    buffer.writeln(
      'Your shipment weighs ${chargeableKg.toStringAsFixed(1)}kg (chargeable weight).',
    );

    if (breakdown.containsKey('base')) {
      buffer.writeln('• Base fee: €${breakdown['base'].toStringAsFixed(2)}');
    }
    if (breakdown.containsKey('perKg')) {
      buffer.writeln(
        '• Per-kg charge: €${breakdown['perKg'].toStringAsFixed(2)}',
      );
    }
    if (breakdown.containsKey('fuel')) {
      buffer.writeln(
        '• Fuel surcharge: €${breakdown['fuel'].toStringAsFixed(2)}',
      );
    }
    if (breakdown.containsKey('oversize') && breakdown['oversize'] > 0) {
      buffer.writeln(
        '• Oversize fee: €${breakdown['oversize'].toStringAsFixed(2)}',
      );
    }

    buffer.writeln();
    buffer.writeln('Total: €${totalCost.toStringAsFixed(2)}');

    return buffer.toString();
  }
}

/// Factory for creating AI providers
class AiProviderFactory {
  static AiImageAnalyzer createImageAnalyzer({
    required String provider,
    required String apiKey,
  }) {
    switch (provider.toLowerCase()) {
      case 'gemini':
        return GeminiImageAnalyzer(apiKey: apiKey);
      // Add more providers here (OpenAI, Ollama, etc.)
      default:
        throw UnsupportedError('Unsupported AI provider: $provider');
    }
  }

  static AiTranscriber createTranscriber({
    required String provider,
    required String apiKey,
  }) {
    switch (provider.toLowerCase()) {
      case 'gemini':
        return GeminiTranscriber(apiKey: apiKey);
      default:
        throw UnsupportedError('Unsupported AI provider: $provider');
    }
  }

  static AiCostExplainer createCostExplainer({
    required String provider,
    required String apiKey,
  }) {
    switch (provider.toLowerCase()) {
      case 'gemini':
        return GeminiCostExplainer(apiKey: apiKey);
      default:
        throw UnsupportedError('Unsupported AI provider: $provider');
    }
  }
}
