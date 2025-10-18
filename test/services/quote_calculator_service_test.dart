import 'package:flutter_test/flutter_test.dart';
import 'package:bockaire/services/quote_calculator_service.dart';
import 'package:bockaire/classes/rate_table.dart';

void main() {
  group('QuoteCalculatorService', () {
    late RateTable testRate;

    setUp(() {
      testRate = const RateTable(
        id: 'test-1',
        carrier: 'DHL',
        service: 'Express',
        baseFee: 50.0,
        perKgLow: 2.5,
        perKgHigh: 2.0,
        breakpointKg: 100.0,
        fuelPct: 0.15, // 15% fuel surcharge
        oversizeFee: 25.0,
        etaMin: 3,
        etaMax: 5,
        notes: 'Test rate',
      );
    });

    group('calculateQuote', () {
      test('uses perKgLow when weight is below breakpoint', () {
        final quote = QuoteCalculatorService.calculateQuote(
          rate: testRate,
          chargeableKg: 50.0, // Below 100kg breakpoint
          isOversized: false,
        );

        // Expected: base + (perKgLow × weight) = 50 + (2.5 × 50) = 175
        // With fuel: 175 × 1.15 = 201.25
        expect(quote.subtotal, closeTo(175.0, 0.01));
        expect(quote.fuelSurcharge, closeTo(26.25, 0.01)); // 175 × 0.15
        expect(quote.oversizeFee, 0.0);
        expect(quote.total, closeTo(201.25, 0.01));
        expect(quote.chargeableKg, 50.0);
      });

      test('uses perKgHigh when weight equals breakpoint', () {
        final quote = QuoteCalculatorService.calculateQuote(
          rate: testRate,
          chargeableKg: 100.0, // Exactly at breakpoint
          isOversized: false,
        );

        // Expected: base + (perKgHigh × weight) = 50 + (2.0 × 100) = 250
        // With fuel: 250 × 1.15 = 287.5
        expect(quote.subtotal, closeTo(250.0, 0.01));
        expect(quote.fuelSurcharge, closeTo(37.5, 0.01)); // 250 × 0.15
        expect(quote.oversizeFee, 0.0);
        expect(quote.total, closeTo(287.5, 0.01));
      });

      test('uses perKgHigh when weight is above breakpoint', () {
        final quote = QuoteCalculatorService.calculateQuote(
          rate: testRate,
          chargeableKg: 150.0, // Above 100kg breakpoint
          isOversized: false,
        );

        // Expected: base + (perKgHigh × weight) = 50 + (2.0 × 150) = 350
        // With fuel: 350 × 1.15 = 402.5
        expect(quote.subtotal, closeTo(350.0, 0.01));
        expect(quote.fuelSurcharge, closeTo(52.5, 0.01)); // 350 × 0.15
        expect(quote.oversizeFee, 0.0);
        expect(quote.total, closeTo(402.5, 0.01));
      });

      test('applies fuel surcharge correctly', () {
        final quote = QuoteCalculatorService.calculateQuote(
          rate: testRate,
          chargeableKg: 40.0,
          isOversized: false,
        );

        // Subtotal: 50 + (2.5 × 40) = 150
        // Fuel: 150 × 0.15 = 22.5
        expect(quote.subtotal, closeTo(150.0, 0.01));
        expect(quote.fuelSurcharge, closeTo(22.5, 0.01));
        expect(quote.total, closeTo(172.5, 0.01));
      });

      test('adds oversize fee when shipment is oversized', () {
        final quote = QuoteCalculatorService.calculateQuote(
          rate: testRate,
          chargeableKg: 50.0,
          isOversized: true, // Oversized
        );

        // Subtotal: 50 + (2.5 × 50) = 175
        // With fuel: 175 × 1.15 = 201.25
        // With oversize: 201.25 + 25 = 226.25
        expect(quote.subtotal, closeTo(175.0, 0.01));
        expect(quote.fuelSurcharge, closeTo(26.25, 0.01));
        expect(quote.oversizeFee, 25.0);
        expect(quote.total, closeTo(226.25, 0.01));
      });

      test('does not add oversize fee when shipment is not oversized', () {
        final quote = QuoteCalculatorService.calculateQuote(
          rate: testRate,
          chargeableKg: 50.0,
          isOversized: false, // Not oversized
        );

        expect(quote.oversizeFee, 0.0);
        expect(quote.total, closeTo(201.25, 0.01)); // No oversize fee added
      });

      test('calculates subtotal correctly with base fee', () {
        final quote = QuoteCalculatorService.calculateQuote(
          rate: testRate,
          chargeableKg: 20.0,
          isOversized: false,
        );

        // Subtotal = baseFee + (perKgLow × chargeableKg)
        // = 50 + (2.5 × 20) = 100
        expect(quote.subtotal, closeTo(100.0, 0.01));
      });

      test('includes carrier and service information', () {
        final quote = QuoteCalculatorService.calculateQuote(
          rate: testRate,
          chargeableKg: 50.0,
          isOversized: false,
        );

        expect(quote.carrier, 'DHL');
        expect(quote.service, 'Express');
        expect(quote.displayName, 'DHL Express');
      });

      test('preserves notes from rate table', () {
        final quote = QuoteCalculatorService.calculateQuote(
          rate: testRate,
          chargeableKg: 50.0,
          isOversized: false,
        );

        expect(quote.notes, 'Test rate');
      });

      test('handles zero weight edge case', () {
        final quote = QuoteCalculatorService.calculateQuote(
          rate: testRate,
          chargeableKg: 0.0,
          isOversized: false,
        );

        // Subtotal: 50 + (2.5 × 0) = 50
        // With fuel: 50 × 1.15 = 57.5
        expect(quote.subtotal, closeTo(50.0, 0.01));
        expect(quote.total, closeTo(57.5, 0.01));
      });

      test('handles very high weight', () {
        final quote = QuoteCalculatorService.calculateQuote(
          rate: testRate,
          chargeableKg: 1000.0, // Very high weight
          isOversized: true,
        );

        // Subtotal: 50 + (2.0 × 1000) = 2050
        // With fuel: 2050 × 1.15 = 2357.5
        // With oversize: 2357.5 + 25 = 2382.5
        expect(quote.subtotal, closeTo(2050.0, 0.01));
        expect(quote.total, closeTo(2382.5, 0.01));
      });

      test('handles zero fuel surcharge', () {
        final noFuelRate = RateTable(
          id: 'test-2',
          carrier: 'UPS',
          service: 'Ground',
          baseFee: 30.0,
          perKgLow: 1.5,
          perKgHigh: 1.0,
          breakpointKg: 50.0,
          fuelPct: 0.0, // No fuel surcharge
          oversizeFee: 20.0,
          etaMin: 5,
          etaMax: 7,
          notes: null,
        );

        final quote = QuoteCalculatorService.calculateQuote(
          rate: noFuelRate,
          chargeableKg: 40.0,
          isOversized: false,
        );

        // Subtotal: 30 + (1.5 × 40) = 90
        // Fuel: 90 × 0.0 = 0
        expect(quote.subtotal, closeTo(90.0, 0.01));
        expect(quote.fuelSurcharge, 0.0);
        expect(quote.total, closeTo(90.0, 0.01));
      });
    });

    group('getBestOptions', () {
      test('returns null badges for empty list', () {
        final badges = QuoteCalculatorService.getBestOptions([]);

        expect(badges.cheapest, isNull);
        expect(badges.fastest, isNull);
        expect(badges.bestValue, isNull);
      });

      test('identifies cheapest quote from multiple options', () {
        final quotes = [
          const ShippingQuote(
            carrier: 'DHL',
            service: 'Express',
            subtotal: 200.0,
            fuelSurcharge: 30.0,
            oversizeFee: 0.0,
            total: 230.0,
            chargeableKg: 50.0,
            notes: null,
          ),
          const ShippingQuote(
            carrier: 'FedEx',
            service: 'Priority',
            subtotal: 180.0,
            fuelSurcharge: 27.0,
            oversizeFee: 0.0,
            total: 207.0, // Cheapest
            chargeableKg: 50.0,
            notes: null,
          ),
          const ShippingQuote(
            carrier: 'UPS',
            service: 'Ground',
            subtotal: 190.0,
            fuelSurcharge: 28.5,
            oversizeFee: 0.0,
            total: 218.5,
            chargeableKg: 50.0,
            notes: null,
          ),
        ];

        final badges = QuoteCalculatorService.getBestOptions(quotes);

        expect(badges.cheapest, isNotNull);
        expect(badges.cheapest!.carrier, 'FedEx');
        expect(badges.cheapest!.service, 'Priority');
        expect(badges.cheapest!.total, 207.0);
      });

      test('handles single quote', () {
        final quotes = [
          const ShippingQuote(
            carrier: 'DHL',
            service: 'Express',
            subtotal: 200.0,
            fuelSurcharge: 30.0,
            oversizeFee: 0.0,
            total: 230.0,
            chargeableKg: 50.0,
            notes: null,
          ),
        ];

        final badges = QuoteCalculatorService.getBestOptions(quotes);

        expect(badges.cheapest, isNotNull);
        expect(badges.cheapest!.carrier, 'DHL');
        expect(badges.bestValue, isNotNull);
        expect(badges.bestValue!.carrier, 'DHL');
      });

      test('handles tie in prices (either is acceptable)', () {
        final quotes = [
          const ShippingQuote(
            carrier: 'DHL',
            service: 'Express',
            subtotal: 200.0,
            fuelSurcharge: 30.0,
            oversizeFee: 0.0,
            total: 230.0, // Same price
            chargeableKg: 50.0,
            notes: null,
          ),
          const ShippingQuote(
            carrier: 'FedEx',
            service: 'Priority',
            subtotal: 200.0,
            fuelSurcharge: 30.0,
            oversizeFee: 0.0,
            total: 230.0, // Same price
            chargeableKg: 50.0,
            notes: null,
          ),
        ];

        final badges = QuoteCalculatorService.getBestOptions(quotes);

        // When there's a tie, either is acceptable
        expect(badges.cheapest!.total, 230.0);
        expect(badges.cheapest!.carrier, anyOf('DHL', 'FedEx'));
      });

      test('returns cheapest as bestValue when no ETA data', () {
        final quotes = [
          const ShippingQuote(
            carrier: 'DHL',
            service: 'Express',
            subtotal: 200.0,
            fuelSurcharge: 30.0,
            oversizeFee: 0.0,
            total: 230.0,
            chargeableKg: 50.0,
            notes: null,
          ),
          const ShippingQuote(
            carrier: 'FedEx',
            service: 'Priority',
            subtotal: 180.0,
            fuelSurcharge: 27.0,
            oversizeFee: 0.0,
            total: 207.0, // Cheapest
            chargeableKg: 50.0,
            notes: null,
          ),
        ];

        final badges = QuoteCalculatorService.getBestOptions(quotes);

        // Since we don't have ETA data, bestValue should be same as cheapest
        expect(badges.bestValue, isNotNull);
        expect(badges.bestValue!.carrier, badges.cheapest!.carrier);
        expect(badges.bestValue!.total, badges.cheapest!.total);
      });

      test('fastest is currently null (not implemented)', () {
        final quotes = [
          const ShippingQuote(
            carrier: 'DHL',
            service: 'Express',
            subtotal: 200.0,
            fuelSurcharge: 30.0,
            oversizeFee: 0.0,
            total: 230.0,
            chargeableKg: 50.0,
            notes: null,
          ),
        ];

        final badges = QuoteCalculatorService.getBestOptions(quotes);

        // Fastest is not yet implemented
        expect(badges.fastest, isNull);
      });
    });

    group('QuoteBadges', () {
      late ShippingQuote quote1;
      late ShippingQuote quote2;
      late QuoteBadges badges;

      setUp(() {
        quote1 = const ShippingQuote(
          carrier: 'DHL',
          service: 'Express',
          subtotal: 200.0,
          fuelSurcharge: 30.0,
          oversizeFee: 0.0,
          total: 230.0,
          chargeableKg: 50.0,
          notes: null,
        );

        quote2 = const ShippingQuote(
          carrier: 'FedEx',
          service: 'Priority',
          subtotal: 180.0,
          fuelSurcharge: 27.0,
          oversizeFee: 0.0,
          total: 207.0,
          chargeableKg: 50.0,
          notes: null,
        );

        badges = QuoteBadges(
          cheapest: quote2,
          fastest: null,
          bestValue: quote2,
        );
      });

      test('isCheapest returns true for matching quote', () {
        expect(badges.isCheapest(quote2), isTrue);
      });

      test('isCheapest returns false for non-matching quote', () {
        expect(badges.isCheapest(quote1), isFalse);
      });

      test('isCheapest returns false when cheapest is null', () {
        final emptyBadges = const QuoteBadges(
          cheapest: null,
          fastest: null,
          bestValue: null,
        );

        expect(emptyBadges.isCheapest(quote1), isFalse);
      });

      test('isFastest returns false when fastest is null', () {
        expect(badges.isFastest(quote1), isFalse);
        expect(badges.isFastest(quote2), isFalse);
      });

      test('isBestValue returns true for matching quote', () {
        expect(badges.isBestValue(quote2), isTrue);
      });

      test('isBestValue returns false for non-matching quote', () {
        expect(badges.isBestValue(quote1), isFalse);
      });
    });

    group('ShippingQuote', () {
      test('displayName combines carrier and service', () {
        const quote = ShippingQuote(
          carrier: 'DHL',
          service: 'Express',
          subtotal: 200.0,
          fuelSurcharge: 30.0,
          oversizeFee: 0.0,
          total: 230.0,
          chargeableKg: 50.0,
          notes: null,
        );

        expect(quote.displayName, 'DHL Express');
      });

      test('toString formats quote information', () {
        const quote = ShippingQuote(
          carrier: 'DHL',
          service: 'Express',
          subtotal: 200.0,
          fuelSurcharge: 30.0,
          oversizeFee: 0.0,
          total: 230.0,
          chargeableKg: 50.5,
          notes: null,
        );

        expect(quote.toString(), 'DHL Express: €230.00 (50.5kg)');
      });

      test('includes estimatedDays when provided', () {
        const quote = ShippingQuote(
          carrier: 'UPS',
          service: 'Express Saver',
          subtotal: 200.0,
          fuelSurcharge: 30.0,
          oversizeFee: 0.0,
          total: 230.0,
          chargeableKg: 50.0,
          notes: 'Test quote',
          estimatedDays: 3,
        );

        expect(quote.estimatedDays, 3);
      });

      test('includes durationTerms when provided', () {
        const quote = ShippingQuote(
          carrier: 'FedEx',
          service: 'Priority',
          subtotal: 200.0,
          fuelSurcharge: 30.0,
          oversizeFee: 0.0,
          total: 230.0,
          chargeableKg: 50.0,
          notes: 'Test quote',
          durationTerms: '2-3 business days',
        );

        expect(quote.durationTerms, '2-3 business days');
      });

      test('handles both estimatedDays and durationTerms', () {
        const quote = ShippingQuote(
          carrier: 'DHL',
          service: 'Express Worldwide',
          subtotal: 250.0,
          fuelSurcharge: 35.0,
          oversizeFee: 0.0,
          total: 285.0,
          chargeableKg: 60.0,
          notes: 'Express service',
          estimatedDays: 2,
          durationTerms: '1-3 business days',
        );

        expect(quote.estimatedDays, 2);
        expect(quote.durationTerms, '1-3 business days');
      });

      test('estimatedDays and durationTerms can be null', () {
        const quote = ShippingQuote(
          carrier: 'Carrier',
          service: 'Standard',
          subtotal: 150.0,
          fuelSurcharge: 20.0,
          oversizeFee: 0.0,
          total: 170.0,
          chargeableKg: 40.0,
          notes: null,
        );

        expect(quote.estimatedDays, null);
        expect(quote.durationTerms, null);
      });

      test('supports zero estimatedDays', () {
        const quote = ShippingQuote(
          carrier: 'Same Day',
          service: 'Instant',
          subtotal: 500.0,
          fuelSurcharge: 50.0,
          oversizeFee: 0.0,
          total: 550.0,
          chargeableKg: 5.0,
          notes: 'Same day delivery',
          estimatedDays: 0,
        );

        expect(quote.estimatedDays, 0);
      });

      test('supports high estimatedDays for sea freight', () {
        const quote = ShippingQuote(
          carrier: 'Maersk',
          service: 'Sea Freight LCL',
          subtotal: 100.0,
          fuelSurcharge: 10.0,
          oversizeFee: 0.0,
          total: 110.0,
          chargeableKg: 200.0,
          notes: 'Ocean freight',
          estimatedDays: 35,
          durationTerms: '30-40 days',
        );

        expect(quote.estimatedDays, 35);
        expect(quote.durationTerms, '30-40 days');
      });
    });
  });
}
