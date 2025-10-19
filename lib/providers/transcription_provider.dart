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
