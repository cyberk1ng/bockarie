import 'package:bockaire/classes/rate_table.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RateTable', () {
    group('calculateCost', () {
      late RateTable rateTable;

      setUp(() {
        rateTable = const RateTable(
          id: '1',
          carrier: 'DHL',
          service: 'Express',
          baseFee: 50.0,
          perKgLow: 5.0,
          perKgHigh: 4.0,
          breakpointKg: 20.0,
          fuelPct: 15.0, // 15%
          oversizeFee: 25.0,
          etaMin: 2,
          etaMax: 4,
          notes: 'Test rate',
        );
      });

      group('Weight Breakpoint Logic', () {
        test('uses perKgLow when weight is below breakpoint', () {
          final cost = rateTable.calculateCost(
            chargeableKg: 15.0,
            hasOversize: false,
          );

          // baseFee: 50, weight: 15 * 5 = 75, subtotal: 125
          // fuel: 125 * 0.15 = 18.75, total: 143.75
          expect(cost, 143.75);
        });

        test('uses perKgLow when weight equals breakpoint', () {
          final cost = rateTable.calculateCost(
            chargeableKg: 20.0,
            hasOversize: false,
          );

          // baseFee: 50, weight: 20 * 5 = 100, subtotal: 150
          // fuel: 150 * 0.15 = 22.5, total: 172.5
          expect(cost, 172.5);
        });

        test('uses perKgHigh when weight is above breakpoint', () {
          final cost = rateTable.calculateCost(
            chargeableKg: 25.0,
            hasOversize: false,
          );

          // baseFee: 50, weight: 25 * 4 = 100, subtotal: 150
          // fuel: 150 * 0.15 = 22.5, total: 172.5
          expect(cost, 172.5);
        });

        test(
          'uses perKgHigh when weight is significantly above breakpoint',
          () {
            final cost = rateTable.calculateCost(
              chargeableKg: 50.0,
              hasOversize: false,
            );

            // baseFee: 50, weight: 50 * 4 = 200, subtotal: 250
            // fuel: 250 * 0.15 = 37.5, total: 287.5
            expect(cost, 287.5);
          },
        );

        test('uses perKgLow just below breakpoint', () {
          final cost = rateTable.calculateCost(
            chargeableKg: 19.9,
            hasOversize: false,
          );

          // baseFee: 50, weight: 19.9 * 5 = 99.5, subtotal: 149.5
          // fuel: 149.5 * 0.15 = 22.425, total: 171.925
          expect(cost, closeTo(171.925, 0.001));
        });

        test('uses perKgHigh just above breakpoint', () {
          final cost = rateTable.calculateCost(
            chargeableKg: 20.1,
            hasOversize: false,
          );

          // baseFee: 50, weight: 20.1 * 4 = 80.4, subtotal: 130.4
          // fuel: 130.4 * 0.15 = 19.56, total: 149.96
          expect(cost, closeTo(149.96, 0.001));
        });
      });

      group('Fuel Surcharge Calculation', () {
        test('applies fuel surcharge correctly', () {
          final cost = rateTable.calculateCost(
            chargeableKg: 10.0,
            hasOversize: false,
          );

          // baseFee: 50, weight: 10 * 5 = 50, subtotal: 100
          // fuel: 100 * 0.15 = 15, total: 115
          expect(cost, 115.0);
        });

        test('handles zero fuel percentage', () {
          final zeroFuelRate = rateTable.copyWith(fuelPct: 0.0);
          final cost = zeroFuelRate.calculateCost(
            chargeableKg: 10.0,
            hasOversize: false,
          );

          // baseFee: 50, weight: 10 * 5 = 50, subtotal: 100
          // fuel: 100 * 0 = 0, total: 100
          expect(cost, 100.0);
        });

        test('handles high fuel percentage', () {
          final highFuelRate = rateTable.copyWith(fuelPct: 50.0);
          final cost = highFuelRate.calculateCost(
            chargeableKg: 10.0,
            hasOversize: false,
          );

          // baseFee: 50, weight: 10 * 5 = 50, subtotal: 100
          // fuel: 100 * 0.5 = 50, total: 150
          expect(cost, 150.0);
        });
      });

      group('Oversize Fee Application', () {
        test('adds oversize fee when hasOversize is true', () {
          final cost = rateTable.calculateCost(
            chargeableKg: 10.0,
            hasOversize: true,
          );

          // baseFee: 50, weight: 10 * 5 = 50, subtotal: 100
          // fuel: 100 * 0.15 = 15, subtotal with fuel: 115
          // oversize: 25, total: 140
          expect(cost, 140.0);
        });

        test('does not add oversize fee when hasOversize is false', () {
          final cost = rateTable.calculateCost(
            chargeableKg: 10.0,
            hasOversize: false,
          );

          // baseFee: 50, weight: 10 * 5 = 50, subtotal: 100
          // fuel: 100 * 0.15 = 15, total: 115 (no oversize)
          expect(cost, 115.0);
        });

        test('handles zero oversize fee', () {
          final noOversizeFeeRate = rateTable.copyWith(oversizeFee: 0.0);
          final cost = noOversizeFeeRate.calculateCost(
            chargeableKg: 10.0,
            hasOversize: true,
          );

          // baseFee: 50, weight: 10 * 5 = 50, subtotal: 100
          // fuel: 100 * 0.15 = 15, total: 115 (oversize fee is 0)
          expect(cost, 115.0);
        });

        test('applies oversize fee with weight above breakpoint', () {
          final cost = rateTable.calculateCost(
            chargeableKg: 30.0,
            hasOversize: true,
          );

          // baseFee: 50, weight: 30 * 4 = 120, subtotal: 170
          // fuel: 170 * 0.15 = 25.5, subtotal with fuel: 195.5
          // oversize: 25, total: 220.5
          expect(cost, 220.5);
        });
      });

      group('Edge Cases', () {
        test('handles zero weight', () {
          final cost = rateTable.calculateCost(
            chargeableKg: 0.0,
            hasOversize: false,
          );

          // baseFee: 50, weight: 0 * 5 = 0, subtotal: 50
          // fuel: 50 * 0.15 = 7.5, total: 57.5
          expect(cost, 57.5);
        });

        test('handles zero weight with oversize', () {
          final cost = rateTable.calculateCost(
            chargeableKg: 0.0,
            hasOversize: true,
          );

          // baseFee: 50, weight: 0 * 5 = 0, subtotal: 50
          // fuel: 50 * 0.15 = 7.5, subtotal with fuel: 57.5
          // oversize: 25, total: 82.5
          expect(cost, 82.5);
        });

        test('handles fractional weights', () {
          final cost = rateTable.calculateCost(
            chargeableKg: 12.5,
            hasOversize: false,
          );

          // baseFee: 50, weight: 12.5 * 5 = 62.5, subtotal: 112.5
          // fuel: 112.5 * 0.15 = 16.875, total: 129.375
          expect(cost, 129.375);
        });

        test('handles very large weights', () {
          final cost = rateTable.calculateCost(
            chargeableKg: 1000.0,
            hasOversize: true,
          );

          // baseFee: 50, weight: 1000 * 4 = 4000, subtotal: 4050
          // fuel: 4050 * 0.15 = 607.5, subtotal with fuel: 4657.5
          // oversize: 25, total: 4682.5
          expect(cost, 4682.5);
        });

        test('handles all zero values', () {
          final zeroRate = const RateTable(
            id: '1',
            carrier: 'Test',
            service: 'Free',
            baseFee: 0.0,
            perKgLow: 0.0,
            perKgHigh: 0.0,
            breakpointKg: 10.0,
            fuelPct: 0.0,
            oversizeFee: 0.0,
            etaMin: 1,
            etaMax: 3,
          );

          final cost = zeroRate.calculateCost(
            chargeableKg: 5.0,
            hasOversize: true,
          );

          expect(cost, 0.0);
        });
      });

      group('Combined Scenarios', () {
        test('calculates correctly with all fees applied', () {
          final cost = rateTable.calculateCost(
            chargeableKg: 30.0,
            hasOversize: true,
          );

          // baseFee: 50, weight: 30 * 4 = 120, subtotal: 170
          // fuel: 170 * 0.15 = 25.5, subtotal with fuel: 195.5
          // oversize: 25, total: 220.5
          expect(cost, 220.5);
        });

        test('calculates with minimal weight and no oversize', () {
          final cost = rateTable.calculateCost(
            chargeableKg: 1.0,
            hasOversize: false,
          );

          // baseFee: 50, weight: 1 * 5 = 5, subtotal: 55
          // fuel: 55 * 0.15 = 8.25, total: 63.25
          expect(cost, 63.25);
        });
      });
    });

    group('copyWith', () {
      late RateTable original;

      setUp(() {
        original = const RateTable(
          id: '1',
          carrier: 'DHL',
          service: 'Express',
          baseFee: 50.0,
          perKgLow: 5.0,
          perKgHigh: 4.0,
          breakpointKg: 20.0,
          fuelPct: 15.0,
          oversizeFee: 25.0,
          etaMin: 2,
          etaMax: 4,
          notes: 'Test rate',
        );
      });

      test('creates copy with updated carrier', () {
        final copy = original.copyWith(carrier: 'FedEx');

        expect(copy.carrier, 'FedEx');
        expect(copy.service, original.service);
        expect(copy.baseFee, original.baseFee);
      });

      test('creates copy with updated pricing', () {
        final copy = original.copyWith(
          baseFee: 60.0,
          perKgLow: 6.0,
          perKgHigh: 5.0,
        );

        expect(copy.baseFee, 60.0);
        expect(copy.perKgLow, 6.0);
        expect(copy.perKgHigh, 5.0);
        expect(copy.carrier, original.carrier);
      });

      test('creates copy with updated fees', () {
        final copy = original.copyWith(fuelPct: 20.0, oversizeFee: 30.0);

        expect(copy.fuelPct, 20.0);
        expect(copy.oversizeFee, 30.0);
        expect(copy.baseFee, original.baseFee);
      });

      test('creates copy with updated ETA', () {
        final copy = original.copyWith(etaMin: 1, etaMax: 3);

        expect(copy.etaMin, 1);
        expect(copy.etaMax, 3);
        expect(copy.carrier, original.carrier);
      });

      test('creates copy with updated notes', () {
        final copy = original.copyWith(notes: 'Updated note');

        expect(copy.notes, 'Updated note');
        expect(copy.carrier, original.carrier);
      });

      test('creates identical copy when no parameters provided', () {
        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.carrier, original.carrier);
        expect(copy.service, original.service);
        expect(copy.baseFee, original.baseFee);
        expect(copy.perKgLow, original.perKgLow);
        expect(copy.perKgHigh, original.perKgHigh);
        expect(copy.breakpointKg, original.breakpointKg);
        expect(copy.fuelPct, original.fuelPct);
        expect(copy.oversizeFee, original.oversizeFee);
        expect(copy.etaMin, original.etaMin);
        expect(copy.etaMax, original.etaMax);
        expect(copy.notes, original.notes);
      });

      test('creates copy with all fields updated', () {
        final copy = original.copyWith(
          id: '2',
          carrier: 'UPS',
          service: 'Ground',
          baseFee: 40.0,
          perKgLow: 4.5,
          perKgHigh: 3.5,
          breakpointKg: 25.0,
          fuelPct: 18.0,
          oversizeFee: 30.0,
          etaMin: 3,
          etaMax: 5,
          notes: 'New note',
        );

        expect(copy.id, '2');
        expect(copy.carrier, 'UPS');
        expect(copy.service, 'Ground');
        expect(copy.baseFee, 40.0);
        expect(copy.perKgLow, 4.5);
        expect(copy.perKgHigh, 3.5);
        expect(copy.breakpointKg, 25.0);
        expect(copy.fuelPct, 18.0);
        expect(copy.oversizeFee, 30.0);
        expect(copy.etaMin, 3);
        expect(copy.etaMax, 5);
        expect(copy.notes, 'New note');
      });

      test('cost calculation works correctly on copied instance', () {
        final copy = original.copyWith(baseFee: 100.0);

        final cost = copy.calculateCost(chargeableKg: 10.0, hasOversize: false);

        // baseFee: 100, weight: 10 * 5 = 50, subtotal: 150
        // fuel: 150 * 0.15 = 22.5, total: 172.5
        expect(cost, 172.5);
      });
    });

    group('Equatable', () {
      test('two rate tables with same values are equal', () {
        final rate1 = const RateTable(
          id: '1',
          carrier: 'DHL',
          service: 'Express',
          baseFee: 50.0,
          perKgLow: 5.0,
          perKgHigh: 4.0,
          breakpointKg: 20.0,
          fuelPct: 15.0,
          oversizeFee: 25.0,
          etaMin: 2,
          etaMax: 4,
          notes: 'Test',
        );

        final rate2 = const RateTable(
          id: '1',
          carrier: 'DHL',
          service: 'Express',
          baseFee: 50.0,
          perKgLow: 5.0,
          perKgHigh: 4.0,
          breakpointKg: 20.0,
          fuelPct: 15.0,
          oversizeFee: 25.0,
          etaMin: 2,
          etaMax: 4,
          notes: 'Test',
        );

        expect(rate1, equals(rate2));
      });

      test('two rate tables with different ids are not equal', () {
        final rate1 = const RateTable(
          id: '1',
          carrier: 'DHL',
          service: 'Express',
          baseFee: 50.0,
          perKgLow: 5.0,
          perKgHigh: 4.0,
          breakpointKg: 20.0,
          fuelPct: 15.0,
          oversizeFee: 25.0,
          etaMin: 2,
          etaMax: 4,
        );

        final rate2 = const RateTable(
          id: '2',
          carrier: 'DHL',
          service: 'Express',
          baseFee: 50.0,
          perKgLow: 5.0,
          perKgHigh: 4.0,
          breakpointKg: 20.0,
          fuelPct: 15.0,
          oversizeFee: 25.0,
          etaMin: 2,
          etaMax: 4,
        );

        expect(rate1, isNot(equals(rate2)));
      });

      test('two rate tables with different baseFee are not equal', () {
        final rate1 = const RateTable(
          id: '1',
          carrier: 'DHL',
          service: 'Express',
          baseFee: 50.0,
          perKgLow: 5.0,
          perKgHigh: 4.0,
          breakpointKg: 20.0,
          fuelPct: 15.0,
          oversizeFee: 25.0,
          etaMin: 2,
          etaMax: 4,
        );

        final rate2 = const RateTable(
          id: '1',
          carrier: 'DHL',
          service: 'Express',
          baseFee: 60.0,
          perKgLow: 5.0,
          perKgHigh: 4.0,
          breakpointKg: 20.0,
          fuelPct: 15.0,
          oversizeFee: 25.0,
          etaMin: 2,
          etaMax: 4,
        );

        expect(rate1, isNot(equals(rate2)));
      });
    });

    group('Real World Scenarios', () {
      test('DHL Express typical calculation', () {
        final dhlRate = const RateTable(
          id: 'dhl-express',
          carrier: 'DHL',
          service: 'Express Worldwide',
          baseFee: 45.0,
          perKgLow: 6.5,
          perKgHigh: 5.2,
          breakpointKg: 21.0,
          fuelPct: 18.5,
          oversizeFee: 30.0,
          etaMin: 2,
          etaMax: 3,
        );

        final cost = dhlRate.calculateCost(
          chargeableKg: 15.5,
          hasOversize: false,
        );

        // baseFee: 45, weight: 15.5 * 6.5 = 100.75, subtotal: 145.75
        // fuel: 145.75 * 0.185 = 26.96375, total: 172.71375
        expect(cost, closeTo(172.71, 0.01));
      });

      test('UPS Ground economy shipping', () {
        final upsRate = const RateTable(
          id: 'ups-ground',
          carrier: 'UPS',
          service: 'Ground',
          baseFee: 35.0,
          perKgLow: 4.0,
          perKgHigh: 3.2,
          breakpointKg: 25.0,
          fuelPct: 12.0,
          oversizeFee: 20.0,
          etaMin: 5,
          etaMax: 7,
        );

        final cost = upsRate.calculateCost(
          chargeableKg: 30.0,
          hasOversize: true,
        );

        // baseFee: 35, weight: 30 * 3.2 = 96, subtotal: 131
        // fuel: 131 * 0.12 = 15.72, subtotal with fuel: 146.72
        // oversize: 20, total: 166.72
        expect(cost, closeTo(166.72, 0.01));
      });
    });
  });
}
