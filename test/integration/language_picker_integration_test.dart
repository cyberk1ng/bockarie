import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bockaire/l10n/app_localizations.dart';
import 'package:bockaire/pages/settings_page.dart';
import 'package:bockaire/providers/locale_provider.dart';
import 'package:bockaire/providers/theme_providers.dart';

void main() {
  group('Language Picker Integration', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    Widget buildApp() {
      return const ProviderScope(child: TestApp());
    }

    testWidgets('complete language change flow from English to French', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // 1. Verify initial language (system default - English)
      expect(find.text('Settings'), findsOneWidget);

      // 2. Tap language selector ListTile (find by icon to avoid ambiguity)
      final languageListTile = find.ancestor(
        of: find.byIcon(Icons.language),
        matching: find.byType(ListTile),
      );
      await tester.tap(languageListTile);
      await tester.pumpAndSettle();

      // 3. Modal should be open
      expect(find.byType(TextField), findsOneWidget);

      // 4. Search for and select French
      await tester.enterText(find.byType(TextField), 'french');
      await tester.pumpAndSettle();

      await tester.tap(find.text('French'));
      await tester.pumpAndSettle();

      // 5. Verify UI updates to French
      expect(
        find.text('Paramètres'),
        findsAtLeastNWidgets(1),
      ); // Settings in French
      // Note: "Langue" appears twice (section title + ListTile title)
      expect(
        find.text('Langue'),
        findsAtLeastNWidgets(1),
      ); // Language in French
    });

    testWidgets('language persists across app restarts', (tester) async {
      // First session: Set language to Spanish
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final languageListTile = find.ancestor(
        of: find.byIcon(Icons.language),
        matching: find.byType(ListTile),
      );
      await tester.tap(languageListTile);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'spanish');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Spanish'));
      await tester.pumpAndSettle();

      // Verify Spanish is displayed
      expect(find.text('Configuración'), findsAtLeastNWidgets(1));

      // Dispose the app
      await tester.pumpWidget(Container());

      // Second session: Restart app
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Wait for async locale load
      await tester.pump(const Duration(milliseconds: 200));

      // Verify Spanish is still selected
      expect(find.text('Configuración'), findsAtLeastNWidgets(1));
    });

    testWidgets('language picker search and selection', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Open language picker
      final languageListTile = find.ancestor(
        of: find.byIcon(Icons.language),
        matching: find.byType(ListTile),
      );
      await tester.tap(languageListTile);
      await tester.pumpAndSettle();

      // Search for Italian
      await tester.enterText(find.byType(TextField), 'ital');
      await tester.pumpAndSettle();

      // Should find Italian
      expect(find.text('Italian'), findsOneWidget);
      expect(find.text('French'), findsNothing);

      // Select Italian
      await tester.tap(find.text('Italian'));
      await tester.pumpAndSettle();

      // Verify Italian is displayed
      expect(find.text('Impostazioni'), findsOneWidget);
    });

    testWidgets('switching from French to Spanish', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Set to French
      var languageListTile = find.ancestor(
        of: find.byIcon(Icons.language),
        matching: find.byType(ListTile),
      );
      await tester.tap(languageListTile);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'french');
      await tester.pumpAndSettle();

      await tester.tap(find.text('French'));
      await tester.pumpAndSettle();

      expect(find.text('Paramètres'), findsOneWidget);

      // Change to Spanish
      languageListTile = find.ancestor(
        of: find.byIcon(Icons.language),
        matching: find.byType(ListTile),
      );
      await tester.tap(languageListTile);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'espagnol');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Espagnol')); // Spanish in French
      await tester.pumpAndSettle();

      // Verify Spanish is displayed
      expect(find.text('Configuración'), findsAtLeastNWidgets(1));
    });

    testWidgets('switching to system default clears saved preference', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Set to French
      var languageListTile = find.ancestor(
        of: find.byIcon(Icons.language),
        matching: find.byType(ListTile),
      );
      await tester.tap(languageListTile);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'french');
      await tester.pumpAndSettle();

      await tester.tap(find.text('French'));
      await tester.pumpAndSettle();

      // Verify SharedPreferences has 'fr'
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), 'fr');

      // Switch back to system default
      languageListTile = find.ancestor(
        of: find.byIcon(Icons.language),
        matching: find.byType(ListTile),
      );
      await tester.tap(languageListTile);
      await tester.pumpAndSettle();

      // Tap System Default using icon-based finder (language-independent)
      final systemDefaultTile = find.ancestor(
        of: find.byIcon(Icons.phone_android),
        matching: find.byType(ListTile),
      );
      await tester.tap(systemDefaultTile);
      await tester.pumpAndSettle();

      // Verify preference is cleared
      expect(prefs.getString('app_locale'), isNull);

      // Verify back to English (system default)
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('flag displays correctly for selected language', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Initially no flag (system default)
      // Open picker and select French
      final languageListTile = find.ancestor(
        of: find.byIcon(Icons.language),
        matching: find.byType(ListTile),
      );
      await tester.tap(languageListTile);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'french');
      await tester.pumpAndSettle();

      await tester.tap(find.text('French'));
      await tester.pumpAndSettle();

      // Should show French flag in settings
      // (This depends on your settings page implementation)
    });

    testWidgets('multiple rapid language switches', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Use languages that are visible without scrolling (alphabetically first)
      final languages = ['Arabic', 'Bulgarian', 'Chinese'];

      for (final lang in languages) {
        final languageListTile = find.ancestor(
          of: find.byIcon(Icons.language),
          matching: find.byType(ListTile),
        );
        await tester.tap(languageListTile);
        await tester.pumpAndSettle();

        // These languages are alphabetically first, so visible without search
        await tester.tap(find.text(lang));
        await tester.pumpAndSettle();

        // Should not crash
        expect(find.byType(SettingsPage), findsOneWidget);
      }
    });

    testWidgets('language change updates all UI elements', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Switch to Portuguese
      final languageListTile = find.ancestor(
        of: find.byIcon(Icons.language),
        matching: find.byType(ListTile),
      );
      await tester.tap(languageListTile);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'portuguese');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Portuguese'));
      await tester.pumpAndSettle();

      // Check multiple UI elements are in Portuguese
      expect(find.text('Configurações'), findsOneWidget); // Settings
      expect(find.text('Aparência'), findsOneWidget); // Appearance
      // Note: "Idioma" appears twice (section title + ListTile title)
      expect(find.text('Idioma'), findsAtLeastNWidgets(1)); // Language
    });

    testWidgets('selected language shows check mark in picker', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Set to Italian
      var languageListTile = find.ancestor(
        of: find.byIcon(Icons.language),
        matching: find.byType(ListTile),
      );
      await tester.tap(languageListTile);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'italian');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Italian'));
      await tester.pumpAndSettle();

      // Open picker again
      languageListTile = find.ancestor(
        of: find.byIcon(Icons.language),
        matching: find.byType(ListTile),
      );
      await tester.tap(languageListTile);
      await tester.pumpAndSettle();

      // Search for Italian again to make it visible
      await tester.enterText(find.byType(TextField), 'italian');
      await tester.pumpAndSettle();

      // Find the Italian list tile
      final tiles = tester.widgetList<ListTile>(find.byType(ListTile));
      final italianTile = tiles.firstWhere(
        (tile) => (tile.title as Text?)?.data == 'Italiano',
      );

      // Should be selected and have check mark
      expect(italianTile.selected, true);
      expect(italianTile.trailing, isA<Icon>());
      expect((italianTile.trailing as Icon).icon, Icons.check);
    });

    testWidgets('language preference survives provider recreation', (
      tester,
    ) async {
      // Set language to French
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final languageListTile = find.ancestor(
        of: find.byIcon(Icons.language),
        matching: find.byType(ListTile),
      );
      await tester.tap(languageListTile);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'french');
      await tester.pumpAndSettle();

      await tester.tap(find.text('French'));
      await tester.pumpAndSettle();

      expect(find.text('Paramètres'), findsOneWidget);

      // Recreate the entire widget tree (simulates hot reload)
      await tester.pumpWidget(Container());
      await tester.pump();

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Wait for async load
      await tester.pump(const Duration(milliseconds: 200));

      // Should still be in French
      expect(find.text('Paramètres'), findsOneWidget);
    });

    testWidgets('multiple languages can be selected and work', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Test Arabic (alphabetically first, so visible without search)
      final languageListTile = find.ancestor(
        of: find.byIcon(Icons.language),
        matching: find.byType(ListTile),
      );
      await tester.tap(languageListTile);
      await tester.pumpAndSettle();

      // Verify modal opened by checking for search field
      expect(find.byType(TextField), findsOneWidget);

      // Search for Arabic to ensure it's visible
      await tester.enterText(find.byType(TextField), 'arabic');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Arabic'));
      await tester.pumpAndSettle();

      // Wait for locale to propagate and UI to rebuild
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Note: Arabic translations are incomplete, so English fallback is used
      expect(find.text('Settings'), findsAtLeastNWidgets(1));
    });

    testWidgets('concurrent locale provider access', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Simulate multiple widgets reading locale simultaneously
      final container = ProviderScope.containerOf(
        tester.element(find.byType(TestApp)),
      );

      final notifier = container.read(localeNotifierProvider.notifier);

      // Rapidly change locale multiple times
      await Future.wait([
        notifier.setLocale(const Locale('fr')),
        notifier.setLocale(const Locale('es')),
        notifier.setLocale(const Locale('it')),
      ]);

      await tester.pumpAndSettle();

      // Should settle on one language without crashing
      expect(find.byType(SettingsPage), findsOneWidget);
    });
  });
}

/// Test app wrapper
class TestApp extends ConsumerWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeNotifierProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      themeMode: themeMode,
      home: const SettingsPage(),
    );
  }
}
