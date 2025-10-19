import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bockaire/database/database.dart';
import 'package:bockaire/logic/optimizer.dart';
import 'package:bockaire/services/shippo_service.dart';
import 'package:bockaire/services/quote_calculator_service.dart';
import 'package:bockaire/services/audio_recorder_service.dart';
import 'package:bockaire/services/whisper_transcription_service.dart';
import 'package:bockaire/services/carton_voice_parser_service.dart';

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  // Database
  getIt.registerSingleton<AppDatabase>(AppDatabase());

  // Services
  getIt.registerSingleton<PackOptimizer>(PackOptimizer());
  getIt.registerLazySingleton<ShippoService>(() => ShippoService());
  getIt.registerLazySingleton<QuoteCalculatorService>(
    () => QuoteCalculatorService(getIt<AppDatabase>(), getIt<ShippoService>()),
  );

  // Voice Input Services
  getIt.registerLazySingleton<AudioRecorderService>(() => AudioRecorderService());
  getIt.registerLazySingleton<WhisperTranscriptionService>(
    () => WhisperTranscriptionService(),
  );
  getIt.registerLazySingleton<CartonVoiceParserService>(
    () => CartonVoiceParserService(
      dotenv.env['GEMINI_API_KEY'] ?? '',
    ),
  );
}
