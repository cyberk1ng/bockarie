import 'dart:io';
import 'package:bockaire/services/ai_provider_interfaces.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GeminiImageAnalyzer analyzer;
  late File testImageFile;
  late Directory tempDir;

  setUp(() async {
    analyzer = GeminiImageAnalyzer(
      apiKey: 'test_api_key_1234567890',
      model: 'gemini-2.0-flash-exp',
    );

    // Create a temporary test image
    tempDir = await Directory.systemTemp.createTemp('gemini_test_');
    testImageFile = File('${tempDir.path}/test_image.jpg');
    await testImageFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]); // JPEG header
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('GeminiImageAnalyzer - Basic Properties', () {
    test('name returns correct format', () {
      expect(analyzer.name, 'Gemini Vision (gemini-2.0-flash-exp)');
    });

    test('isAvailable returns true when API key is not empty', () {
      expect(analyzer.isAvailable, true);
    });

    test('isAvailable returns false when API key is empty', () {
      final emptyAnalyzer = GeminiImageAnalyzer(apiKey: '');
      expect(emptyAnalyzer.isAvailable, false);
    });

    test('uses default model when not specified', () {
      final defaultAnalyzer = GeminiImageAnalyzer(apiKey: 'test_key');
      expect(defaultAnalyzer.model, 'gemini-2.0-flash-exp');
    });

    test('uses custom model when specified', () {
      final customAnalyzer = GeminiImageAnalyzer(
        apiKey: 'test_key',
        model: 'gemini-pro-vision',
      );
      expect(customAnalyzer.model, 'gemini-pro-vision');
    });
  });

  group('GeminiImageAnalyzer - Error Handling', () {
    test('handles file read errors', () async {
      final nonExistentFile = File('${tempDir.path}/nonexistent.jpg');

      expect(
        () => analyzer.extractCartonsFromImage(nonExistentFile),
        throwsA(isA<Exception>()),
      );
    });

    test('throws on invalid API key', () async {
      // With invalid API key, should throw an exception
      expect(
        () => analyzer.extractCartonsFromImage(testImageFile),
        throwsA(isA<Exception>()),
      );
    });
  });

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
        'CartonData(50.0×30.0×20.0 cm, 5.5 kg, type:Laptops, qty:10)',
      );
    });

    test('formats partial data with nulls', () {
      final carton = const CartonData(lengthCm: 50, itemType: 'Boxes');

      expect(
        carton.toString(),
        'CartonData(50.0×null×null cm, null kg, type:Boxes, qty:1)',
      );
    });
  });
}
