import 'package:bockaire/classes/carton.dart' as model;
import 'package:bockaire/classes/quote.dart' as model;
import 'package:bockaire/classes/rate_table.dart' as model;
import 'package:bockaire/classes/shipment.dart' as model;
import 'package:bockaire/database/database.dart';
import 'package:bockaire/services/carrier_rates_provider.dart';
import 'package:bockaire/services/calculation_service.dart';
import 'package:uuid/uuid.dart';

/// Provider that uses local editable rate tables to generate quotes
class LocalRateTablesProvider implements CarrierRatesProvider {
  final AppDatabase _database;
  final String _carrier;

  const LocalRateTablesProvider({
    required AppDatabase database,
    required String carrier,
  }) : _database = database,
       _carrier = carrier;

  @override
  String get carrierName => _carrier;

  @override
  Future<bool> isAvailable() async {
    // Check if we have any rate tables for this carrier
    final tables = await (_database.select(
      _database.rateTables,
    )..where((t) => t.carrier.equals(_carrier))).get();
    return tables.isNotEmpty;
  }

  @override
  Future<List<model.Quote>> getQuotes({
    required model.Shipment shipment,
    required List<model.Carton> cartons,
  }) async {
    // Get all rate tables for this carrier
    final tables = await (_database.select(
      _database.rateTables,
    )..where((t) => t.carrier.equals(_carrier))).get();

    if (tables.isEmpty) {
      return [];
    }

    // Calculate totals for the shipment
    final totals = CalculationService.calculateTotals(cartons);
    const uuid = Uuid();

    // Generate a quote for each service
    final quotes = <model.Quote>[];
    for (final tableRow in tables) {
      final rateTable = model.RateTable(
        id: tableRow.id,
        carrier: tableRow.carrier,
        service: tableRow.service,
        baseFee: tableRow.baseFee,
        perKgLow: tableRow.perKgLow,
        perKgHigh: tableRow.perKgHigh,
        breakpointKg: tableRow.breakpointKg,
        fuelPct: tableRow.fuelPct,
        oversizeFee: tableRow.oversizeFee,
        etaMin: tableRow.etaMin,
        etaMax: tableRow.etaMax,
        notes: tableRow.notes,
      );

      final price = rateTable.calculateCost(
        chargeableKg: totals.chargeableKg,
        hasOversize: totals.isOversized,
      );

      quotes.add(
        model.Quote(
          id: uuid.v4(),
          shipmentId: shipment.id,
          carrier: rateTable.carrier,
          service: rateTable.service,
          etaMin: rateTable.etaMin,
          etaMax: rateTable.etaMax,
          priceEur: price,
          chargeableKg: totals.chargeableKg,
        ),
      );
    }

    return quotes;
  }
}
