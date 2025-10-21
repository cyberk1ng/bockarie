import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bockaire/services/shippo_service.dart';
import 'package:bockaire/database/database.dart';
import 'package:dio/dio.dart';

// Reuse existing mocks from shippo_service_test.dart
class MockDio extends Mock implements Dio {}

class MockInterceptors extends Mock implements Interceptors {}

class FakeInterceptor extends Fake implements Interceptor {}

void main() {
  setUpAll(() async {
    registerFallbackValue(RequestOptions());
    registerFallbackValue(BaseOptions());
    registerFallbackValue(FakeInterceptor());
  });

  group('ShippoService - Test Mode Parcel Consolidation', () {
    late MockDio mockDio;
    late MockInterceptors mockInterceptors;
    late ShippoService service;

    setUp(() {
      mockDio = MockDio();
      mockInterceptors = MockInterceptors();
      when(() => mockDio.interceptors).thenReturn(mockInterceptors);
      when(() => mockInterceptors.add(any())).thenReturn(null);
    });

    group('Test Mode (USE_TEST_MODE=true)', () {
      setUp(() async {
        // Load test environment
        dotenv.testLoad(
          fileInput: 'USE_TEST_MODE=true\nSHIPPO_TEST_API_KEY=test_key',
        );
        service = ShippoService(dio: mockDio);
      });

      test('consolidates multi-quantity carton into single parcel', () async {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 50,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 10, // Multi-quantity
            itemType: 'Box',
          ),
        ];

        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 201,
            data: {
              'object_id': 'shipment_123',
              'object_state': 'VALID',
              'rates': [],
            },
          ),
        );

        await service.getRates(
          originCity: 'Bremen',
          originPostal: '28195',
          originCountry: 'DE',
          destCity: 'Hamburg',
          destPostal: '20095',
          destCountry: 'DE',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final parcels = captured['parcels'] as List;

        // CRITICAL ASSERTIONS
        expect(
          parcels,
          hasLength(1),
          reason: 'Should consolidate into 1 parcel',
        );
        expect(
          parcels[0]['weight'],
          '50.00',
          reason: 'Weight should be 5kg × 10 = 50kg',
        );
        expect(parcels[0]['length'], '50');
        expect(parcels[0]['width'], '30');
        expect(parcels[0]['height'], '20');
      });

      test('does NOT consolidate single-quantity carton', () async {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 50,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 1, // Single quantity - should not consolidate
            itemType: 'Box',
          ),
        ];

        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 201,
            data: {
              'object_id': 'shipment_123',
              'object_state': 'VALID',
              'rates': [],
            },
          ),
        );

        await service.getRates(
          originCity: 'Bremen',
          originPostal: '28195',
          originCountry: 'DE',
          destCity: 'Hamburg',
          destPostal: '20095',
          destCountry: 'DE',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final parcels = captured['parcels'] as List;

        expect(parcels, hasLength(1));
        expect(
          parcels[0]['weight'],
          '5.00',
          reason: 'Should keep original weight, not consolidate',
        );
      });

      test('handles mixed quantities correctly', () async {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 1, // Should not consolidate
            itemType: 'Box',
          ),
          const Carton(
            id: '2',
            shipmentId: 's1',
            lengthCm: 50,
            widthCm: 40,
            heightCm: 30,
            weightKg: 10.0,
            qty: 5, // Should consolidate to 50kg
            itemType: 'Box',
          ),
        ];

        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 201,
            data: {
              'object_id': 'shipment_123',
              'object_state': 'VALID',
              'rates': [],
            },
          ),
        );

        await service.getRates(
          originCity: 'Bremen',
          originPostal: '28195',
          originCountry: 'DE',
          destCity: 'Hamburg',
          destPostal: '20095',
          destCountry: 'DE',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final parcels = captured['parcels'] as List;

        expect(
          parcels,
          hasLength(2),
          reason: '1 individual + 1 consolidated = 2 parcels',
        );

        // First parcel: qty=1, not consolidated
        expect(parcels[0]['length'], '40');
        expect(parcels[0]['weight'], '5.00');

        // Second parcel: qty=5, consolidated
        expect(parcels[1]['length'], '50');
        expect(parcels[1]['weight'], '50.00', reason: '10kg × 5 = 50kg');
      });

      test('edge case: very high consolidation (qty=100)', () async {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 50,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 100, // Edge case: very high quantity
            itemType: 'Box',
          ),
        ];

        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 201,
            data: {
              'object_id': 'shipment_123',
              'object_state': 'VALID',
              'rates': [],
            },
          ),
        );

        await service.getRates(
          originCity: 'Bremen',
          originPostal: '28195',
          originCountry: 'DE',
          destCity: 'Hamburg',
          destPostal: '20095',
          destCountry: 'DE',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final parcels = captured['parcels'] as List;

        expect(parcels, hasLength(1));
        expect(parcels[0]['weight'], '500.00', reason: '5kg × 100 = 500kg');
      });
    });

    group('Production Mode (USE_TEST_MODE=false)', () {
      setUp(() async {
        // Load production environment
        dotenv.testLoad(
          fileInput: 'USE_TEST_MODE=false\nSHIPPO_LIVE_API_KEY=live_key',
        );
        service = ShippoService(dio: mockDio);
      });

      test('creates individual parcels for multi-quantity carton', () async {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 50,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 10, // Should create 10 separate parcels
            itemType: 'Box',
          ),
        ];

        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 201,
            data: {
              'object_id': 'shipment_123',
              'object_state': 'VALID',
              'rates': [],
            },
          ),
        );

        await service.getRates(
          originCity: 'Bremen',
          originPostal: '28195',
          originCountry: 'DE',
          destCity: 'Hamburg',
          destPostal: '20095',
          destCountry: 'DE',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final parcels = captured['parcels'] as List;

        // CRITICAL: Production mode should create 10 individual parcels
        expect(
          parcels,
          hasLength(10),
          reason: 'Should create 10 individual parcels in production',
        );

        // All parcels should have identical dimensions and weight
        for (final parcel in parcels) {
          expect(parcel['length'], '50');
          expect(parcel['width'], '30');
          expect(parcel['height'], '20');
          expect(
            parcel['weight'],
            '5.00',
            reason: 'Each parcel should be 5kg, not consolidated',
          );
        }
      });

      test('handles mixed quantities correctly in production', () async {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 2,
            itemType: 'Box',
          ),
          const Carton(
            id: '2',
            shipmentId: 's1',
            lengthCm: 50,
            widthCm: 40,
            heightCm: 30,
            weightKg: 10.0,
            qty: 3,
            itemType: 'Box',
          ),
        ];

        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 201,
            data: {
              'object_id': 'shipment_123',
              'object_state': 'VALID',
              'rates': [],
            },
          ),
        );

        await service.getRates(
          originCity: 'Bremen',
          originPostal: '28195',
          originCountry: 'DE',
          destCity: 'Hamburg',
          destPostal: '20095',
          destCountry: 'DE',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final parcels = captured['parcels'] as List;

        expect(parcels, hasLength(5), reason: '2 + 3 = 5 individual parcels');

        // First 2 parcels from first carton
        expect(parcels[0]['weight'], '5.00');
        expect(parcels[1]['weight'], '5.00');

        // Last 3 parcels from second carton
        expect(parcels[2]['weight'], '10.00');
        expect(parcels[3]['weight'], '10.00');
        expect(parcels[4]['weight'], '10.00');
      });
    });
  });
}
