import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class WhisperTranscriptionService {
  final String baseUrl;
  final http.Client _httpClient;
  final Logger _logger = Logger();

  WhisperTranscriptionService({
    this.baseUrl = 'http://127.0.0.1:8085',
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Transcribes audio file to text using local Whisper server
  Future<String> transcribe(String audioFilePath) async {
    try {
      _logger.i('Transcribing audio: $audioFilePath');

      // Read and encode audio file
      final audioBytes = await File(audioFilePath).readAsBytes();
      final audioBase64 = base64Encode(audioBytes);

      // Send to local Whisper server
      final response = await _httpClient
          .post(
            Uri.parse('$baseUrl/v1/audio/transcriptions'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': 'whisper-1', // Uses whisper-tiny (fastest)
              'audio': audioBase64,
              'language': 'auto', // Auto-detect language
            }),
          )
          .timeout(
            const Duration(minutes: 2),
            onTimeout: () => throw TimeoutException('Transcription timed out'),
          );

      if (response.statusCode != 200) {
        throw Exception('Transcription failed: HTTP ${response.statusCode}');
      }

      final result = jsonDecode(response.body);
      final text = result['text'] as String;

      _logger.i('Transcription complete: ${text.length} chars');
      return text.trim();
    } catch (e) {
      _logger.e('Transcription error: $e');
      rethrow;
    }
  }

  /// Check if Whisper server is running
  Future<bool> isServerAvailable() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
