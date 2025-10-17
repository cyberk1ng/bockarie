import 'package:bockaire/classes/carton.dart';
import 'package:bockaire/classes/quote.dart';
import 'package:bockaire/classes/shipment.dart';
import 'package:bockaire/services/carrier_rates_provider.dart';

/// Stub provider for FedEx API integration
///
/// TODO: Implement real FedEx API calls when credentials are available
/// API docs: https://developer.fedex.com/api/en-us/catalog/rate/docs.html
class FedexRatesProvider implements CarrierRatesProvider {
  final String? apiKey;
  final String? apiSecret;

  const FedexRatesProvider({this.apiKey, this.apiSecret});

  @override
  String get carrierName => 'FedEx';

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
    // TODO: Implement real FedEx API integration
    // 1. Build FedEx Rating API request with shipment details
    // 2. Make HTTP call to FedEx Rating API
    // 3. Parse response and convert to Quote objects
    // 4. Return list of quotes for available FedEx services

    throw UnimplementedError(
      'FedEx API integration not yet implemented. '
      'Use LocalRateTablesProvider for FedEx rates instead.',
    );
  }
}
