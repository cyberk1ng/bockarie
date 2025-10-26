/// Utilities for building Gemini HTTP requests
///
/// Based on lotti project's GeminiUtils pattern for clean HTTP mocking
class GeminiUtils {
  const GeminiUtils._();

  /// Builds the non-streaming :generateContent URI
  static Uri buildGenerateContentUri({
    required String model,
    required String apiKey,
    String baseUrl = 'https://generativelanguage.googleapis.com',
  }) {
    final parsed = Uri.parse(baseUrl);
    final root = Uri(
      scheme: parsed.scheme.isNotEmpty ? parsed.scheme : 'https',
      host: parsed.host,
      port: parsed.hasPort ? parsed.port : null,
    );

    final trimmed = model.trim().endsWith('/')
        ? model.trim().substring(0, model.trim().length - 1)
        : model.trim();
    final modelPath = trimmed.startsWith('models/')
        ? trimmed
        : 'models/$trimmed';
    final path = '/v1beta/$modelPath:generateContent';

    return root.replace(
      path: path,
      queryParameters: <String, String>{'key': apiKey},
    );
  }

  /// Builds a Gemini request body for JSON generation
  static Map<String, dynamic> buildRequestBody({
    required String prompt,
    double temperature = 0.1,
    String responseMimeType = 'application/json',
  }) {
    return {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'temperature': temperature,
        'responseMimeType': responseMimeType,
      },
    };
  }

  /// Parses Gemini response to extract text from first candidate
  static String? extractTextFromResponse(Map<String, dynamic> response) {
    final candidates = response['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      return null;
    }

    final firstCandidate = candidates[0];
    if (firstCandidate is! Map<String, dynamic>) {
      return null;
    }

    final content = firstCandidate['content'];
    if (content is! Map<String, dynamic>) {
      return null;
    }

    final parts = content['parts'];
    if (parts is! List || parts.isEmpty) {
      return null;
    }

    final firstPart = parts[0];
    if (firstPart is! Map<String, dynamic>) {
      return null;
    }

    return firstPart['text'] as String?;
  }
}
