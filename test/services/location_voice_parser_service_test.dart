import 'package:bockaire/services/ai_provider_interfaces.dart';
import 'package:bockaire/services/location_voice_parser_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocationVoiceParserService service;

  setUp(() {
    service = LocationVoiceParserService('test_api_key');
  });

  group('LocationVoiceParserService', () {
    test('constructor initializes with API key', () {
      expect(service, isNotNull);
    });

    test('parseLocationFromText throws on invalid API key', () async {
      final invalidService = LocationVoiceParserService('invalid_key');

      expect(
        () => invalidService.parseLocationFromText(
          transcribedText: 'from London to Paris',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('parseLocationFromText handles empty transcription', () async {
      expect(
        () => service.parseLocationFromText(transcribedText: ''),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('ShipmentLocationData', () {
    test('isComplete returns true when both cities are present', () {
      const data = ShipmentLocationData(
        originCity: 'London',
        destinationCity: 'Paris',
      );

      expect(data.isComplete, isTrue);
    });

    test('isComplete returns false when origin is missing', () {
      const data = ShipmentLocationData(
        originCity: null,
        destinationCity: 'Paris',
      );

      expect(data.isComplete, isFalse);
    });

    test('isComplete returns false when destination is missing', () {
      const data = ShipmentLocationData(
        originCity: 'London',
        destinationCity: null,
      );

      expect(data.isComplete, isFalse);
    });

    test('isComplete returns false when both cities are missing', () {
      const data = ShipmentLocationData(
        originCity: null,
        destinationCity: null,
      );

      expect(data.isComplete, isFalse);
    });

    test('toString returns formatted string', () {
      const data = ShipmentLocationData(
        originCity: 'Shanghai',
        destinationCity: 'New York',
      );

      expect(
        data.toString(),
        'ShipmentLocationData(from: Shanghai, to: New York)',
      );
    });

    test('toString handles null values', () {
      const data = ShipmentLocationData(
        originCity: null,
        destinationCity: null,
      );

      expect(data.toString(), 'ShipmentLocationData(from: null, to: null)');
    });

    test('can be created with const constructor', () {
      const data1 = ShipmentLocationData(
        originCity: 'London',
        destinationCity: 'Paris',
      );
      const data2 = ShipmentLocationData(
        originCity: 'London',
        destinationCity: 'Paris',
      );

      expect(identical(data1, data2), isTrue);
    });

    test('handles multi-word city names', () {
      const data = ShipmentLocationData(
        originCity: 'Los Angeles',
        destinationCity: 'New York',
      );

      expect(data.originCity, 'Los Angeles');
      expect(data.destinationCity, 'New York');
      expect(data.isComplete, isTrue);
    });

    test('handles special characters in city names', () {
      const data = ShipmentLocationData(
        originCity: 'São Paulo',
        destinationCity: 'München',
      );

      expect(data.originCity, 'São Paulo');
      expect(data.destinationCity, 'München');
      expect(data.isComplete, isTrue);
    });
  });
}
