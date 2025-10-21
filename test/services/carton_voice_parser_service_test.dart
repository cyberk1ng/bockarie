import 'package:bockaire/services/ai_provider_interfaces.dart';
import 'package:bockaire/services/carton_voice_parser_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CartonVoiceParserService service;

  setUp(() {
    service = CartonVoiceParserService('test_api_key');
  });

  group('CartonVoiceParserService', () {
    test('constructor initializes with API key', () {
      expect(service, isNotNull);
    });

    test('parseCartonFromText throws on invalid API key', () async {
      final invalidService = CartonVoiceParserService('invalid_key');

      expect(
        () => invalidService.parseCartonFromText(
          transcribedText: '50 by 30 by 20 cm, 5 kg, quantity 10, laptops',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('parseCartonFromText handles empty transcription', () async {
      expect(
        () => service.parseCartonFromText(transcribedText: ''),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('CartonData', () {
    test('isComplete returns true when all fields are present', () {
      const data = CartonData(
        lengthCm: 50.0,
        widthCm: 30.0,
        heightCm: 20.0,
        weightKg: 5.0,
        qty: 10,
        itemType: 'laptops',
      );

      expect(data.isComplete, isTrue);
    });

    test('isComplete returns false when lengthCm is missing', () {
      const data = CartonData(
        lengthCm: null,
        widthCm: 30.0,
        heightCm: 20.0,
        weightKg: 5.0,
        qty: 10,
        itemType: 'laptops',
      );

      expect(data.isComplete, isFalse);
    });

    test('isComplete returns false when widthCm is missing', () {
      const data = CartonData(
        lengthCm: 50.0,
        widthCm: null,
        heightCm: 20.0,
        weightKg: 5.0,
        qty: 10,
        itemType: 'laptops',
      );

      expect(data.isComplete, isFalse);
    });

    test('isComplete returns false when heightCm is missing', () {
      const data = CartonData(
        lengthCm: 50.0,
        widthCm: 30.0,
        heightCm: null,
        weightKg: 5.0,
        qty: 10,
        itemType: 'laptops',
      );

      expect(data.isComplete, isFalse);
    });

    test('isComplete returns false when weightKg is missing', () {
      const data = CartonData(
        lengthCm: 50.0,
        widthCm: 30.0,
        heightCm: 20.0,
        weightKg: null,
        qty: 10,
        itemType: 'laptops',
      );

      expect(data.isComplete, isFalse);
    });

    test('isComplete returns false when qty is missing', () {
      const data = CartonData(
        lengthCm: 50.0,
        widthCm: 30.0,
        heightCm: 20.0,
        weightKg: 5.0,
        qty: null,
        itemType: 'laptops',
      );

      expect(data.isComplete, isFalse);
    });

    test('isComplete returns false when itemType is missing', () {
      const data = CartonData(
        lengthCm: 50.0,
        widthCm: 30.0,
        heightCm: 20.0,
        weightKg: 5.0,
        qty: 10,
        itemType: null,
      );

      expect(data.isComplete, isFalse);
    });

    test('isComplete returns false when all fields are missing', () {
      const data = CartonData(
        lengthCm: null,
        widthCm: null,
        heightCm: null,
        weightKg: null,
        qty: null,
        itemType: null,
      );

      expect(data.isComplete, isFalse);
    });

    test('toString returns formatted string', () {
      const data = CartonData(
        lengthCm: 50.0,
        widthCm: 30.0,
        heightCm: 20.0,
        weightKg: 5.0,
        qty: 10,
        itemType: 'laptops',
      );

      expect(
        data.toString(),
        'CartonData(50.0×30.0×20.0 cm, 5.0 kg, type:laptops, qty:10)',
      );
    });

    test('toString handles null values', () {
      const data = CartonData(
        lengthCm: null,
        widthCm: null,
        heightCm: null,
        weightKg: null,
        qty: null,
        itemType: null,
      );

      expect(data.toString(), 'CartonData(null×null×null cm, null kg, qty:1)');
    });

    test('toCarton converts complete data to Carton object', () {
      const data = CartonData(
        lengthCm: 50.0,
        widthCm: 30.0,
        heightCm: 20.0,
        weightKg: 5.0,
        qty: 10,
        itemType: 'laptops',
      );

      final carton = data.toCarton(id: 'test-id', shipmentId: 'shipment-123');

      expect(carton.id, 'test-id');
      expect(carton.shipmentId, 'shipment-123');
      expect(carton.lengthCm, 50.0);
      expect(carton.widthCm, 30.0);
      expect(carton.heightCm, 20.0);
      expect(carton.weightKg, 5.0);
      expect(carton.qty, 10);
      expect(carton.itemType, 'laptops');
    });

    test('toCarton uses default values for null fields', () {
      const data = CartonData(
        lengthCm: null,
        widthCm: null,
        heightCm: null,
        weightKg: null,
        qty: null,
        itemType: null,
      );

      final carton = data.toCarton(id: 'test-id', shipmentId: 'shipment-123');

      expect(carton.lengthCm, 0);
      expect(carton.widthCm, 0);
      expect(carton.heightCm, 0);
      expect(carton.weightKg, 0);
      expect(carton.qty, 1);
      expect(carton.itemType, 'Unknown');
    });

    test('handles decimal dimensions', () {
      const data = CartonData(
        lengthCm: 50.5,
        widthCm: 30.7,
        heightCm: 20.2,
        weightKg: 5.3,
        qty: 10,
        itemType: 'boxes',
      );

      expect(data.lengthCm, 50.5);
      expect(data.widthCm, 30.7);
      expect(data.heightCm, 20.2);
      expect(data.weightKg, 5.3);
      expect(data.isComplete, isTrue);
    });

    test('handles integer quantities', () {
      const data = CartonData(
        lengthCm: 50.0,
        widthCm: 30.0,
        heightCm: 20.0,
        weightKg: 5.0,
        qty: 1,
        itemType: 'single item',
      );

      expect(data.qty, 1);
      expect(data.isComplete, isTrue);
    });

    test('handles large quantities', () {
      const data = CartonData(
        lengthCm: 50.0,
        widthCm: 30.0,
        heightCm: 20.0,
        weightKg: 5.0,
        qty: 1000,
        itemType: 'small parts',
      );

      expect(data.qty, 1000);
      expect(data.isComplete, isTrue);
    });

    test('handles very small dimensions', () {
      const data = CartonData(
        lengthCm: 1.0,
        widthCm: 1.0,
        heightCm: 1.0,
        weightKg: 0.1,
        qty: 1,
        itemType: 'tiny item',
      );

      expect(data.lengthCm, 1.0);
      expect(data.widthCm, 1.0);
      expect(data.heightCm, 1.0);
      expect(data.weightKg, 0.1);
      expect(data.isComplete, isTrue);
    });

    test('handles very large dimensions', () {
      const data = CartonData(
        lengthCm: 500.0,
        widthCm: 300.0,
        heightCm: 200.0,
        weightKg: 1000.0,
        qty: 1,
        itemType: 'large item',
      );

      expect(data.lengthCm, 500.0);
      expect(data.widthCm, 300.0);
      expect(data.heightCm, 200.0);
      expect(data.weightKg, 1000.0);
      expect(data.isComplete, isTrue);
    });

    test('handles zero dimensions', () {
      const data = CartonData(
        lengthCm: 0.0,
        widthCm: 0.0,
        heightCm: 0.0,
        weightKg: 0.0,
        qty: 0,
        itemType: 'empty',
      );

      // Zero values are still considered "complete" as they are not null
      expect(data.isComplete, isTrue);
    });

    test('can be created with const constructor', () {
      const data1 = CartonData(
        lengthCm: 50.0,
        widthCm: 30.0,
        heightCm: 20.0,
        weightKg: 5.0,
        qty: 10,
        itemType: 'laptops',
      );
      const data2 = CartonData(
        lengthCm: 50.0,
        widthCm: 30.0,
        heightCm: 20.0,
        weightKg: 5.0,
        qty: 10,
        itemType: 'laptops',
      );

      expect(identical(data1, data2), isTrue);
    });

    test('handles item types with special characters', () {
      const data = CartonData(
        lengthCm: 50.0,
        widthCm: 30.0,
        heightCm: 20.0,
        weightKg: 5.0,
        qty: 10,
        itemType: 'Electronics & Gadgets',
      );

      expect(data.itemType, 'Electronics & Gadgets');
      expect(data.isComplete, isTrue);
    });

    test('handles multi-word item types', () {
      const data = CartonData(
        lengthCm: 50.0,
        widthCm: 30.0,
        heightCm: 20.0,
        weightKg: 5.0,
        qty: 10,
        itemType: 'Computer Parts and Accessories',
      );

      expect(data.itemType, 'Computer Parts and Accessories');
      expect(data.isComplete, isTrue);
    });
  });
}
