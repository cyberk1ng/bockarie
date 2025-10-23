import 'package:logger/logger.dart';
import 'package:bockaire/services/shippo_rates_service.dart';
import 'package:bockaire/database/database.dart';

/// Manual test helper for Shippo live integration
///
/// Use this to test the live Shippo integration without writing formal tests.
/// Run this from your main app or a debug screen.
class ShippoLiveIntegrationTest {
  final Logger _logger = Logger();

  /// Test live rates fetching with a real route
  ///
  /// Example route: Shenzhen (China) → Bremen (Germany)
  Future<void> testLiveRates() async {
    _logger.i('🧪 Testing Shippo Live Rates Integration...');

    final ratesService = ShippoRatesService();

    // Create test cartons
    final testCartons = [
      Carton(
        id: 'test-1',
        shipmentId: 'test-shipment',
        lengthCm: 50,
        widthCm: 30,
        heightCm: 20,
        weightKg: 5.0,
        qty: 2,
        itemType: 'Electronics',
      ),
    ];

    try {
      _logger.i('📦 Fetching rates for: Shenzhen, CN → Bremen, DE');
      _logger.i('Cartons: 50x30x20cm, 5kg, qty=2');

      final quotes = await ratesService.getLiveRates(
        originCity: 'Shenzhen',
        originPostal: '518000',
        originCountry: 'CN',
        destCity: 'Bremen',
        destPostal: '28195',
        destCountry: 'DE',
        cartons: testCartons,
      );

      _logger.i('✅ SUCCESS! Received ${quotes.length} live quotes:');

      for (final quote in quotes) {
        _logger.i(
          '  - ${quote.carrier} ${quote.service}: '
          '${quote.price} ${quote.currency} → ${quote.priceEur.toStringAsFixed(2)} EUR '
          '(${quote.transitDays} days)',
        );
      }

      _logger.i('🎉 Live rates integration test PASSED!');
      return;
    } catch (e) {
      _logger.e('❌ Live rates test FAILED: $e');
      rethrow;
    }
  }

  /// Test with different routes
  Future<void> testMultipleRoutes() async {
    final routes = [
      {
        'name': 'China → Germany',
        'origin': {'city': 'Shanghai', 'postal': '200000', 'country': 'CN'},
        'dest': {'city': 'Hamburg', 'postal': '20095', 'country': 'DE'},
      },
      {
        'name': 'USA → Germany',
        'origin': {'city': 'New York', 'postal': '10001', 'country': 'US'},
        'dest': {'city': 'Berlin', 'postal': '10115', 'country': 'DE'},
      },
    ];

    final ratesService = ShippoRatesService();
    final testCartons = [
      Carton(
        id: 'test-1',
        shipmentId: 'test-shipment',
        lengthCm: 40,
        widthCm: 30,
        heightCm: 25,
        weightKg: 10.0,
        qty: 1,
        itemType: 'General',
      ),
    ];

    for (final route in routes) {
      try {
        _logger.i('Testing route: ${route['name']}');

        final origin = route['origin'] as Map<String, String>;
        final dest = route['dest'] as Map<String, String>;

        final quotes = await ratesService.getLiveRates(
          originCity: origin['city']!,
          originPostal: origin['postal']!,
          originCountry: origin['country']!,
          destCity: dest['city']!,
          destPostal: dest['postal']!,
          destCountry: dest['country']!,
          cartons: testCartons,
        );

        _logger.i('✅ ${route['name']}: ${quotes.length} quotes');
      } catch (e) {
        _logger.e('❌ ${route['name']}: $e');
      }
    }
  }
}
