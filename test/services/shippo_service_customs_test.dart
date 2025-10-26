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
  setUpAll(() async {
    await dotenv.load(fileName: '.env');
    registerFallbackValue(RequestOptions());
    registerFallbackValue(BaseOptions());
    registerFallbackValue(FakeInterceptor());
  });

  group('ShippoService - Customs Declaration', () {
    late MockDio mockDio;
    late MockInterceptors mockInterceptors;
    late ShippoService service;

    setUp(() {
      dotenv.testLoad(
        fileInput: 'USE_TEST_MODE=false\nSHIPPO_LIVE_API_KEY=test_live_key',
      );

      mockDio = MockDio();
      mockInterceptors = MockInterceptors();

      when(() => mockDio.interceptors).thenReturn(mockInterceptors);
      when(() => mockInterceptors.add(any())).thenReturn(null);

      service = ShippoService(dio: mockDio);
    });

    group('_createCustomsDeclaration', () {
      test('Default value estimation uses \$50/kg formula', () async {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 10.0,
            qty: 1,
            itemType: 'General Merchandise',
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
          originCity: 'Shanghai',
          originPostal: '200000',
          originCountry: 'CN',
          destCity: 'Berlin',
          destPostal: '10115',
          destCountry: 'DE',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final customs = captured['customs_declaration'] as Map<String, dynamic>;
        final items = customs['items'] as List;
        final item = items[0] as Map<String, dynamic>;

        // 10kg * 1qty * $50/kg = $500
        expect(item['value_amount'], '500.00');
      });

      test('Empty itemType defaults to "General Merchandise"', () async {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 1,
            itemType: '', // Empty item type
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
          originCity: 'Shanghai',
          originPostal: '200000',
          originCountry: 'CN',
          destCity: 'Berlin',
          destPostal: '10115',
          destCountry: 'DE',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final customs = captured['customs_declaration'] as Map<String, dynamic>;
        final items = customs['items'] as List;
        final item = items[0] as Map<String, dynamic>;

        expect(item['description'], 'General Merchandise');
      });

      test('Contents explanation truncates to first 3 item types', () async {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 1,
            itemType: 'Electronics',
          ),
          const Carton(
            id: '2',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 1,
            itemType: 'Clothing',
          ),
          const Carton(
            id: '3',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 1,
            itemType: 'Toys',
          ),
          const Carton(
            id: '4',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 1,
            itemType: 'Books', // This should be excluded
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
          originCity: 'Shanghai',
          originPostal: '200000',
          originCountry: 'CN',
          destCity: 'Berlin',
          destPostal: '10115',
          destCountry: 'DE',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final customs = captured['customs_declaration'] as Map<String, dynamic>;
        final explanation = customs['contents_explanation'] as String;

        // Should contain first 3 types
        expect(explanation.split(', ').length, lessThanOrEqualTo(3));
        expect(explanation, contains('Electronics'));
        expect(explanation, contains('Clothing'));
        expect(explanation, contains('Toys'));
      });

      test('Tariff code mapping for electronics (8517.12.00)', () async {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 1,
            itemType: 'electronic devices',
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
          originCity: 'Shanghai',
          originPostal: '200000',
          originCountry: 'CN',
          destCity: 'Berlin',
          destPostal: '10115',
          destCountry: 'DE',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final customs = captured['customs_declaration'] as Map<String, dynamic>;
        final items = customs['items'] as List;
        final item = items[0] as Map<String, dynamic>;

        expect(item['tariff_number'], '8517.12.00');
      });

      test('Tariff code mapping for laptop (8517.12.00)', () async {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 1,
            itemType: 'Laptop Computer',
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
          originCity: 'Shanghai',
          originPostal: '200000',
          originCountry: 'CN',
          destCity: 'Berlin',
          destPostal: '10115',
          destCountry: 'DE',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final customs = captured['customs_declaration'] as Map<String, dynamic>;
        final items = customs['items'] as List;
        final item = items[0] as Map<String, dynamic>;

        expect(item['tariff_number'], '8517.12.00');
      });

      test('Tariff code mapping for clothing (6109.10.00)', () async {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 1,
            itemType: 'Clothing items',
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
          originCity: 'Shanghai',
          originPostal: '200000',
          originCountry: 'CN',
          destCity: 'Berlin',
          destPostal: '10115',
          destCountry: 'DE',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final customs = captured['customs_declaration'] as Map<String, dynamic>;
        final items = customs['items'] as List;
        final item = items[0] as Map<String, dynamic>;

        expect(item['tariff_number'], '6109.10.00');
      });

      test('Tariff code mapping for footwear (6403.99.00)', () async {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 1,
            itemType: 'Shoes and footwear',
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
          originCity: 'Shanghai',
          originPostal: '200000',
          originCountry: 'CN',
          destCity: 'Berlin',
          destPostal: '10115',
          destCountry: 'DE',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final customs = captured['customs_declaration'] as Map<String, dynamic>;
        final items = customs['items'] as List;
        final item = items[0] as Map<String, dynamic>;

        expect(item['tariff_number'], '6403.99.00');
      });

      test('Tariff code mapping for toys (9503.00.00)', () async {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 1,
            itemType: 'Toy cars',
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
          originCity: 'Shanghai',
          originPostal: '200000',
          originCountry: 'CN',
          destCity: 'Berlin',
          destPostal: '10115',
          destCountry: 'DE',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final customs = captured['customs_declaration'] as Map<String, dynamic>;
        final items = customs['items'] as List;
        final item = items[0] as Map<String, dynamic>;

        expect(item['tariff_number'], '9503.00.00');
      });

      test('Generic fallback tariff code (9999.00.00)', () async {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 1,
            itemType: 'Random unrecognized item',
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
          originCity: 'Shanghai',
          originPostal: '200000',
          originCountry: 'CN',
          destCity: 'Berlin',
          destPostal: '10115',
          destCountry: 'DE',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final customs = captured['customs_declaration'] as Map<String, dynamic>;
        final items = customs['items'] as List;
        final item = items[0] as Map<String, dynamic>;

        expect(item['tariff_number'], '9999.00.00');
      });

      test('Total weight calculation (weight × quantity)', () async {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.5,
            qty: 3,
            itemType: 'Electronics',
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
          originCity: 'Shanghai',
          originPostal: '200000',
          originCountry: 'CN',
          destCity: 'Berlin',
          destPostal: '10115',
          destCountry: 'DE',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final customs = captured['customs_declaration'] as Map<String, dynamic>;
        final items = customs['items'] as List;
        final item = items[0] as Map<String, dynamic>;

        // 5.5kg * 3 = 16.5kg
        expect(item['net_weight'], '16.50');
        // 5.5kg * 3 * $50/kg = $825
        expect(item['value_amount'], '825.00');
      });

      test('Multiple items with different types', () async {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 1,
            itemType: 'Electronics',
          ),
          const Carton(
            id: '2',
            shipmentId: 's1',
            lengthCm: 30,
            widthCm: 20,
            heightCm: 10,
            weightKg: 2.0,
            qty: 2,
            itemType: 'Clothing',
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
          originCity: 'Shanghai',
          originPostal: '200000',
          originCountry: 'CN',
          destCity: 'Berlin',
          destPostal: '10115',
          destCountry: 'DE',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final customs = captured['customs_declaration'] as Map<String, dynamic>;
        final items = customs['items'] as List;

        expect(items, hasLength(2));

        final item1 = items[0] as Map<String, dynamic>;
        expect(item1['description'], 'Electronics');
        expect(item1['tariff_number'], '8517.12.00');
        expect(item1['net_weight'], '5.00');
        expect(item1['value_amount'], '250.00'); // 5kg * 1 * $50

        final item2 = items[1] as Map<String, dynamic>;
        expect(item2['description'], 'Clothing');
        expect(item2['tariff_number'], '6109.10.00');
        expect(item2['net_weight'], '4.00'); // 2kg * 2
        expect(item2['value_amount'], '200.00'); // 2kg * 2 * $50
      });
    });

    group('International shipment detection', () {
      test('Creates customs when originCountry != destCountry', () async {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 1,
            itemType: 'Electronics',
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
          originCity: 'Shanghai',
          originPostal: '200000',
          originCountry: 'CN',
          destCity: 'Berlin',
          destPostal: '10115',
          destCountry: 'DE',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        expect(captured.containsKey('customs_declaration'), isTrue);
        expect(captured['customs_declaration'], isNotNull);
      });

      test('Skips customs when originCountry == destCountry', () async {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 1,
            itemType: 'Electronics',
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
          destCity: 'Los Angeles',
          destPostal: '90001',
          destCountry: 'US',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        expect(captured.containsKey('customs_declaration'), isFalse);
      });

      test('Customs declaration included in shipment request JSON', () async {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 1,
            itemType: 'Electronics',
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
          destCity: 'Toronto',
          destPostal: 'M5H 2N2',
          destCountry: 'CA',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        final customs = captured['customs_declaration'] as Map<String, dynamic>;
        expect(customs['contents_type'], 'MERCHANDISE');
        expect(customs['non_delivery_option'], 'RETURN');
        expect(customs['certify'], true);
        expect(customs['certify_signer'], 'Sender');
        expect(customs['items'], isNotEmpty);
      });

      test('Customs declaration absent for domestic shipments', () async {
        final cartons = [
          const Carton(
            id: '1',
            shipmentId: 's1',
            lengthCm: 40,
            widthCm: 30,
            heightCm: 20,
            weightKg: 5.0,
            qty: 1,
            itemType: 'Electronics',
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

        // CN domestic shipment
        await service.getRates(
          originCity: 'Shanghai',
          originPostal: '200000',
          originCountry: 'CN',
          destCity: 'Beijing',
          destPostal: '100000',
          destCountry: 'CN',
          cartons: cartons,
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        expect(captured.containsKey('customs_declaration'), isFalse);
      });
    });
  });
}
