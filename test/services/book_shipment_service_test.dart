import 'package:bockaire/services/book_shipment_service.dart';
import 'package:bockaire/models/shippo_models.dart';
import 'package:bockaire/models/customs_models.dart';
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

  group('BookShipmentService', () {
    late MockDio mockDio;
    late MockInterceptors mockInterceptors;
    late BookShipmentService service;

    final testAddressFrom = ShippoAddress(
      name: 'Sender',
      street1: '123 Main St',
      city: 'Shanghai',
      state: '',
      zip: '200000',
      country: 'CN',
    );

    final testAddressTo = ShippoAddress(
      name: 'Recipient',
      street1: '456 Oak Ave',
      city: 'Berlin',
      state: '',
      zip: '10115',
      country: 'DE',
    );

    final testParcels = [
      ShippoParcel(
        length: '40',
        width: '30',
        height: '20',
        distanceUnit: 'cm',
        weight: '5.0',
        massUnit: 'kg',
      ),
    ];

    setUp(() {
      mockDio = MockDio();
      mockInterceptors = MockInterceptors();

      when(() => mockDio.interceptors).thenReturn(mockInterceptors);
      when(() => mockInterceptors.add(any())).thenReturn(null);
      when(() => mockDio.options).thenReturn(BaseOptions());
      // Skip mocking options setter - it doesn't return a value

      service = BookShipmentService(dio: mockDio);
    });

    group('Label Purchase Safety Control', () {
      test('SAFE MODE: blocks label creation when flag disabled', () async {
        // Setup: ENABLE_SHIPPO_LABELS=false
        dotenv.testLoad(
          fileInput: 'ENABLE_SHIPPO_LABELS=false\nSHIPPO_LIVE_API_KEY=test_key',
        );

        // Mock shipment creation
        when(
          () => mockDio.post('/shipments/', data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: {
              'object_id': 'shipment_123',
              'status': 'SUCCESS',
              'messages': [],
            },
          ),
        );

        final result = await service.bookShipment(
          rateId: 'rate_123',
          addressFrom: testAddressFrom,
          addressTo: testAddressTo,
          parcels: testParcels,
          createLabel: true, // User wants label
        );

        // Verify: No label created (safety block)
        expect(result.labelCreated, false);
        expect(result.status, 'SHIPMENT_CREATED');
        expect(result.trackingNumber, isNull);
        expect(result.labelUrl, isNull);

        // Verify: No transaction API call made
        verifyNever(
          () => mockDio.post('/transactions/', data: any(named: 'data')),
        );
      });

      test('LIVE MODE: creates label when flag enabled + confirmed', () async {
        // Setup: ENABLE_SHIPPO_LABELS=true
        dotenv.testLoad(
          fileInput: 'ENABLE_SHIPPO_LABELS=true\nSHIPPO_LIVE_API_KEY=test_key',
        );

        // Mock shipment creation
        when(
          () => mockDio.post('/shipments/', data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: {
              'object_id': 'shipment_123',
              'status': 'SUCCESS',
              'messages': [],
            },
          ),
        );

        // Mock transaction creation (label purchase)
        when(
          () => mockDio.post('/transactions/', data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: {
              'object_id': 'trans_123',
              'status': 'SUCCESS',
              'tracking_number': '1Z999AA10123456784',
              'tracking_url_provider': 'https://track.test/1Z999AA10123456784',
              'label_url': 'https://label.test/label.pdf',
              'messages': [],
            },
          ),
        );

        final result = await service.bookShipment(
          rateId: 'rate_123',
          addressFrom: testAddressFrom,
          addressTo: testAddressTo,
          parcels: testParcels,
          createLabel: true,
        );

        // Verify: Label created
        expect(result.labelCreated, true);
        expect(result.status, 'LABEL_CREATED');
        expect(result.trackingNumber, '1Z999AA10123456784');
        expect(result.labelUrl, 'https://label.test/label.pdf');

        // Verify: Transaction API called
        verify(
          () => mockDio.post('/transactions/', data: any(named: 'data')),
        ).called(1);
      });

      test('USER DECLINED: no label when createLabel=false', () async {
        // Setup: Flag enabled but user declined
        dotenv.testLoad(
          fileInput: 'ENABLE_SHIPPO_LABELS=true\nSHIPPO_LIVE_API_KEY=test_key',
        );

        // Mock shipment creation
        when(
          () => mockDio.post('/shipments/', data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: {
              'object_id': 'shipment_123',
              'status': 'SUCCESS',
              'messages': [],
            },
          ),
        );

        final result = await service.bookShipment(
          rateId: 'rate_123',
          addressFrom: testAddressFrom,
          addressTo: testAddressTo,
          parcels: testParcels,
          createLabel: false, // User said no
        );

        // Verify: No label created
        expect(result.labelCreated, false);
        expect(result.status, 'SHIPMENT_CREATED');

        // Verify: No transaction API call
        verifyNever(
          () => mockDio.post('/transactions/', data: any(named: 'data')),
        );
      });
    });

    group('Transaction Creation (Money Critical)', () {
      setUp(() {
        dotenv.testLoad(
          fileInput: 'ENABLE_SHIPPO_LABELS=true\nSHIPPO_LIVE_API_KEY=test_key',
        );

        // Mock shipment creation for all tests
        when(
          () => mockDio.post('/shipments/', data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: {
              'object_id': 'shipment_123',
              'status': 'SUCCESS',
              'messages': [],
            },
          ),
        );
      });

      test('SUCCESS: creates label and charges account', () async {
        when(
          () => mockDio.post('/transactions/', data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: {
              'object_id': 'trans_123',
              'status': 'SUCCESS',
              'tracking_number': '1Z999AA10123456784',
              'tracking_url_provider': 'https://track.test',
              'label_url': 'https://label.test/label.pdf',
              'messages': [],
            },
          ),
        );

        final result = await service.bookShipment(
          rateId: 'rate_123',
          addressFrom: testAddressFrom,
          addressTo: testAddressTo,
          parcels: testParcels,
          createLabel: true,
        );

        expect(result.trackingNumber, '1Z999AA10123456784');
        expect(result.labelUrl, 'https://label.test/label.pdf');
        expect(result.labelCreated, true);
      });

      test('ERROR: insufficient funds throws exception', () async {
        when(
          () => mockDio.post('/transactions/', data: any(named: 'data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: 402,
              data: {'message': 'Insufficient funds'},
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        expect(
          () => service.bookShipment(
            rateId: 'rate_123',
            addressFrom: testAddressFrom,
            addressTo: testAddressTo,
            parcels: testParcels,
            createLabel: true,
          ),
          throwsA(isA<BookingException>()),
        );
      });

      test('ERROR: rate expired throws exception', () async {
        when(
          () => mockDio.post('/transactions/', data: any(named: 'data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: 400,
              data: {'message': 'Rate no longer valid', 'code': 'RATE_EXPIRED'},
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        expect(
          () => service.bookShipment(
            rateId: 'rate_expired',
            addressFrom: testAddressFrom,
            addressTo: testAddressTo,
            parcels: testParcels,
            createLabel: true,
          ),
          throwsA(isA<BookingException>()),
        );
      });

      test('ERROR: duplicate purchase throws exception', () async {
        when(
          () => mockDio.post('/transactions/', data: any(named: 'data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: 409,
              data: {'message': 'Transaction already exists'},
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        expect(
          () => service.bookShipment(
            rateId: 'rate_123',
            addressFrom: testAddressFrom,
            addressTo: testAddressTo,
            parcels: testParcels,
            createLabel: true,
          ),
          throwsA(isA<BookingException>()),
        );
      });
    });

    group('International Customs Flow', () {
      final testProfile = CustomsProfile(
        id: 'profile_123',
        name: 'My Business',
        importerType: ImporterType.business,
        eoriNumber: 'GB123456789000',
        taxId: '12-3456789',
        companyName: 'Test Company',
        contactName: 'John Doe',
        defaultIncoterms: Incoterms.dap,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      final testCustomsPacket = CustomsPacket(
        id: 'packet_123',
        shipmentId: 'shipment_123',
        profile: testProfile,
        items: [
          const CommodityLine(
            description: 'Electronic Goods',
            quantity: 2,
            netWeight: 1.5,
            valueAmount: 50.00,
            originCountry: 'CN',
            hsCode: '8517.12.00',
          ),
        ],
        incoterms: Incoterms.dap,
        contentsType: ContentsType.merchandise,
        certify: true,
        createdAt: DateTime(2025, 1, 1),
      );

      setUp(() {
        dotenv.testLoad(
          fileInput: 'ENABLE_SHIPPO_LABELS=false\nSHIPPO_LIVE_API_KEY=test_key',
        );

        // Mock shipment creation
        when(
          () => mockDio.post('/shipments/', data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: {
              'object_id': 'shipment_123',
              'status': 'SUCCESS',
              'messages': [],
            },
          ),
        );
      });

      test('creates and attaches customs for international shipment', () async {
        // Mock customs declaration creation
        when(
          () =>
              mockDio.post('/customs/declarations/', data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: {
              'object_id': 'customs_123',
              'commercial_invoice_url': 'https://invoice.test/invoice.pdf',
              'messages': [],
            },
          ),
        );

        // Mock customs attachment
        when(
          () => mockDio.patch(
            '/shipments/shipment_123/',
            data: any(named: 'data'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: {'object_id': 'shipment_123'},
          ),
        );

        final result = await service.bookShipment(
          rateId: 'rate_123',
          addressFrom: testAddressFrom,
          addressTo: testAddressTo,
          parcels: testParcels,
          customsPacket: testCustomsPacket,
        );

        expect(result.customsDeclarationId, 'customs_123');
        expect(result.commercialInvoiceUrl, 'https://invoice.test/invoice.pdf');

        verify(
          () =>
              mockDio.post('/customs/declarations/', data: any(named: 'data')),
        ).called(1);
        verify(
          () => mockDio.patch(
            '/shipments/shipment_123/',
            data: any(named: 'data'),
          ),
        ).called(1);
      });

      test('skips customs for domestic shipment', () async {
        final domesticAddressTo = ShippoAddress(
          name: 'Recipient',
          street1: '456 Oak Ave',
          city: 'Beijing',
          state: '',
          zip: '100000',
          country: 'CN', // Same country
        );

        final result = await service.bookShipment(
          rateId: 'rate_123',
          addressFrom: testAddressFrom,
          addressTo: domesticAddressTo,
          parcels: testParcels,
          customsPacket: testCustomsPacket,
        );

        expect(result.customsDeclarationId, isNull);

        verifyNever(
          () =>
              mockDio.post('/customs/declarations/', data: any(named: 'data')),
        );
      });

      test('skips customs when packet is null', () async {
        final result = await service.bookShipment(
          rateId: 'rate_123',
          addressFrom: testAddressFrom,
          addressTo: testAddressTo,
          parcels: testParcels,
          customsPacket: null,
        );

        expect(result.customsDeclarationId, isNull);

        verifyNever(
          () =>
              mockDio.post('/customs/declarations/', data: any(named: 'data')),
        );
      });
    });

    group('Customs Declaration Data Transformation', () {
      setUp(() {
        dotenv.testLoad(
          fileInput: 'ENABLE_SHIPPO_LABELS=false\nSHIPPO_LIVE_API_KEY=test_key',
        );

        when(
          () => mockDio.post('/shipments/', data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: {
              'object_id': 'shipment_123',
              'status': 'SUCCESS',
              'messages': [],
            },
          ),
        );

        when(() => mockDio.patch(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: {'object_id': 'shipment_123'},
          ),
        );
      });

      test('includes EORI when provided', () async {
        final profile = CustomsProfile(
          id: 'profile_123',
          name: 'My Business',
          importerType: ImporterType.business,
          eoriNumber: 'GB123456789000',
          defaultIncoterms: Incoterms.dap,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        );

        final packet = CustomsPacket(
          id: 'packet_123',
          shipmentId: 'shipment_123',
          profile: profile,
          items: [
            const CommodityLine(
              description: 'Test Item',
              quantity: 1,
              netWeight: 1.0,
              valueAmount: 10.0,
              originCountry: 'CN',
              hsCode: '1234.56.78',
            ),
          ],
          certify: true,
          createdAt: DateTime(2025, 1, 1),
        );

        when(
          () =>
              mockDio.post('/customs/declarations/', data: any(named: 'data')),
        ).thenAnswer((invocation) async {
          final data = invocation.namedArguments[#data] as Map<String, dynamic>;
          final exporterIdent =
              data['exporter_identification'] as Map<String, dynamic>?;
          expect(exporterIdent?['eori_number'], 'GB123456789000');

          return Response(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: {'object_id': 'customs_123', 'messages': []},
          );
        });

        await service.bookShipment(
          rateId: 'rate_123',
          addressFrom: testAddressFrom,
          addressTo: testAddressTo,
          parcels: testParcels,
          customsPacket: packet,
        );

        verify(
          () =>
              mockDio.post('/customs/declarations/', data: any(named: 'data')),
        ).called(1);
      });

      test('includes Tax ID with EIN type', () async {
        final profile = CustomsProfile(
          id: 'profile_123',
          name: 'My Business',
          importerType: ImporterType.business,
          taxId: '12-3456789',
          defaultIncoterms: Incoterms.dap,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        );

        final packet = CustomsPacket(
          id: 'packet_123',
          shipmentId: 'shipment_123',
          profile: profile,
          items: [
            const CommodityLine(
              description: 'Test Item',
              quantity: 1,
              netWeight: 1.0,
              valueAmount: 10.0,
              originCountry: 'CN',
              hsCode: '1234.56.78',
            ),
          ],
          certify: true,
          createdAt: DateTime(2025, 1, 1),
        );

        when(
          () =>
              mockDio.post('/customs/declarations/', data: any(named: 'data')),
        ).thenAnswer((invocation) async {
          final data = invocation.namedArguments[#data] as Map<String, dynamic>;
          final exporterIdent =
              data['exporter_identification'] as Map<String, dynamic>?;
          final taxId = exporterIdent?['tax_id'] as Map<String, dynamic>?;
          expect(taxId?['number'], '12-3456789');
          expect(taxId?['type'], 'EIN');

          return Response(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: {'object_id': 'customs_123', 'messages': []},
          );
        });

        await service.bookShipment(
          rateId: 'rate_123',
          addressFrom: testAddressFrom,
          addressTo: testAddressTo,
          parcels: testParcels,
          customsPacket: packet,
        );

        verify(
          () =>
              mockDio.post('/customs/declarations/', data: any(named: 'data')),
        ).called(1);
      });

      test('omits exporter_identification when no EORI/Tax ID', () async {
        final profile = CustomsProfile(
          id: 'profile_123',
          name: 'My Business',
          importerType: ImporterType.business,
          defaultIncoterms: Incoterms.dap,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        );

        final packet = CustomsPacket(
          id: 'packet_123',
          shipmentId: 'shipment_123',
          profile: profile,
          items: [
            const CommodityLine(
              description: 'Test Item',
              quantity: 1,
              netWeight: 1.0,
              valueAmount: 10.0,
              originCountry: 'CN',
              hsCode: '1234.56.78',
            ),
          ],
          certify: true,
          createdAt: DateTime(2025, 1, 1),
        );

        when(
          () =>
              mockDio.post('/customs/declarations/', data: any(named: 'data')),
        ).thenAnswer((invocation) async {
          final data = invocation.namedArguments[#data] as Map<String, dynamic>;
          final exporterIdent =
              data['exporter_identification'] as Map<String, dynamic>?;
          expect(exporterIdent?.isEmpty ?? true, true);

          return Response(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: {'object_id': 'customs_123', 'messages': []},
          );
        });

        await service.bookShipment(
          rateId: 'rate_123',
          addressFrom: testAddressFrom,
          addressTo: testAddressTo,
          parcels: testParcels,
          customsPacket: packet,
        );
      });

      test('uses fallback for certify signer', () async {
        final packet = CustomsPacket(
          id: 'packet_123',
          shipmentId: 'shipment_123',
          profile: null,
          items: [
            const CommodityLine(
              description: 'Test Item',
              quantity: 1,
              netWeight: 1.0,
              valueAmount: 10.0,
              originCountry: 'CN',
              hsCode: '1234.56.78',
            ),
          ],
          certify: true,
          createdAt: DateTime(2025, 1, 1),
        );

        when(
          () =>
              mockDio.post('/customs/declarations/', data: any(named: 'data')),
        ).thenAnswer((invocation) async {
          final data = invocation.namedArguments[#data] as Map<String, dynamic>;
          expect(data['certify_signer'], 'Shipper');

          return Response(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: {'object_id': 'customs_123', 'messages': []},
          );
        });

        await service.bookShipment(
          rateId: 'rate_123',
          addressFrom: testAddressFrom,
          addressTo: testAddressTo,
          parcels: testParcels,
          customsPacket: packet,
        );
      });

      test('converts incoterms to uppercase', () async {
        final packet = CustomsPacket(
          id: 'packet_123',
          shipmentId: 'shipment_123',
          items: [
            const CommodityLine(
              description: 'Test Item',
              quantity: 1,
              netWeight: 1.0,
              valueAmount: 10.0,
              originCountry: 'CN',
              hsCode: '1234.56.78',
            ),
          ],
          incoterms: Incoterms.dap,
          certify: true,
          createdAt: DateTime(2025, 1, 1),
        );

        when(
          () =>
              mockDio.post('/customs/declarations/', data: any(named: 'data')),
        ).thenAnswer((invocation) async {
          final data = invocation.namedArguments[#data] as Map<String, dynamic>;
          expect(data['incoterm'], 'DAP');

          return Response(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: {'object_id': 'customs_123', 'messages': []},
          );
        });

        await service.bookShipment(
          rateId: 'rate_123',
          addressFrom: testAddressFrom,
          addressTo: testAddressTo,
          parcels: testParcels,
          customsPacket: packet,
        );
      });
    });

    group('HTTP Error Handling', () {
      setUp(() {
        dotenv.testLoad(
          fileInput: 'ENABLE_SHIPPO_LABELS=false\nSHIPPO_LIVE_API_KEY=test_key',
        );
      });

      test('429 Rate Limit', () async {
        when(
          () => mockDio.post('/shipments/', data: any(named: 'data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: 429,
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        try {
          await service.bookShipment(
            rateId: 'rate_123',
            addressFrom: testAddressFrom,
            addressTo: testAddressTo,
            parcels: testParcels,
          );
          fail('Should throw BookingException');
        } on BookingException catch (e) {
          expect(e.message, contains('Rate limit exceeded'));
        }
      });

      test('401 Unauthorized', () async {
        when(
          () => mockDio.post('/shipments/', data: any(named: 'data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: 401,
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        try {
          await service.bookShipment(
            rateId: 'rate_123',
            addressFrom: testAddressFrom,
            addressTo: testAddressTo,
            parcels: testParcels,
          );
          fail('Should throw BookingException');
        } on BookingException catch (e) {
          expect(e.message, contains('Authentication failed'));
        }
      });

      test('403 Forbidden', () async {
        when(
          () => mockDio.post('/shipments/', data: any(named: 'data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: 403,
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        try {
          await service.bookShipment(
            rateId: 'rate_123',
            addressFrom: testAddressFrom,
            addressTo: testAddressTo,
            parcels: testParcels,
          );
          fail('Should throw BookingException');
        } on BookingException catch (e) {
          expect(e.message, contains('Authentication failed'));
        }
      });

      test('400 Bad Request with ShippoError', () async {
        when(
          () => mockDio.post('/shipments/', data: any(named: 'data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: 400,
              data: {'message': 'Invalid address', 'code': 'INVALID_ADDRESS'},
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        try {
          await service.bookShipment(
            rateId: 'rate_123',
            addressFrom: testAddressFrom,
            addressTo: testAddressTo,
            parcels: testParcels,
          );
          fail('Should throw BookingException');
        } on BookingException catch (e) {
          expect(e.message, contains('Invalid address'));
        }
      });

      test('500 Internal Server Error', () async {
        when(
          () => mockDio.post('/shipments/', data: any(named: 'data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              requestOptions: RequestOptions(),
              statusCode: 500,
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        try {
          await service.bookShipment(
            rateId: 'rate_123',
            addressFrom: testAddressFrom,
            addressTo: testAddressTo,
            parcels: testParcels,
          );
          fail('Should throw BookingException');
        } on BookingException catch (e) {
          expect(e.message, contains('API error (500)'));
        }
      });

      test('Connection Timeout', () async {
        when(
          () => mockDio.post('/shipments/', data: any(named: 'data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        try {
          await service.bookShipment(
            rateId: 'rate_123',
            addressFrom: testAddressFrom,
            addressTo: testAddressTo,
            parcels: testParcels,
          );
          fail('Should throw BookingException');
        } on BookingException catch (e) {
          expect(e.message, contains('timed out'));
        }
      });

      test('Send Timeout', () async {
        when(
          () => mockDio.post('/shipments/', data: any(named: 'data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.sendTimeout,
          ),
        );

        try {
          await service.bookShipment(
            rateId: 'rate_123',
            addressFrom: testAddressFrom,
            addressTo: testAddressTo,
            parcels: testParcels,
          );
          fail('Should throw BookingException');
        } on BookingException catch (e) {
          expect(e.message, contains('timed out'));
        }
      });

      test('Receive Timeout', () async {
        when(
          () => mockDio.post('/shipments/', data: any(named: 'data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.receiveTimeout,
          ),
        );

        try {
          await service.bookShipment(
            rateId: 'rate_123',
            addressFrom: testAddressFrom,
            addressTo: testAddressTo,
            parcels: testParcels,
          );
          fail('Should throw BookingException');
        } on BookingException catch (e) {
          expect(e.message, contains('timed out'));
        }
      });

      test('Connection Error', () async {
        when(
          () => mockDio.post('/shipments/', data: any(named: 'data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionError,
          ),
        );

        try {
          await service.bookShipment(
            rateId: 'rate_123',
            addressFrom: testAddressFrom,
            addressTo: testAddressTo,
            parcels: testParcels,
          );
          fail('Should throw BookingException');
        } on BookingException catch (e) {
          expect(e.message, contains('Connection error'));
        }
      });

      test('Request Cancelled', () async {
        when(
          () => mockDio.post('/shipments/', data: any(named: 'data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.cancel,
          ),
        );

        try {
          await service.bookShipment(
            rateId: 'rate_123',
            addressFrom: testAddressFrom,
            addressTo: testAddressTo,
            parcels: testParcels,
          );
          fail('Should throw BookingException');
        } on BookingException catch (e) {
          expect(e.message, contains('cancelled'));
        }
      });
    });
  });
}
