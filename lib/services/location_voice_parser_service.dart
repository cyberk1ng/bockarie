import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:bockaire/services/ai_provider_interfaces.dart';
import 'package:logger/logger.dart';
import 'dart:convert';

class LocationVoiceParserService {
  final GenerativeModel _model;
  final Logger _logger = Logger();

  LocationVoiceParserService(String apiKey)
    : _model = GenerativeModel(
        model: 'gemini-2.0-flash-exp',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.1,
          responseMimeType: 'application/json',
        ),
      );

  /// Parse transcribed text into ShipmentLocationData
  Future<ShipmentLocationData?> parseLocationFromText({
    required String transcribedText,
  }) async {
    try {
      _logger.i('Parsing location from text: $transcribedText');

      final prompt =
          '''
Extract shipping route information from this transcribed voice input:
"$transcribedText"

Parse the following information:
- Origin city (where shipment starts)
- Destination city (where shipment goes)

Common patterns to recognize:
- "from X to Y"
- "X to Y"
- "shipping from X to Y"
- "origin X destination Y"
- "send from X to Y"

Return ONLY valid JSON:
{
  "originCity": "string" or null,
  "destinationCity": "string" or null
}

Examples:
- "From Shanghai to New York"
  → {"originCity": "Shanghai", "destinationCity": "New York"}

- "London to Berlin"
  → {"originCity": "London", "destinationCity": "Berlin"}

- "Shipping from Los Angeles to Miami"
  → {"originCity": "Los Angeles", "destinationCity": "Miami"}

- "Origin Guangzhou destination Frankfurt"
  → {"originCity": "Guangzhou", "destinationCity": "Frankfurt"}

If any value is unclear or not mentioned, use null.
Only extract city names, not countries or postal codes.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final jsonText = response.text?.trim() ?? '{}';

      _logger.d('Gemini response: $jsonText');

      final data = jsonDecode(jsonText) as Map<String, dynamic>;

      final locationData = ShipmentLocationData(
        originCity: data['originCity'] as String?,
        destinationCity: data['destinationCity'] as String?,
      );

      if (!locationData.isComplete) {
        _logger.w('Incomplete location data: $locationData');
        return null;
      }

      _logger.i('Parsed location data: $locationData');
      return locationData;
    } catch (e) {
      _logger.e('Failed to parse location: $e');
      rethrow;
    }
  }
}
