import 'package:bockaire/classes/carton.dart';
import 'package:bockaire/classes/quote.dart';
import 'package:bockaire/classes/shipment.dart';

/// Abstract interface for fetching shipping rates from carriers
///
/// Implementations can use:
/// - Local rate tables (LocalRateTablesProvider)
/// - Real carrier APIs (UpsRatesProvider, DhlRatesProvider, FedexRatesProvider)
/// - Mock data for testing
abstract class CarrierRatesProvider {
  /// Get quotes for a shipment with the given cartons
  ///
  /// Returns a list of quotes from this carrier with pricing and ETA
  Future<List<Quote>> getQuotes({
    required Shipment shipment,
    required List<Carton> cartons,
  });

  /// Get the name of this carrier (e.g., "UPS", "DHL", "FedEx", "Forwarder")
  String get carrierName;

  /// Whether this provider is currently available
  ///
  /// Can be false if API credentials are missing, service is down, etc.
  Future<bool> isAvailable();
}

/// Result of comparing multiple carrier quotes
class QuoteComparison {
  final List<Quote> allQuotes;
  final Quote? cheapest;
  final Quote? fastest;
  final Quote? bestValue;

  const QuoteComparison({
    required this.allQuotes,
    this.cheapest,
    this.fastest,
    this.bestValue,
  });

  /// Create a comparison from a list of quotes
  factory QuoteComparison.fromQuotes(List<Quote> quotes) {
    if (quotes.isEmpty) {
      return const QuoteComparison(allQuotes: []);
    }

    // Sort by price to find cheapest
    final sortedByPrice = List<Quote>.from(quotes)
      ..sort((a, b) => a.priceEur.compareTo(b.priceEur));
    final cheapest = sortedByPrice.first;

    // Sort by max ETA to find fastest
    final sortedBySpeed = List<Quote>.from(quotes)
      ..sort((a, b) => a.etaMax.compareTo(b.etaMax));
    final fastest = sortedBySpeed.first;

    // Best value: balance between price and speed
    // Calculate value score: lower is better
    // Normalize price and speed, then combine
    final maxPrice = sortedByPrice.last.priceEur;
    final minPrice = sortedByPrice.first.priceEur;
    final maxEta = sortedBySpeed.last.etaMax.toDouble();
    final minEta = sortedBySpeed.first.etaMax.toDouble();

    final priceRange = maxPrice - minPrice;
    final etaRange = maxEta - minEta;

    Quote? bestValue;
    if (priceRange > 0 && etaRange > 0) {
      // Calculate value score for each quote
      final quotesWithScores = quotes.map((quote) {
        final normalizedPrice = (quote.priceEur - minPrice) / priceRange;
        final normalizedEta = (quote.etaMax - minEta) / etaRange;
        final valueScore = normalizedPrice + normalizedEta; // Lower is better
        return {'quote': quote, 'score': valueScore};
      }).toList();

      quotesWithScores.sort(
        (a, b) => (a['score'] as double).compareTo(b['score'] as double),
      );
      bestValue = quotesWithScores.first['quote'] as Quote;
    } else {
      // If all prices or ETAs are the same, pick the cheapest
      bestValue = cheapest;
    }

    return QuoteComparison(
      allQuotes: quotes,
      cheapest: cheapest,
      fastest: fastest,
      bestValue: bestValue,
    );
  }
}
