import 'package:bockaire/classes/carton.dart';
import 'package:bockaire/classes/quote.dart';
import 'package:bockaire/classes/shipment.dart';
import 'package:bockaire/services/carrier_rates_provider.dart';

/// Stub provider for UPS API integration
///
/// TODO: Implement real UPS API calls when credentials are available
/// API docs: https://developer.ups.com/api/reference
class UpsRatesProvider implements CarrierRatesProvider {
  final String? apiKey;
  final String? apiSecret;

  const UpsRatesProvider({this.apiKey, this.apiSecret});

  @override
  String get carrierName => 'UPS';

  @override
  Future<bool> isAvailable() async {
    // Check if API credentials are configured
    return apiKey != null && apiSecret != null;
  }

  @override
  Future<List<Quote>> getQuotes({
    required Shipment shipment,
    required List<Carton> cartons,
  }) async {
    // TODO: Implement real UPS API integration
    // 1. Build UPS Rating API request with shipment details
    // 2. Make HTTP call to UPS Rating API
    // 3. Parse response and convert to Quote objects
    // 4. Return list of quotes for available UPS services

    throw UnimplementedError(
      'UPS API integration not yet implemented. '
      'Use LocalRateTablesProvider for UPS rates instead.',
    );
  }
}
