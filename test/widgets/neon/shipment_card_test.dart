import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:country_flags/country_flags.dart';
import 'package:bockaire/widgets/neon/shipment_card.dart';
import 'package:bockaire/widgets/neon/status_badge.dart';
import 'package:bockaire/widgets/neon/neon_button.dart';
import 'package:bockaire/widgets/neon/animated_route_line.dart';
import 'package:bockaire/themes/neon_theme.dart';
import 'package:bockaire/l10n/app_localizations.dart';

void main() {
  Widget buildTestWidget(Widget child, {Brightness? brightness}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: brightness == Brightness.light
          ? NeonTheme.lightTheme()
          : NeonTheme.darkTheme(),
      home: Scaffold(body: child),
    );
  }

  ShipmentCardData createTestData({
    String originCity = 'New York',
    String originCountry = 'US',
    String destinationCity = 'London',
    String destinationCountry = 'GB',
    double weight = 100,
    double price = 500,
    String currency = 'USD',
    ShipmentStatus status = ShipmentStatus.pending,
    Color routeColor = NeonColors.cyan,
  }) {
    return ShipmentCardData(
      originCity: originCity,
      originCountry: originCountry,
      destinationCity: destinationCity,
      destinationCountry: destinationCountry,
      weight: weight,
      price: price,
      currency: currency,
      status: status,
      routeColor: routeColor,
    );
  }

  group('ShipmentCard Basic Rendering', () {
    testWidgets('renders card with all components', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(ShipmentCard(data: createTestData())),
      );
      await tester.pump();

      expect(find.byType(ShipmentCard), findsOneWidget);
      expect(find.byType(StatusBadge), findsOneWidget);
      expect(find.byType(RouteWithFlags), findsOneWidget);
      expect(find.byType(NeonButton), findsOneWidget);
    });

    testWidgets('displays origin and destination cities', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(
            data: createTestData(
              originCity: 'Paris',
              destinationCity: 'Berlin',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Paris -> Berlin'), findsOneWidget);
    });

    testWidgets('displays StatusBadge with correct status', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(data: createTestData(status: ShipmentStatus.delivered)),
        ),
      );
      await tester.pump();

      final statusBadge = tester.widget<StatusBadge>(find.byType(StatusBadge));
      expect(statusBadge.status, ShipmentStatus.delivered);
    });
  });

  group('ShipmentCard Currency Formatting', () {
    testWidgets('formats USD currency correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(data: createTestData(price: 1234, currency: 'USD')),
        ),
      );
      await tester.pump();

      expect(find.textContaining('\$1234'), findsOneWidget);
    });

    testWidgets('formats EUR currency correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(data: createTestData(price: 999, currency: 'EUR')),
        ),
      );
      await tester.pump();

      expect(find.textContaining('€999'), findsOneWidget);
    });

    testWidgets('formats GBP currency correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(data: createTestData(price: 750, currency: 'GBP')),
        ),
      );
      await tester.pump();

      expect(find.textContaining('£750'), findsOneWidget);
    });

    testWidgets('handles unknown currency code', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(data: createTestData(price: 500, currency: 'JPY')),
        ),
      );
      await tester.pump();

      expect(find.textContaining('JPY500'), findsOneWidget);
    });

    testWidgets('currency code is case insensitive', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(data: createTestData(price: 100, currency: 'usd')),
        ),
      );
      await tester.pump();

      expect(find.textContaining('\$100'), findsOneWidget);
    });

    testWidgets('price is displayed without decimals', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(data: createTestData(price: 123.99, currency: 'USD')),
        ),
      );
      await tester.pump();

      expect(find.textContaining('\$124'), findsOneWidget);
    });
  });

  group('ShipmentCard Weight Display', () {
    testWidgets('displays weight correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(ShipmentCard(data: createTestData(weight: 250))),
      );
      await tester.pump();

      expect(find.textContaining('250 kg'), findsOneWidget);
    });

    testWidgets('weight is displayed without decimals', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(ShipmentCard(data: createTestData(weight: 99.75))),
      );
      await tester.pump();

      expect(find.textContaining('100 kg'), findsOneWidget);
    });

    testWidgets('displays weight and price together', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(
            data: createTestData(weight: 150, price: 450, currency: 'EUR'),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('150 kg • €450'), findsOneWidget);
    });
  });

  group('ShipmentCard Conditional Button Rendering', () {
    testWidgets('shows View Quotes button for inTransit status', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(data: createTestData(status: ShipmentStatus.inTransit)),
        ),
      );
      await tester.pump();

      final context = tester.element(find.byType(ShipmentCard));
      final localizations = AppLocalizations.of(context)!;

      expect(find.text(localizations.buttonViewQuotes), findsOneWidget);
      expect(find.text(localizations.buttonOptimize), findsNothing);
    });

    testWidgets('shows Optimize button for delivered status', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(data: createTestData(status: ShipmentStatus.delivered)),
        ),
      );
      await tester.pump();

      final context = tester.element(find.byType(ShipmentCard));
      final localizations = AppLocalizations.of(context)!;

      expect(find.text(localizations.buttonOptimize), findsOneWidget);
      expect(find.text(localizations.buttonViewQuotes), findsNothing);
    });

    testWidgets('shows Optimize button for pending status', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(data: createTestData(status: ShipmentStatus.pending)),
        ),
      );
      await tester.pump();

      final context = tester.element(find.byType(ShipmentCard));
      final localizations = AppLocalizations.of(context)!;

      expect(find.text(localizations.buttonOptimize), findsOneWidget);
      expect(find.text(localizations.buttonViewQuotes), findsNothing);
    });
  });

  group('ShipmentCard Button Callbacks', () {
    testWidgets('onViewQuotes callback is triggered for inTransit status', (
      tester,
    ) async {
      var callbackTriggered = false;

      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(
            data: createTestData(status: ShipmentStatus.inTransit),
            onViewQuotes: () {
              callbackTriggered = true;
            },
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(NeonButton));
      await tester.pump();

      expect(callbackTriggered, true);
    });

    testWidgets('onOptimize callback is triggered for delivered status', (
      tester,
    ) async {
      var callbackTriggered = false;

      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(
            data: createTestData(status: ShipmentStatus.delivered),
            onOptimize: () {
              callbackTriggered = true;
            },
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(NeonButton));
      await tester.pump();

      expect(callbackTriggered, true);
    });

    testWidgets('onOptimize callback is triggered for pending status', (
      tester,
    ) async {
      var callbackTriggered = false;

      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(
            data: createTestData(status: ShipmentStatus.pending),
            onOptimize: () {
              callbackTriggered = true;
            },
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(NeonButton));
      await tester.pump();

      expect(callbackTriggered, true);
    });

    testWidgets('handles null callbacks', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(
            data: createTestData(status: ShipmentStatus.inTransit),
            onViewQuotes: null,
            onOptimize: null,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ShipmentCard), findsOneWidget);
      expect(find.byType(NeonButton), findsOneWidget);
    });
  });

  group('ShipmentCard Route Animation', () {
    testWidgets('animates route for inTransit status', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(data: createTestData(status: ShipmentStatus.inTransit)),
        ),
      );
      await tester.pump();

      final routeWithFlags = tester.widget<RouteWithFlags>(
        find.descendant(
          of: find.byType(ShipmentCard),
          matching: find.byType(RouteWithFlags),
        ),
      );
      expect(routeWithFlags.animate, true);
    });

    testWidgets('does not animate route for delivered status', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(data: createTestData(status: ShipmentStatus.delivered)),
        ),
      );
      await tester.pump();

      final routeWithFlags = tester.widget<RouteWithFlags>(
        find.descendant(
          of: find.byType(ShipmentCard),
          matching: find.byType(RouteWithFlags),
        ),
      );
      expect(routeWithFlags.animate, false);
    });

    testWidgets('does not animate route for pending status', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(data: createTestData(status: ShipmentStatus.pending)),
        ),
      );
      await tester.pump();

      final routeWithFlags = tester.widget<RouteWithFlags>(
        find.descendant(
          of: find.byType(ShipmentCard),
          matching: find.byType(RouteWithFlags),
        ),
      );
      expect(routeWithFlags.animate, false);
    });
  });

  group('ShipmentCard Country Flags', () {
    testWidgets('displays country flags', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(
            data: createTestData(originCountry: 'US', destinationCountry: 'GB'),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CountryFlag), findsNWidgets(2));
    });

    testWidgets('passes correct country codes to flags', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(
            data: createTestData(originCountry: 'FR', destinationCountry: 'DE'),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CountryFlag), findsNWidgets(2));
    });
  });

  group('ShipmentCard Route Color', () {
    testWidgets('applies route color to RouteWithFlags', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(data: createTestData(routeColor: NeonColors.purple)),
        ),
      );
      await tester.pump();

      final routeWithFlags = tester.widget<RouteWithFlags>(
        find.byType(RouteWithFlags),
      );
      expect(routeWithFlags.lineColor, NeonColors.purple);
    });

    testWidgets('applies route color to button', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(
            data: createTestData(
              routeColor: NeonColors.green,
              status: ShipmentStatus.pending,
            ),
          ),
        ),
      );
      await tester.pump();

      final button = tester.widget<NeonButton>(find.byType(NeonButton));
      expect(button.borderColor, NeonColors.green);
      expect(button.textColor, NeonColors.green);
    });
  });

  group('ShipmentCard Theme Adaptation', () {
    testWidgets('adapts to dark theme', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(data: createTestData()),
          brightness: Brightness.dark,
        ),
      );
      await tester.pump();

      expect(find.byType(ShipmentCard), findsOneWidget);
    });

    testWidgets('adapts to light theme', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(data: createTestData()),
          brightness: Brightness.light,
        ),
      );
      await tester.pump();

      expect(find.byType(ShipmentCard), findsOneWidget);
    });
  });

  group('ShipmentCard Layout', () {
    testWidgets('has correct container structure', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(ShipmentCard(data: createTestData())),
      );
      await tester.pump();

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ShipmentCard),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(decoration.boxShadow, isNotNull);
    });

    testWidgets('uses Column for layout', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(ShipmentCard(data: createTestData())),
      );
      await tester.pump();

      expect(find.byType(Column), findsAtLeastNWidgets(1));
    });

    testWidgets('has correct number of main sections', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(ShipmentCard(data: createTestData())),
      );
      await tester.pump();

      // Should have: Cities+Status row, Route, Details row
      expect(find.byType(Row), findsAtLeastNWidgets(2));
    });
  });

  group('ShipmentCard Button Variant', () {
    testWidgets('uses outline variant for buttons', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(data: createTestData(status: ShipmentStatus.inTransit)),
        ),
      );
      await tester.pump();

      final button = tester.widget<NeonButton>(
        find.descendant(
          of: find.byType(ShipmentCard),
          matching: find.byType(NeonButton),
        ),
      );
      expect(button.variant, NeonButtonVariant.outline);
    });

    testWidgets('button has correct height', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(ShipmentCard(data: createTestData())),
      );
      await tester.pump();

      final button = tester.widget<NeonButton>(
        find.descendant(
          of: find.byType(ShipmentCard),
          matching: find.byType(NeonButton),
        ),
      );
      expect(button.height, 36);
    });

    testWidgets('button has correct padding', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(ShipmentCard(data: createTestData())),
      );
      await tester.pump();

      final button = tester.widget<NeonButton>(
        find.descendant(
          of: find.byType(ShipmentCard),
          matching: find.byType(NeonButton),
        ),
      );
      expect(button.padding, EdgeInsets.symmetric(horizontal: 16, vertical: 8));
    });
  });

  group('ShipmentCard Edge Cases', () {
    testWidgets('handles zero weight', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(ShipmentCard(data: createTestData(weight: 0))),
      );
      await tester.pump();

      expect(find.textContaining('0 kg'), findsOneWidget);
    });

    testWidgets('handles zero price', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(data: createTestData(price: 0, currency: 'USD')),
        ),
      );
      await tester.pump();

      expect(find.textContaining('\$0'), findsOneWidget);
    });

    testWidgets('handles very large weight', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(ShipmentCard(data: createTestData(weight: 999999))),
      );
      await tester.pump();

      expect(find.textContaining('999999 kg'), findsOneWidget);
    });

    testWidgets('handles very large price', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(data: createTestData(price: 999999, currency: 'USD')),
        ),
      );
      await tester.pump();

      expect(find.textContaining('\$999999'), findsOneWidget);
    });

    testWidgets('handles long city names', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(
            data: createTestData(
              originCity: 'Very Long City Name Here',
              destinationCity: 'Another Very Long City Name',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ShipmentCard), findsOneWidget);
    });

    testWidgets('handles empty currency string', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ShipmentCard(data: createTestData(price: 100, currency: '')),
        ),
      );
      await tester.pump();

      expect(find.textContaining('100'), findsOneWidget);
    });
  });

  group('ShipmentCardData Model', () {
    test('creates instance with all required fields', () {
      final data = ShipmentCardData(
        originCity: 'Paris',
        originCountry: 'FR',
        destinationCity: 'Rome',
        destinationCountry: 'IT',
        weight: 150,
        price: 350,
        currency: 'EUR',
        status: ShipmentStatus.inTransit,
        routeColor: NeonColors.cyan,
      );

      expect(data.originCity, 'Paris');
      expect(data.originCountry, 'FR');
      expect(data.destinationCity, 'Rome');
      expect(data.destinationCountry, 'IT');
      expect(data.weight, 150);
      expect(data.price, 350);
      expect(data.currency, 'EUR');
      expect(data.status, ShipmentStatus.inTransit);
      expect(data.routeColor, NeonColors.cyan);
    });
  });
}
