import 'package:bockaire/services/shippo_service.dart';
import 'package:bockaire/database/database.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MockDio extends Mock implements Dio {}

class MockInterceptors extends Mock implements Interceptors {}

class FakeInterceptor extends Fake implements Interceptor {}

void main() {
  // Load environment variables before all tests
  setUpAll(() async {
    await dotenv.load(fileName: '.env');
    // Register fallback values for mocktail
    registerFallbackValue(RequestOptions());
    registerFallbackValue(BaseOptions());
    registerFallbackValue(FakeInterceptor());
  });

  group('ShippoService', () {
    late MockDio mockDio;
    late MockInterceptors mockInterceptors;
    late ShippoService service;

    setUp(() {
      // Set production mode for these tests (they expect individual parcels, not consolidation)
      dotenv.testLoad(
        fileInput: 'USE_TEST_MODE=false\nSHIPPO_LIVE_API_KEY=test_live_key',
      );

      mockDio = MockDio();
      mockInterceptors = MockInterceptors();

      // Mock the interceptors property
      when(() => mockDio.interceptors).thenReturn(mockInterceptors);
      when(() => mockInterceptors.add(any())).thenReturn(null);

      service = ShippoService(dio: mockDio);
    });

    group('getRates', () {
      final testCartons = [
        const Carton(
          id: '1',
          shipmentId: 's1',
          lengthCm: 40,
          widthCm: 30,
          heightCm: 20,
          weightKg: 5.5,
          qty: 1,
          itemType: 'Box',
        ),
      ];

      test('returns rates on successful API call', () async {
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 201,
            data: {
              'object_id': 'shipment_123',
              'object_state': 'VALID',
              'rates': [
                {
                  'object_id': 'rate_1',
                  'provider': 'USPS',
                  'servicelevel': {
                    'name': 'Priority',
                    'token': 'usps_priority',
                  },
                  'amount': '25.50',
                  'currency': 'USD',
                  'estimated_days': 2,
                },
              ],
            },
          ),
        );

        final rates = await service.getRates(
          originCity: 'New York',
          originPostal: '10001',
          originCountry: 'US',
          originState: 'NY',
          destCity: 'Atlanta',
          destPostal: '30303',
          destCountry: 'US',
          destState: 'GA',
          cartons: testCartons,
        );

        expect(rates, hasLength(1));
        expect(rates[0].provider, 'USPS');
        expect(rates[0].amount, '25.50');
        expect(rates[0].servicelevel.name, 'Priority');
        expect(rates[0].estimatedDays, 2);
      });

      test('returns empty list when API returns no rates', () async {
        // China→Germany scenario
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 201,
            data: {
              'object_id': 'shipment_456',
              'object_state': 'VALID',
              'rates': [],
            },
          ),
        );

        final rates = await service.getRates(
          originCity: 'Shanghai',
          originPostal: '200000',
          originCountry: 'CN',
          destCity: 'Berlin',
          destPostal: '10115',
          destCountry: 'DE',
          cartons: testCartons,
        );

        expect(rates, isEmpty);
      });

      test('throws ShippoServiceException on connection timeout', () async {
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        expect(
          () => service.getRates(
            originCity: 'New York',
            originPostal: '10001',
            originCountry: 'US',
            destCity: 'Atlanta',
            destPostal: '30303',
            destCountry: 'US',
            cartons: testCartons,
          ),
          throwsA(
            isA<ShippoServiceException>().having(
              (e) => e.message,
              'message',
              contains('timeout'),
            ),
          ),
        );
      });

      test('throws ShippoServiceException on send timeout', () async {
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.sendTimeout,
          ),
        );

        expect(
          () => service.getRates(
            originCity: 'New York',
            originPostal: '10001',
            originCountry: 'US',
            destCity: 'Atlanta',
            destPostal: '30303',
            destCountry: 'US',
            cartons: testCartons,
          ),
          throwsA(
            isA<ShippoServiceException>().having(
              (e) => e.message,
              'message',
              contains('timeout'),
            ),
          ),
        );
      });

      test('throws ShippoServiceException on receive timeout', () async {
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.receiveTimeout,
          ),
        );

        expect(
          () => service.getRates(
            originCity: 'New York',
            originPostal: '10001',
            originCountry: 'US',
            destCity: 'Atlanta',
            destPostal: '30303',
            destCountry: 'US',
            cartons: testCartons,
          ),
          throwsA(
            isA<ShippoServiceException>().having(
              (e) => e.message,
              'message',
              contains('timeout'),
            ),
          ),
        );
      });

      test(
        'throws ShippoServiceException on bad response with ShippoError JSON',
        () async {
          when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
            DioException(
              requestOptions: RequestOptions(),
              type: DioExceptionType.badResponse,
              response: Response(
                requestOptions: RequestOptions(),
                statusCode: 400,
                data: {'message': 'Invalid address', 'code': 'INVALID_ADDRESS'},
              ),
            ),
          );

          expect(
            () => service.getRates(
              originCity: 'New York',
              originPostal: '10001',
              originCountry: 'US',
              destCity: 'Atlanta',
              destPostal: '30303',
              destCountry: 'US',
              cartons: testCartons,
            ),
            throwsA(
              isA<ShippoServiceException>().having(
                (e) => e.message,
                'message',
                contains('Invalid address'),
              ),
            ),
          );
        },
      );

      test(
        'throws ShippoServiceException on bad response with non-JSON',
        () async {
          when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
            DioException(
              requestOptions: RequestOptions(),
              type: DioExceptionType.badResponse,
              response: Response(
                requestOptions: RequestOptions(),
                statusCode: 500,
                data: 'Internal Server Error',
              ),
            ),
          );

          expect(
            () => service.getRates(
              originCity: 'New York',
              originPostal: '10001',
              originCountry: 'US',
              destCity: 'Atlanta',
              destPostal: '30303',
              destCountry: 'US',
              cartons: testCartons,
            ),
            throwsA(isA<ShippoServiceException>()),
          );
        },
      );

      test('throws ShippoServiceException on request cancelled', () async {
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.cancel,
          ),
        );

        expect(
          () => service.getRates(
            originCity: 'New York',
            originPostal: '10001',
            originCountry: 'US',
            destCity: 'Atlanta',
            destPostal: '30303',
            destCountry: 'US',
            cartons: testCartons,
          ),
          throwsA(
            isA<ShippoServiceException>().having(
              (e) => e.message,
              'message',
              contains('cancelled'),
            ),
          ),
        );
      });

      test('throws ShippoServiceException on connection error', () async {
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionError,
          ),
        );

        expect(
          () => service.getRates(
            originCity: 'New York',
            originPostal: '10001',
            originCountry: 'US',
            destCity: 'Atlanta',
            destPostal: '30303',
            destCountry: 'US',
            cartons: testCartons,
          ),
          throwsA(
            isA<ShippoServiceException>().having(
              (e) => e.message,
              'message',
              contains('Connection error'),
            ),
          ),
        );
      });

      test(
        'throws ShippoServiceException on unknown DioException type',
        () async {
          when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
            DioException(
              requestOptions: RequestOptions(),
              type: DioExceptionType.unknown,
            ),
          );

          expect(
            () => service.getRates(
              originCity: 'New York',
              originPostal: '10001',
              originCountry: 'US',
              destCity: 'Atlanta',
              destPostal: '30303',
              destCountry: 'US',
              cartons: testCartons,
            ),
            throwsA(
              isA<ShippoServiceException>().having(
                (e) => e.message,
                'message',
                contains('Network error'),
              ),
            ),
          );
        },
      );

      test('handles multiple cartons correctly', () async {
        final multipleCartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.5,
            qty: 1,
            itemType: 'Box',
          ),
          const Carton(
            id: '2',
            shipmentId: 's1',
            lengthCm: 50,
            widthCm: 40,
            heightCm: 30,
            weightKg: 10.0,
            qty: 2,
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
          originCity: 'New York',
          originPostal: '10001',
          originCountry: 'US',
          destCity: 'Atlanta',
          destPostal: '30303',
          destCountry: 'US',
          cartons: multipleCartons,
        );

        // Verify the request contains 3 parcels (1 + 2*qty)
        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final parcels = captured['parcels'] as List;
        expect(parcels, hasLength(3)); // 1 + 2
      });

      test('handles empty state strings', () async {
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
          originCity: 'Shanghai',
          originPostal: '200000',
          originCountry: 'CN',
          originState: '', // Empty state
          destCity: 'Berlin',
          destPostal: '10115',
          destCountry: 'DE',
          destState: '', // Empty state
          cartons: testCartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final addressFrom = captured['address_from'] as Map<String, dynamic>;
        final addressTo = captured['address_to'] as Map<String, dynamic>;

        expect(addressFrom['state'], '');
        expect(addressTo['state'], '');
      });
    });

    group('_convertCartonsToShippoParcels', () {
      test('creates single parcel for carton with qty=1', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.5,
            qty: 1,
            itemType: 'Box',
          ),
        ];

        // Access private method through public API
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

        service.getRates(
          originCity: 'New York',
          originPostal: '10001',
          originCountry: 'US',
          destCity: 'Atlanta',
          destPostal: '30303',
          destCountry: 'US',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final parcels = captured['parcels'] as List;
        expect(parcels, hasLength(1));
        expect(parcels[0]['length'], '40');
        expect(parcels[0]['width'], '30');
        expect(parcels[0]['height'], '20');
        expect(parcels[0]['weight'], '5.50');
        expect(parcels[0]['distance_unit'], 'cm');
        expect(parcels[0]['mass_unit'], 'kg');
      });

      test('creates multiple parcels for carton with qty > 1', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.5,
            qty: 5,
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

        service.getRates(
          originCity: 'New York',
          originPostal: '10001',
          originCountry: 'US',
          destCity: 'Atlanta',
          destPostal: '30303',
          destCountry: 'US',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final parcels = captured['parcels'] as List;
        expect(parcels, hasLength(5));

        // All parcels should have identical dimensions
        for (final parcel in parcels) {
          expect(parcel['length'], '40');
          expect(parcel['width'], '30');
          expect(parcel['height'], '20');
          expect(parcel['weight'], '5.50');
        }
      });

      test('handles multiple cartons with different quantities', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.5,
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

        service.getRates(
          originCity: 'New York',
          originPostal: '10001',
          originCountry: 'US',
          destCity: 'Atlanta',
          destPostal: '30303',
          destCountry: 'US',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final parcels = captured['parcels'] as List;
        expect(parcels, hasLength(5)); // 2 + 3

        // First 2 parcels should be from first carton
        expect(parcels[0]['length'], '40');
        expect(parcels[1]['length'], '40');

        // Last 3 parcels should be from second carton
        expect(parcels[2]['length'], '50');
        expect(parcels[3]['length'], '50');
        expect(parcels[4]['length'], '50');
      });

      test('handles empty carton list', () {
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

        service.getRates(
          originCity: 'New York',
          originPostal: '10001',
          originCountry: 'US',
          destCity: 'Atlanta',
          destPostal: '30303',
          destCountry: 'US',
          cartons: [],
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final parcels = captured['parcels'] as List;
        expect(parcels, isEmpty);
      });

      test('formats dimensions with correct precision', () {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40.7,
            widthCm: 30.3,
            heightCm: 20.9,
            weightKg: 5.567,
            qty: 1,
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

        service.getRates(
          originCity: 'New York',
          originPostal: '10001',
          originCountry: 'US',
          destCity: 'Atlanta',
          destPostal: '30303',
          destCountry: 'US',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final parcels = captured['parcels'] as List;
        final parcel = parcels[0];

        // Dimensions should be rounded to whole numbers (0 decimals)
        expect(parcel['length'], '41');
        expect(parcel['width'], '30');
        expect(parcel['height'], '21');

        // Weight should have 2 decimal places
        expect(parcel['weight'], '5.57');
      });
    });

    group('purchaseLabel', () {
      test('returns label URL on success', () async {
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 201,
            data: {'label_url': 'https://example.com/label.pdf'},
          ),
        );

        final labelUrl = await service.purchaseLabel('rate_123');

        expect(labelUrl, 'https://example.com/label.pdf');
      });

      test('calls API with correct parameters', () async {
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 201,
            data: {'label_url': 'https://example.com/label.pdf'},
          ),
        );

        await service.purchaseLabel('rate_123');

        verify(
          () => mockDio.post(
            '/transactions/',
            data: {
              'rate': 'rate_123',
              'label_file_type': 'PDF',
              'async': false,
            },
          ),
        ).called(1);
      });

      test('throws ShippoServiceException on DioException', () async {
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: 400,
              data: {'message': 'Invalid rate ID'},
            ),
          ),
        );

        expect(
          () => service.purchaseLabel('invalid_rate'),
          throwsA(
            isA<ShippoServiceException>().having(
              (e) => e.message,
              'message',
              contains('Invalid rate ID'),
            ),
          ),
        );
      });

      test('throws ShippoServiceException on unexpected error', () async {
        when(
          () => mockDio.post(any(), data: any(named: 'data')),
        ).thenThrow(Exception('Unexpected'));

        expect(
          () => service.purchaseLabel('rate_123'),
          throwsA(
            isA<ShippoServiceException>().having(
              (e) => e.message,
              'message',
              contains('Unexpected error'),
            ),
          ),
        );
      });
    });
  });

  group('ShippoServiceException', () {
    test('toString returns message', () {
      final exception = ShippoServiceException('Test error');
      expect(exception.toString(), 'Test error');
    });
  });
}
