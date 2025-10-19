import 'package:bockaire/providers/image_analysis_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ImageAnalysisProviderNotifier', () {
    test('initial state is ImageAnalysisProviderType.gemini', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(imageAnalysisProviderProvider);

      expect(state, ImageAnalysisProviderType.gemini);
    });

    test('loads saved provider from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'image_analysis_provider': 'ollama',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Trigger the read to mount the provider
      container.read(imageAnalysisProviderProvider);

      // Wait for async initialization with longer delay
      await Future.delayed(const Duration(milliseconds: 500));

      final state = container.read(imageAnalysisProviderProvider);

      expect(state, ImageAnalysisProviderType.ollama);
    });

    test('handles invalid provider name with fallback to gemini', () async {
      SharedPreferences.setMockInitialValues({
        'image_analysis_provider': 'invalid_provider',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Trigger the read to mount the provider
      container.read(imageAnalysisProviderProvider);

      // Wait for async initialization
      await Future.delayed(const Duration(milliseconds: 500));

      final state = container.read(imageAnalysisProviderProvider);

      expect(state, ImageAnalysisProviderType.gemini);
    });

    test(
      'setProvider updates state and persists to SharedPreferences',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(imageAnalysisProviderProvider.notifier);

        await notifier.setProvider(ImageAnalysisProviderType.ollama);

        final state = container.read(imageAnalysisProviderProvider);
        expect(state, ImageAnalysisProviderType.ollama);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('image_analysis_provider'), 'ollama');
      },
    );

    test('setProvider persists gemini selection', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(imageAnalysisProviderProvider.notifier);

      await notifier.setProvider(ImageAnalysisProviderType.gemini);

      final state = container.read(imageAnalysisProviderProvider);
      expect(state, ImageAnalysisProviderType.gemini);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('image_analysis_provider'), 'gemini');
    });

    test('handles missing SharedPreferences value', () async {
      // No initial values set
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Trigger the read to mount the provider
      container.read(imageAnalysisProviderProvider);

      // Wait for async initialization
      await Future.delayed(const Duration(milliseconds: 500));

      final state = container.read(imageAnalysisProviderProvider);

      expect(state, ImageAnalysisProviderType.gemini);
    });
  });

  group('OllamaBaseUrlNotifier', () {
    test('initial state is http://localhost:11434', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(ollamaBaseUrlProvider);

      expect(state, 'http://localhost:11434');
    });

    test('loads saved URL from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'ollama_base_url': 'http://192.168.1.100:11434',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Trigger the read to mount the provider
      container.read(ollamaBaseUrlProvider);

      // Wait for async initialization
      await Future.delayed(const Duration(milliseconds: 500));

      final state = container.read(ollamaBaseUrlProvider);

      expect(state, 'http://192.168.1.100:11434');
    });

    test(
      'setBaseUrl updates state and persists to SharedPreferences',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(ollamaBaseUrlProvider.notifier);

        await notifier.setBaseUrl('http://custom-server:11434');

        final state = container.read(ollamaBaseUrlProvider);
        expect(state, 'http://custom-server:11434');

        final prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getString('ollama_base_url'),
          'http://custom-server:11434',
        );
      },
    );

    test('handles empty URL', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(ollamaBaseUrlProvider.notifier);

      await notifier.setBaseUrl('');

      final state = container.read(ollamaBaseUrlProvider);
      expect(state, '');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('ollama_base_url'), '');
    });

    test('handles missing SharedPreferences value', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Trigger the read to mount the provider
      container.read(ollamaBaseUrlProvider);

      // Wait for async initialization
      await Future.delayed(const Duration(milliseconds: 500));

      final state = container.read(ollamaBaseUrlProvider);

      expect(state, 'http://localhost:11434');
    });
  });

  group('OllamaVisionModelNotifier', () {
    test('initial state is llava:13b', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(ollamaVisionModelProvider);

      expect(state, 'llava:13b');
    });

    test('loads saved model from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'ollama_vision_model': 'minicpm-v:8b',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Trigger the read to mount the provider
      container.read(ollamaVisionModelProvider);

      // Wait for async initialization
      await Future.delayed(const Duration(milliseconds: 500));

      final state = container.read(ollamaVisionModelProvider);

      expect(state, 'minicpm-v:8b');
    });

    test('setModel updates state and persists to SharedPreferences', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(ollamaVisionModelProvider.notifier);

      await notifier.setModel('bakllava:7b');

      final state = container.read(ollamaVisionModelProvider);
      expect(state, 'bakllava:7b');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('ollama_vision_model'), 'bakllava:7b');
    });

    test('availableModels contains expected models', () {
      expect(OllamaVisionModelNotifier.availableModels, hasLength(6));
      expect(OllamaVisionModelNotifier.availableModels, contains('llava:13b'));
      expect(
        OllamaVisionModelNotifier.availableModels,
        contains('minicpm-v:8b'),
      );
      expect(
        OllamaVisionModelNotifier.availableModels,
        contains('bakllava:7b'),
      );
    });

    test('handles custom model name', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(ollamaVisionModelProvider.notifier);

      await notifier.setModel('custom-model:latest');

      final state = container.read(ollamaVisionModelProvider);
      expect(state, 'custom-model:latest');
    });

    test('handles missing SharedPreferences value', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Trigger the read to mount the provider
      container.read(ollamaVisionModelProvider);

      // Wait for async initialization
      await Future.delayed(const Duration(milliseconds: 500));

      final state = container.read(ollamaVisionModelProvider);

      expect(state, 'llava:13b');
    });
  });

  group('GeminiVisionModelNotifier', () {
    test('initial state is gemini-2.0-flash-exp', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(geminiVisionModelProvider);

      expect(state, 'gemini-2.0-flash-exp');
    });

    test('loads saved model from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'gemini_vision_model': 'gemini-1.5-pro',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Trigger the read to mount the provider
      container.read(geminiVisionModelProvider);

      // Wait for async initialization
      await Future.delayed(const Duration(milliseconds: 500));

      final state = container.read(geminiVisionModelProvider);

      expect(state, 'gemini-1.5-pro');
    });

    test('setModel updates state and persists to SharedPreferences', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(geminiVisionModelProvider.notifier);

      await notifier.setModel('gemini-1.5-flash');

      final state = container.read(geminiVisionModelProvider);
      expect(state, 'gemini-1.5-flash');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('gemini_vision_model'), 'gemini-1.5-flash');
    });

    test('availableModels contains expected models', () {
      expect(GeminiVisionModelNotifier.availableModels, hasLength(6));
      expect(
        GeminiVisionModelNotifier.availableModels,
        contains('gemini-2.0-flash-exp'),
      );
      expect(
        GeminiVisionModelNotifier.availableModels,
        contains('gemini-1.5-pro'),
      );
      expect(
        GeminiVisionModelNotifier.availableModels,
        contains('gemini-pro-vision'),
      );
    });

    test('handles missing SharedPreferences value', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Trigger the read to mount the provider
      container.read(geminiVisionModelProvider);

      // Wait for async initialization
      await Future.delayed(const Duration(milliseconds: 500));

      final state = container.read(geminiVisionModelProvider);

      expect(state, 'gemini-2.0-flash-exp');
    });

    test('can switch between different models', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(geminiVisionModelProvider.notifier);

      await notifier.setModel('gemini-1.5-flash-8b');
      expect(container.read(geminiVisionModelProvider), 'gemini-1.5-flash-8b');

      await notifier.setModel('gemini-1.5-pro-latest');
      expect(
        container.read(geminiVisionModelProvider),
        'gemini-1.5-pro-latest',
      );
    });
  });

  group('Integration - Provider Interactions', () {
    test(
      'multiple providers can coexist and maintain independent state',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final imageAnalysisNotifier = container.read(
          imageAnalysisProviderProvider.notifier,
        );
        final ollamaUrlNotifier = container.read(
          ollamaBaseUrlProvider.notifier,
        );
        final ollamaModelNotifier = container.read(
          ollamaVisionModelProvider.notifier,
        );
        final geminiModelNotifier = container.read(
          geminiVisionModelProvider.notifier,
        );

        await imageAnalysisNotifier.setProvider(
          ImageAnalysisProviderType.ollama,
        );
        await ollamaUrlNotifier.setBaseUrl('http://custom:11434');
        await ollamaModelNotifier.setModel('llava:7b');
        await geminiModelNotifier.setModel('gemini-1.5-pro');

        expect(
          container.read(imageAnalysisProviderProvider),
          ImageAnalysisProviderType.ollama,
        );
        expect(container.read(ollamaBaseUrlProvider), 'http://custom:11434');
        expect(container.read(ollamaVisionModelProvider), 'llava:7b');
        expect(container.read(geminiVisionModelProvider), 'gemini-1.5-pro');
      },
    );

    test('persisted values survive provider recreation', () async {
      SharedPreferences.setMockInitialValues({
        'image_analysis_provider': 'ollama',
        'ollama_base_url': 'http://saved:11434',
        'ollama_vision_model': 'minicpm-v:8b',
        'gemini_vision_model': 'gemini-1.5-flash',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Trigger reads to mount all providers
      container.read(imageAnalysisProviderProvider);
      container.read(ollamaBaseUrlProvider);
      container.read(ollamaVisionModelProvider);
      container.read(geminiVisionModelProvider);

      // Wait for async initialization
      await Future.delayed(const Duration(milliseconds: 500));

      expect(
        container.read(imageAnalysisProviderProvider),
        ImageAnalysisProviderType.ollama,
      );
      expect(container.read(ollamaBaseUrlProvider), 'http://saved:11434');
      expect(container.read(ollamaVisionModelProvider), 'minicpm-v:8b');
      expect(container.read(geminiVisionModelProvider), 'gemini-1.5-flash');
    });
  });
}
