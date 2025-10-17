import 'package:bockaire/classes/carton.dart';
import 'package:bockaire/classes/quote.dart';
import 'package:bockaire/classes/shipment.dart';
import 'package:bockaire/services/carrier_rates_provider.dart';

/// Stub provider for DHL API integration
///
/// TODO: Implement real DHL API calls when credentials are available
/// API docs: https://developer.dhl.com/api-reference
class DhlRatesProvider implements CarrierRatesProvider {
  final String? apiKey;

  const DhlRatesProvider({this.apiKey});

  @override
  String get carrierName => 'DHL';

  @override
  Future<bool> isAvailable() async {
    // Check if API credentials are configured
    return apiKey != null;
  }

  @override
  Future<List<Quote>> getQuotes({
    required Shipment shipment,
    required List<Carton> cartons,
  }) async {
    // TODO: Implement real DHL API integration
    // 1. Build DHL Rating API request with shipment details
    // 2. Make HTTP call to DHL Rating API
    // 3. Parse response and convert to Quote objects
    // 4. Return list of quotes for available DHL services

    throw UnimplementedError(
      'DHL API integration not yet implemented. '
      'Use LocalRateTablesProvider for DHL rates instead.',
    );
  }
}
