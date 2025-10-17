import 'package:bockaire/database/database.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Database seeder for initial data
class DatabaseSeeder {
  final AppDatabase _database;
  final _uuid = const Uuid();

  DatabaseSeeder(this._database);

  /// Seed the database with initial rate tables
  Future<void> seedRateTables() async {
    // Check if rate tables already exist
    final existing = await _database.select(_database.rateTables).get();
    if (existing.isNotEmpty) {
      return; // Already seeded
    }

    final rateTablesToSeed = [
      // UPS Saver: base 120, per-kg 6.2, fuel 12%, oversize 50, eta 5–7
      RateTablesCompanion.insert(
        id: _uuid.v4(),
        carrier: 'UPS',
        service: 'Saver',
        baseFee: 120.0,
        perKgLow: 6.2,
        perKgHigh: 6.2,
        breakpointKg: 100.0, // After 100kg, use high rate (same as low for now)
        fuelPct: 12.0,
        oversizeFee: 50.0,
        etaMin: 5,
        etaMax: 7,
        notes: const Value('Express service, fastest UPS option'),
      ),

      // UPS Expedited: base 100, per-kg 5.5, fuel 12%, oversize 50, eta 7–9
      RateTablesCompanion.insert(
        id: _uuid.v4(),
        carrier: 'UPS',
        service: 'Expedited',
        baseFee: 100.0,
        perKgLow: 5.5,
        perKgHigh: 5.5,
        breakpointKg: 100.0,
        fuelPct: 12.0,
        oversizeFee: 50.0,
        etaMin: 7,
        etaMax: 9,
        notes: const Value('Standard express service'),
      ),

      // DHL Express: base 140, per-kg 6.8, fuel 14%, oversize 60, eta 5–7
      RateTablesCompanion.insert(
        id: _uuid.v4(),
        carrier: 'DHL',
        service: 'Express',
        baseFee: 140.0,
        perKgLow: 6.8,
        perKgHigh: 6.8,
        breakpointKg: 100.0,
        fuelPct: 14.0,
        oversizeFee: 60.0,
        etaMin: 5,
        etaMax: 7,
        notes: const Value('Premium express service'),
      ),

      // FedEx IP: base 130, per-kg 6.4, fuel 13%, oversize 55, eta 5–7
      RateTablesCompanion.insert(
        id: _uuid.v4(),
        carrier: 'FedEx',
        service: 'International Priority',
        baseFee: 130.0,
        perKgLow: 6.4,
        perKgHigh: 6.4,
        breakpointKg: 100.0,
        fuelPct: 13.0,
        oversizeFee: 55.0,
        etaMin: 5,
        etaMax: 7,
        notes: const Value('Fast international delivery'),
      ),

      // Forwarder Air: base 60, per-kg 4.2, fuel 8%, oversize 0, eta 7–12
      RateTablesCompanion.insert(
        id: _uuid.v4(),
        carrier: 'Forwarder',
        service: 'Air Freight',
        baseFee: 60.0,
        perKgLow: 4.2,
        perKgHigh: 4.2,
        breakpointKg: 100.0,
        fuelPct: 8.0,
        oversizeFee: 0.0,
        etaMin: 7,
        etaMax: 12,
        notes: const Value('Economical air freight option'),
      ),
    ];

    // Insert all rate tables
    await _database.batch((batch) {
      batch.insertAll(_database.rateTables, rateTablesToSeed);
    });
  }

  /// Seed all tables
  Future<void> seedAll() async {
    await seedRateTables();
  }
}
