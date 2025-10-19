import 'package:bockaire/database/database.dart';
import 'package:bockaire/get_it.dart';
import 'package:bockaire/providers/theme_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAppDatabase mockDb;

  setUp(() {
    mockDb = MockAppDatabase();

    // Register mock in GetIt
    if (getIt.isRegistered<AppDatabase>()) {
      getIt.unregister<AppDatabase>();
    }
    getIt.registerSingleton<AppDatabase>(mockDb);
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('ThemeModeNotifier', () {
    group('Initialization', () {
      test('initial state is ThemeMode.system', () {
        when(
          () => mockDb.getSetting('theme_mode'),
        ).thenAnswer((_) async => null);

        final notifier = ThemeModeNotifier();

        expect(notifier.state, ThemeMode.system);
      });

      test('loads saved light theme from database on init', () async {
        when(
          () => mockDb.getSetting('theme_mode'),
        ).thenAnswer((_) async => 'light');

        final notifier = ThemeModeNotifier();

        // Wait for async initialization
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state, ThemeMode.light);
        verify(() => mockDb.getSetting('theme_mode')).called(1);
      });

      test('loads saved dark theme from database on init', () async {
        when(
          () => mockDb.getSetting('theme_mode'),
        ).thenAnswer((_) async => 'dark');

        final notifier = ThemeModeNotifier();

        // Wait for async initialization
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state, ThemeMode.dark);
        verify(() => mockDb.getSetting('theme_mode')).called(1);
      });

      test('loads saved system theme from database on init', () async {
        when(
          () => mockDb.getSetting('theme_mode'),
        ).thenAnswer((_) async => 'system');

        final notifier = ThemeModeNotifier();

        // Wait for async initialization
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state, ThemeMode.system);
        verify(() => mockDb.getSetting('theme_mode')).called(1);
      });

      test('defaults to system when no saved preference', () async {
        when(
          () => mockDb.getSetting('theme_mode'),
        ).thenAnswer((_) async => null);

        final notifier = ThemeModeNotifier();

        // Wait for async initialization
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state, ThemeMode.system);
      });

      test(
        'handles invalid theme mode string by defaulting to system',
        () async {
          when(
            () => mockDb.getSetting('theme_mode'),
          ).thenAnswer((_) async => 'invalid_mode');

          final notifier = ThemeModeNotifier();

          // Wait for async initialization
          await Future.delayed(const Duration(milliseconds: 100));

          expect(notifier.state, ThemeMode.system);
        },
      );

      test('handles database errors gracefully during load', () async {
        when(
          () => mockDb.getSetting('theme_mode'),
        ).thenThrow(Exception('Database error'));

        final notifier = ThemeModeNotifier();

        // Wait for async initialization
        await Future.delayed(const Duration(milliseconds: 100));

        // Should keep default value
        expect(notifier.state, ThemeMode.system);
      });
    });

    group('Theme Mode Setting', () {
      test('setThemeMode() updates state to light', () async {
        when(
          () => mockDb.getSetting('theme_mode'),
        ).thenAnswer((_) async => null);
        when(
          () => mockDb.saveSetting(any(), any()),
        ).thenAnswer((_) async => {});

        final notifier = ThemeModeNotifier();

        notifier.setThemeMode(ThemeMode.light);

        expect(notifier.state, ThemeMode.light);
      });

      test('setThemeMode() updates state to dark', () async {
        when(
          () => mockDb.getSetting('theme_mode'),
        ).thenAnswer((_) async => null);
        when(
          () => mockDb.saveSetting(any(), any()),
        ).thenAnswer((_) async => {});

        final notifier = ThemeModeNotifier();

        notifier.setThemeMode(ThemeMode.dark);

        expect(notifier.state, ThemeMode.dark);
      });

      test('setThemeMode() updates state to system', () async {
        when(
          () => mockDb.getSetting('theme_mode'),
        ).thenAnswer((_) async => null);
        when(
          () => mockDb.saveSetting(any(), any()),
        ).thenAnswer((_) async => {});

        final notifier = ThemeModeNotifier();

        notifier.setThemeMode(ThemeMode.system);

        expect(notifier.state, ThemeMode.system);
      });

      test(
        'setThemeMode() persists to database with correct key and value',
        () async {
          when(
            () => mockDb.getSetting('theme_mode'),
          ).thenAnswer((_) async => null);
          when(
            () => mockDb.saveSetting(any(), any()),
          ).thenAnswer((_) async => {});

          final notifier = ThemeModeNotifier();

          notifier.setThemeMode(ThemeMode.dark);

          // Wait for async save
          await Future.delayed(const Duration(milliseconds: 50));

          verify(() => mockDb.saveSetting('theme_mode', 'dark')).called(1);
        },
      );

      test('setThemeMode() handles multiple rapid changes correctly', () async {
        when(
          () => mockDb.getSetting('theme_mode'),
        ).thenAnswer((_) async => null);
        when(
          () => mockDb.saveSetting(any(), any()),
        ).thenAnswer((_) async => {});

        final notifier = ThemeModeNotifier();

        notifier.setThemeMode(ThemeMode.light);
        notifier.setThemeMode(ThemeMode.dark);
        notifier.setThemeMode(ThemeMode.system);

        expect(notifier.state, ThemeMode.system);

        // Wait for async saves
        await Future.delayed(const Duration(milliseconds: 100));

        // Should have called save 3 times
        verify(() => mockDb.saveSetting('theme_mode', any())).called(3);
      });
    });

    group('Database Persistence', () {
      test('saves theme mode as string correctly', () async {
        when(
          () => mockDb.getSetting('theme_mode'),
        ).thenAnswer((_) async => null);
        when(
          () => mockDb.saveSetting(any(), any()),
        ).thenAnswer((_) async => {});

        final notifier = ThemeModeNotifier();

        notifier.setThemeMode(ThemeMode.light);
        await Future.delayed(const Duration(milliseconds: 50));

        verify(() => mockDb.saveSetting('theme_mode', 'light')).called(1);
      });

      test('handles save failures without crashing', () async {
        when(
          () => mockDb.getSetting('theme_mode'),
        ).thenAnswer((_) async => null);
        when(
          () => mockDb.saveSetting(any(), any()),
        ).thenThrow(Exception('Save failed'));

        final notifier = ThemeModeNotifier();

        // Should not throw
        expect(() => notifier.setThemeMode(ThemeMode.dark), returnsNormally);

        // State should still be updated
        expect(notifier.state, ThemeMode.dark);
      });

      test('round-trip: save → load → verify', () async {
        String? savedValue;

        when(
          () => mockDb.getSetting('theme_mode'),
        ).thenAnswer((_) async => savedValue);
        when(() => mockDb.saveSetting(any(), any())).thenAnswer((
          invocation,
        ) async {
          savedValue = invocation.positionalArguments[1] as String;
        });

        // First notifier: save dark mode
        final notifier1 = ThemeModeNotifier();
        notifier1.setThemeMode(ThemeMode.dark);
        await Future.delayed(const Duration(milliseconds: 100));

        // Second notifier: should load dark mode
        final notifier2 = ThemeModeNotifier();
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier2.state, ThemeMode.dark);
      });
    });

    group('Edge Cases', () {
      test('empty string theme mode returns system', () async {
        when(() => mockDb.getSetting('theme_mode')).thenAnswer((_) async => '');

        final notifier = ThemeModeNotifier();

        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state, ThemeMode.system);
      });

      test('null from database during load keeps system default', () async {
        when(
          () => mockDb.getSetting('theme_mode'),
        ).thenAnswer((_) async => null);

        final notifier = ThemeModeNotifier();

        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state, ThemeMode.system);
      });

      test('database connection failure during save is handled', () async {
        when(
          () => mockDb.getSetting('theme_mode'),
        ).thenAnswer((_) async => null);
        when(
          () => mockDb.saveSetting(any(), any()),
        ).thenThrow(Exception('Connection lost'));

        final notifier = ThemeModeNotifier();

        expect(() => notifier.setThemeMode(ThemeMode.light), returnsNormally);
        expect(notifier.state, ThemeMode.light);
      });

      test('case-sensitive theme mode name comparison', () async {
        when(
          () => mockDb.getSetting('theme_mode'),
        ).thenAnswer((_) async => 'DARK');

        final notifier = ThemeModeNotifier();

        await Future.delayed(const Duration(milliseconds: 100));

        // Should default to system because 'DARK' != 'dark'
        expect(notifier.state, ThemeMode.system);
      });
    });
  });

  group('Theme Providers', () {
    test('themeModeProvider returns ThemeModeNotifier', () {
      when(() => mockDb.getSetting('theme_mode')).thenAnswer((_) async => null);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(themeModeProvider.notifier);

      expect(notifier, isA<ThemeModeNotifier>());
    });

    test('themeModeProvider state changes when notifier updates', () async {
      when(() => mockDb.getSetting('theme_mode')).thenAnswer((_) async => null);
      when(() => mockDb.saveSetting(any(), any())).thenAnswer((_) async => {});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(themeModeProvider), ThemeMode.system);

      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);

      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    testWidgets('lightThemeProvider returns ThemeData with Neon theme', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final theme = container.read(lightThemeProvider);

      expect(theme, isA<ThemeData>());
      expect(theme.brightness, Brightness.light);
      expect(theme.useMaterial3, true);
    });

    testWidgets('darkThemeProvider returns ThemeData with Neon theme', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final theme = container.read(darkThemeProvider);

      expect(theme, isA<ThemeData>());
      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, true);
    });

    testWidgets('lightThemeProvider theme data is not null', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final theme = container.read(lightThemeProvider);

      expect(theme.colorScheme, isNotNull);
      expect(theme.primaryColor, isNotNull);
      expect(theme.scaffoldBackgroundColor, isNotNull);
    });

    testWidgets('darkThemeProvider theme data is not null', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final theme = container.read(darkThemeProvider);

      expect(theme.colorScheme, isNotNull);
      expect(theme.primaryColor, isNotNull);
      expect(theme.scaffoldBackgroundColor, isNotNull);
    });

    testWidgets('light and dark themes have different brightness', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final lightTheme = container.read(lightThemeProvider);
      final darkTheme = container.read(darkThemeProvider);

      expect(lightTheme.brightness, Brightness.light);
      expect(darkTheme.brightness, Brightness.dark);
      expect(lightTheme.brightness, isNot(equals(darkTheme.brightness)));
    });

    testWidgets('themes use Material3 design', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final lightTheme = container.read(lightThemeProvider);
      final darkTheme = container.read(darkThemeProvider);

      expect(lightTheme.useMaterial3, true);
      expect(darkTheme.useMaterial3, true);
    });
  });

  group('Provider Integration', () {
    test('multiple containers have independent theme mode state', () async {
      when(() => mockDb.getSetting('theme_mode')).thenAnswer((_) async => null);
      when(() => mockDb.saveSetting(any(), any())).thenAnswer((_) async => {});

      final container1 = ProviderContainer();
      final container2 = ProviderContainer();
      addTearDown(container1.dispose);
      addTearDown(container2.dispose);

      container1.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
      container2.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);

      expect(container1.read(themeModeProvider), ThemeMode.dark);
      expect(container2.read(themeModeProvider), ThemeMode.light);
    });

    test('provider listeners are notified of state changes', () async {
      when(() => mockDb.getSetting('theme_mode')).thenAnswer((_) async => null);
      when(() => mockDb.saveSetting(any(), any())).thenAnswer((_) async => {});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final states = <ThemeMode>[];

      container.listen(themeModeProvider, (previous, next) {
        states.add(next);
      });

      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);

      expect(states, [ThemeMode.light, ThemeMode.dark]);
    });
  });
}
