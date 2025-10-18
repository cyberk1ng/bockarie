import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bockaire/classes/supported_language.dart';
import 'package:bockaire/l10n/app_localizations.dart';

void main() {
  group('SupportedLanguage', () {
    group('fromCode', () {
      test('returns correct language for valid code - en', () {
        expect(SupportedLanguage.fromCode('en'), SupportedLanguage.en);
      });

      test('returns correct language for valid code - de', () {
        expect(SupportedLanguage.fromCode('de'), SupportedLanguage.de);
      });

      test('returns correct language for valid code - zh', () {
        expect(SupportedLanguage.fromCode('zh'), SupportedLanguage.zh);
      });

      test('returns correct language for valid code - fr', () {
        expect(SupportedLanguage.fromCode('fr'), SupportedLanguage.fr);
      });

      test('returns correct language for valid code - es', () {
        expect(SupportedLanguage.fromCode('es'), SupportedLanguage.es);
      });

      test('returns correct language for valid code - it', () {
        expect(SupportedLanguage.fromCode('it'), SupportedLanguage.it);
      });

      test('returns correct language for valid code - pt', () {
        expect(SupportedLanguage.fromCode('pt'), SupportedLanguage.pt);
      });

      test('returns correct language for valid code - nl', () {
        expect(SupportedLanguage.fromCode('nl'), SupportedLanguage.nl);
      });

      test('returns correct language for valid code - pl', () {
        expect(SupportedLanguage.fromCode('pl'), SupportedLanguage.pl);
      });

      test('returns correct language for valid code - el', () {
        expect(SupportedLanguage.fromCode('el'), SupportedLanguage.el);
      });

      test('returns correct language for valid code - cs', () {
        expect(SupportedLanguage.fromCode('cs'), SupportedLanguage.cs);
      });

      test('returns correct language for valid code - hu', () {
        expect(SupportedLanguage.fromCode('hu'), SupportedLanguage.hu);
      });

      test('returns correct language for valid code - ro', () {
        expect(SupportedLanguage.fromCode('ro'), SupportedLanguage.ro);
      });

      test('returns correct language for valid code - sv', () {
        expect(SupportedLanguage.fromCode('sv'), SupportedLanguage.sv);
      });

      test('returns correct language for valid code - da', () {
        expect(SupportedLanguage.fromCode('da'), SupportedLanguage.da);
      });

      test('returns correct language for valid code - fi', () {
        expect(SupportedLanguage.fromCode('fi'), SupportedLanguage.fi);
      });

      test('returns correct language for valid code - sk', () {
        expect(SupportedLanguage.fromCode('sk'), SupportedLanguage.sk);
      });

      test('returns correct language for valid code - bg', () {
        expect(SupportedLanguage.fromCode('bg'), SupportedLanguage.bg);
      });

      test('returns correct language for valid code - hr', () {
        expect(SupportedLanguage.fromCode('hr'), SupportedLanguage.hr);
      });

      test('returns correct language for valid code - lt', () {
        expect(SupportedLanguage.fromCode('lt'), SupportedLanguage.lt);
      });

      test('returns correct language for valid code - lv', () {
        expect(SupportedLanguage.fromCode('lv'), SupportedLanguage.lv);
      });

      test('returns correct language for valid code - sl', () {
        expect(SupportedLanguage.fromCode('sl'), SupportedLanguage.sl);
      });

      test('returns correct language for valid code - et', () {
        expect(SupportedLanguage.fromCode('et'), SupportedLanguage.et);
      });

      test('returns correct language for valid code - mt', () {
        expect(SupportedLanguage.fromCode('mt'), SupportedLanguage.mt);
      });

      test('returns correct language for valid code - ga', () {
        expect(SupportedLanguage.fromCode('ga'), SupportedLanguage.ga);
      });

      test('returns correct language for valid code - ar', () {
        expect(SupportedLanguage.fromCode('ar'), SupportedLanguage.ar);
      });

      test('returns correct language for valid code - tr', () {
        expect(SupportedLanguage.fromCode('tr'), SupportedLanguage.tr);
      });

      test('returns correct language for valid code - he', () {
        expect(SupportedLanguage.fromCode('he'), SupportedLanguage.he);
      });

      test('returns correct language for valid code - fa', () {
        expect(SupportedLanguage.fromCode('fa'), SupportedLanguage.fa);
      });

      test('returns null for invalid code', () {
        expect(SupportedLanguage.fromCode('invalid'), isNull);
      });

      test('returns null for non-existent language code', () {
        expect(SupportedLanguage.fromCode('xx'), isNull);
      });

      test('returns null for empty string', () {
        expect(SupportedLanguage.fromCode(''), isNull);
      });

      test('returns null for unknown two-letter code', () {
        expect(SupportedLanguage.fromCode('zz'), isNull);
      });
    });

    group('localizedName', () {
      testWidgets('returns English name when locale is en', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Builder(
              builder: (context) {
                expect(SupportedLanguage.en.localizedName(context), 'English');
                expect(SupportedLanguage.de.localizedName(context), 'German');
                expect(SupportedLanguage.zh.localizedName(context), 'Chinese');
                expect(SupportedLanguage.fr.localizedName(context), 'French');
                expect(SupportedLanguage.es.localizedName(context), 'Spanish');
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('returns French name when locale is fr', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
            home: Builder(
              builder: (context) {
                expect(SupportedLanguage.en.localizedName(context), 'Anglais');
                expect(SupportedLanguage.de.localizedName(context), 'Allemand');
                expect(SupportedLanguage.zh.localizedName(context), 'Chinois');
                expect(SupportedLanguage.fr.localizedName(context), 'Français');
                expect(SupportedLanguage.es.localizedName(context), 'Espagnol');
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('returns Spanish name when locale is es', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('es'),
            home: Builder(
              builder: (context) {
                expect(SupportedLanguage.en.localizedName(context), 'Inglés');
                expect(SupportedLanguage.de.localizedName(context), 'Alemán');
                expect(SupportedLanguage.fr.localizedName(context), 'Francés');
                expect(SupportedLanguage.es.localizedName(context), 'Español');
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('returns Italian name when locale is it', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('it'),
            home: Builder(
              builder: (context) {
                expect(SupportedLanguage.en.localizedName(context), 'Inglese');
                expect(SupportedLanguage.de.localizedName(context), 'Tedesco');
                expect(SupportedLanguage.fr.localizedName(context), 'Francese');
                expect(SupportedLanguage.it.localizedName(context), 'Italiano');
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('returns Portuguese name when locale is pt', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('pt'),
            home: Builder(
              builder: (context) {
                expect(SupportedLanguage.en.localizedName(context), 'Inglês');
                expect(SupportedLanguage.de.localizedName(context), 'Alemão');
                expect(SupportedLanguage.fr.localizedName(context), 'Francês');
                expect(
                  SupportedLanguage.pt.localizedName(context),
                  'Português',
                );
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('all 29 languages return non-empty names in English', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Builder(
              builder: (context) {
                for (final lang in SupportedLanguage.values) {
                  final name = lang.localizedName(context);
                  expect(
                    name.isNotEmpty,
                    true,
                    reason: '${lang.code} should have a non-empty name',
                  );
                }
                return Container();
              },
            ),
          ),
        );
      });
    });

    test('values contains all 29 languages', () {
      expect(SupportedLanguage.values.length, 29);
    });

    test('all languages have unique codes', () {
      final codes = SupportedLanguage.values.map((lang) => lang.code).toSet();
      expect(codes.length, SupportedLanguage.values.length);
    });

    test('all languages have non-empty names', () {
      for (final lang in SupportedLanguage.values) {
        expect(lang.name.isNotEmpty, true);
      }
    });

    test('language codes are lowercase', () {
      for (final lang in SupportedLanguage.values) {
        expect(lang.code, lang.code.toLowerCase());
      }
    });

    test('language codes are exactly 2 characters', () {
      for (final lang in SupportedLanguage.values) {
        expect(lang.code.length, 2);
      }
    });
  });
}
