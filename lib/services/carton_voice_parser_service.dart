import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:bockaire/services/ai_provider_interfaces.dart';
import 'package:logger/logger.dart';
import 'dart:convert';

class CartonVoiceParserService {
  final GenerativeModel _model;
  final Logger _logger = Logger();

  CartonVoiceParserService(String apiKey)
    : _model = GenerativeModel(
        model: 'gemini-2.0-flash-exp', // Fast and smart
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.1, // Deterministic parsing
          responseMimeType: 'application/json',
        ),
      );

  /// Parse transcribed text into CartonData
  Future<CartonData?> parseCartonFromText({
    required String transcribedText,
  }) async {
    try {
      _logger.i('Parsing carton from text: $transcribedText');

      final prompt =
          '''
Extract shipping carton details from this transcribed voice input:
"$transcribedText"

Parse the following information:
- Length, width, height (in centimeters)
- Weight (in kilograms)
- Quantity/count
- Item type/description

Return ONLY valid JSON:
{
  "lengthCm": number or null,
  "widthCm": number or null,
  "heightCm": number or null,
  "weightKg": number or null,
  "qty": number or null,
  "itemType": "string" or null
}

Examples:
- "A box 50 by 30 by 20 centimeters, weighing 5 kilos, quantity 10, laptops"
  → {"lengthCm": 50, "widthCm": 30, "heightCm": 20, "weightKg": 5, "qty": 10, "itemType": "laptops"}

- "3 cartons of shoes, each 40 by 30 by 25, weight 3.5 kg"
  → {"lengthCm": 40, "widthCm": 30, "heightCm": 25, "weightKg": 3.5, "qty": 3, "itemType": "shoes"}

If any value is unclear or not mentioned, use null.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final jsonText = response.text?.trim() ?? '{}';

      _logger.d('Gemini response: $jsonText');

      final data = jsonDecode(jsonText) as Map<String, dynamic>;

      // Create CartonData object
      final cartonData = CartonData(
        lengthCm: data['lengthCm'] != null
            ? (data['lengthCm'] as num).toDouble()
            : null,
        widthCm: data['widthCm'] != null
            ? (data['widthCm'] as num).toDouble()
            : null,
        heightCm: data['heightCm'] != null
            ? (data['heightCm'] as num).toDouble()
            : null,
        weightKg: data['weightKg'] != null
            ? (data['weightKg'] as num).toDouble()
            : null,
        qty: data['qty'] != null ? (data['qty'] as num).toInt() : null,
        itemType: data['itemType'] as String?,
      );

      if (!cartonData.isComplete) {
        _logger.w('Incomplete carton data: $cartonData');
        return null;
      }

      _logger.i('Parsed carton data: $cartonData');
      return cartonData;
    } catch (e) {
      _logger.e('Failed to parse carton: $e');
      rethrow;
    }
  }
}
