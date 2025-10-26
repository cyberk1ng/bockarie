import 'dart:io';
import 'package:bockaire/services/gemini_audio_transcription_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GeminiAudioTranscriptionService service;

  setUp(() {
    service = GeminiAudioTranscriptionService('test_api_key_1234567890');
  });

  tearDown(() {
    service.dispose();
  });

  group('GeminiAudioTranscriptionService', () {
    test('constructor initializes with API key', () {
      expect(service.apiKey, 'test_api_key_1234567890');
    });

    test('transcribe throws exception when file not found', () async {
      final nonExistentPath = '/nonexistent/path/audio.m4a';

      await expectLater(
        service.transcribe(nonExistentPath),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('transcribe handles empty audio file path', () async {
      await expectLater(
        service.transcribe(''),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('dispose can be called multiple times', () {
      service.dispose();
      service.dispose(); // Should not throw
    });
  });
}
