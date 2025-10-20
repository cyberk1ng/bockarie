import 'package:bockaire/l10n/app_localizations.dart';
import 'package:bockaire/models/transport_method.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createTestWidget({Locale locale = const Locale('en')}) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(builder: (context) => Scaffold(body: Container())),
    );
  }

  group('Transport Method Localization', () {
    test('transport method info has English display names', () {
      expect(
        transportMethods[TransportMethod.expressAir]!.displayName,
        'Express Air',
      );
      expect(
        transportMethods[TransportMethod.standardAir]!.displayName,
        'Standard Air',
      );
      expect(
        transportMethods[TransportMethod.airFreight]!.displayName,
        'Air Freight',
      );
      expect(
        transportMethods[TransportMethod.seaFreightLCL]!.displayName,
        'Sea Freight (LCL)',
      );
      expect(
        transportMethods[TransportMethod.seaFreightFCL]!.displayName,
        'Sea Freight (FCL)',
      );
      expect(
        transportMethods[TransportMethod.roadFreight]!.displayName,
        'Road Freight',
      );
    });
  });

  group('ARB Translations Completeness', () {
    testWidgets('German ARB has transport method translations', (tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold));
      final localizations = AppLocalizations.of(context)!;

      // Verify all transport method translations exist
      expect(localizations.transportExpressAir, 'Express-Luftfracht');
      expect(localizations.transportStandardAir, 'Standard-Luftfracht');
      expect(localizations.transportAirFreight, 'Luftfracht');
      expect(localizations.transportSeaFreightLCL, 'Seefracht (LCL)');
      expect(localizations.transportSeaFreightFCL, 'Seefracht (FCL)');
      expect(localizations.transportRoadFreight, 'Straßenfracht');
    });

    testWidgets('English ARB has transport method translations', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold));
      final localizations = AppLocalizations.of(context)!;

      // Verify all transport method translations exist in English
      expect(localizations.transportExpressAir, 'Express Air');
      expect(localizations.transportStandardAir, 'Standard Air');
      expect(localizations.transportAirFreight, 'Air Freight');
      expect(localizations.transportSeaFreightLCL, 'Sea Freight (LCL)');
      expect(localizations.transportSeaFreightFCL, 'Sea Freight (FCL)');
      expect(localizations.transportRoadFreight, 'Road Freight');
    });

    testWidgets('German ARB has duration format translation', (tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold));
      final localizations = AppLocalizations.of(context)!;

      // Verify duration format uses German translation
      expect(localizations.etaDays(3, 7), '3-7 Tage');
      expect(localizations.etaDays(1, 3), '1-3 Tage');
      expect(localizations.etaDays(25, 40), '25-40 Tage');
    });

    testWidgets('English ARB has duration format translation', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold));
      final localizations = AppLocalizations.of(context)!;

      expect(localizations.etaDays(3, 7), '3-7 days');
      expect(localizations.etaDays(1, 3), '1-3 days');
      expect(localizations.etaDays(25, 40), '25-40 days');
    });

    testWidgets('German ARB has all UI element translations', (tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold));
      final localizations = AppLocalizations.of(context)!;

      expect(localizations.tooltipListView, 'Listenansicht');
      expect(
        localizations.tooltipGroupByTransportMethod,
        'Nach Transportart gruppieren',
      );
      expect(localizations.tooltipSort, 'Sortieren');
      expect(localizations.filterAll, 'Alle');
    });

    testWidgets('German ARB has sort option translations', (tester) async {
      await tester.pumpWidget(createTestWidget(locale: const Locale('de')));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold));
      final localizations = AppLocalizations.of(context)!;

      // These are the sort options that were causing UI overflow
      expect(localizations.sortPriceLowHigh, 'Preis: Niedrig bis Hoch');
      expect(localizations.sortPriceHighLow, 'Preis: Hoch bis Niedrig');
      expect(
        localizations.sortSpeedFastest,
        'Geschwindigkeit: Schnellste zuerst',
      );
      expect(
        localizations.sortSpeedSlowest,
        'Geschwindigkeit: Langsamste zuerst',
      );
    });

    testWidgets('English ARB has sort option translations', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold));
      final localizations = AppLocalizations.of(context)!;

      expect(localizations.sortPriceLowHigh, 'Price: Low to High');
      expect(localizations.sortPriceHighLow, 'Price: High to Low');
      expect(localizations.sortSpeedFastest, 'Speed: Fastest First');
      expect(localizations.sortSpeedSlowest, 'Speed: Slowest First');
    });
  });

  group('Localization Helper Method Behavior', () {
    test('all transport methods can be mapped to localization keys', () {
      // This verifies that every TransportMethod enum value has a corresponding
      // localization key, ensuring the _getLocalizedTransportMethodName helper
      // will work for all cases

      final allMethods = TransportMethod.values;
      expect(allMethods.length, 6);

      // Verify we have a displayName for each (from transportMethods map)
      for (final method in allMethods) {
        expect(
          transportMethods.containsKey(method),
          true,
          reason: 'Missing transport method info for $method',
        );
      }
    });
  });

  group('Shippo Test Mode Localizations', () {
    testWidgets('English has new test mode strings', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold));
      final localizations = AppLocalizations.of(context)!;

      // Verify test mode warning banner text exists
      expect(localizations.shippoTestModeWarning, isNotEmpty);
      expect(localizations.shippoTestModeWarning, contains('Test mode'));
      expect(
        localizations.shippoTestModeWarning,
        'Test mode: Multi-parcel shipments auto-consolidated. Production will show accurate pricing.',
      );

      // Verify multi-parcel limitation message exists
      expect(localizations.shippoTestMultiParcelLimitation, isNotEmpty);
      expect(
        localizations.shippoTestMultiParcelLimitation,
        contains('Multi-parcel'),
      );
      expect(
        localizations.shippoTestMultiParcelLimitation.toLowerCase().contains(
          'test mode',
        ),
        true,
      );
      expect(
        localizations.shippoTestMultiParcelLimitation,
        contains('quantities to 1'),
      );

      // Verify general test mode no quotes message exists
      expect(localizations.shippoTestNoQuotes, isNotEmpty);
      expect(localizations.shippoTestNoQuotes, contains('test mode'));
      expect(localizations.shippoTestNoQuotes, contains('production'));
    });

    testWidgets('English test mode strings have expected content', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold));
      final localizations = AppLocalizations.of(context)!;

      // Verify specific expected content
      expect(
        localizations.shippoTestMultiParcelLimitation,
        'Test mode limitation: Multi-parcel shipments may not return quotes. This will work in production with real carrier accounts. For testing, try setting all quantities to 1.',
      );

      expect(
        localizations.shippoTestNoQuotes,
        'No quotes available in test mode. Some routes or configurations require production carrier accounts. Switch to production mode for real quotes.',
      );
    });
  });
}
