import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bockaire/features/settings/ui/widgets/currency_selection_modal.dart';
import 'package:bockaire/classes/supported_currency.dart';
import 'package:bockaire/l10n/app_localizations.dart';
import 'package:bockaire/providers/currency_provider.dart';
import 'package:bockaire/repositories/currency_repository.dart';

void main() {
  group('CurrencySelectionModal', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });
    group('rendering', () {
      testWidgets('displays all 3 currencies', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: CurrencySelectionModal(
                  currentCurrency: SupportedCurrency.eur,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should find 3 currency items
        expect(find.byType(ListTile), findsNWidgets(3));
      });

      testWidgets('displays currency symbols', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: CurrencySelectionModal(
                  currentCurrency: SupportedCurrency.eur,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('€'), findsOneWidget);
        expect(find.textContaining('\$'), findsOneWidget);
        expect(find.textContaining('£'), findsOneWidget);
      });

      testWidgets('displays currency codes', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: CurrencySelectionModal(
                  currentCurrency: SupportedCurrency.eur,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('EUR'), findsOneWidget);
        expect(find.textContaining('USD'), findsOneWidget);
        expect(find.textContaining('GBP'), findsOneWidget);
      });

      testWidgets('displays localized names in English', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('en'),
              home: Scaffold(
                body: CurrencySelectionModal(
                  currentCurrency: SupportedCurrency.eur,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Euro'), findsOneWidget);
        expect(find.text('US Dollar'), findsOneWidget);
        expect(find.text('British Pound'), findsOneWidget);
      });

      testWidgets('shows title', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: CurrencySelectionModal(
                  currentCurrency: SupportedCurrency.eur,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Currency'), findsOneWidget);
      });
    });

    group('selection behavior', () {
      testWidgets('highlights current currency', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: CurrencySelectionModal(
                  currentCurrency: SupportedCurrency.usd,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find the ListTile for USD
        final usdTile = find.ancestor(
          of: find.text('US Dollar'),
          matching: find.byType(ListTile),
        );

        final listTile = tester.widget<ListTile>(usdTile);
        expect(listTile.selected, true);
      });

      testWidgets('shows checkmark on selected currency', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: CurrencySelectionModal(
                  currentCurrency: SupportedCurrency.gbp,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should find exactly one checkmark icon
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('tapping currency pops with selection', (tester) async {
        SupportedCurrency? selectedCurrency;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () async {
                        selectedCurrency =
                            await showModalBottomSheet<SupportedCurrency>(
                              context: context,
                              builder: (context) => CurrencySelectionModal(
                                currentCurrency: SupportedCurrency.eur,
                              ),
                            );
                      },
                      child: const Text('Open'),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        // Open modal
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Tap USD
        await tester.tap(find.text('US Dollar'));
        await tester.pumpAndSettle();

        expect(selectedCurrency, SupportedCurrency.usd);
      });

      testWidgets('can select different currency', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: CurrencySelectionModal(
                  currentCurrency: SupportedCurrency.eur,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // All currencies should be tappable
        expect(find.text('Euro'), findsOneWidget);
        expect(find.text('US Dollar'), findsOneWidget);
        expect(find.text('British Pound'), findsOneWidget);
      });

      testWidgets('visual selection state is correct', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: CurrencySelectionModal(
                  currentCurrency: SupportedCurrency.eur,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find EUR tile
        final eurTile = find.ancestor(
          of: find.text('Euro'),
          matching: find.byType(ListTile),
        );

        // EUR should be selected
        final eurListTile = tester.widget<ListTile>(eurTile);
        expect(eurListTile.selected, true);

        // Find USD tile
        final usdTile = find.ancestor(
          of: find.text('US Dollar'),
          matching: find.byType(ListTile),
        );

        // USD should not be selected
        final usdListTile = tester.widget<ListTile>(usdTile);
        expect(usdListTile.selected, false);
      });
    });

    group('localization', () {
      testWidgets('shows German names in German locale', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('de'),
              home: Scaffold(
                body: CurrencySelectionModal(
                  currentCurrency: SupportedCurrency.eur,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Euro'), findsOneWidget);
        expect(find.text('US-Dollar'), findsOneWidget);
        expect(find.text('Britisches Pfund'), findsOneWidget);
        expect(find.text('Währung'), findsOneWidget); // Title in German
      });

      testWidgets('shows Chinese names in Chinese locale', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('zh'),
              home: Scaffold(
                body: CurrencySelectionModal(
                  currentCurrency: SupportedCurrency.eur,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('欧元'), findsOneWidget);
        expect(find.text('美元'), findsOneWidget);
        expect(find.text('英镑'), findsOneWidget);
        expect(find.text('货币'), findsOneWidget); // Title in Chinese
      });
    });

    group('layout', () {
      testWidgets('uses Column layout', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: CurrencySelectionModal(
                  currentCurrency: SupportedCurrency.eur,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(Column), findsWidgets);
      });

      testWidgets('has divider after title', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: CurrencySelectionModal(
                  currentCurrency: SupportedCurrency.eur,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(Divider), findsOneWidget);
      });

      testWidgets('proper padding and spacing', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: CurrencySelectionModal(
                  currentCurrency: SupportedCurrency.eur,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(Container), findsWidgets);
        expect(find.byType(Padding), findsWidgets);
      });

      testWidgets('uses mainAxisSize.min for Column', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: CurrencySelectionModal(
                  currentCurrency: SupportedCurrency.eur,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final column = tester.widget<Column>(
          find.descendant(
            of: find.byType(Container),
            matching: find.byType(Column),
          ),
        );

        expect(column.mainAxisSize, MainAxisSize.min);
      });
    });

    group('edge cases', () {
      testWidgets('handles all currencies as current', (tester) async {
        for (final currency in SupportedCurrency.values) {
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                currencyRepositoryProvider.overrideWithValue(
                  CurrencyRepository(prefs),
                ),
              ],
              child: MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(
                  body: CurrencySelectionModal(currentCurrency: currency),
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Should show exactly one checkmark
          expect(find.byIcon(Icons.check_circle), findsOneWidget);
        }
      });

      testWidgets('renders correctly in bottom sheet', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => CurrencySelectionModal(
                            currentCurrency: SupportedCurrency.eur,
                          ),
                        );
                      },
                      child: const Text('Open'),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.byType(CurrencySelectionModal), findsOneWidget);
        expect(find.byType(ListTile), findsNWidgets(3));
      });
    });
  });
}
