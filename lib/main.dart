import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bockaire/l10n/app_localizations.dart';
import 'package:bockaire/get_it.dart';
import 'package:bockaire/utils/router.dart';
import 'package:bockaire/utils/app_lifecycle_observer.dart';
import 'package:bockaire/providers/theme_providers.dart';
import 'package:bockaire/providers/locale_provider.dart';
import 'package:bockaire/providers/currency_provider.dart';
import 'package:bockaire/repositories/currency_repository.dart';
import 'package:bockaire/database/seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  await setupGetIt();

  // Seed the database with initial data
  final seeder = DatabaseSeeder(getIt.get());
  await seeder.seedAll();

  // Initialize SharedPreferences for currency repository
  final prefs = await SharedPreferences.getInstance();

  // Register lifecycle observer for server cleanup
  final observer = AppLifecycleObserver();
  WidgetsBinding.instance.addObserver(observer);

  runApp(
    ProviderScope(
      overrides: [
        currencyRepositoryProvider.overrideWithValue(CurrencyRepository(prefs)),
      ],
      child: const BockaireApp(),
    ),
  );
}

class BockaireApp extends ConsumerWidget {
  const BockaireApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lightTheme = ref.watch(lightThemeProvider);
    final darkTheme = ref.watch(darkThemeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeNotifierProvider);

    return MaterialApp.router(
      title: 'Bockaire - Shipping Optimizer',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
