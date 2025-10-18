import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bockaire/get_it.dart';
import 'package:bockaire/utils/router.dart';
import 'package:bockaire/providers/theme_providers.dart';
import 'package:bockaire/database/seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  await setupGetIt();

  // Seed the database with initial data
  final seeder = DatabaseSeeder(getIt.get());
  await seeder.seedAll();

  runApp(const ProviderScope(child: BockaireApp()));
}

class BockaireApp extends ConsumerWidget {
  const BockaireApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lightTheme = ref.watch(lightThemeProvider);
    final darkTheme = ref.watch(darkThemeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Bockaire - Shipping Optimizer',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
