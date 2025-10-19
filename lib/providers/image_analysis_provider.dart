import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ImageAnalysisProviderType { gemini, ollama }

class ImageAnalysisProviderNotifier
    extends StateNotifier<ImageAnalysisProviderType> {
  ImageAnalysisProviderNotifier() : super(ImageAnalysisProviderType.gemini) {
    _loadProvider();
  }

  static const _key = 'image_analysis_provider';

  Future<void> _loadProvider() async {
    final prefs = await SharedPreferences.getInstance();
    final providerName = prefs.getString(_key);
    if (providerName != null && mounted) {
      state = ImageAnalysisProviderType.values.firstWhere(
        (e) => e.name == providerName,
        orElse: () => ImageAnalysisProviderType.gemini,
      );
    }
  }

  Future<void> setProvider(ImageAnalysisProviderType provider) async {
    state = provider;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, provider.name);
  }
}

final imageAnalysisProviderProvider =
    StateNotifierProvider<
      ImageAnalysisProviderNotifier,
      ImageAnalysisProviderType
    >((ref) => ImageAnalysisProviderNotifier());

// Ollama settings providers
class OllamaBaseUrlNotifier extends StateNotifier<String> {
  OllamaBaseUrlNotifier() : super('http://localhost:11434') {
    _loadBaseUrl();
  }

  static const _key = 'ollama_base_url';

  Future<void> _loadBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(_key);
    if (url != null && mounted) {
      state = url;
    }
  }

  Future<void> setBaseUrl(String url) async {
    state = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, url);
  }
}

final ollamaBaseUrlProvider =
    StateNotifierProvider<OllamaBaseUrlNotifier, String>(
      (ref) => OllamaBaseUrlNotifier(),
    );

class OllamaVisionModelNotifier extends StateNotifier<String> {
  OllamaVisionModelNotifier() : super('llava:13b') {
    _loadModel();
  }

  static const _key = 'ollama_vision_model';

  // Recommended vision models for Ollama
  static const List<String> availableModels = [
    'llava:7b',
    'llava:13b',
    'llava:34b',
    'llava-llama3:8b',
    'minicpm-v:8b',
    'bakllava:7b',
  ];

  Future<void> _loadModel() async {
    final prefs = await SharedPreferences.getInstance();
    final model = prefs.getString(_key);
    if (model != null && mounted) {
      state = model;
    }
  }

  Future<void> setModel(String model) async {
    state = model;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, model);
  }
}

final ollamaVisionModelProvider =
    StateNotifierProvider<OllamaVisionModelNotifier, String>(
      (ref) => OllamaVisionModelNotifier(),
    );

// Gemini model selection
class GeminiVisionModelNotifier extends StateNotifier<String> {
  GeminiVisionModelNotifier() : super('gemini-2.0-flash-exp') {
    _loadModel();
  }

  static const _key = 'gemini_vision_model';

  // Available Gemini vision models
  static const List<String> availableModels = [
    'gemini-2.0-flash-exp',
    'gemini-1.5-flash',
    'gemini-1.5-flash-8b',
    'gemini-1.5-pro',
    'gemini-1.5-pro-latest',
    'gemini-pro-vision',
  ];

  Future<void> _loadModel() async {
    final prefs = await SharedPreferences.getInstance();
    final model = prefs.getString(_key);
    if (model != null && mounted) {
      state = model;
    }
  }

  Future<void> setModel(String model) async {
    state = model;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, model);
  }
}

final geminiVisionModelProvider =
    StateNotifierProvider<GeminiVisionModelNotifier, String>(
      (ref) => GeminiVisionModelNotifier(),
    );
