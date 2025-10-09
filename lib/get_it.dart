import 'package:get_it/get_it.dart';
import 'package:bockaire/database/database.dart';
import 'package:bockaire/logic/optimizer.dart';

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  // Database
  getIt.registerSingleton<AppDatabase>(AppDatabase());

  // Services
  getIt.registerSingleton<PackOptimizer>(PackOptimizer());
}
