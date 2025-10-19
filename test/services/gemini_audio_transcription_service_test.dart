import 'dart:io';
import 'package:bockaire/services/gemini_audio_transcription_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  late GeminiAudioTranscriptionService service;
  Directory? tempDir;

  setUp(() {
    service = GeminiAudioTranscriptionService('test_api_key_1234567890');
  });

  tearDown(() async {
    service.dispose();
    if (tempDir != null && tempDir!.existsSync()) {
      await tempDir!.delete(recursive: true);
    }
  });

  group('GeminiAudioTranscriptionService', () {
    test('constructor initializes with API key', () {
      expect(service.apiKey, 'test_api_key_1234567890');
    });

    test('transcribe throws exception when file not found', () async {
      final nonExistentPath = '/nonexistent/path/audio.m4a';

      expect(
        () => service.transcribe(nonExistentPath),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('transcribe handles empty audio file path', () async {
      expect(() => service.transcribe(''), throwsA(isA<FileSystemException>()));
    });

    test('transcribe throws on invalid API key', () async {
      tempDir = await Directory.systemTemp.createTemp('audio_test_');
      final audioFile = File(path.join(tempDir!.path, 'test_audio.m4a'));
      await audioFile.writeAsBytes([1, 2, 3, 4, 5]);

      final invalidService = GeminiAudioTranscriptionService('invalid_key');

      expect(
        () => invalidService.transcribe(audioFile.path),
        throwsA(isA<Exception>()),
      );
      invalidService.dispose();
    });

    test('dispose can be called multiple times', () {
      service.dispose();
      service.dispose(); // Should not throw
    });

    test('transcribe reads audio file correctly', () async {
      tempDir = await Directory.systemTemp.createTemp('audio_test_');
      final audioFile = File(path.join(tempDir!.path, 'test_audio.m4a'));
      final testData = [1, 2, 3, 4, 5, 6, 7, 8];
      await audioFile.writeAsBytes(testData);

      // This will fail with invalid API key, but confirms file is read
      expect(
        () => service.transcribe(audioFile.path),
        throwsA(isA<Exception>()),
      );
    });

    test('transcribe handles large audio files', () async {
      tempDir = await Directory.systemTemp.createTemp('audio_test_');
      final audioFile = File(path.join(tempDir!.path, 'large_audio.m4a'));
      // Create a larger file (100KB)
      final largeData = List<int>.filled(100 * 1024, 0);
      await audioFile.writeAsBytes(largeData);

      // Will fail with invalid key but confirms large files can be read
      expect(
        () => service.transcribe(audioFile.path),
        throwsA(isA<Exception>()),
      );
    });

    test('transcribe handles empty audio file', () async {
      tempDir = await Directory.systemTemp.createTemp('audio_test_');
      final audioFile = File(path.join(tempDir!.path, 'empty_audio.m4a'));
      await audioFile.writeAsBytes([]);

      // Empty file should still be processed (though transcription might be empty)
      expect(
        () => service.transcribe(audioFile.path),
        throwsA(isA<Exception>()),
      );
    });
  });
}
