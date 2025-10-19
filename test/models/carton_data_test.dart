import 'package:bockaire/services/ai_provider_interfaces.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CartonData - fromJson', () {
    test('parses complete valid data', () {
      final json = {
        'lengthCm': 50.0,
        'widthCm': 30.0,
        'heightCm': 20.0,
        'weightKg': 5.5,
        'qty': 10,
        'itemType': 'Laptops',
      };

      final carton = CartonData.fromJson(json);

      expect(carton.lengthCm, 50.0);
      expect(carton.widthCm, 30.0);
      expect(carton.heightCm, 20.0);
      expect(carton.weightKg, 5.5);
      expect(carton.qty, 10);
      expect(carton.itemType, 'Laptops');
    });

    test('handles null fields', () {
      final json = <String, dynamic>{};

      final carton = CartonData.fromJson(json);

      expect(carton.lengthCm, isNull);
      expect(carton.widthCm, isNull);
      expect(carton.heightCm, isNull);
      expect(carton.weightKg, isNull);
      expect(carton.qty, isNull);
      expect(carton.itemType, isNull);
    });

    test('converts int to double for dimensions', () {
      final json = {
        'lengthCm': 50,
        'widthCm': 30,
        'heightCm': 20,
        'weightKg': 5,
        'qty': 10,
        'itemType': 'Boxes',
      };

      final carton = CartonData.fromJson(json);

      expect(carton.lengthCm, 50.0);
      expect(carton.widthCm, 30.0);
      expect(carton.heightCm, 20.0);
      expect(carton.weightKg, 5.0);
    });

    test('converts double to int for qty', () {
      final json = {
        'lengthCm': 50.0,
        'widthCm': 30.0,
        'heightCm': 20.0,
        'weightKg': 5.0,
        'qty': 10.5,
        'itemType': 'Boxes',
      };

      final carton = CartonData.fromJson(json);

      expect(carton.qty, 10);
    });

    test('handles partial data', () {
      final json = {'lengthCm': 50.0, 'itemType': 'Boxes'};

      final carton = CartonData.fromJson(json);

      expect(carton.lengthCm, 50.0);
      expect(carton.itemType, 'Boxes');
      expect(carton.widthCm, isNull);
      expect(carton.heightCm, isNull);
      expect(carton.weightKg, isNull);
      expect(carton.qty, isNull);
    });

    test('handles mixed int/double types', () {
      final json = {
        'lengthCm': 50,
        'widthCm': 30.5,
        'heightCm': 20,
        'weightKg': 5.25,
        'qty': 10,
        'itemType': 'Mixed',
      };

      final carton = CartonData.fromJson(json);

      expect(carton.lengthCm, 50.0);
      expect(carton.widthCm, 30.5);
      expect(carton.heightCm, 20.0);
      expect(carton.weightKg, 5.25);
      expect(carton.qty, 10);
    });

    test('handles zero values', () {
      final json = {
        'lengthCm': 0,
        'widthCm': 0,
        'heightCm': 0,
        'weightKg': 0,
        'qty': 0,
        'itemType': 'Empty',
      };

      final carton = CartonData.fromJson(json);

      expect(carton.lengthCm, 0.0);
      expect(carton.widthCm, 0.0);
      expect(carton.heightCm, 0.0);
      expect(carton.weightKg, 0.0);
      expect(carton.qty, 0);
    });

    test('handles negative values', () {
      final json = {
        'lengthCm': -50.0,
        'widthCm': -30.0,
        'heightCm': -20.0,
        'weightKg': -5.0,
        'qty': -10,
        'itemType': 'Negative',
      };

      final carton = CartonData.fromJson(json);

      expect(carton.lengthCm, -50.0);
      expect(carton.widthCm, -30.0);
      expect(carton.heightCm, -20.0);
      expect(carton.weightKg, -5.0);
      expect(carton.qty, -10);
    });

    test('handles very large numbers', () {
      final json = {
        'lengthCm': 999999.99,
        'widthCm': 999999.99,
        'heightCm': 999999.99,
        'weightKg': 999999.99,
        'qty': 999999,
        'itemType': 'Large',
      };

      final carton = CartonData.fromJson(json);

      expect(carton.lengthCm, 999999.99);
      expect(carton.widthCm, 999999.99);
      expect(carton.heightCm, 999999.99);
      expect(carton.weightKg, 999999.99);
      expect(carton.qty, 999999);
    });

    test('handles empty string for itemType', () {
      final json = {
        'lengthCm': 50.0,
        'widthCm': 30.0,
        'heightCm': 20.0,
        'weightKg': 5.0,
        'qty': 10,
        'itemType': '',
      };

      final carton = CartonData.fromJson(json);

      expect(carton.itemType, '');
    });
  });

  group('CartonData - isComplete', () {
    test('returns true when all fields are present', () {
      final carton = const CartonData(
        lengthCm: 50,
        widthCm: 30,
        heightCm: 20,
        weightKg: 5,
        qty: 10,
        itemType: 'Laptops',
      );

      expect(carton.isComplete, true);
    });

    test('returns true when all fields are zero but present', () {
      final carton = const CartonData(
        lengthCm: 0,
        widthCm: 0,
        heightCm: 0,
        weightKg: 0,
        qty: 0,
        itemType: '',
      );

      expect(carton.isComplete, true);
    });

    test('returns false when lengthCm is null', () {
      final carton = const CartonData(
        widthCm: 30,
        heightCm: 20,
        weightKg: 5,
        qty: 10,
        itemType: 'Laptops',
      );

      expect(carton.isComplete, false);
    });

    test('returns false when widthCm is null', () {
      final carton = const CartonData(
        lengthCm: 50,
        heightCm: 20,
        weightKg: 5,
        qty: 10,
        itemType: 'Laptops',
      );

      expect(carton.isComplete, false);
    });

    test('returns false when heightCm is null', () {
      final carton = const CartonData(
        lengthCm: 50,
        widthCm: 30,
        weightKg: 5,
        qty: 10,
        itemType: 'Laptops',
      );

      expect(carton.isComplete, false);
    });

    test('returns false when weightKg is null', () {
      final carton = const CartonData(
        lengthCm: 50,
        widthCm: 30,
        heightCm: 20,
        qty: 10,
        itemType: 'Laptops',
      );

      expect(carton.isComplete, false);
    });

    test('returns false when qty is null', () {
      final carton = const CartonData(
        lengthCm: 50,
        widthCm: 30,
        heightCm: 20,
        weightKg: 5,
        itemType: 'Laptops',
      );

      expect(carton.isComplete, false);
    });

    test('returns false when itemType is null', () {
      final carton = const CartonData(
        lengthCm: 50,
        widthCm: 30,
        heightCm: 20,
        weightKg: 5,
        qty: 10,
      );

      expect(carton.isComplete, false);
    });

    test('returns false when all fields are null', () {
      final carton = const CartonData();

      expect(carton.isComplete, false);
    });

    test('returns false when only one field is present', () {
      final carton = const CartonData(lengthCm: 50);

      expect(carton.isComplete, false);
    });
  });

  group('CartonData - toCarton', () {
    test('creates Carton with all fields', () {
      final cartonData = const CartonData(
        lengthCm: 50,
        widthCm: 30,
        heightCm: 20,
        weightKg: 5.5,
        qty: 10,
        itemType: 'Laptops',
      );

      final carton = cartonData.toCarton(
        id: 'test-id',
        shipmentId: 'shipment-123',
      );

      expect(carton.id, 'test-id');
      expect(carton.shipmentId, 'shipment-123');
      expect(carton.lengthCm, 50);
      expect(carton.widthCm, 30);
      expect(carton.heightCm, 20);
      expect(carton.weightKg, 5.5);
      expect(carton.qty, 10);
      expect(carton.itemType, 'Laptops');
    });

    test('provides fallback values for null fields', () {
      final cartonData = const CartonData();

      final carton = cartonData.toCarton(
        id: 'test-id',
        shipmentId: 'shipment-123',
      );

      expect(carton.id, 'test-id');
      expect(carton.shipmentId, 'shipment-123');
      expect(carton.lengthCm, 0);
      expect(carton.widthCm, 0);
      expect(carton.heightCm, 0);
      expect(carton.weightKg, 0);
      expect(carton.qty, 1);
      expect(carton.itemType, 'Unknown');
    });

    test('provides fallback for partial data', () {
      final cartonData = const CartonData(lengthCm: 50, weightKg: 5);

      final carton = cartonData.toCarton(
        id: 'test-id',
        shipmentId: 'shipment-123',
      );

      expect(carton.lengthCm, 50);
      expect(carton.widthCm, 0);
      expect(carton.heightCm, 0);
      expect(carton.weightKg, 5);
      expect(carton.qty, 1);
      expect(carton.itemType, 'Unknown');
    });

    test('preserves zero values instead of using fallbacks', () {
      final cartonData = const CartonData(
        lengthCm: 0,
        widthCm: 0,
        heightCm: 0,
        weightKg: 0,
        qty: 0,
        itemType: '',
      );

      final carton = cartonData.toCarton(
        id: 'test-id',
        shipmentId: 'shipment-123',
      );

      expect(carton.lengthCm, 0);
      expect(carton.widthCm, 0);
      expect(carton.heightCm, 0);
      expect(carton.weightKg, 0);
      expect(carton.qty, 0);
      expect(carton.itemType, '');
    });

    test('handles mixed null and valid fields', () {
      final cartonData = const CartonData(
        lengthCm: 50,
        widthCm: 30,
        itemType: 'Boxes',
      );

      final carton = cartonData.toCarton(
        id: 'test-id',
        shipmentId: 'shipment-123',
      );

      expect(carton.lengthCm, 50);
      expect(carton.widthCm, 30);
      expect(carton.heightCm, 0);
      expect(carton.weightKg, 0);
      expect(carton.qty, 1);
      expect(carton.itemType, 'Boxes');
    });
  });

  group('CartonData - toString', () {
    test('formats complete data correctly', () {
      final carton = const CartonData(
        lengthCm: 50,
        widthCm: 30,
        heightCm: 20,
        weightKg: 5.5,
        qty: 10,
        itemType: 'Laptops',
      );

      expect(
        carton.toString(),
        'CartonData(50.0×30.0×20.0 cm, 5.5 kg, qty:10, type:Laptops)',
      );
    });

    test('formats partial data with nulls', () {
      final carton = const CartonData(lengthCm: 50, itemType: 'Boxes');

      expect(
        carton.toString(),
        'CartonData(50.0×null×null cm, null kg, qty:null, type:Boxes)',
      );
    });

    test('formats data with all nulls', () {
      final carton = const CartonData();

      expect(
        carton.toString(),
        'CartonData(null×null×null cm, null kg, qty:null, type:null)',
      );
    });

    test('formats data with zero values', () {
      final carton = const CartonData(
        lengthCm: 0,
        widthCm: 0,
        heightCm: 0,
        weightKg: 0,
        qty: 0,
        itemType: 'Empty',
      );

      expect(
        carton.toString(),
        'CartonData(0.0×0.0×0.0 cm, 0.0 kg, qty:0, type:Empty)',
      );
    });

    test('formats data with decimal values', () {
      final carton = const CartonData(
        lengthCm: 50.5,
        widthCm: 30.25,
        heightCm: 20.75,
        weightKg: 5.125,
        qty: 10,
        itemType: 'Precise',
      );

      expect(
        carton.toString(),
        'CartonData(50.5×30.25×20.75 cm, 5.125 kg, qty:10, type:Precise)',
      );
    });
  });

  group('CartonData - Constructor', () {
    test('creates instance with all fields', () {
      final carton = const CartonData(
        lengthCm: 50,
        widthCm: 30,
        heightCm: 20,
        weightKg: 5,
        qty: 10,
        itemType: 'Boxes',
      );

      expect(carton.lengthCm, 50);
      expect(carton.widthCm, 30);
      expect(carton.heightCm, 20);
      expect(carton.weightKg, 5);
      expect(carton.qty, 10);
      expect(carton.itemType, 'Boxes');
    });

    test('creates instance with no fields (all null)', () {
      final carton = const CartonData();

      expect(carton.lengthCm, isNull);
      expect(carton.widthCm, isNull);
      expect(carton.heightCm, isNull);
      expect(carton.weightKg, isNull);
      expect(carton.qty, isNull);
      expect(carton.itemType, isNull);
    });

    test('creates instance with partial fields', () {
      final carton = const CartonData(lengthCm: 50, itemType: 'Partial');

      expect(carton.lengthCm, 50);
      expect(carton.itemType, 'Partial');
      expect(carton.widthCm, isNull);
      expect(carton.heightCm, isNull);
      expect(carton.weightKg, isNull);
      expect(carton.qty, isNull);
    });
  });
}
