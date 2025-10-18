import 'package:bockaire/classes/carton.dart';
import 'package:bockaire/logic/optimizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OptimizedCarton', () {
    test('calculates volumeCm3 correctly', () {
      const carton = OptimizedCarton(
        lengthCm: 50,
        widthCm: 40,
        heightCm: 30,
        weightKg: 10,
        itemTypes: ['Electronics'],
      );

      expect(carton.volumeCm3, 60000);
    });

    test('calculates dimensionalWeight correctly', () {
      const carton = OptimizedCarton(
        lengthCm: 50,
        widthCm: 40,
        heightCm: 30,
        weightKg: 10,
        itemTypes: ['Electronics'],
      );

      // (50 * 40 * 30) / 5000 = 12
      expect(carton.dimensionalWeight, 12.0);
    });

    test('chargeableWeight returns actual weight when greater', () {
      const carton = OptimizedCarton(
        lengthCm: 20,
        widthCm: 20,
        heightCm: 20,
        weightKg: 10, // Dimensional: 1.6
        itemTypes: ['Heavy'],
      );

      expect(carton.chargeableWeight, 10.0);
    });

    test('chargeableWeight returns dimensional weight when greater', () {
      const carton = OptimizedCarton(
        lengthCm: 50,
        widthCm: 40,
        heightCm: 30,
        weightKg: 5, // Dimensional: 12
        itemTypes: ['Light'],
      );

      expect(carton.chargeableWeight, 12.0);
    });

    test('isOversize returns true when length > 60cm', () {
      const carton = OptimizedCarton(
        lengthCm: 61,
        widthCm: 40,
        heightCm: 30,
        weightKg: 10,
        itemTypes: ['Oversize'],
      );

      expect(carton.isOversize, true);
    });

    test('isOversize returns false when length <= 60cm', () {
      const carton = OptimizedCarton(
        lengthCm: 60,
        widthCm: 40,
        heightCm: 30,
        weightKg: 10,
        itemTypes: ['Standard'],
      );

      expect(carton.isOversize, false);
    });
  });

  group('PackOptimizer', () {
    late PackOptimizer optimizer;

    setUp(() {
      optimizer = PackOptimizer();
    });

    group('optimize - Edge Cases', () {
      test('handles empty carton list', () {
        final result = optimizer.optimize([]);

        expect(result.optimizedCartons, isEmpty);
        expect(result.originalVolume, 0.0);
        expect(result.optimizedVolume, 0.0);
        expect(result.volumeSavingsPct, 0.0);
        expect(result.originalChargeableKg, 0.0);
        expect(result.optimizedChargeableKg, 0.0);
      });

      test('handles single carton', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 30,
            widthCm: 25,
            heightCm: 20,
            weightKg: 5,
            qty: 1,
            itemType: 'Electronics',
          ),
        ];

        final result = optimizer.optimize(cartons);

        expect(result.optimizedCartons.length, 1);
        expect(result.optimizedCartons.first.itemTypes, ['Electronics']);
        expect(result.optimizedCartons.first.weightKg, 5.0);
      });

      test('handles single carton with high quantity', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 20,
            widthCm: 15,
            heightCm: 10,
            weightKg: 2,
            qty: 10,
            itemType: 'Books',
          ),
        ];

        final result = optimizer.optimize(cartons);

        // Should pack into multiple standard cartons
        expect(result.optimizedCartons.isNotEmpty, true);

        // Total weight should be preserved
        final totalWeight = result.optimizedCartons.fold<double>(
          0,
          (sum, c) => sum + c.weightKg,
        );
        expect(totalWeight, 20.0); // 2kg * 10 items
      });
    });

    group('optimize - Weight Limit', () {
      test('respects 24kg weight limit per carton', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 30,
            widthCm: 20,
            heightCm: 15,
            weightKg: 8,
            qty: 5, // Total 40kg
            itemType: 'Heavy Items',
          ),
        ];

        final result = optimizer.optimize(cartons);

        // Check that no carton exceeds weight limit
        for (final carton in result.optimizedCartons) {
          expect(carton.weightKg, lessThanOrEqualTo(24.0));
        }

        // Total weight should be preserved
        final totalWeight = result.optimizedCartons.fold<double>(
          0,
          (sum, c) => sum + c.weightKg,
        );
        expect(totalWeight, 40.0);
      });

      test('splits items at exactly 24kg boundary', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 25,
            widthCm: 20,
            heightCm: 15,
            weightKg: 12,
            qty: 2, // Total 24kg - exactly at limit
            itemType: 'Medium Items',
          ),
        ];

        final result = optimizer.optimize(cartons);

        // Should fit in one carton at exactly 24kg
        expect(result.optimizedCartons.any((c) => c.weightKg == 24.0), true);
      });

      test('handles items that individually exceed weight limit', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 25,
            weightKg: 30, // Exceeds limit
            qty: 1,
            itemType: 'Very Heavy',
          ),
        ];

        final result = optimizer.optimize(cartons);

        // Should still create a carton even though it exceeds limit
        // (Real-world would need special handling)
        expect(result.optimizedCartons.isNotEmpty, true);
      });
    });

    group('optimize - Standard Sizes', () {
      test('uses smallest standard size (50x40x40)', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 20,
            widthCm: 15,
            heightCm: 10,
            weightKg: 2,
            qty: 1,
            itemType: 'Small Items',
          ),
        ];

        final result = optimizer.optimize(cartons);

        // Should use 50x40x40 standard size
        expect(result.optimizedCartons.first.lengthCm, 50);
        expect(result.optimizedCartons.first.widthCm, 40);
        expect(result.optimizedCartons.first.heightCm, 40);
      });

      test('uses larger standard size (60x40x40) when needed', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 35,
            heightCm: 30,
            weightKg: 10,
            qty: 3, // Large volume
            itemType: 'Large Items',
          ),
        ];

        final result = optimizer.optimize(cartons);

        // Should use larger size or multiple cartons
        expect(result.optimizedCartons.isNotEmpty, true);
      });

      test('uses largest standard size for very large items', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 58,
            widthCm: 39,
            heightCm: 39,
            weightKg: 12,
            qty: 2,
            itemType: 'Large Items',
          ),
        ];

        final result = optimizer.optimize(cartons);

        // Should use largest standard size (60x40x40) for very large items
        // Volume per item: 58*39*39 = 88,218 cm³
        // This exceeds 50x40x40 (80,000 cm³), so should use 60x40x40 (96,000 cm³)
        expect(result.optimizedCartons.isNotEmpty, true);
        // Standard sizes max at 60cm, so none should be oversize (>60cm)
        final oversizeCartons = result.optimizedCartons.where(
          (c) => c.isOversize,
        );
        expect(oversizeCartons.isEmpty, true);
        // Should use the 60cm length size
        expect(result.optimizedCartons.any((c) => c.lengthCm == 60), true);
      });
    });

    group('optimize - Multiple Item Types', () {
      test('groups items by type', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 25,
            widthCm: 20,
            heightCm: 15,
            weightKg: 3,
            qty: 2,
            itemType: 'Electronics',
          ),
          const Carton(
            id: '2',
            shipmentId: 's1',
            lengthCm: 30,
            widthCm: 20,
            heightCm: 10,
            weightKg: 2,
            qty: 3,
            itemType: 'Books',
          ),
          const Carton(
            id: '3',
            shipmentId: 's1',
            lengthCm: 20,
            widthCm: 15,
            heightCm: 10,
            weightKg: 1,
            qty: 5,
            itemType: 'Electronics',
          ),
        ];

        final result = optimizer.optimize(cartons);

        // Should have separate cartons for different item types
        final electronicsCartons = result.optimizedCartons.where(
          (c) => c.itemTypes.contains('Electronics'),
        );
        final booksCartons = result.optimizedCartons.where(
          (c) => c.itemTypes.contains('Books'),
        );

        expect(electronicsCartons.isNotEmpty, true);
        expect(booksCartons.isNotEmpty, true);
      });

      test('handles same item type from different original cartons', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 30,
            widthCm: 20,
            heightCm: 15,
            weightKg: 4,
            qty: 2,
            itemType: 'Toys',
          ),
          const Carton(
            id: '2',
            shipmentId: 's1',
            lengthCm: 25,
            widthCm: 18,
            heightCm: 12,
            weightKg: 3,
            qty: 3,
            itemType: 'Toys',
          ),
        ];

        final result = optimizer.optimize(cartons);

        // Total weight should be preserved
        final totalWeight = result.optimizedCartons.fold<double>(
          0,
          (sum, c) => sum + c.weightKg,
        );
        expect(totalWeight, 17.0); // (4*2) + (3*3)
      });
    });

    group('optimize - Volume Savings', () {
      test('calculates volume savings correctly', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 45,
            widthCm: 35,
            heightCm: 30,
            weightKg: 8,
            qty: 1,
            itemType: 'Items',
          ),
        ];

        final result = optimizer.optimize(cartons);

        final originalVol = 45.0 * 35.0 * 30.0; // 47250
        expect(result.originalVolume, originalVol);
        expect(result.optimizedVolume, greaterThan(0));

        // Savings should be between 0 and 100
        expect(result.volumeSavingsPct, greaterThanOrEqualTo(0));
        expect(result.volumeSavingsPct, lessThanOrEqualTo(100));
      });

      test('handles negative savings (no improvement)', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 50,
            widthCm: 40,
            heightCm: 40,
            weightKg: 20,
            qty: 1,
            itemType: 'Items',
          ),
        ];

        final result = optimizer.optimize(cartons);

        // Already optimal size, savings clamped at 0
        expect(result.volumeSavingsPct, greaterThanOrEqualTo(0));
      });

      test('provides savings with multiple small items', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 35,
            widthCm: 30,
            heightCm: 25,
            weightKg: 3,
            qty: 1,
            itemType: 'Small',
          ),
          const Carton(
            id: '2',
            shipmentId: 's1',
            lengthCm: 30,
            widthCm: 25,
            heightCm: 20,
            weightKg: 2,
            qty: 1,
            itemType: 'Small',
          ),
        ];

        final result = optimizer.optimize(cartons);

        final originalVol = (35.0 * 30.0 * 25.0) + (30.0 * 25.0 * 20.0);
        expect(result.originalVolume, originalVol);

        // Combining items should provide some savings
        expect(result.volumeSavingsPct, greaterThanOrEqualTo(0));
      });
    });

    group('optimize - Chargeable Weight', () {
      test('calculates original chargeable weight correctly', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 50,
            widthCm: 40,
            heightCm: 30,
            weightKg: 5, // Dimensional: 12, Chargeable: 12
            qty: 2,
            itemType: 'Light',
          ),
        ];

        final result = optimizer.optimize(cartons);

        // Original chargeable: 12 * 2 = 24
        expect(result.originalChargeableKg, 24.0);
      });

      test('optimized chargeable weight is calculated', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 30,
            widthCm: 25,
            heightCm: 20,
            weightKg: 4,
            qty: 3,
            itemType: 'Items',
          ),
        ];

        final result = optimizer.optimize(cartons);

        expect(result.optimizedChargeableKg, greaterThan(0));

        // Each optimized carton should contribute to total
        final calculatedTotal = result.optimizedCartons.fold<double>(
          0,
          (sum, c) => sum + c.chargeableWeight,
        );
        expect(result.optimizedChargeableKg, calculatedTotal);
      });
    });

    group('optimize - Density Sorting', () {
      test('sorts items by density for better packing', () {
        final cartons = [
          // Low density (light, large)
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 25,
            weightKg: 2,
            qty: 2,
            itemType: 'Light',
          ),
          // High density (heavy, small)
          const Carton(
            id: '2',
            shipmentId: 's1',
            lengthCm: 20,
            widthCm: 15,
            heightCm: 10,
            weightKg: 8,
            qty: 2,
            itemType: 'Light',
          ),
        ];

        final result = optimizer.optimize(cartons);

        // Should pack efficiently regardless of input order
        expect(result.optimizedCartons.isNotEmpty, true);

        // Total weight preserved
        final totalWeight = result.optimizedCartons.fold<double>(
          0,
          (sum, c) => sum + c.weightKg,
        );
        expect(totalWeight, 20.0); // (2*2) + (8*2)
      });
    });

    group('optimize - Real World Scenarios', () {
      test('optimizes mixed electronics shipment', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5,
            qty: 3,
            itemType: 'Laptops',
          ),
          const Carton(
            id: '2',
            shipmentId: 's1',
            lengthCm: 30,
            widthCm: 20,
            heightCm: 15,
            weightKg: 2,
            qty: 5,
            itemType: 'Tablets',
          ),
          const Carton(
            id: '3',
            shipmentId: 's1',
            lengthCm: 15,
            widthCm: 10,
            heightCm: 8,
            weightKg: 0.5,
            qty: 10,
            itemType: 'Accessories',
          ),
        ];

        final result = optimizer.optimize(cartons);

        // Should create optimized cartons
        expect(result.optimizedCartons.length, greaterThan(0));

        // Total weight: (5*3) + (2*5) + (0.5*10) = 15 + 10 + 5 = 30kg
        final totalWeight = result.optimizedCartons.fold<double>(
          0,
          (sum, c) => sum + c.weightKg,
        );
        expect(totalWeight, 30.0);

        // No carton should exceed weight limit
        for (final carton in result.optimizedCartons) {
          expect(carton.weightKg, lessThanOrEqualTo(24.0));
        }
      });

      test('handles bulk shipment of identical items', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 25,
            widthCm: 20,
            heightCm: 15,
            weightKg: 3,
            qty: 50, // Bulk order
            itemType: 'Books',
          ),
        ];

        final result = optimizer.optimize(cartons);

        // Should split into multiple cartons respecting weight limit
        expect(result.optimizedCartons.length, greaterThan(1));

        // Total weight: 3 * 50 = 150kg
        final totalWeight = result.optimizedCartons.fold<double>(
          0,
          (sum, c) => sum + c.weightKg,
        );
        expect(totalWeight, 150.0);

        // All should be Books
        for (final carton in result.optimizedCartons) {
          expect(carton.itemTypes, contains('Books'));
        }
      });

      test('optimizes shipment with varying item sizes', () {
        final cartons = [
          // Small items
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 15,
            widthCm: 12,
            heightCm: 8,
            weightKg: 1,
            qty: 8,
            itemType: 'Small',
          ),
          // Medium items
          const Carton(
            id: '2',
            shipmentId: 's1',
            lengthCm: 30,
            widthCm: 25,
            heightCm: 18,
            weightKg: 4,
            qty: 4,
            itemType: 'Medium',
          ),
          // Large items
          const Carton(
            id: '3',
            shipmentId: 's1',
            lengthCm: 45,
            widthCm: 38,
            heightCm: 32,
            weightKg: 12,
            qty: 2,
            itemType: 'Large',
          ),
        ];

        final result = optimizer.optimize(cartons);

        expect(result.optimizedCartons.isNotEmpty, true);

        // Total weight: (1*8) + (4*4) + (12*2) = 8 + 16 + 24 = 48kg
        final totalWeight = result.optimizedCartons.fold<double>(
          0,
          (sum, c) => sum + c.weightKg,
        );
        expect(totalWeight, 48.0);

        // Should provide some optimization
        expect(result.volumeSavingsPct, greaterThanOrEqualTo(0));
      });
    });

    group('OptimizationResult', () {
      test('contains all required fields', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 30,
            widthCm: 25,
            heightCm: 20,
            weightKg: 5,
            qty: 2,
            itemType: 'Test',
          ),
        ];

        final result = optimizer.optimize(cartons);

        expect(result.optimizedCartons, isNotEmpty);
        expect(result.originalVolume, greaterThan(0));
        expect(result.optimizedVolume, greaterThan(0));
        expect(result.volumeSavingsPct, isA<double>());
        expect(result.originalChargeableKg, greaterThan(0));
        expect(result.optimizedChargeableKg, greaterThan(0));
      });
    });
  });
}
