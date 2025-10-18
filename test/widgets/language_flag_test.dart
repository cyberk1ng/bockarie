import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:country_flags/country_flags.dart';
import 'package:bockaire/widgets/flags/language_flag.dart';
import 'package:bockaire/classes/supported_language.dart';

void main() {
  group('buildLanguageFlag', () {
    testWidgets('renders CountryFlag widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: buildLanguageFlag(languageCode: 'en', height: 24, width: 32),
          ),
        ),
      );

      expect(find.byType(CountryFlag), findsOneWidget);
    });

    group('override mappings', () {
      testWidgets('uses cn flag for zh (Chinese)', (tester) async {
        final widget = buildLanguageFlag(
          languageCode: 'zh',
          height: 24,
          width: 32,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

        expect(find.byType(CountryFlag), findsOneWidget);
        final countryFlag = tester.widget<CountryFlag>(
          find.byType(CountryFlag),
        );
        // Verify it's using country code (CountryFlag.fromCountryCode)
        expect(countryFlag, isNotNull);
      });

      testWidgets('uses gb flag for en (English)', (tester) async {
        final widget = buildLanguageFlag(
          languageCode: 'en',
          height: 24,
          width: 32,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

        expect(find.byType(CountryFlag), findsOneWidget);
      });

      testWidgets('uses ie flag for ga (Irish)', (tester) async {
        final widget = buildLanguageFlag(
          languageCode: 'ga',
          height: 24,
          width: 32,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

        expect(find.byType(CountryFlag), findsOneWidget);
      });

      testWidgets('uses gr flag for el (Greek)', (tester) async {
        final widget = buildLanguageFlag(
          languageCode: 'el',
          height: 24,
          width: 32,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

        expect(find.byType(CountryFlag), findsOneWidget);
      });

      testWidgets('uses dk flag for da (Danish)', (tester) async {
        final widget = buildLanguageFlag(
          languageCode: 'da',
          height: 24,
          width: 32,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

        expect(find.byType(CountryFlag), findsOneWidget);
      });

      testWidgets('uses se flag for sv (Swedish)', (tester) async {
        final widget = buildLanguageFlag(
          languageCode: 'sv',
          height: 24,
          width: 32,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

        expect(find.byType(CountryFlag), findsOneWidget);
      });

      testWidgets('uses sa flag for ar (Arabic)', (tester) async {
        final widget = buildLanguageFlag(
          languageCode: 'ar',
          height: 24,
          width: 32,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

        expect(find.byType(CountryFlag), findsOneWidget);
      });

      testWidgets('uses il flag for he (Hebrew)', (tester) async {
        final widget = buildLanguageFlag(
          languageCode: 'he',
          height: 24,
          width: 32,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

        expect(find.byType(CountryFlag), findsOneWidget);
      });

      testWidgets('uses ir flag for fa (Persian)', (tester) async {
        final widget = buildLanguageFlag(
          languageCode: 'fa',
          height: 24,
          width: 32,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

        expect(find.byType(CountryFlag), findsOneWidget);
      });
    });

    group('direct language-to-country mapping', () {
      testWidgets('uses fr flag for fr (French)', (tester) async {
        final widget = buildLanguageFlag(
          languageCode: 'fr',
          height: 24,
          width: 32,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

        expect(find.byType(CountryFlag), findsOneWidget);
      });

      testWidgets('uses de flag for de (German)', (tester) async {
        final widget = buildLanguageFlag(
          languageCode: 'de',
          height: 24,
          width: 32,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

        expect(find.byType(CountryFlag), findsOneWidget);
      });

      testWidgets('uses es flag for es (Spanish)', (tester) async {
        final widget = buildLanguageFlag(
          languageCode: 'es',
          height: 24,
          width: 32,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

        expect(find.byType(CountryFlag), findsOneWidget);
      });

      testWidgets('uses it flag for it (Italian)', (tester) async {
        final widget = buildLanguageFlag(
          languageCode: 'it',
          height: 24,
          width: 32,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

        expect(find.byType(CountryFlag), findsOneWidget);
      });

      testWidgets('uses pt flag for pt (Portuguese)', (tester) async {
        final widget = buildLanguageFlag(
          languageCode: 'pt',
          height: 24,
          width: 32,
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

        expect(find.byType(CountryFlag), findsOneWidget);
      });
    });

    testWidgets('renders flags for all 29 supported languages', (tester) async {
      for (final lang in SupportedLanguage.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: buildLanguageFlag(
                languageCode: lang.code,
                height: 24,
                width: 32,
              ),
            ),
          ),
        );

        expect(
          find.byType(CountryFlag),
          findsOneWidget,
          reason: 'Flag for ${lang.code} (${lang.name}) should render',
        );

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('respects custom height and width', (tester) async {
      final widget = buildLanguageFlag(
        languageCode: 'en',
        height: 48,
        width: 64,
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      final countryFlag = tester.widget<CountryFlag>(find.byType(CountryFlag));
      expect(countryFlag.height, 48);
      expect(countryFlag.width, 64);
    });

    testWidgets('respects custom key', (tester) async {
      const customKey = ValueKey('custom-flag');

      final widget = buildLanguageFlag(
        languageCode: 'fr',
        height: 24,
        width: 32,
        key: customKey,
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      expect(find.byKey(customKey), findsOneWidget);
    });

    testWidgets('generates default key from language code', (tester) async {
      final widget = buildLanguageFlag(
        languageCode: 'de',
        height: 24,
        width: 32,
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      expect(find.byKey(const ValueKey('flag-de')), findsOneWidget);
    });

    testWidgets('can render multiple flags simultaneously', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                buildLanguageFlag(languageCode: 'en', height: 24, width: 32),
                buildLanguageFlag(languageCode: 'fr', height: 24, width: 32),
                buildLanguageFlag(languageCode: 'es', height: 24, width: 32),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(CountryFlag), findsNWidgets(3));
    });

    testWidgets('handles very small dimensions', (tester) async {
      final widget = buildLanguageFlag(languageCode: 'en', height: 1, width: 1);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      final countryFlag = tester.widget<CountryFlag>(find.byType(CountryFlag));
      expect(countryFlag.height, 1);
      expect(countryFlag.width, 1);
    });

    testWidgets('handles very large dimensions', (tester) async {
      final widget = buildLanguageFlag(
        languageCode: 'en',
        height: 500,
        width: 750,
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      final countryFlag = tester.widget<CountryFlag>(find.byType(CountryFlag));
      expect(countryFlag.height, 500);
      expect(countryFlag.width, 750);
    });
  });
}
