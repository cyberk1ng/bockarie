import 'package:flutter_test/flutter_test.dart';
import 'package:bockaire/services/calculation_service.dart';
import 'package:bockaire/classes/carton.dart';

void main() {
  group('CalculationService', () {
    group('calculateDimWeight', () {
      test('calculates dimensional weight correctly', () {
        final dimWeight = CalculationService.calculateDimWeight(
          lengthCm: 50,
          widthCm: 40,
          heightCm: 30,
        );

        // (50 * 40 * 30) / 5000 = 60000 / 5000 = 12
        expect(dimWeight, 12.0);
      });

      test('handles zero dimensions', () {
        final dimWeight = CalculationService.calculateDimWeight(
          lengthCm: 0,
          widthCm: 40,
          heightCm: 30,
        );

        expect(dimWeight, 0.0);
      });
    });

    group('calculateActualWeight', () {
      test('sums actual weight with quantities', () {
        final cartons = [
          Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 50,
            widthCm: 40,
            heightCm: 30,
            weightKg: 10,
            qty: 2,
            itemType: 'Box',
          ),
          Carton(
            id: '2',
            shipmentId: 's1',
            lengthCm: 60,
            widthCm: 40,
            heightCm: 40,
            weightKg: 15,
            qty: 3,
            itemType: 'Box',
          ),
        ];

        final actualWeight = CalculationService.calculateActualWeight(cartons);

        // (10 * 2) + (15 * 3) = 20 + 45 = 65
        expect(actualWeight, 65.0);
      });

      test('returns 0 for empty list', () {
        final actualWeight = CalculationService.calculateActualWeight([]);
        expect(actualWeight, 0.0);
      });
    });

    group('calculateTotalDimWeight', () {
      test('sums dimensional weight with quantities', () {
        final cartons = [
          Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 50,
            widthCm: 40,
            heightCm: 30,
            weightKg: 10,
            qty: 2,
            itemType: 'Box',
          ),
        ];

        final dimWeight = CalculationService.calculateTotalDimWeight(cartons);

        // (50 * 40 * 30) / 5000 = 12 kg per carton
        // 12 * 2 qty = 24 kg total
        expect(dimWeight, 24.0);
      });
    });

    group('calculateChargeableWeight', () {
      test('returns actual weight when higher than dim weight', () {
        final cartons = [
          Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 30,
            widthCm: 20,
            heightCm: 10,
            weightKg: 50, // High actual weight
            qty: 1,
            itemType: 'Dense',
          ),
        ];

        final chargeableWeight = CalculationService.calculateChargeableWeight(
          cartons,
        );

        // Dim weight: (30 * 20 * 10) / 5000 = 1.2
        // Actual: 50
        // Chargeable should be 50
        expect(chargeableWeight, 50.0);
      });

      test('returns dim weight when higher than actual weight', () {
        final cartons = [
          Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 100,
            widthCm: 80,
            heightCm: 60,
            weightKg: 5, // Low actual weight
            qty: 1,
            itemType: 'Light',
          ),
        ];

        final chargeableWeight = CalculationService.calculateChargeableWeight(
          cartons,
        );

        // Dim weight: (100 * 80 * 60) / 5000 = 96
        // Actual: 5
        // Chargeable should be 96
        expect(chargeableWeight, 96.0);
      });
    });

    group('isOversized', () {
      test('detects oversized carton with default threshold (60cm)', () {
        final cartons = [
          Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 70, // > 60
            widthCm: 40,
            heightCm: 30,
            weightKg: 10,
            qty: 1,
            itemType: 'Box',
          ),
        ];

        expect(CalculationService.isOversized(cartons), true);
      });

      test('detects oversized on any dimension', () {
        final cartons = [
          Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 50,
            heightCm: 65, // > 60
            weightKg: 10,
            qty: 1,
            itemType: 'Box',
          ),
        ];

        expect(CalculationService.isOversized(cartons), true);
      });

      test('returns false when all dimensions under threshold', () {
        final cartons = [
          Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 50,
            widthCm: 40,
            heightCm: 30,
            weightKg: 10,
            qty: 1,
            itemType: 'Box',
          ),
        ];

        expect(CalculationService.isOversized(cartons), false);
      });

      test('supports custom threshold', () {
        final cartons = [
          Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 55,
            widthCm: 40,
            heightCm: 30,
            weightKg: 10,
            qty: 1,
            itemType: 'Box',
          ),
        ];

        expect(CalculationService.isOversized(cartons, threshold: 50), true);
        expect(CalculationService.isOversized(cartons, threshold: 60), false);
      });
    });

    group('calculateTotals', () {
      test('returns comprehensive totals', () {
        final cartons = [
          Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 50,
            widthCm: 40,
            heightCm: 30,
            weightKg: 10,
            qty: 2,
            itemType: 'Box',
          ),
          Carton(
            id: '2',
            shipmentId: 's1',
            lengthCm: 70,
            widthCm: 50,
            heightCm: 40,
            weightKg: 20,
            qty: 1,
            itemType: 'Large',
          ),
        ];

        final totals = CalculationService.calculateTotals(cartons);

        expect(totals.cartonCount, 2);
        expect(totals.actualKg, 40.0); // (10*2) + (20*1)
        expect(totals.dimKg, 52.0); // ((50*40*30)/5000*2) + ((70*50*40)/5000*1)
        expect(totals.chargeableKg, 52.0); // max(40, 52)
        expect(totals.largestSideCm, 70.0);
        expect(totals.isOversized, true); // 70 > 60
      });
    });
  });
}
