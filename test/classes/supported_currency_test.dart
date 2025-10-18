import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bockaire/classes/supported_currency.dart';
import 'package:bockaire/l10n/app_localizations.dart';

void main() {
  group('SupportedCurrency', () {
    group('fromCode', () {
      test('returns EUR for valid code EUR', () {
        expect(SupportedCurrency.fromCode('EUR'), SupportedCurrency.eur);
      });

      test('returns USD for valid code USD', () {
        expect(SupportedCurrency.fromCode('USD'), SupportedCurrency.usd);
      });

      test('returns GBP for valid code GBP', () {
        expect(SupportedCurrency.fromCode('GBP'), SupportedCurrency.gbp);
      });

      test('returns null for invalid code', () {
        expect(SupportedCurrency.fromCode('invalid'), isNull);
      });

      test('returns null for empty string', () {
        expect(SupportedCurrency.fromCode(''), isNull);
      });

      test('handles case insensitivity', () {
        expect(SupportedCurrency.fromCode('eur'), SupportedCurrency.eur);
        expect(SupportedCurrency.fromCode('usd'), SupportedCurrency.usd);
        expect(SupportedCurrency.fromCode('gbp'), SupportedCurrency.gbp);
        expect(SupportedCurrency.fromCode('Eur'), SupportedCurrency.eur);
        expect(SupportedCurrency.fromCode('UsD'), SupportedCurrency.usd);
      });

      test('returns null for non-existent currency code', () {
        expect(SupportedCurrency.fromCode('JPY'), isNull);
        expect(SupportedCurrency.fromCode('CNY'), isNull);
        expect(SupportedCurrency.fromCode('XXX'), isNull);
      });
    });

    group('format', () {
      test('formats EUR with € symbol', () {
        expect(SupportedCurrency.eur.format(100), '€100.00');
        expect(SupportedCurrency.eur.format(99.99), '€99.99');
      });

      test('formats USD with \$ symbol', () {
        expect(SupportedCurrency.usd.format(100), '\$100.00');
        expect(SupportedCurrency.usd.format(99.99), '\$99.99');
      });

      test('formats GBP with £ symbol', () {
        expect(SupportedCurrency.gbp.format(100), '£100.00');
        expect(SupportedCurrency.gbp.format(99.99), '£99.99');
      });

      test('formats with 0 decimals', () {
        expect(SupportedCurrency.eur.format(100, decimals: 0), '€100');
        expect(SupportedCurrency.usd.format(99.99, decimals: 0), '\$100');
        expect(SupportedCurrency.gbp.format(50.5, decimals: 0), '£51');
      });

      test('formats with 2 decimals (default)', () {
        expect(SupportedCurrency.eur.format(100), '€100.00');
        expect(SupportedCurrency.eur.format(100.1), '€100.10');
        expect(SupportedCurrency.eur.format(100.12), '€100.12');
      });

      test('formats with custom decimals', () {
        expect(SupportedCurrency.eur.format(100, decimals: 3), '€100.000');
        expect(SupportedCurrency.usd.format(99.9999, decimals: 4), '\$99.9999');
        expect(
          SupportedCurrency.gbp.format(50.12345, decimals: 5),
          '£50.12345',
        );
      });

      test('formats zero amount', () {
        expect(SupportedCurrency.eur.format(0), '€0.00');
        expect(SupportedCurrency.usd.format(0), '\$0.00');
        expect(SupportedCurrency.gbp.format(0), '£0.00');
      });

      test('formats negative amount', () {
        expect(SupportedCurrency.eur.format(-100), '€-100.00');
        expect(SupportedCurrency.usd.format(-50.5), '\$-50.50');
        expect(SupportedCurrency.gbp.format(-0.01), '£-0.01');
      });

      test('formats very large amount', () {
        expect(SupportedCurrency.eur.format(999999999.99), '€999999999.99');
      });

      test('formats very small amount', () {
        expect(SupportedCurrency.eur.format(0.01), '€0.01');
        expect(SupportedCurrency.usd.format(0.001, decimals: 3), '\$0.001');
      });
    });

    group('formatWithCode', () {
      test('formats with currency code instead of symbol', () {
        expect(SupportedCurrency.eur.formatWithCode(100), '100.00 EUR');
        expect(SupportedCurrency.usd.formatWithCode(99.99), '99.99 USD');
        expect(SupportedCurrency.gbp.formatWithCode(50), '50.00 GBP');
      });

      test('respects decimal parameter', () {
        expect(
          SupportedCurrency.eur.formatWithCode(100, decimals: 0),
          '100 EUR',
        );
        expect(
          SupportedCurrency.usd.formatWithCode(99.99, decimals: 3),
          '99.990 USD',
        );
      });

      test('formats zero with code', () {
        expect(SupportedCurrency.eur.formatWithCode(0), '0.00 EUR');
      });

      test('formats negative with code', () {
        expect(SupportedCurrency.usd.formatWithCode(-50), '-50.00 USD');
      });
    });

    group('localizedName', () {
      testWidgets('returns localized names in English', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Builder(
              builder: (context) {
                expect(SupportedCurrency.eur.localizedName(context), 'Euro');
                expect(
                  SupportedCurrency.usd.localizedName(context),
                  'US Dollar',
                );
                expect(
                  SupportedCurrency.gbp.localizedName(context),
                  'British Pound',
                );
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('returns localized names in German', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('de'),
            home: Builder(
              builder: (context) {
                expect(SupportedCurrency.eur.localizedName(context), 'Euro');
                expect(
                  SupportedCurrency.usd.localizedName(context),
                  'US-Dollar',
                );
                expect(
                  SupportedCurrency.gbp.localizedName(context),
                  'Britisches Pfund',
                );
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('returns localized names in Chinese', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('zh'),
            home: Builder(
              builder: (context) {
                expect(SupportedCurrency.eur.localizedName(context), '欧元');
                expect(SupportedCurrency.usd.localizedName(context), '美元');
                expect(SupportedCurrency.gbp.localizedName(context), '英镑');
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('properties', () {
      test('defaultCurrency is EUR', () {
        expect(SupportedCurrency.defaultCurrency, SupportedCurrency.eur);
      });

      test('values contains exactly 3 currencies', () {
        expect(SupportedCurrency.values.length, 3);
      });

      test('all currencies have unique codes', () {
        final codes = SupportedCurrency.values
            .map((currency) => currency.code)
            .toSet();
        expect(codes.length, SupportedCurrency.values.length);
      });

      test('all currency codes are uppercase', () {
        for (final currency in SupportedCurrency.values) {
          expect(currency.code, currency.code.toUpperCase());
        }
      });

      test('all currencies have non-empty symbols', () {
        for (final currency in SupportedCurrency.values) {
          expect(currency.symbol.isNotEmpty, true);
        }
      });

      test('all currencies have non-empty names', () {
        for (final currency in SupportedCurrency.values) {
          expect(currency.name.isNotEmpty, true);
        }
      });

      test('all currencies have valid country codes', () {
        for (final currency in SupportedCurrency.values) {
          expect(currency.countryCode.isNotEmpty, true);
          expect(currency.countryCode.length, 2);
        }
      });

      test('currency codes are exactly 3 characters', () {
        for (final currency in SupportedCurrency.values) {
          expect(currency.code.length, 3);
        }
      });
    });
  });
}
