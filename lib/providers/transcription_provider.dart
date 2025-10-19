import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TranscriptionProviderType { gemini, whisper }

class TranscriptionProviderNotifier
    extends StateNotifier<TranscriptionProviderType> {
  TranscriptionProviderNotifier() : super(TranscriptionProviderType.gemini) {
    _loadProvider();
  }

  static const _key = 'transcription_provider';

  Future<void> _loadProvider() async {
    final prefs = await SharedPreferences.getInstance();
    final providerName = prefs.getString(_key);
    if (providerName != null) {
      state = TranscriptionProviderType.values.firstWhere(
        (e) => e.name == providerName,
        orElse: () => TranscriptionProviderType.gemini,
      );
    }
  }

  Future<void> setProvider(TranscriptionProviderType provider) async {
    state = provider;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, provider.name);
  }
}

final transcriptionProviderProvider =
    StateNotifierProvider<
      TranscriptionProviderNotifier,
      TranscriptionProviderType
    >((ref) => TranscriptionProviderNotifier());

// Gemini audio model selection
class GeminiAudioModelNotifier extends StateNotifier<String> {
  GeminiAudioModelNotifier() : super('gemini-2.0-flash-exp') {
    _loadModel();
  }

  static const _key = 'gemini_audio_model';

  // Available Gemini models with audio support
  static const List<String> availableModels = [
    'gemini-2.0-flash-exp',
    'gemini-1.5-flash',
    'gemini-1.5-flash-8b',
    'gemini-1.5-pro',
    'gemini-1.5-pro-latest',
  ];

  Future<void> _loadModel() async {
    final prefs = await SharedPreferences.getInstance();
    final model = prefs.getString(_key);
    if (model != null) {
      state = model;
    }
  }

  Future<void> setModel(String model) async {
    state = model;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, model);
  }
}

final geminiAudioModelProvider =
    StateNotifierProvider<GeminiAudioModelNotifier, String>(
      (ref) => GeminiAudioModelNotifier(),
    );

// Whisper model selection
class WhisperModelNotifier extends StateNotifier<String> {
  WhisperModelNotifier() : super('whisper-large-v3') {
    _loadModel();
  }

  static const _key = 'whisper_model';

  // Available Whisper models for local transcription
  static const List<String> availableModels = [
    'whisper-large-v3',
    'whisper-medium',
    'whisper-small',
    'whisper-base',
    'whisper-tiny',
  ];

  Future<void> _loadModel() async {
    final prefs = await SharedPreferences.getInstance();
    final model = prefs.getString(_key);
    if (model != null) {
      state = model;
    }
  }

  Future<void> setModel(String model) async {
    state = model;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, model);
  }
}

final whisperModelProvider =
    StateNotifierProvider<WhisperModelNotifier, String>(
      (ref) => WhisperModelNotifier(),
    );
