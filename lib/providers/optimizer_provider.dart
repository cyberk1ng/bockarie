import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'optimizer_provider.g.dart';

enum OptimizerProviderType { gemini, ollama }

@riverpod
class OptimizerProviderNotifier extends _$OptimizerProviderNotifier {
  static const _key = 'optimizer_provider';

  @override
  OptimizerProviderType build() {
    _loadFromPrefs();
    return OptimizerProviderType.gemini;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value != null) {
      state = OptimizerProviderType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => OptimizerProviderType.gemini,
      );
    }
  }

  Future<void> setProvider(OptimizerProviderType provider) async {
    state = provider;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, provider.name);
  }
}

@riverpod
class OllamaOptimizerBaseUrl extends _$OllamaOptimizerBaseUrl {
  static const _key = 'ollama_optimizer_base_url';

  @override
  String build() {
    _loadFromPrefs();
    return 'http://localhost:11434';
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key) ?? 'http://localhost:11434';
  }

  Future<void> setUrl(String url) async {
    state = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, url);
  }
}

@riverpod
class OllamaOptimizerModel extends _$OllamaOptimizerModel {
  static const _key = 'ollama_optimizer_model';

  @override
  String build() {
    _loadFromPrefs();
    return 'llama3.1:8b';
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key) ?? 'llama3.1:8b';
  }

  Future<void> setModel(String model) async {
    state = model;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, model);
  }
}
