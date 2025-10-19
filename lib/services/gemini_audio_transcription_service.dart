import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:openai_dart/openai_dart.dart';

/// Gemini audio transcription using OpenAI-compatible API
///
/// This service uses Gemini's OpenAI-compatible API endpoint to transcribe audio
/// with streaming support for efficient processing.
class GeminiAudioTranscriptionService {
  final String apiKey;
  final http.Client _httpClient;
  final Logger _logger = Logger();

  GeminiAudioTranscriptionService(this.apiKey, {http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  /// Transcribe audio file using Gemini's OpenAI-compatible API
  ///
  /// Uses streaming and chunk collection for efficient processing.
  Future<String> transcribe(String audioFilePath) async {
    try {
      _logger.i('Transcribing audio with Gemini: $audioFilePath');

      // Read audio file and encode to base64
      final audioBytes = await File(audioFilePath).readAsBytes();
      final audioBase64 = base64Encode(audioBytes);

      _logger.i(
        'Audio file size: ${audioBytes.length} bytes (${(audioBytes.length / 1024).toStringAsFixed(1)} KB)',
      );

      // Create OpenAI client with Gemini's OpenAI-compatible endpoint
      // Note: baseUrl must not end with '/' for openai_dart package
      final client = OpenAIClient(
        baseUrl: 'https://generativelanguage.googleapis.com/v1beta/openai',
        apiKey: apiKey,
      );

      // Transcription prompt
      const prompt = 'Transcribe the audio to natural text.';

      _logger.i('🌐 Sending transcription request to Gemini...');
      _logger.i('🔑 Using API key: ${apiKey.substring(0, 10)}...');
      _logger.i('📦 Audio base64 length: ${audioBase64.length} chars');

      // Create streaming request for audio transcription
      final stream = client.createChatCompletionStream(
        request: CreateChatCompletionRequest(
          messages: [
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.parts([
                ChatCompletionMessageContentPart.text(text: prompt),
                ChatCompletionMessageContentPart.audio(
                  inputAudio: ChatCompletionMessageInputAudio(
                    data: audioBase64,
                    format: ChatCompletionMessageInputAudioFormat
                        .mp3, // Gemini accepts m4a as mp3 format
                  ),
                ),
              ]),
            ),
          ],
          model: const ChatCompletionModel.modelId('gemini-2.0-flash-exp'),
          stream: true, // Enable streaming for efficient processing
        ),
      );

      _logger.i('🔄 Stream created, collecting chunks...');

      // Collect stream chunks into buffer
      final buffer = StringBuffer();
      var chunkCount = 0;
      await for (final chunk in stream) {
        chunkCount++;
        final content = chunk.choices?.firstOrNull?.delta?.content ?? '';
        _logger.i(
          '📨 Chunk #$chunkCount: "$content" (${content.length} chars)',
        );
        if (content.isNotEmpty) {
          buffer.write(content);
        }
      }

      final text = buffer.toString().trim();

      _logger.i(
        '✅ Gemini transcription complete: ${text.length} chars from $chunkCount chunks',
      );
      _logger.i('📝 Full transcribed text: "$text"');

      if (text.isEmpty) {
        _logger.w('Empty transcription received from Gemini');
        throw Exception('Empty transcription from Gemini');
      }

      return text;
    } catch (e) {
      _logger.e('Gemini transcription failed: $e');
      rethrow;
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
