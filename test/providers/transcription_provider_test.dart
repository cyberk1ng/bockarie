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
}
