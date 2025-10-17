import 'dart:io';
import 'package:bockaire/classes/carton.dart';

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

/// Gemini implementation of image analyzer
class GeminiImageAnalyzer implements AiImageAnalyzer {
  final String apiKey;

  GeminiImageAnalyzer({required this.apiKey});

  @override
  String get name => 'Gemini Vision';

  @override
  bool get isAvailable => apiKey.isNotEmpty;

  @override
  Future<List<CartonData>> extractCartonsFromImage(File imageFile) async {
    // TODO: Implement Gemini Vision API call
    // For now, return empty list
    throw UnimplementedError('Gemini image analysis not yet implemented');
  }
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
