import 'dart:convert';

import 'package:bockaire/services/ai_optimizer_interfaces.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:logger/logger.dart';

class GeminiPackingOptimizer implements PackingOptimizerAI {
  final String apiKey;
  final String model;
  final Logger _logger = Logger();
  late final GenerativeModel _model;

  GeminiPackingOptimizer({
    required this.apiKey,
    this.model = 'gemini-2.0-flash-exp',
  }) {
    _model = GenerativeModel(
      model: model,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.3, // Creative but not random
        responseMimeType: 'application/json',
      ),
    );
  }

  @override
  String get name => 'Gemini ($model)';

  @override
  bool get isAvailable => apiKey.isNotEmpty;

  @override
  Future<PackingRecommendation> getRecommendations({
    required OptimizationContext context,
  }) async {
    try {
      _logger.i('Getting AI packing recommendations from Gemini');

      final prompt = _buildPrompt(context);
      final response = await _model.generateContent([Content.text(prompt)]);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini');
      }

      _logger.d('Gemini response: ${response.text}');

      final jsonResponse = jsonDecode(response.text!);
      return PackingRecommendation.fromJson(jsonResponse);
    } catch (e, stackTrace) {
      _logger.e('Gemini optimization error', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  String _buildPrompt(OptimizationContext context) {
    final totalItems = context.cartons.fold(0, (sum, c) => sum + c.qty);

    final totalWeight = context.cartons.fold(
      0.0,
      (sum, c) => sum + (c.weightKg * c.qty),
    );

    final currentBoxCount = context.cartons.length;

    final cartonsSummary = context.cartons
        .map((c) {
          return '- ${c.qty}x ${c.itemType}: ${c.lengthCm}×${c.widthCm}×${c.heightCm} cm, ${c.weightKg} kg each';
        })
        .join('\n');

    return '''
You are an expert shipping logistics consultant specializing in clothing and textiles shipment optimization from China to Germany.

CURRENT PACKING ($currentBoxCount separate boxes):
$cartonsSummary

TOTALS:
- Number of boxes/cartons to ship: $currentBoxCount
- Total items across all boxes: $totalItems
- Total weight: ${totalWeight.toStringAsFixed(1)} kg
- Item type: ${context.itemDescription ?? 'general items'}
- Material: ${context.materialType ?? 'unknown'}
- Max weight per box: ${context.maxWeightPerBox} kg
- Compression allowed: ${context.allowCompression}

GOAL:
REDUCE the number of boxes needed by optimizing packing. Your recommendedBoxCount MUST be LESS THAN $currentBoxCount.

TASK:
Analyze this packing and provide optimization recommendations. Consider:
1. Material properties (compressibility, fragility, moisture sensitivity)
2. Volumetric weight calculation (L×W×H ÷ 5000)
3. Safe compression limits for the material type
4. Stacking and handling constraints
5. Customs and shipping best practices for Germany
6. Consolidating items to reduce total box count
7. Using vacuum compression for textiles to save space

Return ONLY valid JSON in this exact format:
{
  "recommendedBoxCount": <number LESS THAN $currentBoxCount>,
  "compressionAdvice": "<specific advice on how to compress items safely>",
  "estimatedSavingsPercent": <number between 0-100>,
  "warnings": ["<warning 1>", "<warning 2>"],
  "tips": ["<actionable tip 1>", "<actionable tip 2>"],
  "explanation": "<natural language explanation in 2-3 sentences>",
  "structuredData": {
    "compressionRatio": <number 0-1>,
    "suggestedBoxDimensions": [<length>, <width>, <height>],
    "itemsPerBox": <number>
  }
}

IMPORTANT:
- recommendedBoxCount MUST be LESS than the current $currentBoxCount boxes
- Be specific and actionable
- Focus on clothing/textile optimization if that's the item type
- Consider German import regulations
- Provide realistic savings estimates (typically 10-40% for clothing)
- Warn about potential damage risks
- The goal is to ship fewer, more efficiently packed boxes
''';
  }
}
