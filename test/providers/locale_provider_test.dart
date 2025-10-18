import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bockaire/providers/locale_provider.dart';
import 'package:bockaire/classes/supported_language.dart';

void main() {
  group('LocaleNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is null (system default)', () async {
      final notifier = container.read(localeNotifierProvider.notifier);
      // Wait a bit for async initialization
      await Future.delayed(const Duration(milliseconds: 50));
      expect(notifier.state, isNull);
    });

    test('loadLocale loads saved locale from SharedPreferences', () async {
      // Set up SharedPreferences with a saved locale
      SharedPreferences.setMockInitialValues({'app_locale': 'fr'});

      // Create new container to trigger fresh initialization
      final container2 = ProviderContainer();
      addTearDown(container2.dispose);

      // Trigger provider build and wait for async load
      final notifier = container2.read(localeNotifierProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 200));

      expect(notifier.state?.languageCode, 'fr');
    });

    test('loadLocale handles missing SharedPreferences value', () async {
      SharedPreferences.setMockInitialValues({});

      final container2 = ProviderContainer();
      addTearDown(container2.dispose);

      // Wait for async load
      await Future.delayed(const Duration(milliseconds: 100));

      final locale = container2.read(localeNotifierProvider);
      expect(locale, isNull);
    });

    test('setLocale updates state immediately', () async {
      final notifier = container.read(localeNotifierProvider.notifier);

      await notifier.setLocale(const Locale('es'));

      expect(notifier.state?.languageCode, 'es');
    });

    test('setLocale saves locale to SharedPreferences', () async {
      final notifier = container.read(localeNotifierProvider.notifier);

      await notifier.setLocale(const Locale('es'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), 'es');
    });

    test('setLocale with null removes from SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_locale', 'de');

      final notifier = container.read(localeNotifierProvider.notifier);
      // First set to de explicitly
      await notifier.setLocale(const Locale('de'));
      expect(notifier.state?.languageCode, 'de');

      // Then set to null
      await notifier.setLocale(null);

      expect(notifier.state, isNull);
      expect(prefs.getString('app_locale'), isNull);
    });

    test('setLocale persists across container recreations', () async {
      final notifier = container.read(localeNotifierProvider.notifier);
      await notifier.setLocale(const Locale('it'));

      // Dispose old container
      container.dispose();

      // Create new container
      final container2 = ProviderContainer();
      addTearDown(container2.dispose);

      // Trigger provider initialization and wait for async load
      final notifier2 = container2.read(localeNotifierProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 200));

      expect(notifier2.state?.languageCode, 'it');
    });

    test('handles all 29 supported languages', () async {
      final notifier = container.read(localeNotifierProvider.notifier);
      final prefs = await SharedPreferences.getInstance();

      for (final lang in SupportedLanguage.values) {
        await notifier.setLocale(Locale(lang.code));

        expect(
          notifier.state?.languageCode,
          lang.code,
          reason: 'State should be ${lang.code}',
        );
        expect(
          prefs.getString('app_locale'),
          lang.code,
          reason: 'SharedPreferences should have ${lang.code}',
        );
      }
    });

    test('can switch between languages multiple times', () async {
      final notifier = container.read(localeNotifierProvider.notifier);
      final prefs = await SharedPreferences.getInstance();

      // Switch to French
      await notifier.setLocale(const Locale('fr'));
      expect(notifier.state?.languageCode, 'fr');
      expect(prefs.getString('app_locale'), 'fr');

      // Switch to Spanish
      await notifier.setLocale(const Locale('es'));
      expect(notifier.state?.languageCode, 'es');
      expect(prefs.getString('app_locale'), 'es');

      // Switch to German
      await notifier.setLocale(const Locale('de'));
      expect(notifier.state?.languageCode, 'de');
      expect(prefs.getString('app_locale'), 'de');

      // Switch back to system default
      await notifier.setLocale(null);
      expect(notifier.state, isNull);
      expect(prefs.getString('app_locale'), isNull);
    });

    test('setLocale with same value updates state', () async {
      final notifier = container.read(localeNotifierProvider.notifier);

      await notifier.setLocale(const Locale('en'));
      expect(notifier.state?.languageCode, 'en');

      // Set to same value again
      await notifier.setLocale(const Locale('en'));
      expect(notifier.state?.languageCode, 'en');
    });

    test(
      'initial load does not overwrite null state if no saved preference',
      () async {
        SharedPreferences.setMockInitialValues({});

        final container2 = ProviderContainer();
        addTearDown(container2.dispose);

        final notifier = container2.read(localeNotifierProvider.notifier);

        // Wait for load
        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state, isNull);
      },
    );

    test('provider can be watched and rebuilds on change', () async {
      final container2 = ProviderContainer();
      addTearDown(container2.dispose);

      // Track state changes
      final states = <Locale?>[];

      container2.listen<Locale?>(
        localeNotifierProvider,
        (previous, next) => states.add(next),
        fireImmediately: true,
      );

      // Initial null
      expect(states, [null]);

      // Change to French
      final notifier = container2.read(localeNotifierProvider.notifier);
      await notifier.setLocale(const Locale('fr'));

      expect(states.last?.languageCode, 'fr');

      // Change to Spanish
      await notifier.setLocale(const Locale('es'));

      expect(states.last?.languageCode, 'es');
    });

    test('handles country code in locale', () async {
      final notifier = container.read(localeNotifierProvider.notifier);
      final prefs = await SharedPreferences.getInstance();

      await notifier.setLocale(const Locale('en', 'US'));

      expect(notifier.state?.languageCode, 'en');
      expect(notifier.state?.countryCode, 'US');
      // Only language code is saved
      expect(prefs.getString('app_locale'), 'en');
    });

    test('loading locale with country code only loads language code', () async {
      // Save locale with country code in SharedPreferences
      SharedPreferences.setMockInitialValues({'app_locale': 'pt'});

      final container2 = ProviderContainer();
      addTearDown(container2.dispose);

      // Trigger provider initialization
      final notifier = container2.read(localeNotifierProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 200));

      // Should load as 'pt'
      expect(notifier.state?.languageCode, 'pt');
    });
  });
}
