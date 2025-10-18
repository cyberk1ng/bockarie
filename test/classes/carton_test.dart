import 'package:bockaire/classes/carton.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Carton', () {
    group('dimensionalWeight', () {
      test('calculates correctly with standard dimensions', () {
        final carton = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 50,
          widthCm: 40,
          heightCm: 30,
          weightKg: 10,
          qty: 1,
          itemType: 'Electronics',
        );

        // (50 * 40 * 30) / 5000 = 60000 / 5000 = 12
        expect(carton.dimensionalWeight, 12.0);
      });

      test('calculates correctly with small dimensions', () {
        final carton = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 10,
          widthCm: 10,
          heightCm: 10,
          weightKg: 5,
          qty: 1,
          itemType: 'Small Item',
        );

        // (10 * 10 * 10) / 5000 = 1000 / 5000 = 0.2
        expect(carton.dimensionalWeight, 0.2);
      });

      test('calculates correctly with large dimensions', () {
        final carton = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 100,
          widthCm: 80,
          heightCm: 60,
          weightKg: 20,
          qty: 1,
          itemType: 'Large Item',
        );

        // (100 * 80 * 60) / 5000 = 480000 / 5000 = 96
        expect(carton.dimensionalWeight, 96.0);
      });
    });

    group('chargeableWeight', () {
      test('returns actual weight when greater than dimensional', () {
        final carton = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 20,
          widthCm: 20,
          heightCm: 20,
          weightKg: 10, // Dimensional: (20*20*20)/5000 = 1.6
          qty: 1,
          itemType: 'Heavy Small Box',
        );

        expect(carton.chargeableWeight, 10.0);
      });

      test('returns dimensional weight when greater than actual', () {
        final carton = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 50,
          widthCm: 40,
          heightCm: 30,
          weightKg: 5, // Dimensional: (50*40*30)/5000 = 12
          qty: 1,
          itemType: 'Light Large Box',
        );

        expect(carton.chargeableWeight, 12.0);
      });

      test('returns correct weight when actual equals dimensional', () {
        final carton = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 50,
          widthCm: 40,
          heightCm: 30,
          weightKg: 12, // Dimensional: (50*40*30)/5000 = 12
          qty: 1,
          itemType: 'Balanced Box',
        );

        expect(carton.chargeableWeight, 12.0);
      });

      test('handles zero weight', () {
        final carton = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 30,
          widthCm: 30,
          heightCm: 30,
          weightKg: 0, // Dimensional: (30*30*30)/5000 = 5.4
          qty: 1,
          itemType: 'Empty Box',
        );

        expect(carton.chargeableWeight, 5.4);
      });
    });

    group('totalChargeableWeight', () {
      test('multiplies chargeable weight by quantity', () {
        final carton = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 50,
          widthCm: 40,
          heightCm: 30,
          weightKg: 5, // Chargeable: 12 (dimensional)
          qty: 3,
          itemType: 'Multiple Boxes',
        );

        // Chargeable: 12, Qty: 3 = 36
        expect(carton.totalChargeableWeight, 36.0);
      });

      test('works with quantity of 1', () {
        final carton = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 40,
          widthCm: 30,
          heightCm: 20,
          weightKg: 8,
          qty: 1,
          itemType: 'Single Box',
        );

        // Dimensional: (40*30*20)/5000 = 4.8, Actual: 8, Chargeable: 8
        expect(carton.totalChargeableWeight, 8.0);
      });

      test('works with large quantities', () {
        final carton = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 30,
          widthCm: 20,
          heightCm: 15,
          weightKg: 2, // Dimensional: (30*20*15)/5000 = 1.8, Chargeable: 2
          qty: 100,
          itemType: 'Bulk Items',
        );

        expect(carton.totalChargeableWeight, 200.0);
      });
    });

    group('isOversize', () {
      test('returns true when length exceeds 60cm', () {
        final carton = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 61,
          widthCm: 40,
          heightCm: 30,
          weightKg: 10,
          qty: 1,
          itemType: 'Oversize Box',
        );

        expect(carton.isOversize, true);
      });

      test('returns false when length equals 60cm', () {
        final carton = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 60,
          widthCm: 40,
          heightCm: 30,
          weightKg: 10,
          qty: 1,
          itemType: 'Exactly 60cm',
        );

        expect(carton.isOversize, false);
      });

      test('returns false when length is less than 60cm', () {
        final carton = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 59,
          widthCm: 40,
          heightCm: 30,
          weightKg: 10,
          qty: 1,
          itemType: 'Standard Box',
        );

        expect(carton.isOversize, false);
      });

      test('returns true for very large length', () {
        final carton = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 120,
          widthCm: 40,
          heightCm: 30,
          weightKg: 10,
          qty: 1,
          itemType: 'Very Large Box',
        );

        expect(carton.isOversize, true);
      });
    });

    group('volumeCm3', () {
      test('calculates volume correctly', () {
        final carton = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 50,
          widthCm: 40,
          heightCm: 30,
          weightKg: 10,
          qty: 1,
          itemType: 'Standard Box',
        );

        // 50 * 40 * 30 = 60000
        expect(carton.volumeCm3, 60000);
      });

      test('multiplies by quantity', () {
        final carton = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 30,
          widthCm: 20,
          heightCm: 10,
          weightKg: 5,
          qty: 5,
          itemType: 'Multiple Boxes',
        );

        // (30 * 20 * 10) * 5 = 6000 * 5 = 30000
        expect(carton.volumeCm3, 30000);
      });

      test('handles small dimensions', () {
        final carton = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 10,
          widthCm: 10,
          heightCm: 10,
          weightKg: 1,
          qty: 1,
          itemType: 'Small Box',
        );

        expect(carton.volumeCm3, 1000);
      });
    });

    group('copyWith', () {
      test('creates copy with updated id', () {
        final original = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 50,
          widthCm: 40,
          heightCm: 30,
          weightKg: 10,
          qty: 1,
          itemType: 'Box',
        );

        final copy = original.copyWith(id: '2');

        expect(copy.id, '2');
        expect(copy.shipmentId, original.shipmentId);
        expect(copy.lengthCm, original.lengthCm);
      });

      test('creates copy with updated dimensions', () {
        final original = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 50,
          widthCm: 40,
          heightCm: 30,
          weightKg: 10,
          qty: 1,
          itemType: 'Box',
        );

        final copy = original.copyWith(lengthCm: 60, widthCm: 50, heightCm: 40);

        expect(copy.lengthCm, 60);
        expect(copy.widthCm, 50);
        expect(copy.heightCm, 40);
        expect(copy.id, original.id);
        expect(copy.weightKg, original.weightKg);
      });

      test('creates copy with updated weight and quantity', () {
        final original = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 50,
          widthCm: 40,
          heightCm: 30,
          weightKg: 10,
          qty: 1,
          itemType: 'Box',
        );

        final copy = original.copyWith(weightKg: 15, qty: 3);

        expect(copy.weightKg, 15);
        expect(copy.qty, 3);
        expect(copy.lengthCm, original.lengthCm);
      });

      test('creates copy with updated itemType', () {
        final original = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 50,
          widthCm: 40,
          heightCm: 30,
          weightKg: 10,
          qty: 1,
          itemType: 'Box',
        );

        final copy = original.copyWith(itemType: 'Electronics');

        expect(copy.itemType, 'Electronics');
        expect(copy.id, original.id);
      });

      test('creates identical copy when no parameters provided', () {
        final original = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 50,
          widthCm: 40,
          heightCm: 30,
          weightKg: 10,
          qty: 1,
          itemType: 'Box',
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.shipmentId, original.shipmentId);
        expect(copy.lengthCm, original.lengthCm);
        expect(copy.widthCm, original.widthCm);
        expect(copy.heightCm, original.heightCm);
        expect(copy.weightKg, original.weightKg);
        expect(copy.qty, original.qty);
        expect(copy.itemType, original.itemType);
      });

      test('creates copy with all fields updated', () {
        final original = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 50,
          widthCm: 40,
          heightCm: 30,
          weightKg: 10,
          qty: 1,
          itemType: 'Box',
        );

        final copy = original.copyWith(
          id: '2',
          shipmentId: 's2',
          lengthCm: 60,
          widthCm: 50,
          heightCm: 40,
          weightKg: 15,
          qty: 3,
          itemType: 'Electronics',
        );

        expect(copy.id, '2');
        expect(copy.shipmentId, 's2');
        expect(copy.lengthCm, 60);
        expect(copy.widthCm, 50);
        expect(copy.heightCm, 40);
        expect(copy.weightKg, 15);
        expect(copy.qty, 3);
        expect(copy.itemType, 'Electronics');
      });
    });

    group('Equatable', () {
      test('two cartons with same values are equal', () {
        final carton1 = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 50,
          widthCm: 40,
          heightCm: 30,
          weightKg: 10,
          qty: 1,
          itemType: 'Box',
        );

        final carton2 = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 50,
          widthCm: 40,
          heightCm: 30,
          weightKg: 10,
          qty: 1,
          itemType: 'Box',
        );

        expect(carton1, equals(carton2));
      });

      test('two cartons with different ids are not equal', () {
        final carton1 = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 50,
          widthCm: 40,
          heightCm: 30,
          weightKg: 10,
          qty: 1,
          itemType: 'Box',
        );

        final carton2 = Carton(
          id: '2',
          shipmentId: 's1',
          lengthCm: 50,
          widthCm: 40,
          heightCm: 30,
          weightKg: 10,
          qty: 1,
          itemType: 'Box',
        );

        expect(carton1, isNot(equals(carton2)));
      });
    });

    group('Edge Cases', () {
      test('handles fractional dimensions', () {
        final carton = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 50.5,
          widthCm: 40.3,
          heightCm: 30.7,
          weightKg: 10.2,
          qty: 1,
          itemType: 'Box',
        );

        // (50.5 * 40.3 * 30.7) / 5000 = 12.499021
        expect(carton.dimensionalWeight, closeTo(12.50, 0.05));
        expect(carton.chargeableWeight, closeTo(12.50, 0.05));
      });

      test('handles very small dimensions', () {
        final carton = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 1,
          widthCm: 1,
          heightCm: 1,
          weightKg: 0.1,
          qty: 1,
          itemType: 'Tiny',
        );

        expect(carton.dimensionalWeight, 0.0002);
        expect(carton.chargeableWeight, 0.1); // Actual weight is higher
      });

      test('handles oversize boundary precisely', () {
        final carton60 = Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 60.0,
          widthCm: 40,
          heightCm: 30,
          weightKg: 10,
          qty: 1,
          itemType: 'Exactly 60',
        );

        final carton60Plus = Carton(
          id: '2',
          shipmentId: 's1',
          lengthCm: 60.1,
          widthCm: 40,
          heightCm: 30,
          weightKg: 10,
          qty: 1,
          itemType: 'Just over 60',
        );

        expect(carton60.isOversize, false);
        expect(carton60Plus.isOversize, true);
      });
    });
  });
}
