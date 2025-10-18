import 'package:bockaire/database/database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    // Create in-memory database for testing
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('Database Schema v4', () {
    test('quotes table has transportMethod column', () async {
      // Create a quote with transport method
      await database
          .into(database.quotes)
          .insert(
            QuotesCompanion.insert(
              id: 'quote_1',
              shipmentId: 'ship_1',
              carrier: 'UPS',
              service: 'Express Saver',
              etaMin: 2,
              etaMax: 3,
              priceEur: 100.0,
              chargeableKg: 10.0,
              transportMethod: const Value('expressAir'),
            ),
          );

      final quotes = await database.select(database.quotes).get();
      expect(quotes.first.transportMethod, 'expressAir');
    });

    test('transportMethod can be null for backward compatibility', () async {
      // Create quote without transport method
      await database
          .into(database.quotes)
          .insert(
            QuotesCompanion.insert(
              id: 'quote_1',
              shipmentId: 'ship_1',
              carrier: 'UPS',
              service: 'Standard',
              etaMin: 5,
              etaMax: 7,
              priceEur: 80.0,
              chargeableKg: 10.0,
            ),
          );

      final quotes = await database.select(database.quotes).get();
      expect(quotes.first.transportMethod, null);
    });

    test('can query quotes by transportMethod', () async {
      // Insert multiple quotes with different transport methods
      await database
          .into(database.quotes)
          .insert(
            QuotesCompanion.insert(
              id: 'quote_1',
              shipmentId: 'ship_1',
              carrier: 'UPS',
              service: 'Express',
              etaMin: 2,
              etaMax: 3,
              priceEur: 100.0,
              chargeableKg: 10.0,
              transportMethod: const Value('expressAir'),
            ),
          );

      await database
          .into(database.quotes)
          .insert(
            QuotesCompanion.insert(
              id: 'quote_2',
              shipmentId: 'ship_1',
              carrier: 'FedEx',
              service: 'Ground',
              etaMin: 5,
              etaMax: 7,
              priceEur: 50.0,
              chargeableKg: 10.0,
              transportMethod: const Value('roadFreight'),
            ),
          );

      await database
          .into(database.quotes)
          .insert(
            QuotesCompanion.insert(
              id: 'quote_3',
              shipmentId: 'ship_1',
              carrier: 'DHL',
              service: 'Express',
              etaMin: 1,
              etaMax: 2,
              priceEur: 120.0,
              chargeableKg: 10.0,
              transportMethod: const Value('expressAir'),
            ),
          );

      // Query only express air quotes
      final expressQuotes = await (database.select(
        database.quotes,
      )..where((q) => q.transportMethod.equals('expressAir'))).get();

      expect(expressQuotes, hasLength(2));
      expect(expressQuotes[0].id, 'quote_1');
      expect(expressQuotes[1].id, 'quote_3');
    });

    test('can update transportMethod on existing quote', () async {
      await database
          .into(database.quotes)
          .insert(
            QuotesCompanion.insert(
              id: 'quote_1',
              shipmentId: 'ship_1',
              carrier: 'UPS',
              service: 'Standard',
              etaMin: 5,
              etaMax: 7,
              priceEur: 80.0,
              chargeableKg: 10.0,
            ),
          );

      // Update to add transport method
      await (database.update(database.quotes)
            ..where((q) => q.id.equals('quote_1')))
          .write(const QuotesCompanion(transportMethod: Value('standardAir')));

      final quote = await (database.select(
        database.quotes,
      )..where((q) => q.id.equals('quote_1'))).getSingle();

      expect(quote.transportMethod, 'standardAir');
    });

    test('supports all transport method types', () async {
      final transportMethods = [
        'expressAir',
        'standardAir',
        'airFreight',
        'seaFreightLCL',
        'seaFreightFCL',
        'roadFreight',
      ];

      // Insert a quote for each transport method
      for (var i = 0; i < transportMethods.length; i++) {
        await database
            .into(database.quotes)
            .insert(
              QuotesCompanion.insert(
                id: 'quote_$i',
                shipmentId: 'ship_1',
                carrier: 'Carrier$i',
                service: 'Service$i',
                etaMin: i + 1,
                etaMax: i + 2,
                priceEur: 100.0 + i * 10,
                chargeableKg: 10.0,
                transportMethod: Value(transportMethods[i]),
              ),
            );
      }

      final allQuotes = await database.select(database.quotes).get();
      expect(allQuotes, hasLength(6));

      // Verify each one has the correct transport method
      for (var i = 0; i < transportMethods.length; i++) {
        expect(allQuotes[i].transportMethod, transportMethods[i]);
      }
    });

    test('quotes table has all required columns', () async {
      await database
          .into(database.quotes)
          .insert(
            QuotesCompanion.insert(
              id: 'quote_1',
              shipmentId: 'ship_1',
              carrier: 'UPS',
              service: 'Express',
              etaMin: 2,
              etaMax: 3,
              priceEur: 100.0,
              chargeableKg: 10.0,
              transportMethod: const Value('expressAir'),
            ),
          );

      final quote = await (database.select(
        database.quotes,
      )..where((q) => q.id.equals('quote_1'))).getSingle();

      expect(quote.id, 'quote_1');
      expect(quote.shipmentId, 'ship_1');
      expect(quote.carrier, 'UPS');
      expect(quote.service, 'Express');
      expect(quote.etaMin, 2);
      expect(quote.etaMax, 3);
      expect(quote.priceEur, 100.0);
      expect(quote.chargeableKg, 10.0);
      expect(quote.transportMethod, 'expressAir');
    });
  });

  group('Database Schema Integrity', () {
    test('shipments table works correctly', () async {
      await database
          .into(database.shipments)
          .insert(
            ShipmentsCompanion.insert(
              id: 'ship_1',
              createdAt: DateTime.now(),
              originCity: 'Shanghai',
              originPostal: '200000',
              originCountry: const Value('CN'),
              destCity: 'Hamburg',
              destPostal: '20095',
              destCountry: const Value('DE'),
            ),
          );

      final shipments = await database.select(database.shipments).get();
      expect(shipments, hasLength(1));
      expect(shipments.first.id, 'ship_1');
    });

    test('quotes reference shipments correctly', () async {
      // Create shipment first
      await database
          .into(database.shipments)
          .insert(
            ShipmentsCompanion.insert(
              id: 'ship_1',
              createdAt: DateTime.now(),
              originCity: 'Shanghai',
              originPostal: '200000',
              destCity: 'Hamburg',
              destPostal: '20095',
            ),
          );

      // Create quote referencing shipment
      await database
          .into(database.quotes)
          .insert(
            QuotesCompanion.insert(
              id: 'quote_1',
              shipmentId: 'ship_1',
              carrier: 'UPS',
              service: 'Express',
              etaMin: 2,
              etaMax: 3,
              priceEur: 100.0,
              chargeableKg: 10.0,
              transportMethod: const Value('expressAir'),
            ),
          );

      final quotes = await database.select(database.quotes).get();
      expect(quotes.first.shipmentId, 'ship_1');
    });

    test('cartons table works correctly', () async {
      await database
          .into(database.shipments)
          .insert(
            ShipmentsCompanion.insert(
              id: 'ship_1',
              createdAt: DateTime.now(),
              originCity: 'Shanghai',
              originPostal: '200000',
              destCity: 'Hamburg',
              destPostal: '20095',
            ),
          );

      await database
          .into(database.cartons)
          .insert(
            CartonsCompanion.insert(
              id: 'carton_1',
              shipmentId: 'ship_1',
              lengthCm: 40.0,
              widthCm: 30.0,
              heightCm: 20.0,
              weightKg: 10.0,
              qty: 2,
              itemType: 'Box',
            ),
          );

      final cartons = await database.select(database.cartons).get();
      expect(cartons, hasLength(1));
      expect(cartons.first.shipmentId, 'ship_1');
    });
  });

  group('Schema Version', () {
    test('database is at version 4', () {
      expect(database.schemaVersion, 4);
    });
  });
}
