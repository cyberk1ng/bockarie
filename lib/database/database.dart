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
  TextColumn get destCity => text()();
  TextColumn get destPostal => text()();
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

@DriftDatabase(tables: [Shipments, Cartons, RateTables, Quotes, CompanyInfo])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

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
    },
  );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'bockaire.sqlite'));
      return NativeDatabase(file);
    });
  }
}
