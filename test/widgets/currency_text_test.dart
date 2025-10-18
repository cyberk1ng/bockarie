import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bockaire/widgets/currency/currency_text.dart';
import 'package:bockaire/providers/currency_provider.dart';
import 'package:bockaire/repositories/currency_repository.dart';
import 'package:bockaire/classes/supported_currency.dart';

void main() {
  group('CurrencyText', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    Widget buildTestApp(Widget child, {SharedPreferences? customPrefs}) {
      return ProviderScope(
        overrides: [
          currencyRepositoryProvider.overrideWithValue(
            CurrencyRepository(customPrefs ?? prefs),
          ),
        ],
        child: MaterialApp(home: Scaffold(body: child)),
      );
    }

    testWidgets('renders formatted EUR amount', (tester) async {
      await tester.pumpWidget(buildTestApp(CurrencyText(amountInEur: 100)));
      await tester.pumpAndSettle();
      expect(find.text('€100.00'), findsOneWidget);
    });

    testWidgets('renders formatted USD amount', (tester) async {
      SharedPreferences.setMockInitialValues({'app_currency': 'USD'});
      final usdPrefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        buildTestApp(CurrencyText(amountInEur: 100), customPrefs: usdPrefs),
      );
      await tester.pumpAndSettle();
      expect(find.text('\$108.00'), findsOneWidget);
    });

    testWidgets('renders formatted GBP amount', (tester) async {
      SharedPreferences.setMockInitialValues({'app_currency': 'GBP'});
      final gbpPrefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        buildTestApp(CurrencyText(amountInEur: 100), customPrefs: gbpPrefs),
      );
      await tester.pumpAndSettle();
      expect(find.text('£86.00'), findsOneWidget);
    });

    testWidgets('applies custom TextStyle', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          CurrencyText(
            amountInEur: 100,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(find.text('€100.00'));
      expect(textWidget.style?.fontSize, 24);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('updates when currency changes', (tester) async {
      final container = ProviderContainer(
        overrides: [
          currencyRepositoryProvider.overrideWithValue(
            CurrencyRepository(prefs),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(body: CurrencyText(amountInEur: 100)),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('€100.00'), findsOneWidget);

      // Change currency
      await container
          .read(currencyNotifierProvider.notifier)
          .setCurrency(SupportedCurrency.usd);

      await tester.pumpAndSettle();
      expect(find.text('\$108.00'), findsOneWidget);
      expect(find.text('€100.00'), findsNothing);
    });

    testWidgets('respects decimals parameter', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Column(
            children: [
              CurrencyText(amountInEur: 100, decimals: 0),
              CurrencyText(amountInEur: 100, decimals: 2),
              CurrencyText(amountInEur: 100, decimals: 3),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('€100'), findsOneWidget);
      expect(find.text('€100.00'), findsOneWidget);
      expect(find.text('€100.000'), findsOneWidget);
    });

    testWidgets('handles zero amount', (tester) async {
      await tester.pumpWidget(buildTestApp(CurrencyText(amountInEur: 0)));

      await tester.pumpAndSettle();

      expect(find.text('€0.00'), findsOneWidget);
    });

    testWidgets('handles negative amount', (tester) async {
      await tester.pumpWidget(buildTestApp(CurrencyText(amountInEur: -50)));

      await tester.pumpAndSettle();

      expect(find.text('€-50.00'), findsOneWidget);
    });

    testWidgets('handles large amount', (tester) async {
      await tester.pumpWidget(buildTestApp(CurrencyText(amountInEur: 999999)));

      await tester.pumpAndSettle();

      expect(find.text('€999999.00'), findsOneWidget);
    });

    testWidgets('rebuilds on provider update', (tester) async {
      final container = ProviderContainer(
        overrides: [
          currencyRepositoryProvider.overrideWithValue(
            CurrencyRepository(prefs),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(body: CurrencyText(amountInEur: 100)),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial EUR display
      expect(find.text('€100.00'), findsOneWidget);

      // Change currency
      await container
          .read(currencyNotifierProvider.notifier)
          .setCurrency(SupportedCurrency.gbp);

      await tester.pumpAndSettle();

      // Verify it updated to GBP
      expect(find.text('€100.00'), findsNothing);
      expect(find.text('£86.00'), findsOneWidget);
    });

    testWidgets('handles small decimal amounts', (tester) async {
      await tester.pumpWidget(buildTestApp(CurrencyText(amountInEur: 0.01)));

      await tester.pumpAndSettle();

      expect(find.text('€0.01'), findsOneWidget);
    });

    testWidgets('formats fractional amounts correctly', (tester) async {
      SharedPreferences.setMockInitialValues({'app_currency': 'USD'});
      final usdPrefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        buildTestApp(CurrencyText(amountInEur: 50.5), customPrefs: usdPrefs),
      );

      await tester.pumpAndSettle();

      // 50.5 EUR * 1.08 = 54.54 USD
      expect(find.text('\$54.54'), findsOneWidget);
    });
  });
}
