import 'package:bockaire/database/database.dart';
import 'package:bockaire/get_it.dart';
import 'package:bockaire/pages/settings_page.dart';
import 'package:bockaire/providers/theme_providers.dart';
import 'package:bockaire/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late MockAppDatabase mockDb;

  setUp(() {
    mockDb = MockAppDatabase();

    // Register mock in GetIt
    if (getIt.isRegistered<AppDatabase>()) {
      getIt.unregister<AppDatabase>();
    }
    getIt.registerSingleton<AppDatabase>(mockDb);

    // Default mocks
    when(() => mockDb.getSetting('theme_mode')).thenAnswer((_) async => null);
    when(() => mockDb.saveSetting(any(), any())).thenAnswer((_) async => {});
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildTestApp({required Widget child}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }

  group('Complete Theme Flow', () {
    testWidgets('app loads theme from database on startup', (tester) async {
      when(
        () => mockDb.getSetting('theme_mode'),
      ).thenAnswer((_) async => 'dark');

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: buildTestApp(child: const SettingsPage()),
        ),
      );

      // Give time for async initialization
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();

      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    testWidgets('user changes theme and it saves to database', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: buildTestApp(child: const SettingsPage()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Tap the dark mode icon
      await tester.tap(find.byIcon(Icons.nightlight_round));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Verify save was called
      await tester.pump(const Duration(milliseconds: 100));
      verify(
        () => mockDb.saveSetting('theme_mode', 'dark'),
      ).called(greaterThanOrEqualTo(1));
    });

    testWidgets('theme persists across navigation', (tester) async {
      await tester.pumpWidget(
        ProviderScope(child: buildTestApp(child: const SettingsPage())),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );

      // Change theme
      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Navigate away and back (simulated)
      await tester.pumpWidget(
        ProviderScope(
          child: buildTestApp(child: Scaffold(body: const Text('Other Page'))),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      await tester.pumpWidget(
        ProviderScope(child: buildTestApp(child: const SettingsPage())),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Theme should still be dark
      final newContainer = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );
      expect(newContainer.read(themeModeProvider), ThemeMode.dark);
    });

    testWidgets('full user journey: open settings → change theme → verify', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: buildTestApp(child: const SettingsPage()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Initial state should be system
      expect(container.read(themeModeProvider), ThemeMode.system);

      // User taps light mode icon
      await tester.tap(find.byIcon(Icons.wb_sunny));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Theme should be light
      expect(container.read(themeModeProvider), ThemeMode.light);

      // Verify it was saved
      await tester.pump(const Duration(milliseconds: 100));
      verify(
        () => mockDb.saveSetting('theme_mode', 'light'),
      ).called(greaterThanOrEqualTo(1));
    });

    testWidgets('theme changes apply to MaterialApp', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: Builder(
            builder: (context) {
              return Consumer(
                builder: (context, ref, _) {
                  final themeMode = ref.watch(themeModeProvider);
                  final lightTheme = ref.watch(lightThemeProvider);
                  final darkTheme = ref.watch(darkThemeProvider);

                  return MaterialApp(
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    theme: lightTheme,
                    darkTheme: darkTheme,
                    themeMode: themeMode,
                    home: const SettingsPage(),
                  );
                },
              );
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );

      // Change to dark mode
      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // MaterialApp should use dark theme
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.dark);
    });
  });

  group('Cross-Feature Integration', () {
    testWidgets('theme providers work across multiple pages', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: buildTestApp(child: const SettingsPage()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Change theme
      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Navigate to a different page
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: buildTestApp(
            child: Scaffold(body: const Text('Different Page')),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Theme should still be dark
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    testWidgets('multiple widgets can access same theme state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Column(
                children: [
                  Consumer(
                    builder: (context, ref, _) {
                      final mode = ref.watch(themeModeProvider);
                      return Text('Widget 1: ${mode.name}');
                    },
                  ),
                  Consumer(
                    builder: (context, ref, _) {
                      final mode = ref.watch(themeModeProvider);
                      return Text('Widget 2: ${mode.name}');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(find.text('Widget 1: system'), findsOneWidget);
      expect(find.text('Widget 2: system'), findsOneWidget);

      final container = ProviderScope.containerOf(
        tester.element(find.text('Widget 1: system')),
      );

      // Change theme
      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(find.text('Widget 1: light'), findsOneWidget);
      expect(find.text('Widget 2: light'), findsOneWidget);
    });

    testWidgets('theme changes propagate to all listeners', (tester) async {
      final states = <ThemeMode>[];

      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.listen(themeModeProvider, (previous, next) {
        states.add(next);
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: buildTestApp(child: const SettingsPage()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Change theme multiple times
      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
      await tester.pump();
      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
      await tester.pump();
      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(states, [ThemeMode.light, ThemeMode.dark, ThemeMode.system]);
    });
  });

  group('Database Persistence Integration', () {
    testWidgets('theme setting persists after app restart simulation', (
      tester,
    ) async {
      String? savedTheme;

      when(
        () => mockDb.getSetting('theme_mode'),
      ).thenAnswer((_) async => savedTheme);
      when(() => mockDb.saveSetting(any(), any())).thenAnswer((
        invocation,
      ) async {
        savedTheme = invocation.positionalArguments[1] as String;
      });

      // First app session
      final container1 = ProviderContainer();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container1,
          child: buildTestApp(child: const SettingsPage()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      container1.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
      await tester.pump(const Duration(milliseconds: 100));

      container1.dispose();

      // Second app session (restart)
      final container2 = ProviderContainer();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container2,
          child: buildTestApp(child: const SettingsPage()),
        ),
      );

      // Give time for async initialization
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();

      expect(container2.read(themeModeProvider), ThemeMode.dark);

      container2.dispose();
    });

    testWidgets('handles database errors during load gracefully', (
      tester,
    ) async {
      when(
        () => mockDb.getSetting('theme_mode'),
      ).thenThrow(Exception('DB Error'));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: buildTestApp(child: const SettingsPage()),
        ),
      );

      // Give time for async initialization
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();

      // Should default to system mode
      expect(container.read(themeModeProvider), ThemeMode.system);

      // UI should still be functional
      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('handles database errors during save gracefully', (
      tester,
    ) async {
      when(
        () => mockDb.saveSetting(any(), any()),
      ).thenThrow(Exception('Save failed'));

      await tester.pumpWidget(
        ProviderScope(child: buildTestApp(child: const SettingsPage())),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );

      // Should not crash
      expect(
        () => container
            .read(themeModeProvider.notifier)
            .setThemeMode(ThemeMode.dark),
        returnsNormally,
      );

      // State should still update locally
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });
  });

  group('Theme Data Integration', () {
    testWidgets('light theme provider returns valid theme', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final lightTheme = container.read(lightThemeProvider);

      expect(lightTheme, isA<ThemeData>());
      expect(lightTheme.brightness, Brightness.light);
      expect(lightTheme.useMaterial3, true);
      expect(lightTheme.colorScheme, isNotNull);
    });

    testWidgets('dark theme provider returns valid theme', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final darkTheme = container.read(darkThemeProvider);

      expect(darkTheme, isA<ThemeData>());
      expect(darkTheme.brightness, Brightness.dark);
      expect(darkTheme.useMaterial3, true);
      expect(darkTheme.colorScheme, isNotNull);
    });

    testWidgets('themes have different color schemes', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final lightTheme = container.read(lightThemeProvider);
      final darkTheme = container.read(darkThemeProvider);

      expect(
        lightTheme.colorScheme.primary,
        isNot(equals(darkTheme.colorScheme.primary)),
      );
      expect(
        lightTheme.scaffoldBackgroundColor,
        isNot(equals(darkTheme.scaffoldBackgroundColor)),
      );
    });
  });

  group('Real-World Scenarios', () {
    testWidgets('user switches theme multiple times in quick succession', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(child: buildTestApp(child: const SettingsPage())),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );

      // Rapid theme changes
      for (var i = 0; i < 5; i++) {
        container
            .read(themeModeProvider.notifier)
            .setThemeMode(ThemeMode.light);
        await tester.pump();
        container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
        await tester.pump();
      }

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Should end up in a valid state
      expect(
        container.read(themeModeProvider),
        isIn([ThemeMode.light, ThemeMode.dark]),
      );
    });

    testWidgets('theme works correctly with system theme changes', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(child: buildTestApp(child: const SettingsPage())),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );

      // Set to system mode
      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(container.read(themeModeProvider), ThemeMode.system);

      // In system mode, the app should adapt to platform brightness
      // This is handled by MaterialApp's themeMode property
    });

    testWidgets('app handles theme change while other operations are ongoing', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(child: buildTestApp(child: const SettingsPage())),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );

      // Change theme
      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Theme should change immediately
      expect(container.read(themeModeProvider), ThemeMode.dark);

      // Change again to verify it works during multiple operations
      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(container.read(themeModeProvider), ThemeMode.light);
    });
  });
}
