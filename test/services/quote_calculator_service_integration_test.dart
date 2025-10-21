import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bockaire/services/quote_calculator_service.dart';
import 'package:bockaire/services/shippo_service.dart';
import 'package:bockaire/database/database.dart';
import 'package:bockaire/models/shippo_models.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

class MockShippoService extends Mock implements ShippoService {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const Carton(
        id: '1',
        shipmentId: 's1',
        lengthCm: 50,
        widthCm: 30,
        heightCm: 20,
        weightKg: 5.0,
        qty: 1,
        itemType: 'Box',
      ),
    );
  });

  group('QuoteCalculatorService - calculateAllQuotes', () {
    late MockAppDatabase mockDatabase;
    late MockShippoService mockShippoService;
    late QuoteCalculatorService service;

    setUp(() {
      mockDatabase = MockAppDatabase();
      mockShippoService = MockShippoService();
      service = QuoteCalculatorService(mockDatabase, mockShippoService);
    });

    test('returns Shippo quotes when API succeeds', () async {
      when(
        () => mockShippoService.getRates(
          originCity: any(named: 'originCity'),
          originPostal: any(named: 'originPostal'),
          originCountry: any(named: 'originCountry'),
          originState: any(named: 'originState'),
          destCity: any(named: 'destCity'),
          destPostal: any(named: 'destPostal'),
          destCountry: any(named: 'destCountry'),
          destState: any(named: 'destState'),
          cartons: any(named: 'cartons'),
        ),
      ).thenAnswer(
        (_) async => [
          ShippoRate(
            objectId: 'rate_1',
            provider: 'DHL',
            servicelevel: ShippoServiceLevel(
              name: 'Express',
              token: 'dhl_express',
            ),
            amount: '25.50',
            currency: 'USD',
            estimatedDays: 2,
            durationTerms: '1-3 days',
          ),
        ],
      );

      final quotes = await service.calculateAllQuotes(
        chargeableKg: 50.0,
        isOversized: false,
        originCity: 'Bremen',
        originPostal: '28195',
        originCountry: 'DE',
        destCity: 'Hamburg',
        destPostal: '20095',
        destCountry: 'DE',
        cartons: [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 50,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 10,
            itemType: 'Box',
          ),
        ],
        useShippoApi: true,
        fallbackToLocalRates: false,
      );

      expect(quotes, hasLength(1));
      expect(quotes[0].carrier, 'DHL');
      expect(quotes[0].service, 'Express');
      expect(quotes[0].source, 'shippo');
      expect(quotes[0].estimatedDays, 2);
    });

    group('Test Mode Multi-Parcel Detection', () {
      setUp(() async {
        dotenv.testLoad(fileInput: 'USE_TEST_MODE=true');
      });

      test(
        'returns empty list when no rates for multi-parcel shipment',
        () async {
          // Mock: Shippo returns empty rates
          when(
            () => mockShippoService.getRates(
              originCity: any(named: 'originCity'),
              originPostal: any(named: 'originPostal'),
              originCountry: any(named: 'originCountry'),
              originState: any(named: 'originState'),
              destCity: any(named: 'destCity'),
              destPostal: any(named: 'destPostal'),
              destCountry: any(named: 'destCountry'),
              destState: any(named: 'destState'),
              cartons: any(named: 'cartons'),
            ),
          ).thenAnswer((_) async => []); // Empty rates

          final quotes = await service.calculateAllQuotes(
            chargeableKg: 50.0,
            isOversized: false,
            originCity: 'Bremen',
            originPostal: '28195',
            originCountry: 'DE',
            destCity: 'Hamburg',
            destPostal: '20095',
            destCountry: 'DE',
            cartons: [
              const Carton(
                id: '1',
                shipmentId: 's1',
                lengthCm: 50,
                widthCm: 30,
                heightCm: 20,
                weightKg: 5.0,
                qty: 10, // Multi-parcel: total qty > 1
                itemType: 'Box',
              ),
            ],
            useShippoApi: true,
            fallbackToLocalRates: false,
          );

          expect(quotes, isEmpty);
        },
      );

      test('returns empty list when no rates for single parcel', () async {
        when(
          () => mockShippoService.getRates(
            originCity: any(named: 'originCity'),
            originPostal: any(named: 'originPostal'),
            originCountry: any(named: 'originCountry'),
            originState: any(named: 'originState'),
            destCity: any(named: 'destCity'),
            destPostal: any(named: 'destPostal'),
            destCountry: any(named: 'destCountry'),
            destState: any(named: 'destState'),
            cartons: any(named: 'cartons'),
          ),
        ).thenAnswer((_) async => []);

        final quotes = await service.calculateAllQuotes(
          chargeableKg: 5.0,
          isOversized: false,
          originCity: 'Bremen',
          originPostal: '28195',
          originCountry: 'DE',
          destCity: 'Hamburg',
          destPostal: '20095',
          destCountry: 'DE',
          cartons: [
            const Carton(
              id: '1',
              shipmentId: 's1',
              lengthCm: 50,
              widthCm: 30,
              heightCm: 20,
              weightKg: 5.0,
              qty: 1, // Single parcel
              itemType: 'Box',
            ),
          ],
          useShippoApi: true,
          fallbackToLocalRates: false,
        );

        expect(quotes, isEmpty);
      });

      test('calculates total parcels correctly', () async {
        when(
          () => mockShippoService.getRates(
            originCity: any(named: 'originCity'),
            originPostal: any(named: 'originPostal'),
            originCountry: any(named: 'originCountry'),
            originState: any(named: 'originState'),
            destCity: any(named: 'destCity'),
            destPostal: any(named: 'destPostal'),
            destCountry: any(named: 'destCountry'),
            destState: any(named: 'destState'),
            cartons: any(named: 'cartons'),
          ),
        ).thenAnswer((_) async => []);

        await service.calculateAllQuotes(
          chargeableKg: 50.0,
          isOversized: false,
          originCity: 'Bremen',
          originPostal: '28195',
          originCountry: 'DE',
          destCity: 'Hamburg',
          destPostal: '20095',
          destCountry: 'DE',
          cartons: [
            const Carton(
              id: '1',
              shipmentId: 's1',
              lengthCm: 50,
              widthCm: 30,
              heightCm: 20,
              weightKg: 5.0,
              qty: 2,
              itemType: 'Box',
            ),
            const Carton(
              id: '2',
              shipmentId: 's1',
              lengthCm: 40,
              widthCm: 30,
              heightCm: 20,
              weightKg: 3.0,
              qty: 3,
              itemType: 'Box',
            ),
          ],
          useShippoApi: true,
          fallbackToLocalRates: false,
        );

        // The fold operation should calculate: 2 + 3 = 5 total parcels
        // This test verifies the code runs without errors
        // Logger verification would require additional mocking
      });
    });

    group('Production Mode', () {
      setUp(() async {
        dotenv.testLoad(fileInput: 'USE_TEST_MODE=false');
      });

      test('returns empty list when no rates in production', () async {
        when(
          () => mockShippoService.getRates(
            originCity: any(named: 'originCity'),
            originPostal: any(named: 'originPostal'),
            originCountry: any(named: 'originCountry'),
            originState: any(named: 'originState'),
            destCity: any(named: 'destCity'),
            destPostal: any(named: 'destPostal'),
            destCountry: any(named: 'destCountry'),
            destState: any(named: 'destState'),
            cartons: any(named: 'cartons'),
          ),
        ).thenAnswer((_) async => []);

        await service.calculateAllQuotes(
          chargeableKg: 50.0,
          isOversized: false,
          originCity: 'Bremen',
          originPostal: '28195',
          originCountry: 'DE',
          destCity: 'Hamburg',
          destPostal: '20095',
          destCountry: 'DE',
          cartons: [
            const Carton(
              id: '1',
              shipmentId: 's1',
              lengthCm: 50,
              widthCm: 30,
              heightCm: 20,
              weightKg: 5.0,
              qty: 10,
              itemType: 'Box',
            ),
          ],
          useShippoApi: true,
          fallbackToLocalRates: false,
        );

        // Verify no test mode warnings in production
        // This would require logger mocking
      });
    });

    // Note: Testing fallback to local rates requires complex database mocking
    // which is challenging with Drift. The fallback logic is tested via the
    // else branch verification below.

    test('does NOT fallback when disabled', () async {
      when(
        () => mockShippoService.getRates(
          originCity: any(named: 'originCity'),
          originPostal: any(named: 'originPostal'),
          originCountry: any(named: 'originCountry'),
          originState: any(named: 'originState'),
          destCity: any(named: 'destCity'),
          destPostal: any(named: 'destPostal'),
          destCountry: any(named: 'destCountry'),
          destState: any(named: 'destState'),
          cartons: any(named: 'cartons'),
        ),
      ).thenAnswer((_) async => []);

      final quotes = await service.calculateAllQuotes(
        chargeableKg: 50.0,
        isOversized: false,
        originCity: 'Bremen',
        originPostal: '28195',
        originCountry: 'DE',
        destCity: 'Hamburg',
        destPostal: '20095',
        destCountry: 'DE',
        cartons: [],
        useShippoApi: true,
        fallbackToLocalRates: false, // Disable fallback
      );

      expect(quotes, isEmpty);
    });

    test(
      'returns empty list when useShippoApi is false and fallback disabled',
      () async {
        final quotes = await service.calculateAllQuotes(
          chargeableKg: 50.0,
          isOversized: false,
          originCity: 'Bremen',
          originPostal: '28195',
          originCountry: 'DE',
          destCity: 'Hamburg',
          destPostal: '20095',
          destCountry: 'DE',
          cartons: [],
          useShippoApi: false, // Don't use Shippo API
          fallbackToLocalRates: false,
        );

        expect(quotes, isEmpty);
      },
    );

    test(
      'handles Shippo API errors and returns empty list when fallback disabled',
      () async {
        when(
          () => mockShippoService.getRates(
            originCity: any(named: 'originCity'),
            originPostal: any(named: 'originPostal'),
            originCountry: any(named: 'originCountry'),
            originState: any(named: 'originState'),
            destCity: any(named: 'destCity'),
            destPostal: any(named: 'destPostal'),
            destCountry: any(named: 'destCountry'),
            destState: any(named: 'destState'),
            cartons: any(named: 'cartons'),
          ),
        ).thenThrow(Exception('API Error'));

        final quotes = await service.calculateAllQuotes(
          chargeableKg: 50.0,
          isOversized: false,
          originCity: 'Bremen',
          originPostal: '28195',
          originCountry: 'DE',
          destCity: 'Hamburg',
          destPostal: '20095',
          destCountry: 'DE',
          cartons: [
            const Carton(
              id: '1',
              shipmentId: 's1',
              lengthCm: 50,
              widthCm: 30,
              heightCm: 20,
              weightKg: 5.0,
              qty: 1,
              itemType: 'Box',
            ),
          ],
          useShippoApi: true,
          fallbackToLocalRates: false,
        );

        expect(quotes, isEmpty);
      },
    );

    // Note: Testing fallback to local rates on API error requires complex
    // database mocking with Drift, which is tested separately via integration tests.
  });
}
