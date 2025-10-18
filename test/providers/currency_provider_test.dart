import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bockaire/providers/currency_provider.dart';
import 'package:bockaire/repositories/currency_repository.dart';
import 'package:bockaire/classes/supported_currency.dart';

void main() {
  group('CurrencyNotifier', () {
    late ProviderContainer container;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          currencyRepositoryProvider.overrideWithValue(
            CurrencyRepository(prefs),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('initialization', () {
      test('initial state is EUR (default)', () {
        final currency = container.read(currencyNotifierProvider);
        expect(currency, SupportedCurrency.eur);
      });

      test('loads saved currency from SharedPreferences', () async {
        // Set up SharedPreferences with a saved currency
        SharedPreferences.setMockInitialValues({'app_currency': 'USD'});
        prefs = await SharedPreferences.getInstance();

        // Create new container with the new prefs
        final container2 = ProviderContainer(
          overrides: [
            currencyRepositoryProvider.overrideWithValue(
              CurrencyRepository(prefs),
            ),
          ],
        );
        addTearDown(container2.dispose);

        // Provider should load USD synchronously
        final currency = container2.read(currencyNotifierProvider);
        expect(currency, SupportedCurrency.usd);
      });

      test('handles missing SharedPreferences gracefully', () async {
        SharedPreferences.setMockInitialValues({});
        prefs = await SharedPreferences.getInstance();

        final container2 = ProviderContainer(
          overrides: [
            currencyRepositoryProvider.overrideWithValue(
              CurrencyRepository(prefs),
            ),
          ],
        );
        addTearDown(container2.dispose);

        final currency = container2.read(currencyNotifierProvider);
        expect(currency, SupportedCurrency.eur); // Should use default
      });

      test('handles invalid currency code in preferences', () async {
        SharedPreferences.setMockInitialValues({'app_currency': 'INVALID'});
        prefs = await SharedPreferences.getInstance();

        final container2 = ProviderContainer(
          overrides: [
            currencyRepositoryProvider.overrideWithValue(
              CurrencyRepository(prefs),
            ),
          ],
        );
        addTearDown(container2.dispose);

        final currency = container2.read(currencyNotifierProvider);
        expect(currency, SupportedCurrency.eur); // Should fallback to default
      });
    });

    group('setCurrency', () {
      test('updates state immediately', () async {
        final notifier = container.read(currencyNotifierProvider.notifier);

        await notifier.setCurrency(SupportedCurrency.usd);

        expect(notifier.state, SupportedCurrency.usd);
      });

      test('saves to SharedPreferences', () async {
        final notifier = container.read(currencyNotifierProvider.notifier);

        await notifier.setCurrency(SupportedCurrency.gbp);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('app_currency'), 'GBP');
      });

      test('persists across container recreations', () async {
        final notifier = container.read(currencyNotifierProvider.notifier);
        await notifier.setCurrency(SupportedCurrency.gbp);

        // Dispose old container
        container.dispose();

        // Create new container with same prefs (which now has GBP saved)
        final container2 = ProviderContainer(
          overrides: [
            currencyRepositoryProvider.overrideWithValue(
              CurrencyRepository(prefs),
            ),
          ],
        );
        addTearDown(container2.dispose);

        // Should load GBP from SharedPreferences
        final currency = container2.read(currencyNotifierProvider);
        expect(currency, SupportedCurrency.gbp);
      });

      test('handles all currencies', () async {
        final notifier = container.read(currencyNotifierProvider.notifier);

        for (final currency in SupportedCurrency.values) {
          await notifier.setCurrency(currency);
          expect(notifier.state, currency);

          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getString('app_currency'), currency.code);
        }
      });

      test('can switch between currencies multiple times', () async {
        final notifier = container.read(currencyNotifierProvider.notifier);

        await notifier.setCurrency(SupportedCurrency.usd);
        expect(notifier.state, SupportedCurrency.usd);

        await notifier.setCurrency(SupportedCurrency.gbp);
        expect(notifier.state, SupportedCurrency.gbp);

        await notifier.setCurrency(SupportedCurrency.eur);
        expect(notifier.state, SupportedCurrency.eur);
      });
    });

    group('loading saved currency', () {
      test('loads valid currency code', () async {
        SharedPreferences.setMockInitialValues({'app_currency': 'GBP'});
        prefs = await SharedPreferences.getInstance();

        final container2 = ProviderContainer(
          overrides: [
            currencyRepositoryProvider.overrideWithValue(
              CurrencyRepository(prefs),
            ),
          ],
        );
        addTearDown(container2.dispose);

        final currency = container2.read(currencyNotifierProvider);
        expect(currency, SupportedCurrency.gbp);
      });

      test('handles corrupted preferences data gracefully', () async {
        SharedPreferences.setMockInitialValues({'app_currency': ''});
        prefs = await SharedPreferences.getInstance();

        final container2 = ProviderContainer(
          overrides: [
            currencyRepositoryProvider.overrideWithValue(
              CurrencyRepository(prefs),
            ),
          ],
        );
        addTearDown(container2.dispose);

        final currency = container2.read(currencyNotifierProvider);
        expect(currency, SupportedCurrency.eur);
      });

      test('loads lowercase currency code', () async {
        SharedPreferences.setMockInitialValues({'app_currency': 'usd'});
        prefs = await SharedPreferences.getInstance();

        final container2 = ProviderContainer(
          overrides: [
            currencyRepositoryProvider.overrideWithValue(
              CurrencyRepository(prefs),
            ),
          ],
        );
        addTearDown(container2.dispose);

        final currency = container2.read(currencyNotifierProvider);
        expect(currency, SupportedCurrency.usd);
      });
    });

    group('state updates', () {
      test('notifies listeners when currency changes', () async {
        var notificationCount = 0;

        container.listen(currencyNotifierProvider, (previous, next) {
          notificationCount++;
        });

        final notifier = container.read(currencyNotifierProvider.notifier);
        await notifier.setCurrency(SupportedCurrency.usd);

        expect(notificationCount, greaterThan(0));
      });

      test('state is readable from provider', () async {
        final notifier = container.read(currencyNotifierProvider.notifier);
        await notifier.setCurrency(SupportedCurrency.gbp);

        final currency = container.read(currencyNotifierProvider);
        expect(currency, SupportedCurrency.gbp);
      });
    });
  });

  group('currencyService provider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('returns CurrencyService instance', () {
      final service = container.read(currencyServiceProvider);
      expect(service, isNotNull);
    });

    test('provides same instance on multiple reads', () {
      final service1 = container.read(currencyServiceProvider);
      final service2 = container.read(currencyServiceProvider);
      expect(identical(service1, service2), true);
    });
  });

  group('formatCurrency provider', () {
    late ProviderContainer container;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          currencyRepositoryProvider.overrideWithValue(
            CurrencyRepository(prefs),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('formats amount in current currency', () {
      final formatted = container.read(formatCurrencyProvider(100));
      expect(formatted, '€100.00'); // Default is EUR
    });

    test('updates when currency changes', () async {
      final notifier = container.read(currencyNotifierProvider.notifier);
      await notifier.setCurrency(SupportedCurrency.usd);

      // Read the formatted value - it should reflect the USD currency now
      final formatted = container.read(formatCurrencyProvider(100));
      expect(formatted, '\$108.00'); // 100 EUR = 108 USD
    });

    test('respects decimal parameter', () {
      final formatted = container.read(
        formatCurrencyProvider(100, decimals: 0),
      );
      expect(formatted, '€100');
    });

    test('watches currencyNotifier', () async {
      var callCount = 0;

      container.listen(formatCurrencyProvider(100), (previous, next) {
        callCount++;
      });

      await Future.delayed(const Duration(milliseconds: 50));

      final notifier = container.read(currencyNotifierProvider.notifier);
      await notifier.setCurrency(SupportedCurrency.usd);

      // Trigger read to update
      container.read(formatCurrencyProvider(100));

      expect(callCount, greaterThan(0));
    });

    test('formats different amounts correctly', () async {
      final notifier = container.read(currencyNotifierProvider.notifier);
      await notifier.setCurrency(SupportedCurrency.gbp);

      expect(
        container.read(formatCurrencyProvider(100)),
        '£86.00',
      ); // 100 EUR = 86 GBP
      expect(container.read(formatCurrencyProvider(50)), '£43.00');
      expect(container.read(formatCurrencyProvider(0)), '£0.00');
    });
  });

  group('error handling', () {
    test('handles rapid successive changes', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          currencyRepositoryProvider.overrideWithValue(
            CurrencyRepository(prefs),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(currencyNotifierProvider.notifier);

      // Rapid changes
      await notifier.setCurrency(SupportedCurrency.usd);
      await notifier.setCurrency(SupportedCurrency.gbp);
      await notifier.setCurrency(SupportedCurrency.eur);
      await notifier.setCurrency(SupportedCurrency.usd);

      expect(notifier.state, SupportedCurrency.usd);
    });

    test('state remains consistent during async operations', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          currencyRepositoryProvider.overrideWithValue(
            CurrencyRepository(prefs),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(currencyNotifierProvider.notifier);

      // Start multiple async operations
      final future1 = notifier.setCurrency(SupportedCurrency.usd);
      final future2 = notifier.setCurrency(SupportedCurrency.gbp);

      await Future.wait([future1, future2]);

      // State should be the last one set
      expect(notifier.state, SupportedCurrency.gbp);
    });
  });
}
