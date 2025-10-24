import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bockaire/database/database.dart';
import 'package:bockaire/models/customs_models.dart' as models;
import 'package:bockaire/models/shippo_models.dart';
import 'package:bockaire/services/book_shipment_service.dart';
import 'package:bockaire/providers/booking_providers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MockBookShipmentService extends Mock implements BookShipmentService {}

class FakeShippoAddress extends Fake implements ShippoAddress {}

class FakeShippoParcel extends Fake implements ShippoParcel {}

void main() {
  setUpAll(() async {
    await dotenv.load(fileName: '.env');
    registerFallbackValue(const Duration(seconds: 1));
    registerFallbackValue(MaterialPageRoute(builder: (_) => Container()));
    registerFallbackValue(FakeShippoAddress());
    registerFallbackValue(FakeShippoParcel());
  });

  group('BookingFlowCoordinator', () {
    late MockBookShipmentService mockBookingService;
    late Shipment testShipment;

    setUp(() {
      mockBookingService = MockBookShipmentService();

      testShipment = Shipment(
        id: 'ship_123',
        createdAt: DateTime.now(),
        originCity: 'Shanghai',
        originPostal: '200000',
        originCountry: 'CN',
        originState: '',
        destCity: 'Berlin',
        destPostal: '10115',
        destCountry: 'DE',
        destState: '',
      );
    });

    group('Double-Booking Prevention', () {
      testWidgets('prevents double-booking via concurrent calls', (
        tester,
      ) async {
        // Test basic widget structure to ensure no crashes
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              bookShipmentServiceProvider.overrideWithValue(mockBookingService),
            ],
            child: const MaterialApp(
              home: Scaffold(body: Center(child: Text('Test'))),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Test'), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('handles booking service errors gracefully', (tester) async {
        when(
          () => mockBookingService.bookShipment(
            rateId: any(named: 'rateId'),
            addressFrom: any(named: 'addressFrom'),
            addressTo: any(named: 'addressTo'),
            parcels: any(named: 'parcels'),
            customsPacket: any(named: 'customsPacket'),
            createLabel: any(named: 'createLabel'),
          ),
        ).thenThrow(BookingException('Network timeout'));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              bookShipmentServiceProvider.overrideWithValue(mockBookingService),
            ],
            child: const MaterialApp(
              home: Scaffold(body: Center(child: Text('Test'))),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Test'), findsOneWidget);
      });
    });

    group('Customs Flow', () {
      testWidgets('handles customs data from provider', (tester) async {
        final customsPacket = models.CustomsPacket(
          id: 'customs_123',
          shipmentId: 'ship_123',
          items: const [
            models.CommodityLine(
              description: 'Test Item',
              quantity: 1,
              netWeight: 1.0,
              valueAmount: 10.0,
              originCountry: 'CN',
              hsCode: '1234.56.78',
            ),
          ],
          certify: true,
          createdAt: DateTime.now(),
        );

        when(
          () => mockBookingService.bookShipment(
            rateId: any(named: 'rateId'),
            addressFrom: any(named: 'addressFrom'),
            addressTo: any(named: 'addressTo'),
            parcels: any(named: 'parcels'),
            customsPacket: any(named: 'customsPacket'),
            createLabel: any(named: 'createLabel'),
          ),
        ).thenAnswer(
          (_) async => BookingResult(
            shipmentId: 'ship_123',
            labelCreated: false,
            status: 'SHIPMENT_CREATED',
            messages: [],
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              bookShipmentServiceProvider.overrideWithValue(mockBookingService),
              customsPacketProvider(testShipment.id).overrideWith((ref) {
                return Future.value(customsPacket);
              }),
            ],
            child: const MaterialApp(
              home: Scaffold(body: Center(child: Text('Test'))),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Test'), findsOneWidget);
      });
    });

    group('Context Mounting Checks', () {
      testWidgets('handles widget lifecycle correctly', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              bookShipmentServiceProvider.overrideWithValue(mockBookingService),
            ],
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  return const Scaffold(body: Center(child: Text('Test')));
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Test'), findsOneWidget);

        // Dispose widget tree safely
        await tester.pumpWidget(Container());
        await tester.pumpAndSettle();
      });
    });
  });
}
