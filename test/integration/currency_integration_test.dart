import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bockaire/providers/currency_provider.dart';
import 'package:bockaire/repositories/currency_repository.dart';
import 'package:bockaire/classes/supported_currency.dart';

void main() {
  group('Currency Feature Integration', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    group('end-to-end scenarios', () {
      test('currency provider state management', () async {
        final container = ProviderContainer(
          overrides: [
            currencyRepositoryProvider.overrideWithValue(
              CurrencyRepository(prefs),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Verify initial EUR
        final initialCurrency = container.read(currencyNotifierProvider);
        expect(initialCurrency, SupportedCurrency.eur);

        // Change to USD
        await container
            .read(currencyNotifierProvider.notifier)
            .setCurrency(SupportedCurrency.usd);

        final updatedCurrency = container.read(currencyNotifierProvider);
        expect(updatedCurrency, SupportedCurrency.usd);
      });

      test('currency persists in SharedPreferences', () async {
        final container = ProviderContainer(
          overrides: [
            currencyRepositoryProvider.overrideWithValue(
              CurrencyRepository(prefs),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Set currency to GBP
        await container
            .read(currencyNotifierProvider.notifier)
            .setCurrency(SupportedCurrency.gbp);

        // Verify it's saved
        expect(prefs.getString('app_currency'), 'GBP');
      });
    });

    group('error scenarios', () {
      test('handles invalid saved currency gracefully', () async {
        SharedPreferences.setMockInitialValues({'app_currency': 'INVALID'});
        final invalidPrefs = await SharedPreferences.getInstance();

        final container = ProviderContainer(
          overrides: [
            currencyRepositoryProvider.overrideWithValue(
              CurrencyRepository(invalidPrefs),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Should fallback to EUR
        final currency = container.read(currencyNotifierProvider);
        expect(currency, SupportedCurrency.eur);
      });

      test('handles missing SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({});
        final emptyPrefs = await SharedPreferences.getInstance();

        final container = ProviderContainer(
          overrides: [
            currencyRepositoryProvider.overrideWithValue(
              CurrencyRepository(emptyPrefs),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Should use default EUR
        final currency = container.read(currencyNotifierProvider);
        expect(currency, SupportedCurrency.eur);
      });

      test('handles corrupted SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({'app_currency': ''});
        final corruptedPrefs = await SharedPreferences.getInstance();

        final container = ProviderContainer(
          overrides: [
            currencyRepositoryProvider.overrideWithValue(
              CurrencyRepository(corruptedPrefs),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Should fallback to EUR
        final currency = container.read(currencyNotifierProvider);
        expect(currency, SupportedCurrency.eur);
      });
    });

    group('currency conversion accuracy', () {
      test('EUR to USD conversion is accurate', () async {
        final container = ProviderContainer(
          overrides: [
            currencyRepositoryProvider.overrideWithValue(
              CurrencyRepository(prefs),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(currencyNotifierProvider.notifier)
            .setCurrency(SupportedCurrency.usd);

        final service = container.read(currencyServiceProvider);
        final result = service.convert(
          amountInEur: 100,
          targetCurrency: SupportedCurrency.usd,
        );

        expect(result, 108.0);
      });

      test('EUR to GBP conversion is accurate', () async {
        final container = ProviderContainer(
          overrides: [
            currencyRepositoryProvider.overrideWithValue(
              CurrencyRepository(prefs),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(currencyNotifierProvider.notifier)
            .setCurrency(SupportedCurrency.gbp);

        final service = container.read(currencyServiceProvider);
        final result = service.convert(
          amountInEur: 100,
          targetCurrency: SupportedCurrency.gbp,
        );

        expect(result, 86.0);
      });

      test('formatting includes correct symbol', () async {
        final container = ProviderContainer(
          overrides: [
            currencyRepositoryProvider.overrideWithValue(
              CurrencyRepository(prefs),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(currencyNotifierProvider.notifier)
            .setCurrency(SupportedCurrency.usd);

        final formatted = container.read(formatCurrencyProvider(100));
        expect(formatted, '\$108.00');
      });
    });

    group('accessibility', () {
      // These tests are covered in currency_selection_modal_test.dart
      test('all currencies are accessible', () {
        // Verify all currencies have required properties
        for (final currency in SupportedCurrency.values) {
          expect(currency.code.isNotEmpty, true);
          expect(currency.symbol.isNotEmpty, true);
          expect(currency.name.isNotEmpty, true);
          expect(currency.countryCode.isNotEmpty, true);
        }
      });
    });
  });
}
