import 'package:bockaire/database/database.dart';
import 'package:bockaire/classes/rate_table.dart' as models;
import 'package:bockaire/services/shippo_service.dart';
import 'package:bockaire/config/shippo_config.dart';
import 'package:logger/logger.dart';

/// Service for calculating shipping quotes from rate tables
class QuoteCalculatorService {
  final AppDatabase _database;
  final ShippoService _shippoService;
  final Logger _logger = Logger();

  QuoteCalculatorService(this._database, this._shippoService);

  /// Calculate quote from a rate table
  /// Formula: total = (base + perKg × chargeable) × (1 + fuel%) + oversize_fee
  static ShippingQuote calculateQuote({
    required models.RateTable rate,
    required double chargeableKg,
    required bool isOversized,
  }) {
    // Determine per-kg rate based on breakpoint
    final perKgRate = chargeableKg >= rate.breakpointKg
        ? rate.perKgHigh
        : rate.perKgLow;

    // Calculate subtotal
    final subtotal = rate.baseFee + (perKgRate * chargeableKg);

    // Apply fuel surcharge
    final withFuel = subtotal * (1 + rate.fuelPct);

    // Add oversize fee if applicable
    final total = withFuel + (isOversized ? rate.oversizeFee : 0);

    return ShippingQuote(
      carrier: rate.carrier,
      service: rate.service,
      subtotal: subtotal,
      fuelSurcharge: withFuel - subtotal,
      oversizeFee: isOversized ? rate.oversizeFee : 0,
      total: total,
      chargeableKg: chargeableKg,
      notes: rate.notes,
    );
  }

  /// Calculate all quotes from Shippo API
  Future<List<ShippingQuote>> calculateAllQuotes({
    required double chargeableKg,
    required bool isOversized,
    String? originCity,
    String? originPostal,
    String? originCountry,
    String? originState,
    String? destCity,
    String? destPostal,
    String? destCountry,
    String? destState,
    List<Carton>? cartons,
    bool useShippoApi = true,
  }) async {
    // If we have all the required information and should use Shippo API, get real rates
    if (useShippoApi &&
        originCity != null &&
        originPostal != null &&
        destCity != null &&
        destPostal != null &&
        cartons != null &&
        cartons.isNotEmpty) {
      try {
        _logger.i('Fetching real rates from Shippo API');

        final shippoRates = await _shippoService.getRates(
          originCity: originCity,
          originPostal: originPostal,
          originCountry: originCountry ?? 'CN', // Default to China
          originState: originState ?? '',
          destCity: destCity,
          destPostal: destPostal,
          destCountry: destCountry ?? 'DE', // Default to Germany
          destState: destState ?? '',
          cartons: cartons,
        );

        _logger.i('Received ${shippoRates.length} rates from Shippo');

        // Convert Shippo rates to ShippingQuote objects
        return shippoRates.map((rate) {
          final priceEur = rate.toPriceEur(ShippoConfig.usdToEurRate);

          return ShippingQuote(
            carrier: rate.provider,
            service: rate.servicelevel.name,
            subtotal: priceEur,
            fuelSurcharge: 0.0, // Shippo includes this in the total
            oversizeFee: 0.0, // Shippo includes this in the total
            total: priceEur,
            chargeableKg: chargeableKg,
            notes: rate.estimatedDays != null
                ? 'ETA: ${rate.estimatedDays} days'
                : null,
            estimatedDays: rate.estimatedDays,
            durationTerms: rate.durationTerms,
          );
        }).toList();
      } catch (e) {
        _logger.e('Error fetching rates from Shippo', error: e);
        _logger.w('Falling back to local rate tables');
        // Fall back to local rate tables if Shippo fails
      }
    }

    // Fall back to local rate tables
    _logger.i('Using local rate tables');
    final rates = await _database.select(_database.rateTables).get();

    return rates.map((rateRow) {
      final rate = models.RateTable(
        id: rateRow.id,
        carrier: rateRow.carrier,
        service: rateRow.service,
        baseFee: rateRow.baseFee,
        perKgLow: rateRow.perKgLow,
        perKgHigh: rateRow.perKgHigh,
        breakpointKg: rateRow.breakpointKg,
        fuelPct: rateRow.fuelPct,
        oversizeFee: rateRow.oversizeFee,
        etaMin: rateRow.etaMin,
        etaMax: rateRow.etaMax,
        notes: rateRow.notes,
      );

      return calculateQuote(
        rate: rate,
        chargeableKg: chargeableKg,
        isOversized: isOversized,
      );
    }).toList();
  }

  /// Get best options from quotes
  static QuoteBadges getBestOptions(List<ShippingQuote> quotes) {
    if (quotes.isEmpty) {
      return const QuoteBadges(cheapest: null, fastest: null, bestValue: null);
    }

    // Find cheapest
    final cheapest = quotes.reduce((a, b) => a.total < b.total ? a : b);

    // For now, we don't have ETA data, so we can't determine fastest
    // This would be added when ETA is included in rate tables
    ShippingQuote? fastest;

    // Best value could be a balance of price and speed
    // For now, we'll use cheapest as best value
    final bestValue = cheapest;

    return QuoteBadges(
      cheapest: cheapest,
      fastest: fastest,
      bestValue: bestValue,
    );
  }
}

/// Shipping quote calculation result
class ShippingQuote {
  final String carrier;
  final String service;
  final double subtotal;
  final double fuelSurcharge;
  final double oversizeFee;
  final double total;
  final double chargeableKg;
  final String? notes;
  final int? estimatedDays;
  final String? durationTerms;

  const ShippingQuote({
    required this.carrier,
    required this.service,
    required this.subtotal,
    required this.fuelSurcharge,
    required this.oversizeFee,
    required this.total,
    required this.chargeableKg,
    this.notes,
    this.estimatedDays,
    this.durationTerms,
  });

  String get displayName => '$carrier $service';

  @override
  String toString() {
    return '$displayName: €${total.toStringAsFixed(2)} '
        '(${chargeableKg.toStringAsFixed(1)}kg)';
  }
}

/// Best quote options
class QuoteBadges {
  final ShippingQuote? cheapest;
  final ShippingQuote? fastest;
  final ShippingQuote? bestValue;

  const QuoteBadges({
    required this.cheapest,
    required this.fastest,
    required this.bestValue,
  });

  bool isCheapest(ShippingQuote quote) =>
      cheapest != null && quote.displayName == cheapest!.displayName;

  bool isFastest(ShippingQuote quote) =>
      fastest != null && quote.displayName == fastest!.displayName;

  bool isBestValue(ShippingQuote quote) =>
      bestValue != null && quote.displayName == bestValue!.displayName;
}
