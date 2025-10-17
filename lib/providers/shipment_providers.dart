import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bockaire/database/database.dart';
import 'package:bockaire/get_it.dart';
import 'package:bockaire/classes/carton.dart' as models;
import 'package:drift/drift.dart';

part 'shipment_providers.g.dart';

/// Provider for accessing the database
@riverpod
// ignore: deprecated_member_use_from_same_package
AppDatabase database(DatabaseRef ref) {
  return getIt<AppDatabase>();
}

/// Provider for fetching a single shipment by ID
@riverpod
// ignore: deprecated_member_use_from_same_package
Future<Shipment> shipment(ShipmentRef ref, String shipmentId) async {
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.shipments,
  )..where((s) => s.id.equals(shipmentId))).getSingle();
}

/// Provider for fetching all cartons for a shipment
@riverpod
// ignore: deprecated_member_use_from_same_package
Future<List<Carton>> cartons(CartonsRef ref, String shipmentId) async {
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.cartons,
  )..where((c) => c.shipmentId.equals(shipmentId))).get();
}

/// Provider for fetching cartons as models (for calculations)
@riverpod
Future<List<models.Carton>> cartonModels(
  // ignore: deprecated_member_use_from_same_package
  CartonModelsRef ref,
  String shipmentId,
) async {
  final cartons = await ref.watch(cartonsProvider(shipmentId).future);
  return cartons
      .map(
        (c) => models.Carton(
          id: c.id,
          shipmentId: c.shipmentId,
          lengthCm: c.lengthCm,
          widthCm: c.widthCm,
          heightCm: c.heightCm,
          weightKg: c.weightKg,
          qty: c.qty,
          itemType: c.itemType,
        ),
      )
      .toList();
}

/// Provider for fetching all quotes for a shipment
@riverpod
// ignore: deprecated_member_use_from_same_package
Future<List<Quote>> quotes(QuotesRef ref, String shipmentId) async {
  final db = ref.watch(databaseProvider);
  final quotesList =
      await (db.select(db.quotes)
            ..where((q) => q.shipmentId.equals(shipmentId))
            ..orderBy([(q) => OrderingTerm.asc(q.priceEur)]))
          .get();
  return quotesList;
}

/// Provider for fetching recent shipments (for home page)
@riverpod
// ignore: deprecated_member_use_from_same_package
Stream<List<Shipment>> recentShipments(RecentShipmentsRef ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.shipments)
        ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
        ..limit(10))
      .watch();
}

/// Provider for cheapest quote for a shipment
@riverpod
// ignore: deprecated_member_use_from_same_package
Future<Quote?> cheapestQuote(CheapestQuoteRef ref, String shipmentId) async {
  final quotesList = await ref.watch(quotesProvider(shipmentId).future);
  if (quotesList.isEmpty) return null;
  return quotesList.first; // Already sorted by price
}
