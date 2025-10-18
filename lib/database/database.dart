import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// Tables
class Shipments extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get originCity => text()();
  TextColumn get originPostal => text()();
  TextColumn get originCountry => text().withDefault(
    const Constant(''),
  )(); // ISO country code (e.g., "US", "CN", "DE")
  TextColumn get originState => text().withDefault(
    const Constant(''),
  )(); // State/province for US addresses
  TextColumn get destCity => text()();
  TextColumn get destPostal => text()();
  TextColumn get destCountry => text().withDefault(
    const Constant(''),
  )(); // ISO country code (e.g., "US", "CN", "DE")
  TextColumn get destState => text().withDefault(
    const Constant(''),
  )(); // State/province for US addresses
  IntColumn get deadlineDays => integer().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Cartons extends Table {
  TextColumn get id => text()();
  TextColumn get shipmentId => text().references(Shipments, #id)();
  RealColumn get lengthCm => real()();
  RealColumn get widthCm => real()();
  RealColumn get heightCm => real()();
  RealColumn get weightKg => real()();
  IntColumn get qty => integer()();
  TextColumn get itemType => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class RateTables extends Table {
  TextColumn get id => text()();
  TextColumn get carrier => text()();
  TextColumn get service => text()();
  RealColumn get baseFee => real()();
  RealColumn get perKgLow => real()();
  RealColumn get perKgHigh => real()();
  RealColumn get breakpointKg => real()();
  RealColumn get fuelPct => real()();
  RealColumn get oversizeFee => real()();
  IntColumn get etaMin => integer()();
  IntColumn get etaMax => integer()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Quotes extends Table {
  TextColumn get id => text()();
  TextColumn get shipmentId => text().references(Shipments, #id)();
  TextColumn get carrier => text()();
  TextColumn get service => text()();
  IntColumn get etaMin => integer()();
  IntColumn get etaMax => integer()();
  RealColumn get priceEur => real()();
  RealColumn get chargeableKg => real()();
  TextColumn get transportMethod => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class CompanyInfo extends Table {
  TextColumn get id => text()();
  TextColumn get companyName => text()();
  TextColumn get address => text()();
  TextColumn get city => text()();
  TextColumn get postalCode => text()();
  TextColumn get country => text()();
  TextColumn get vatNumber => text().nullable()();
  TextColumn get eoriNumber => text().nullable()();
  TextColumn get contactName => text().nullable()();
  TextColumn get contactEmail => text().nullable()();
  TextColumn get contactPhone => text().nullable()();
  TextColumn get defaultHsCodes =>
      text().nullable()(); // JSON string for common HS codes

  @override
  Set<Column> get primaryKey => {id};
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [Shipments, Cartons, RateTables, Quotes, CompanyInfo, Settings],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Constructor for testing with custom executor
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Migration from version 1 to 2
        // Add deadlineDays column to Shipments table
        await m.addColumn(shipments, shipments.deadlineDays);

        // Add etaMin and etaMax columns to RateTables table
        await m.addColumn(rateTables, rateTables.etaMin);
        await m.addColumn(rateTables, rateTables.etaMax);

        // Create CompanyInfo table
        await m.createTable(companyInfo);
      }
      if (from < 3) {
        // Migration from version 2 to 3
        // Add country and state columns to Shipments table for Shippo API
        await m.addColumn(shipments, shipments.originCountry);
        await m.addColumn(shipments, shipments.originState);
        await m.addColumn(shipments, shipments.destCountry);
        await m.addColumn(shipments, shipments.destState);
      }
      if (from < 4) {
        // Migration from version 3 to 4
        // Add transportMethod column to Quotes table
        await m.addColumn(quotes, quotes.transportMethod);
      }
      if (from < 5) {
        // Migration from version 4 to 5
        // Create Settings table for theme preferences
        await m.createTable(settings);
      }
    },
  );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'bockaire.sqlite'));
      return NativeDatabase(file);
    });
  }

  // Settings DAO methods
  Future<String?> getSetting(String key) async {
    final query = select(settings)..where((s) => s.key.equals(key));
    final result = await query.getSingleOrNull();
    return result?.value;
  }

  Future<void> saveSetting(String key, String value) async {
    await into(
      settings,
    ).insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));
  }
}
