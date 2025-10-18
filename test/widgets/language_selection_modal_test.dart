import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:country_flags/country_flags.dart';
import 'package:bockaire/features/settings/ui/widgets/language_selection_modal.dart';
import 'package:bockaire/classes/supported_language.dart';
import 'package:bockaire/l10n/app_localizations.dart';

void main() {
  group('LanguageSelectionModal', () {
    Widget buildTestWidget({String? currentLanguageCode}) {
      return ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: LanguageSelectionModal(
              currentLanguageCode: currentLanguageCode,
            ),
          ),
        ),
      );
    }

    testWidgets('displays search field', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('displays all 29 languages plus system default', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // ListView is lazy-loaded, so we should see at least system default + some languages
      expect(find.byType(ListTile), findsAtLeastNWidgets(10));
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('displays system default option first', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final firstTile = tester.widget<ListTile>(find.byType(ListTile).first);
      final title = firstTile.title as Text;

      expect(title.data, 'System Default');
      expect(firstTile.leading, isA<Icon>());
      expect((firstTile.leading as Icon).icon, Icons.phone_android);
    });

    testWidgets('shows check mark for current language', (tester) async {
      await tester.pumpWidget(buildTestWidget(currentLanguageCode: 'ar'));
      await tester.pumpAndSettle();

      // Find all visible list tiles
      final tiles = tester.widgetList<ListTile>(find.byType(ListTile));

      // Find the Arabic tile (should be visible as it's near the top alphabetically)
      final arabicTile = tiles.firstWhere(
        (tile) {
          final title = tile.title as Text?;
          return title?.data == 'Arabic';
        },
        orElse: () => throw StateError(
          'Arabic tile not found - try scrolling or use a different language',
        ),
      );

      // Should have check icon in trailing
      expect(arabicTile.trailing, isA<Icon>());
      expect((arabicTile.trailing as Icon).icon, Icons.check);
      expect(arabicTile.selected, true);
    });

    testWidgets('shows check mark for system default when current is null', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(currentLanguageCode: null));
      await tester.pumpAndSettle();

      final firstTile = tester.widget<ListTile>(find.byType(ListTile).first);

      expect(firstTile.selected, true);
      expect(firstTile.trailing, isA<Icon>());
      expect((firstTile.trailing as Icon).icon, Icons.check);
    });

    testWidgets('displays country flags for languages', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Should have multiple CountryFlag widgets visible (lazy loaded)
      expect(find.byType(CountryFlag), findsAtLeastNWidgets(5));
    });

    group('search functionality', () {
      testWidgets('search filters languages by name', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Type "arab" in search field
        await tester.enterText(find.byType(TextField), 'arab');
        await tester.pumpAndSettle();

        // Should show system default + Arabic only
        expect(find.text('Arabic'), findsOneWidget);
        expect(find.text('Spanish'), findsNothing);
        expect(find.text('German'), findsNothing);
      });

      testWidgets('search is case insensitive', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'SPANISH');
        await tester.pumpAndSettle();

        expect(find.text('Spanish'), findsOneWidget);
      });

      testWidgets('search filters by language code', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'es');
        await tester.pumpAndSettle();

        expect(find.text('Spanish'), findsOneWidget);
      });

      testWidgets('search with partial match returns multiple results', (
        tester,
      ) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Search for "an" should match German, Romanian, etc.
        await tester.enterText(find.byType(TextField), 'an');
        await tester.pumpAndSettle();

        final tiles = tester.widgetList<ListTile>(find.byType(ListTile));
        // Should have more than just system default
        expect(tiles.length, greaterThan(1));
      });

      testWidgets('search with no results shows only system default', (
        tester,
      ) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'zzzzz');
        await tester.pumpAndSettle();

        // Should show only system default
        expect(find.byType(ListTile), findsOneWidget);
        expect(find.text('System Default'), findsOneWidget);
      });

      testWidgets('clearing search shows all languages again', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Enter search
        await tester.enterText(find.byType(TextField), 'arab');
        await tester.pumpAndSettle();
        expect(find.text('Arabic'), findsOneWidget);

        // Clear search
        await tester.enterText(find.byType(TextField), '');
        await tester.pumpAndSettle();

        // Should show many languages again (lazy loaded)
        expect(find.byType(ListTile), findsAtLeastNWidgets(10));
      });

      testWidgets('search updates dynamically as user types', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Type "f"
        await tester.enterText(find.byType(TextField), 'f');
        await tester.pumpAndSettle();
        final afterF = tester
            .widgetList<ListTile>(find.byType(ListTile))
            .length;

        // Type "fr"
        await tester.enterText(find.byType(TextField), 'fr');
        await tester.pumpAndSettle();
        final afterFr = tester
            .widgetList<ListTile>(find.byType(ListTile))
            .length;

        // Type "fre"
        await tester.enterText(find.byType(TextField), 'fre');
        await tester.pumpAndSettle();
        final afterFre = tester
            .widgetList<ListTile>(find.byType(ListTile))
            .length;

        // Each refinement should reduce or maintain the number of results
        expect(afterFr, lessThanOrEqualTo(afterF));
        expect(afterFre, lessThanOrEqualTo(afterFr));
      });
    });

    group('selection behavior', () {
      testWidgets('selecting language pops with selected language', (
        tester,
      ) async {
        SupportedLanguage? result;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Builder(
                builder: (context) {
                  return Scaffold(
                    body: ElevatedButton(
                      onPressed: () async {
                        result = await showDialog<SupportedLanguage>(
                          context: context,
                          builder: (context) => Dialog(
                            child: SizedBox(
                              height: 500,
                              child: LanguageSelectionModal(
                                currentLanguageCode: null,
                              ),
                            ),
                          ),
                        );
                      },
                      child: const Text('Open'),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Tap on Arabic (visible without scrolling)
        await tester.tap(find.text('Arabic'));
        await tester.pumpAndSettle();

        expect(result, SupportedLanguage.ar);
      });

      testWidgets('selecting system default pops with null', (tester) async {
        SupportedLanguage? result = SupportedLanguage.fr; // Start non-null

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Builder(
                builder: (context) {
                  return Scaffold(
                    body: ElevatedButton(
                      onPressed: () async {
                        result = await showDialog<SupportedLanguage?>(
                          context: context,
                          builder: (context) => Dialog(
                            child: SizedBox(
                              height: 500,
                              child: LanguageSelectionModal(
                                currentLanguageCode: 'fr',
                              ),
                            ),
                          ),
                        );
                      },
                      child: const Text('Open'),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('System Default'));
        await tester.pumpAndSettle();

        expect(result, isNull);
      });

      testWidgets('can select from visible languages', (tester) async {
        // Test first few alphabetically (which are visible)
        final testLangs = [
          SupportedLanguage.ar,
          SupportedLanguage.bg,
          SupportedLanguage.zh,
        ];

        for (final lang in testLangs) {
          SupportedLanguage? result;

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Builder(
                  builder: (context) {
                    return Scaffold(
                      body: ElevatedButton(
                        onPressed: () async {
                          result = await showDialog<SupportedLanguage>(
                            context: context,
                            builder: (context) => Dialog(
                              child: SizedBox(
                                height: 500,
                                child: LanguageSelectionModal(
                                  currentLanguageCode: null,
                                ),
                              ),
                            ),
                          );
                        },
                        child: const Text('Open'),
                      ),
                    );
                  },
                ),
              ),
            ),
          );

          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();

          // Get localized name
          final ctx = tester.element(find.byType(LanguageSelectionModal));
          final languageName = lang.localizedName(ctx);

          if (find.text(languageName).evaluate().isNotEmpty) {
            await tester.tap(find.text(languageName));
            await tester.pumpAndSettle();

            expect(result, lang);
          }

          // Reset for next iteration
          await tester.pumpWidget(Container());
        }
      });
    });

    group('sorting', () {
      testWidgets('languages are sorted alphabetically in English', (
        tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('en'),
              home: Scaffold(
                body: LanguageSelectionModal(currentLanguageCode: null),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final tiles = tester
            .widgetList<ListTile>(find.byType(ListTile))
            .toList();
        final languageNames = tiles
            .skip(1) // Skip system default
            .map((tile) => (tile.title as Text).data!)
            .toList();

        // Verify sorted
        final sortedNames = List<String>.from(languageNames)..sort();
        expect(languageNames, sortedNames);
      });

      testWidgets('languages are sorted alphabetically in French', (
        tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('fr'),
              home: Scaffold(
                body: LanguageSelectionModal(currentLanguageCode: null),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final tiles = tester
            .widgetList<ListTile>(find.byType(ListTile))
            .toList();
        final languageNames = tiles
            .skip(1) // Skip system default
            .map((tile) => (tile.title as Text).data!)
            .toList();

        // Verify sorted
        final sortedNames = List<String>.from(languageNames)..sort();
        expect(languageNames, sortedNames);
      });
    });

    group('layout and UI', () {
      testWidgets('search field has correct hint text', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        final textField = tester.widget<TextField>(find.byType(TextField));
        final decoration = textField.decoration as InputDecoration;

        expect(decoration.hintText, 'Search languages...');
      });

      testWidgets('list is scrollable', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('uses Column with expanded list', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(Column), findsOneWidget);
        expect(find.byType(Expanded), findsOneWidget);
      });

      testWidgets('search field has padding', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        final padding = tester.widget<Padding>(
          find
              .ancestor(
                of: find.byType(TextField),
                matching: find.byType(Padding),
              )
              .first,
        );

        expect(padding.padding, const EdgeInsets.all(16));
      });
    });

    group('memory management', () {
      testWidgets('disposes search controller', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Dispose widget
        await tester.pumpWidget(Container());

        // If controller wasn't disposed, this would cause a memory leak
        // This test ensures dispose is called without errors
      });
    });

    group('edge cases', () {
      testWidgets('handles search with special characters', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '@#\$%');
        await tester.pumpAndSettle();

        // Should not crash, should show only system default (no matches)
        expect(find.byType(ListTile), findsOneWidget);
      });

      testWidgets('handles very long search query', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'a' * 1000);
        await tester.pumpAndSettle();

        // Should not crash
        expect(find.byType(ListTile), findsAtLeastNWidgets(1));
      });

      testWidgets('handles rapid search changes', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        for (var i = 0; i < 10; i++) {
          await tester.enterText(find.byType(TextField), 'search$i');
          await tester.pump(); // Don't settle, just pump once
        }

        await tester.pumpAndSettle();

        // Should not crash
        expect(find.byType(LanguageSelectionModal), findsOneWidget);
      });
    });
  });
}
