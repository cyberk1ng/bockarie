import 'package:bockaire/providers/transcription_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('TranscriptionProviderType', () {
    test('enum has gemini and whisper values', () {
      expect(TranscriptionProviderType.values, hasLength(2));
      expect(
        TranscriptionProviderType.values,
        contains(TranscriptionProviderType.gemini),
      );
      expect(
        TranscriptionProviderType.values,
        contains(TranscriptionProviderType.whisper),
      );
    });

    test('enum name returns correct string', () {
      expect(TranscriptionProviderType.gemini.name, 'gemini');
      expect(TranscriptionProviderType.whisper.name, 'whisper');
    });
  });

  group('TranscriptionProviderNotifier', () {
    test('initializes with gemini as default provider', () async {
      final notifier = TranscriptionProviderNotifier();

      // Give time for _loadProvider to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state, TranscriptionProviderType.gemini);
    });

    test('loads saved provider from SharedPreferences', () async {
      // Set up SharedPreferences with saved provider
      SharedPreferences.setMockInitialValues({
        'transcription_provider': 'whisper',
      });

      final notifier = TranscriptionProviderNotifier();

      // Give time for _loadProvider to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state, TranscriptionProviderType.whisper);
    });

    test(
      'setProvider updates state and persists to SharedPreferences',
      () async {
        final notifier = TranscriptionProviderNotifier();

        // Give time for initial load
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state, TranscriptionProviderType.gemini);

        // Change to whisper
        await notifier.setProvider(TranscriptionProviderType.whisper);

        expect(notifier.state, TranscriptionProviderType.whisper);

        // Verify it was persisted
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('transcription_provider'), 'whisper');
      },
    );

    test('setProvider persists gemini provider', () async {
      // Start with whisper
      SharedPreferences.setMockInitialValues({
        'transcription_provider': 'whisper',
      });

      final notifier = TranscriptionProviderNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state, TranscriptionProviderType.whisper);

      // Change to gemini
      await notifier.setProvider(TranscriptionProviderType.gemini);

      expect(notifier.state, TranscriptionProviderType.gemini);

      // Verify it was persisted
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('transcription_provider'), 'gemini');
    });

    test('loads default when no saved preference exists', () async {
      SharedPreferences.setMockInitialValues({});

      final notifier = TranscriptionProviderNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state, TranscriptionProviderType.gemini);
    });

    test('loads default when invalid provider name is saved', () async {
      SharedPreferences.setMockInitialValues({
        'transcription_provider': 'invalid_provider',
      });

      final notifier = TranscriptionProviderNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // Should fall back to gemini
      expect(notifier.state, TranscriptionProviderType.gemini);
    });

    test('handles multiple provider switches', () async {
      final notifier = TranscriptionProviderNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state, TranscriptionProviderType.gemini);

      // Switch to whisper
      await notifier.setProvider(TranscriptionProviderType.whisper);
      expect(notifier.state, TranscriptionProviderType.whisper);

      // Switch back to gemini
      await notifier.setProvider(TranscriptionProviderType.gemini);
      expect(notifier.state, TranscriptionProviderType.gemini);

      // Switch to whisper again
      await notifier.setProvider(TranscriptionProviderType.whisper);
      expect(notifier.state, TranscriptionProviderType.whisper);
    });

    test('persisted provider survives notifier recreation', () async {
      // First notifier sets whisper
      final notifier1 = TranscriptionProviderNotifier();
      await Future.delayed(const Duration(milliseconds: 100));
      await notifier1.setProvider(TranscriptionProviderType.whisper);

      // Create new notifier - should load whisper
      final notifier2 = TranscriptionProviderNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier2.state, TranscriptionProviderType.whisper);
    });

    test('handles empty string as provider name', () async {
      // Set up with empty string
      SharedPreferences.setMockInitialValues({'transcription_provider': ''});

      final notifier = TranscriptionProviderNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // Should fall back to default (gemini)
      expect(notifier.state, TranscriptionProviderType.gemini);
    });

    test('setProvider completes successfully', () async {
      final notifier = TranscriptionProviderNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // This should complete without throwing
      await expectLater(
        notifier.setProvider(TranscriptionProviderType.whisper),
        completes,
      );
    });

    test('state updates immediately after setProvider call', () async {
      final notifier = TranscriptionProviderNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state, TranscriptionProviderType.gemini);

      final future = notifier.setProvider(TranscriptionProviderType.whisper);

      // State should update immediately (before await)
      expect(notifier.state, TranscriptionProviderType.whisper);

      await future;
    });
  });

  group('GeminiAudioModelNotifier', () {
    test('initializes with gemini-2.0-flash-exp as default model', () async {
      final notifier = GeminiAudioModelNotifier();

      // Give time for _loadModel to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state, 'gemini-2.0-flash-exp');
    });

    test('loads saved model from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'gemini_audio_model': 'gemini-1.5-pro',
      });

      final notifier = GeminiAudioModelNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state, 'gemini-1.5-pro');
    });

    test('setModel updates state and persists to SharedPreferences', () async {
      final notifier = GeminiAudioModelNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state, 'gemini-2.0-flash-exp');

      await notifier.setModel('gemini-1.5-flash-8b');

      expect(notifier.state, 'gemini-1.5-flash-8b');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('gemini_audio_model'), 'gemini-1.5-flash-8b');
    });

    test('availableModels contains 5 models', () {
      expect(GeminiAudioModelNotifier.availableModels, hasLength(5));
      expect(
        GeminiAudioModelNotifier.availableModels,
        contains('gemini-2.0-flash-exp'),
      );
      expect(
        GeminiAudioModelNotifier.availableModels,
        contains('gemini-1.5-flash'),
      );
      expect(
        GeminiAudioModelNotifier.availableModels,
        contains('gemini-1.5-flash-8b'),
      );
      expect(
        GeminiAudioModelNotifier.availableModels,
        contains('gemini-1.5-pro'),
      );
      expect(
        GeminiAudioModelNotifier.availableModels,
        contains('gemini-1.5-pro-latest'),
      );
    });

    test('handles empty string as model name', () async {
      SharedPreferences.setMockInitialValues({'gemini_audio_model': ''});

      final notifier = GeminiAudioModelNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // Should use empty string as stored, not fall back to default
      expect(notifier.state, '');
    });

    test('loads default when no saved preference exists', () async {
      SharedPreferences.setMockInitialValues({});

      final notifier = GeminiAudioModelNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state, 'gemini-2.0-flash-exp');
    });

    test('persisted model survives notifier recreation', () async {
      final notifier1 = GeminiAudioModelNotifier();
      await Future.delayed(const Duration(milliseconds: 100));
      await notifier1.setModel('gemini-1.5-pro-latest');

      final notifier2 = GeminiAudioModelNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier2.state, 'gemini-1.5-pro-latest');
    });

    test('setModel completes successfully', () async {
      final notifier = GeminiAudioModelNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      await expectLater(notifier.setModel('gemini-1.5-flash'), completes);
    });

    test('state updates immediately after setModel call', () async {
      final notifier = GeminiAudioModelNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state, 'gemini-2.0-flash-exp');

      final future = notifier.setModel('gemini-1.5-pro');

      expect(notifier.state, 'gemini-1.5-pro');

      await future;
    });

    test('handles multiple model switches', () async {
      final notifier = GeminiAudioModelNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      await notifier.setModel('gemini-1.5-flash');
      expect(notifier.state, 'gemini-1.5-flash');

      await notifier.setModel('gemini-1.5-pro');
      expect(notifier.state, 'gemini-1.5-pro');

      await notifier.setModel('gemini-1.5-flash-8b');
      expect(notifier.state, 'gemini-1.5-flash-8b');
    });
  });

  group('WhisperModelNotifier', () {
    test('initializes with whisper-small as default model', () async {
      final notifier = WhisperModelNotifier();

      // Give time for _loadModel to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state, 'whisper-small');
    });

    test('loads saved model from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'whisper_model': 'whisper-large',
      });

      final notifier = WhisperModelNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state, 'whisper-large');
    });

    test('setModel updates state and persists to SharedPreferences', () async {
      final notifier = WhisperModelNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state, 'whisper-small');

      await notifier.setModel('whisper-medium');

      expect(notifier.state, 'whisper-medium');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('whisper_model'), 'whisper-medium');
    });

    test('availableModels contains 4 models', () {
      expect(WhisperModelNotifier.availableModels, hasLength(4));
      expect(WhisperModelNotifier.availableModels, contains('whisper-tiny'));
      expect(WhisperModelNotifier.availableModels, contains('whisper-small'));
      expect(WhisperModelNotifier.availableModels, contains('whisper-medium'));
      expect(WhisperModelNotifier.availableModels, contains('whisper-large'));
    });

    test('handles empty string as model name', () async {
      SharedPreferences.setMockInitialValues({'whisper_model': ''});

      final notifier = WhisperModelNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // Should use empty string as stored, not fall back to default
      expect(notifier.state, '');
    });

    test('loads default when no saved preference exists', () async {
      SharedPreferences.setMockInitialValues({});

      final notifier = WhisperModelNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state, 'whisper-small');
    });

    test('persisted model survives notifier recreation', () async {
      final notifier1 = WhisperModelNotifier();
      await Future.delayed(const Duration(milliseconds: 100));
      await notifier1.setModel('whisper-large');

      final notifier2 = WhisperModelNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier2.state, 'whisper-large');
    });

    test('setModel completes successfully', () async {
      final notifier = WhisperModelNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      await expectLater(notifier.setModel('whisper-tiny'), completes);
    });

    test('state updates immediately after setModel call', () async {
      final notifier = WhisperModelNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state, 'whisper-small');

      final future = notifier.setModel('whisper-large');

      expect(notifier.state, 'whisper-large');

      await future;
    });

    test('handles multiple model switches', () async {
      final notifier = WhisperModelNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      await notifier.setModel('whisper-tiny');
      expect(notifier.state, 'whisper-tiny');

      await notifier.setModel('whisper-medium');
      expect(notifier.state, 'whisper-medium');

      await notifier.setModel('whisper-large');
      expect(notifier.state, 'whisper-large');
    });
  });
}
