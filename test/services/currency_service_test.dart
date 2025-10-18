import 'package:flutter_test/flutter_test.dart';
import 'package:bockaire/services/currency_service.dart';
import 'package:bockaire/classes/supported_currency.dart';

void main() {
  group('CurrencyService', () {
    late CurrencyService service;

    setUp(() {
      service = CurrencyService();
    });

    group('convert', () {
      test('EUR to EUR returns same amount', () {
        final result = service.convert(
          amountInEur: 100,
          targetCurrency: SupportedCurrency.eur,
        );
        expect(result, 100.0);
      });

      test('EUR to USD applies 1.08 rate', () {
        final result = service.convert(
          amountInEur: 100,
          targetCurrency: SupportedCurrency.usd,
        );
        expect(result, 108.0);
      });

      test('EUR to GBP applies 0.86 rate', () {
        final result = service.convert(
          amountInEur: 100,
          targetCurrency: SupportedCurrency.gbp,
        );
        expect(result, 86.0);
      });

      test('handles zero amount', () {
        final result = service.convert(
          amountInEur: 0,
          targetCurrency: SupportedCurrency.usd,
        );
        expect(result, 0.0);
      });

      test('handles negative amount', () {
        final result = service.convert(
          amountInEur: -100,
          targetCurrency: SupportedCurrency.usd,
        );
        expect(result, -108.0);
      });

      test('handles large amount', () {
        final result = service.convert(
          amountInEur: 1000000,
          targetCurrency: SupportedCurrency.usd,
        );
        expect(result, 1080000.0);
      });

      test('preserves precision for small amounts', () {
        final result = service.convert(
          amountInEur: 0.01,
          targetCurrency: SupportedCurrency.usd,
        );
        expect(result, closeTo(0.0108, 0.0001));
      });

      test('handles fractional amounts correctly', () {
        final result = service.convert(
          amountInEur: 50.55,
          targetCurrency: SupportedCurrency.usd,
        );
        expect(result, closeTo(54.594, 0.001));
      });
    });

    group('convertBetween', () {
      test('USD to GBP conversion', () {
        final result = service.convertBetween(
          amount: 108,
          fromCurrency: SupportedCurrency.usd,
          toCurrency: SupportedCurrency.gbp,
        );
        // 108 USD -> 100 EUR -> 86 GBP
        expect(result, closeTo(86.0, 0.01));
      });

      test('GBP to USD conversion', () {
        final result = service.convertBetween(
          amount: 86,
          fromCurrency: SupportedCurrency.gbp,
          toCurrency: SupportedCurrency.usd,
        );
        // 86 GBP -> 100 EUR -> 108 USD
        expect(result, closeTo(108.0, 0.01));
      });

      test('same currency returns same amount', () {
        final result = service.convertBetween(
          amount: 100,
          fromCurrency: SupportedCurrency.eur,
          toCurrency: SupportedCurrency.eur,
        );
        expect(result, 100.0);
      });

      test('EUR to USD matches convert() method', () {
        final result1 = service.convertBetween(
          amount: 100,
          fromCurrency: SupportedCurrency.eur,
          toCurrency: SupportedCurrency.usd,
        );
        final result2 = service.convert(
          amountInEur: 100,
          targetCurrency: SupportedCurrency.usd,
        );
        expect(result1, result2);
      });

      test('transitive conversion accuracy', () {
        // Convert EUR -> USD -> GBP
        final eurToUsd = service.convert(
          amountInEur: 100,
          targetCurrency: SupportedCurrency.usd,
        );
        final usdToGbp = service.convertBetween(
          amount: eurToUsd,
          fromCurrency: SupportedCurrency.usd,
          toCurrency: SupportedCurrency.gbp,
        );

        // Direct EUR -> GBP
        final eurToGbp = service.convert(
          amountInEur: 100,
          targetCurrency: SupportedCurrency.gbp,
        );

        expect(usdToGbp, closeTo(eurToGbp, 0.01));
      });

      test('handles zero', () {
        final result = service.convertBetween(
          amount: 0,
          fromCurrency: SupportedCurrency.usd,
          toCurrency: SupportedCurrency.gbp,
        );
        expect(result, 0.0);
      });

      test('handles negative', () {
        final result = service.convertBetween(
          amount: -100,
          fromCurrency: SupportedCurrency.usd,
          toCurrency: SupportedCurrency.gbp,
        );
        expect(result, lessThan(0));
      });

      test('handles large numbers', () {
        final result = service.convertBetween(
          amount: 1000000,
          fromCurrency: SupportedCurrency.usd,
          toCurrency: SupportedCurrency.gbp,
        );
        expect(result, isA<double>());
        expect(result.isFinite, true);
      });
    });

    group('getExchangeRate', () {
      test('EUR to EUR returns 1.0', () {
        final rate = service.getExchangeRate(
          fromCurrency: SupportedCurrency.eur,
          toCurrency: SupportedCurrency.eur,
        );
        expect(rate, 1.0);
      });

      test('EUR to USD returns 1.08', () {
        final rate = service.getExchangeRate(
          fromCurrency: SupportedCurrency.eur,
          toCurrency: SupportedCurrency.usd,
        );
        expect(rate, 1.08);
      });

      test('EUR to GBP returns 0.86', () {
        final rate = service.getExchangeRate(
          fromCurrency: SupportedCurrency.eur,
          toCurrency: SupportedCurrency.gbp,
        );
        expect(rate, 0.86);
      });

      test('USD to GBP calculates correctly', () {
        final rate = service.getExchangeRate(
          fromCurrency: SupportedCurrency.usd,
          toCurrency: SupportedCurrency.gbp,
        );
        // (0.86 / 1.08) ≈ 0.7963
        expect(rate, closeTo(0.7963, 0.0001));
      });

      test('rate reciprocity holds', () {
        final eurToUsd = service.getExchangeRate(
          fromCurrency: SupportedCurrency.eur,
          toCurrency: SupportedCurrency.usd,
        );
        final usdToEur = service.getExchangeRate(
          fromCurrency: SupportedCurrency.usd,
          toCurrency: SupportedCurrency.eur,
        );
        expect(eurToUsd * usdToEur, closeTo(1.0, 0.0001));
      });

      test('all rates are positive', () {
        for (final from in SupportedCurrency.values) {
          for (final to in SupportedCurrency.values) {
            final rate = service.getExchangeRate(
              fromCurrency: from,
              toCurrency: to,
            );
            expect(rate, greaterThan(0));
          }
        }
      });
    });

    group('formatAmount', () {
      test('formats EUR correctly', () {
        final result = service.formatAmount(
          amountInEur: 100,
          currency: SupportedCurrency.eur,
        );
        expect(result, '€100.00');
      });

      test('formats USD correctly', () {
        final result = service.formatAmount(
          amountInEur: 100,
          currency: SupportedCurrency.usd,
        );
        expect(result, '\$108.00');
      });

      test('formats GBP correctly', () {
        final result = service.formatAmount(
          amountInEur: 100,
          currency: SupportedCurrency.gbp,
        );
        expect(result, '£86.00');
      });

      test('respects decimal parameter', () {
        final result = service.formatAmount(
          amountInEur: 100,
          currency: SupportedCurrency.usd,
          decimals: 0,
        );
        expect(result, '\$108');
      });

      test('integrates conversion and formatting', () {
        final result = service.formatAmount(
          amountInEur: 50.50,
          currency: SupportedCurrency.usd,
          decimals: 2,
        );
        // 50.50 EUR * 1.08 = 54.54 USD
        expect(result, '\$54.54');
      });

      test('handles zero', () {
        final result = service.formatAmount(
          amountInEur: 0,
          currency: SupportedCurrency.usd,
        );
        expect(result, '\$0.00');
      });

      test('handles negative', () {
        final result = service.formatAmount(
          amountInEur: -50,
          currency: SupportedCurrency.gbp,
        );
        expect(result, '£-43.00');
      });

      test('handles small amounts', () {
        final result = service.formatAmount(
          amountInEur: 0.01,
          currency: SupportedCurrency.usd,
          decimals: 4,
        );
        expect(result, '\$0.0108');
      });
    });

    group('exchange rates validation', () {
      test('EUR base rate is 1.0', () {
        final rate = service.getExchangeRate(
          fromCurrency: SupportedCurrency.eur,
          toCurrency: SupportedCurrency.eur,
        );
        expect(rate, 1.0);
      });

      test('all rates are positive', () {
        for (final from in SupportedCurrency.values) {
          for (final to in SupportedCurrency.values) {
            final rate = service.getExchangeRate(
              fromCurrency: from,
              toCurrency: to,
            );
            expect(rate, greaterThan(0));
          }
        }
      });

      test('all rates are finite', () {
        for (final from in SupportedCurrency.values) {
          for (final to in SupportedCurrency.values) {
            final rate = service.getExchangeRate(
              fromCurrency: from,
              toCurrency: to,
            );
            expect(rate.isFinite, true);
            expect(rate.isNaN, false);
          }
        }
      });

      test('conversion works for all supported currencies', () {
        for (final currency in SupportedCurrency.values) {
          final result = service.convert(
            amountInEur: 100,
            targetCurrency: currency,
          );
          expect(result, greaterThan(0));
          expect(result.isFinite, true);
        }
      });
    });

    group('edge cases', () {
      test('handles very small amounts', () {
        final result = service.convert(
          amountInEur: 0.001,
          targetCurrency: SupportedCurrency.usd,
        );
        expect(result, closeTo(0.00108, 0.00001));
      });

      test('handles precision in multi-step conversion', () {
        // EUR -> USD -> GBP -> EUR should be close to original
        var amount = 100.0;
        amount = service.convertBetween(
          amount: amount,
          fromCurrency: SupportedCurrency.eur,
          toCurrency: SupportedCurrency.usd,
        );
        amount = service.convertBetween(
          amount: amount,
          fromCurrency: SupportedCurrency.usd,
          toCurrency: SupportedCurrency.gbp,
        );
        amount = service.convertBetween(
          amount: amount,
          fromCurrency: SupportedCurrency.gbp,
          toCurrency: SupportedCurrency.eur,
        );
        expect(amount, closeTo(100.0, 0.01));
      });

      test('conversion is commutative for amount', () {
        final result1 = service.convert(
          amountInEur: 50 + 50,
          targetCurrency: SupportedCurrency.usd,
        );
        final result2 =
            service.convert(
              amountInEur: 50,
              targetCurrency: SupportedCurrency.usd,
            ) +
            service.convert(
              amountInEur: 50,
              targetCurrency: SupportedCurrency.usd,
            );
        expect(result1, closeTo(result2, 0.0001));
      });
    });
  });
}
