import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bockaire/database/database.dart';
import 'package:bockaire/providers/currency_provider.dart';
import 'package:bockaire/providers/shipment_providers.dart';
import 'package:bockaire/repositories/currency_repository.dart';
import 'package:bockaire/l10n/app_localizations.dart';
import 'package:bockaire/pages/quotes_page.dart';

void main() {
  group('Quote Card Expansion Animation', () {
    late Quote testQuote;
    late Shipment testShipment;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();

      testQuote = const Quote(
        id: 'quote_123',
        shipmentId: 'ship_123',
        carrier: 'DHL',
        service: 'Express',
        etaMin: 3,
        etaMax: 5,
        priceEur: 45.20,
        chargeableKg: 5.0,
        transportMethod: 'expressAir',
      );

      testShipment = Shipment(
        id: 'ship_123',
        createdAt: DateTime.now(),
        originCity: 'Shanghai',
        originPostal: '200000',
        originCountry: 'CN',
        originState: '',
        destCity: 'Berlin',
        destPostal: '10115',
        destCountry: 'DE',
        destState: '',
      );
    });

    Widget buildTestWidget(Quote quote) {
      return ProviderScope(
        overrides: [
          currencyRepositoryProvider.overrideWithValue(
            CurrencyRepository(prefs),
          ),
          // Mock quotes provider
          quotesProvider('ship_123').overrideWith((ref) {
            return Stream.value([quote]);
          }),
          // Mock shipment provider
          shipmentProvider('ship_123').overrideWith((ref) {
            return Future.value(testShipment);
          }),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            // Use QuotesPage which contains _QuoteCard
            // Since _QuoteCard is private, we test it via QuotesPage
            body: QuotesPage(shipmentId: 'ship_123'),
          ),
        ),
      );
    }

    testWidgets('wraps content with AnimatedSize widget', (tester) async {
      // Set larger viewport to avoid off-screen issues
      await tester.binding.setSurfaceSize(const Size(1200, 1600));
      // Since _QuoteCard is private, we'll test the animation behavior
      // by verifying that AnimatedSize is present in the widget tree
      await tester.pumpWidget(buildTestWidget(testQuote));
      await tester.pumpAndSettle();

      // AnimatedSize should be present in the widget tree
      expect(find.byType(AnimatedSize), findsWidgets);
    });

    testWidgets('AnimatedSize uses 300ms duration', (tester) async {
      await tester.pumpWidget(buildTestWidget(testQuote));
      await tester.pumpAndSettle();

      // Find AnimatedSize widgets
      final animatedSizes = tester.widgetList<AnimatedSize>(
        find.byType(AnimatedSize),
      );

      // At least one should have 300ms duration
      expect(
        animatedSizes.any(
          (widget) => widget.duration == const Duration(milliseconds: 300),
        ),
        true,
      );
    });

    testWidgets('AnimatedSize uses easeInOut curve', (tester) async {
      await tester.pumpWidget(buildTestWidget(testQuote));
      await tester.pumpAndSettle();

      // Find AnimatedSize widgets
      final animatedSizes = tester.widgetList<AnimatedSize>(
        find.byType(AnimatedSize),
      );

      // At least one should have easeInOut curve
      expect(
        animatedSizes.any((widget) => widget.curve == Curves.easeInOut),
        true,
      );
    });

    testWidgets('expands smoothly when Details tapped', (tester) async {
      await tester.pumpWidget(buildTestWidget(testQuote));
      await tester.pumpAndSettle();

      // Initially collapsed - details not visible
      expect(find.text('Price Breakdown'), findsNothing);

      // Find and tap Details button
      final detailsButton = find.text('Details').first;
      await tester.tap(detailsButton);
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 150)); // Mid-animation

      // Complete animation
      await tester.pumpAndSettle();

      // Now expanded - details visible
      expect(find.text('Price Breakdown'), findsWidgets);
      expect(find.text('Chargeable Weight'), findsWidgets);
    });

    testWidgets('collapses smoothly when Less tapped', (tester) async {
      // Set larger viewport to avoid off-screen issues
      await tester.binding.setSurfaceSize(const Size(1200, 1600));

      await tester.pumpWidget(buildTestWidget(testQuote));
      await tester.pumpAndSettle();

      // Expand first
      await tester.tap(find.widgetWithText(OutlinedButton, 'Details'));
      await tester.pumpAndSettle();

      // Verify expanded
      expect(find.text('Price Breakdown'), findsWidgets);

      // Now collapse
      await tester.tap(find.widgetWithText(OutlinedButton, 'Less'));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 150)); // Mid-animation

      // Complete animation
      await tester.pumpAndSettle();

      // Now collapsed
      expect(find.text('Price Breakdown'), findsNothing);
    });

    testWidgets('toggles button text between Details and Less', (tester) async {
      // Set larger viewport to avoid off-screen issues
      await tester.binding.setSurfaceSize(const Size(1200, 1600));

      await tester.pumpWidget(buildTestWidget(testQuote));
      await tester.pumpAndSettle();

      // Initially shows "Details"
      expect(find.text('Details'), findsWidgets);
      expect(find.text('Less'), findsNothing);

      // Tap to expand
      await tester.tap(find.widgetWithText(OutlinedButton, 'Details'));
      await tester.pumpAndSettle();

      // Now shows "Less"
      expect(find.text('Less'), findsWidgets);

      // Tap to collapse
      await tester.tap(find.widgetWithText(OutlinedButton, 'Less'));
      await tester.pumpAndSettle();

      // Back to "Details"
      expect(find.text('Details'), findsWidgets);
    });

    testWidgets('toggles icon between down and up arrow', (tester) async {
      await tester.pumpWidget(buildTestWidget(testQuote));
      await tester.pumpAndSettle();

      // Initially shows down arrow
      expect(find.byIcon(Icons.keyboard_arrow_down), findsWidgets);

      // Expand
      await tester.tap(find.text('Details').first);
      await tester.pumpAndSettle();

      // Now shows up arrow
      expect(find.byIcon(Icons.keyboard_arrow_up), findsWidgets);
    });

    testWidgets('shows price breakdown when expanded', (tester) async {
      await tester.pumpWidget(buildTestWidget(testQuote));
      await tester.pumpAndSettle();

      // Expand
      await tester.tap(find.text('Details').first);
      await tester.pumpAndSettle();

      // Verify breakdown details visible
      expect(find.text('Price Breakdown'), findsWidgets);
      expect(find.text('Chargeable Weight'), findsWidgets);
      expect(find.textContaining('5.0 kg'), findsWidgets);
      expect(find.text('Total Price'), findsWidgets);
    });

    testWidgets('hides price breakdown when collapsed', (tester) async {
      await tester.pumpWidget(buildTestWidget(testQuote));
      await tester.pumpAndSettle();

      // Initially collapsed
      expect(find.text('Price Breakdown'), findsNothing);
      expect(find.text('Chargeable Weight'), findsNothing);
    });

    testWidgets('maintains state through multiple expand/collapse cycles', (
      tester,
    ) async {
      // Set larger viewport to avoid off-screen issues
      await tester.binding.setSurfaceSize(const Size(1200, 1600));

      await tester.pumpWidget(buildTestWidget(testQuote));
      await tester.pumpAndSettle();

      // Cycle 1: Expand
      await tester.tap(find.widgetWithText(OutlinedButton, 'Details'));
      await tester.pumpAndSettle();
      expect(find.text('Price Breakdown'), findsWidgets);

      // Cycle 1: Collapse
      await tester.tap(find.widgetWithText(OutlinedButton, 'Less'));
      await tester.pumpAndSettle();
      expect(find.text('Price Breakdown'), findsNothing);

      // Cycle 2: Expand again
      await tester.tap(find.widgetWithText(OutlinedButton, 'Details'));
      await tester.pumpAndSettle();
      expect(find.text('Price Breakdown'), findsWidgets);

      // Cycle 2: Collapse again
      await tester.tap(find.widgetWithText(OutlinedButton, 'Less'));
      await tester.pumpAndSettle();
      expect(find.text('Price Breakdown'), findsNothing);
    });
  });
}
