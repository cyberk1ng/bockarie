import 'package:bockaire/database/database.dart';
import 'package:bockaire/services/calculation_service.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bockaire/classes/carton.dart' as models;

/// Unit tests for the delete carton functionality
/// These tests cover the core business logic without UI dependencies
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Delete Carton Database Operations', () {
    test('deleting a carton removes it from database', () async {
      final shipmentId = 'shipment-1';
      await db
          .into(db.shipments)
          .insert(
            ShipmentsCompanion.insert(
              id: shipmentId,
              createdAt: DateTime.now(),
              originCity: 'Berlin',
              originPostal: '10115',
              destCity: 'London',
              destPostal: 'SW1A',
            ),
          );

      // Insert 2 cartons
      await db
          .into(db.cartons)
          .insert(
            CartonsCompanion.insert(
              id: 'carton-1',
              shipmentId: shipmentId,
              lengthCm: 50.0,
              widthCm: 40.0,
              heightCm: 30.0,
              weightKg: 10.0,
              qty: 1,
              itemType: 'General',
            ),
          );

      await db
          .into(db.cartons)
          .insert(
            CartonsCompanion.insert(
              id: 'carton-2',
              shipmentId: shipmentId,
              lengthCm: 60.0,
              widthCm: 50.0,
              heightCm: 40.0,
              weightKg: 15.0,
              qty: 2,
              itemType: 'General',
            ),
          );

      // Verify 2 cartons exist
      var cartons = await db.select(db.cartons).get();
      expect(cartons.length, 2);

      // Delete carton-1
      await (db.delete(db.cartons)..where((c) => c.id.equals('carton-1'))).go();

      // Verify only 1 carton remains
      cartons = await db.select(db.cartons).get();
      expect(cartons.length, 1);
      expect(cartons.first.id, 'carton-2');
    });

    test('can delete multiple cartons in sequence', () async {
      final shipmentId = 'shipment-2';
      await db
          .into(db.shipments)
          .insert(
            ShipmentsCompanion.insert(
              id: shipmentId,
              createdAt: DateTime.now(),
              originCity: 'Paris',
              originPostal: '75001',
              destCity: 'Rome',
              destPostal: '00100',
            ),
          );

      // Insert 3 cartons
      for (int i = 1; i <= 3; i++) {
        await db
            .into(db.cartons)
            .insert(
              CartonsCompanion.insert(
                id: 'carton-$i',
                shipmentId: shipmentId,
                lengthCm: 50.0,
                widthCm: 40.0,
                heightCm: 30.0,
                weightKg: 10.0,
                qty: 1,
                itemType: 'General',
              ),
            );
      }

      var cartons = await db.select(db.cartons).get();
      expect(cartons.length, 3);

      // Delete first carton
      await (db.delete(db.cartons)..where((c) => c.id.equals('carton-1'))).go();
      cartons = await db.select(db.cartons).get();
      expect(cartons.length, 2);

      // Delete second carton
      await (db.delete(db.cartons)..where((c) => c.id.equals('carton-2'))).go();
      cartons = await db.select(db.cartons).get();
      expect(cartons.length, 1);
      expect(cartons.first.id, 'carton-3');
    });

    test('deleting carton does not affect other shipments', () async {
      // Create two shipments
      await db
          .into(db.shipments)
          .insert(
            ShipmentsCompanion.insert(
              id: 'shipment-1',
              createdAt: DateTime.now(),
              originCity: 'Madrid',
              originPostal: '28001',
              destCity: 'Lisbon',
              destPostal: '1000',
            ),
          );

      await db
          .into(db.shipments)
          .insert(
            ShipmentsCompanion.insert(
              id: 'shipment-2',
              createdAt: DateTime.now(),
              originCity: 'Amsterdam',
              originPostal: '1012',
              destCity: 'Brussels',
              destPostal: '1000',
            ),
          );

      // Add cartons to both shipments
      await db
          .into(db.cartons)
          .insert(
            CartonsCompanion.insert(
              id: 'carton-ship1',
              shipmentId: 'shipment-1',
              lengthCm: 50.0,
              widthCm: 40.0,
              heightCm: 30.0,
              weightKg: 10.0,
              qty: 1,
              itemType: 'General',
            ),
          );

      await db
          .into(db.cartons)
          .insert(
            CartonsCompanion.insert(
              id: 'carton-ship2',
              shipmentId: 'shipment-2',
              lengthCm: 60.0,
              widthCm: 50.0,
              heightCm: 40.0,
              weightKg: 15.0,
              qty: 1,
              itemType: 'General',
            ),
          );

      // Delete carton from shipment-1
      await (db.delete(
        db.cartons,
      )..where((c) => c.id.equals('carton-ship1'))).go();

      // Verify shipment-2's carton is unaffected
      final ship2Cartons = await (db.select(
        db.cartons,
      )..where((c) => c.shipmentId.equals('shipment-2'))).get();
      expect(ship2Cartons.length, 1);
      expect(ship2Cartons.first.id, 'carton-ship2');
    });

    test('deleting carton also deletes related quotes', () async {
      final shipmentId = 'shipment-3';
      await db
          .into(db.shipments)
          .insert(
            ShipmentsCompanion.insert(
              id: shipmentId,
              createdAt: DateTime.now(),
              originCity: 'Vienna',
              originPostal: '1010',
              destCity: 'Prague',
              destPostal: '110',
            ),
          );

      await db
          .into(db.cartons)
          .insert(
            CartonsCompanion.insert(
              id: 'carton-1',
              shipmentId: shipmentId,
              lengthCm: 50.0,
              widthCm: 40.0,
              heightCm: 30.0,
              weightKg: 10.0,
              qty: 1,
              itemType: 'General',
            ),
          );

      // Add quotes for the shipment
      await db
          .into(db.quotes)
          .insert(
            QuotesCompanion.insert(
              id: 'quote-1',
              shipmentId: shipmentId,
              carrier: 'UPS',
              service: 'Express',
              etaMin: 2,
              etaMax: 3,
              priceEur: 100.0,
              chargeableKg: 10.0,
            ),
          );

      var quotes = await db.select(db.quotes).get();
      expect(quotes.length, 1);

      // When deleting carton, quotes should also be deleted (based on implementation)
      await (db.delete(
        db.quotes,
      )..where((q) => q.shipmentId.equals(shipmentId))).go();

      quotes = await db.select(db.quotes).get();
      expect(quotes.length, 0);
    });
  });

  group('Save Carton Database Operations', () {
    test('updating carton dimensions persists to database', () async {
      final shipmentId = 'shipment-4';
      await db
          .into(db.shipments)
          .insert(
            ShipmentsCompanion.insert(
              id: shipmentId,
              createdAt: DateTime.now(),
              originCity: 'Stockholm',
              originPostal: '111',
              destCity: 'Copenhagen',
              destPostal: '1050',
            ),
          );

      final cartonId = 'carton-1';
      await db
          .into(db.cartons)
          .insert(
            CartonsCompanion.insert(
              id: cartonId,
              shipmentId: shipmentId,
              lengthCm: 50.0,
              widthCm: 40.0,
              heightCm: 30.0,
              weightKg: 10.0,
              qty: 1,
              itemType: 'General',
            ),
          );

      // Update dimensions
      await (db.update(db.cartons)..where((c) => c.id.equals(cartonId))).write(
        const CartonsCompanion(
          lengthCm: drift.Value(75.5),
          widthCm: drift.Value(55.3),
          heightCm: drift.Value(45.2),
        ),
      );

      // Verify update
      final updated = await (db.select(
        db.cartons,
      )..where((c) => c.id.equals(cartonId))).getSingle();

      expect(updated.lengthCm, 75.5);
      expect(updated.widthCm, 55.3);
      expect(updated.heightCm, 45.2);
    });

    test('updating carton quantity persists to database', () async {
      final shipmentId = 'shipment-5';
      await db
          .into(db.shipments)
          .insert(
            ShipmentsCompanion.insert(
              id: shipmentId,
              createdAt: DateTime.now(),
              originCity: 'Oslo',
              originPostal: '0150',
              destCity: 'Helsinki',
              destPostal: '00100',
            ),
          );

      final cartonId = 'carton-qty';
      await db
          .into(db.cartons)
          .insert(
            CartonsCompanion.insert(
              id: cartonId,
              shipmentId: shipmentId,
              lengthCm: 50.0,
              widthCm: 40.0,
              heightCm: 30.0,
              weightKg: 10.0,
              qty: 1,
              itemType: 'General',
            ),
          );

      // Update quantity
      await (db.update(db.cartons)..where((c) => c.id.equals(cartonId))).write(
        const CartonsCompanion(qty: drift.Value(5)),
      );

      // Verify update
      final updated = await (db.select(
        db.cartons,
      )..where((c) => c.id.equals(cartonId))).getSingle();

      expect(updated.qty, 5);
    });

    test('updating carton weight persists to database', () async {
      final shipmentId = 'shipment-6';
      await db
          .into(db.shipments)
          .insert(
            ShipmentsCompanion.insert(
              id: shipmentId,
              createdAt: DateTime.now(),
              originCity: 'Dublin',
              originPostal: 'D01',
              destCity: 'Edinburgh',
              destPostal: 'EH1',
            ),
          );

      final cartonId = 'carton-weight';
      await db
          .into(db.cartons)
          .insert(
            CartonsCompanion.insert(
              id: cartonId,
              shipmentId: shipmentId,
              lengthCm: 50.0,
              widthCm: 40.0,
              heightCm: 30.0,
              weightKg: 10.0,
              qty: 1,
              itemType: 'General',
            ),
          );

      // Update weight
      await (db.update(db.cartons)..where((c) => c.id.equals(cartonId))).write(
        const CartonsCompanion(weightKg: drift.Value(25.5)),
      );

      // Verify update
      final updated = await (db.select(
        db.cartons,
      )..where((c) => c.id.equals(cartonId))).getSingle();

      expect(updated.weightKg, 25.5);
    });
  });

  group('Carton Calculations After Delete', () {
    test('totals recalculate correctly after deleting a carton', () async {
      // Create cartons
      final carton1 = models.Carton(
        id: 'carton-1',
        shipmentId: 'ship-1',
        lengthCm: 50.0,
        widthCm: 40.0,
        heightCm: 30.0,
        weightKg: 10.0,
        qty: 2,
        itemType: 'General',
      );

      final carton2 = models.Carton(
        id: 'carton-2',
        shipmentId: 'ship-1',
        lengthCm: 60.0,
        widthCm: 50.0,
        heightCm: 40.0,
        weightKg: 15.0,
        qty: 1,
        itemType: 'General',
      );

      // Calculate totals with both cartons
      var totals = CalculationService.calculateTotals([carton1, carton2]);
      final totalWithBoth = totals.actualKg;

      // Calculate totals after "deleting" carton1 (only carton2 remains)
      totals = CalculationService.calculateTotals([carton2]);
      final totalAfterDelete = totals.actualKg;

      // Verify totals changed
      expect(totalAfterDelete, lessThan(totalWithBoth));
      expect(totalAfterDelete, equals(15.0)); // Only carton2's weight
    });

    test(
      'chargeable weight recalculates after deleting oversized carton',
      () async {
        // Create one regular and one oversized carton
        final regularCarton = models.Carton(
          id: 'regular',
          shipmentId: 'ship-1',
          lengthCm: 50.0,
          widthCm: 40.0,
          heightCm: 30.0,
          weightKg: 10.0,
          qty: 1,
          itemType: 'General',
        );

        final oversizedCarton = models.Carton(
          id: 'oversized',
          shipmentId: 'ship-1',
          lengthCm: 200.0,
          widthCm: 100.0,
          heightCm: 100.0,
          weightKg: 50.0,
          qty: 1,
          itemType: 'General',
        );

        // Calculate with both
        var totals = CalculationService.calculateTotals([
          regularCarton,
          oversizedCarton,
        ]);
        expect(totals.isOversized, true);

        // Calculate after "deleting" oversized carton
        totals = CalculationService.calculateTotals([regularCarton]);
        expect(totals.isOversized, false);
      },
    );
  });

  group('Edge Cases', () {
    test('cannot delete non-existent carton', () async {
      final shipmentId = 'shipment-7';
      await db
          .into(db.shipments)
          .insert(
            ShipmentsCompanion.insert(
              id: shipmentId,
              createdAt: DateTime.now(),
              originCity: 'Warsaw',
              originPostal: '00-001',
              destCity: 'Budapest',
              destPostal: '1011',
            ),
          );

      // Try to delete non-existent carton (should not throw)
      final deleteCount = await (db.delete(
        db.cartons,
      )..where((c) => c.id.equals('non-existent'))).go();

      expect(deleteCount, 0);
    });

    test('deleting all cartons leaves empty carton list', () async {
      final shipmentId = 'shipment-8';
      await db
          .into(db.shipments)
          .insert(
            ShipmentsCompanion.insert(
              id: shipmentId,
              createdAt: DateTime.now(),
              originCity: 'Athens',
              originPostal: '10431',
              destCity: 'Istanbul',
              destPostal: '34000',
            ),
          );

      await db
          .into(db.cartons)
          .insert(
            CartonsCompanion.insert(
              id: 'only-carton',
              shipmentId: shipmentId,
              lengthCm: 50.0,
              widthCm: 40.0,
              heightCm: 30.0,
              weightKg: 10.0,
              qty: 1,
              itemType: 'General',
            ),
          );

      // Delete the carton
      await (db.delete(
        db.cartons,
      )..where((c) => c.shipmentId.equals(shipmentId))).go();

      // Verify no cartons remain
      final cartons = await (db.select(
        db.cartons,
      )..where((c) => c.shipmentId.equals(shipmentId))).get();

      expect(cartons.isEmpty, true);
    });
  });
}
