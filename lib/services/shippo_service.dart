import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:bockaire/config/shippo_config.dart';
import 'package:bockaire/config/ui_strings.dart';
import 'package:bockaire/models/shippo_models.dart';
import 'package:bockaire/database/database.dart';

/// Service for interacting with Shippo API
class ShippoService {
  final Dio _dio;
  final Logger _logger = Logger();

  ShippoService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: ShippoConfig.baseUrl,
      connectTimeout: Duration(milliseconds: ShippoConfig.timeoutMs),
      receiveTimeout: Duration(milliseconds: ShippoConfig.timeoutMs),
      headers: {
        'Authorization': 'ShippoToken ${ShippoConfig.apiKey}',
        'Content-Type': 'application/json',
        'Shippo-API-Version': ShippoConfig.apiVersion,
      },
    );

    // Add logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => _logger.d(obj),
      ),
    );
  }

  /// Get shipping rates from Shippo API
  ///
  /// Returns a list of rates for the given shipment details
  Future<List<ShippoRate>> getRates({
    required String originCity,
    required String originPostal,
    required String originCountry,
    String originState = '',
    required String destCity,
    required String destPostal,
    required String destCountry,
    String destState = '',
    required List<Carton> cartons,
  }) async {
    try {
      _logger.i('Getting rates from Shippo API');
      _logger.d('Origin: $originCity, $originPostal, $originCountry');
      _logger.d('Destination: $destCity, $destPostal, $destCountry');
      _logger.d('Cartons: ${cartons.length}');

      // Convert cartons to Shippo parcels
      final parcels = _convertCartonsToShippoParcels(cartons);

      // Check if this is an international shipment (different countries)
      final isInternational = originCountry != destCountry;
      ShippoCustomsDeclaration? customsDeclaration;

      if (isInternational) {
        _logger.i(
          'International shipment detected - creating customs declaration',
        );
        customsDeclaration = _createCustomsDeclaration(cartons, originCountry);
      }

      // Create shipment request
      final request = ShippoShipmentRequest(
        addressFrom: ShippoAddress(
          name: 'Sender',
          street1: 'Street 1',
          city: originCity,
          state: originState,
          zip: originPostal,
          country: originCountry,
        ),
        addressTo: ShippoAddress(
          name: 'Recipient',
          street1: 'Street 1',
          city: destCity,
          state: destState,
          zip: destPostal,
          country: destCountry,
        ),
        parcels: parcels,
        async: false,
        customsDeclaration: customsDeclaration,
      );

      _logger.d('Request payload: ${request.toJson()}');

      // Make API request
      final response = await _dio.post('/shipments/', data: request.toJson());

      _logger.i('Received response from Shippo API');
      _logger.d('Response status: ${response.statusCode}');

      // Log raw response for debugging
      _logger.d('Raw response data: ${response.data}');

      // Parse response
      final shipmentResponse = ShippoShipmentResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      _logger.i('Parsed ${shipmentResponse.rates.length} rates');

      // Log each rate
      for (final rate in shipmentResponse.rates) {
        _logger.d(
          'Rate: ${rate.provider} ${rate.servicelevel.name} - ${rate.amount} ${rate.currency}',
        );
      }

      // If no rates returned, log warning with shipment status
      if (shipmentResponse.rates.isEmpty) {
        _logger.w('No rates returned from Shippo API!');
        _logger.w('Shipment status: ${shipmentResponse.status}');
        if (shipmentResponse.messages.isNotEmpty) {
          _logger.w('Messages from Shippo:');
          for (final msg in shipmentResponse.messages) {
            _logger.w('  - ${msg.text} (${msg.code})');
          }
        }
      }

      return shipmentResponse.rates;
    } on DioException catch (e) {
      _logger.e('Shippo API error', error: e);
      throw _handleDioError(e);
    } catch (e) {
      _logger.e('Unexpected error getting rates', error: e);
      throw ShippoServiceException('Unexpected error: $e');
    }
  }

  /// Convert app cartons to Shippo parcels (LIVE PRODUCTION MODE)
  ///
  /// Creates individual parcels for each quantity for accurate carrier pricing.
  /// Real carriers need exact parcel counts for proper pricing and logistics.
  List<ShippoParcel> _convertCartonsToShippoParcels(List<Carton> cartons) {
    final parcels = <ShippoParcel>[];

    for (final carton in cartons) {
      _logger.d(
        'Converting carton: ${carton.lengthCm}x${carton.widthCm}x${carton.heightCm}cm, '
        '${carton.weightKg}kg, qty=${carton.qty}',
      );

      // Create individual parcels for accurate carrier pricing
      for (int i = 0; i < carton.qty; i++) {
        parcels.add(
          ShippoParcel(
            length: carton.lengthCm.toStringAsFixed(0),
            width: carton.widthCm.toStringAsFixed(0),
            height: carton.heightCm.toStringAsFixed(0),
            weight: carton.weightKg.toStringAsFixed(2),
            distanceUnit: 'cm',
            massUnit: 'kg',
          ),
        );
      }
    }

    _logger.i(
      'Created ${parcels.length} parcels from ${cartons.length} carton entries (LIVE mode)',
    );

    return parcels;
  }

  /// Create customs declaration for international shipments
  ///
  /// Generates a customs declaration from carton data for cross-border shipping.
  /// Required for UPS, DHL, FedEx international shipments.
  ShippoCustomsDeclaration _createCustomsDeclaration(
    List<Carton> cartons,
    String originCountry,
  ) {
    // Calculate total weight for customs
    final _ = cartons.fold<double>(
      0,
      (sum, carton) => sum + (carton.weightKg * carton.qty),
    );

    // Create customs items from cartons
    final customsItems = cartons.map((carton) {
      // Estimate value per kg (can be configured later)
      const estimatedValuePerKg = 50.0; // USD
      final totalValue = (carton.weightKg * carton.qty * estimatedValuePerKg);

      return ShippoCustomsItem(
        description: carton.itemType.isNotEmpty
            ? carton.itemType
            : 'General Merchandise',
        quantity: carton.qty,
        netWeight: (carton.weightKg * carton.qty).toStringAsFixed(2),
        massUnit: 'kg',
        valueAmount: totalValue.toStringAsFixed(2),
        valueCurrency: 'USD',
        originCountry: originCountry,
        tariffNumber: _getDefaultTariffNumber(carton.itemType),
      );
    }).toList();

    return ShippoCustomsDeclaration(
      contentsType: 'MERCHANDISE',
      contentsExplanation: _generateContentsExplanation(cartons),
      nonDeliveryOption: 'RETURN',
      certify: true,
      certifySigner: 'Sender',
      items: customsItems,
    );
  }

  /// Generate a brief contents explanation from carton types
  String _generateContentsExplanation(List<Carton> cartons) {
    final uniqueTypes = cartons
        .map((c) => c.itemType)
        .where((type) => type.isNotEmpty)
        .toSet()
        .take(3)
        .join(', ');

    return uniqueTypes.isNotEmpty ? uniqueTypes : 'General Merchandise';
  }

  /// Get default tariff number based on item type
  ///
  /// Returns a generic HS code. For production use, proper tariff codes
  /// should be provided by the user or looked up in a database.
  String? _getDefaultTariffNumber(String itemType) {
    final type = itemType.toLowerCase();

    // Common HS codes for typical items
    if (type.contains('electronic') || type.contains('laptop')) {
      return '8517.12.00'; // Telephones/electronics
    } else if (type.contains('clothing') ||
        type.contains('shirt') ||
        type.contains('apparel')) {
      return '6109.10.00'; // T-shirts and similar garments
    } else if (type.contains('shoe') || type.contains('footwear')) {
      return '6403.99.00'; // Footwear
    } else if (type.contains('toy')) {
      return '9503.00.00'; // Toys
    }

    // Generic merchandise code
    return '9999.00.00';
  }

  /// Handle Dio errors and convert to ShippoServiceException
  ShippoServiceException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ShippoServiceException(UIStrings.errorRequestTimeout);

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        if (data is Map<String, dynamic>) {
          final error = ShippoError.fromJson(data);
          return ShippoServiceException(
            'Shippo API error ($statusCode): ${error.message}',
          );
        }

        return ShippoServiceException(
          'Shippo API error ($statusCode): ${e.message}',
        );

      case DioExceptionType.cancel:
        return ShippoServiceException('Request was cancelled');

      case DioExceptionType.connectionError:
        return ShippoServiceException(
          'Connection error. Please check your internet connection.',
        );

      default:
        return ShippoServiceException('Network error: ${e.message}');
    }
  }

  /// Purchase a shipping label (optional for future implementation)
  Future<String> purchaseLabel(String rateId) async {
    try {
      _logger.i('Purchasing label for rate: $rateId');

      final response = await _dio.post(
        '/transactions/',
        data: {'rate': rateId, 'label_file_type': 'PDF', 'async': false},
      );

      final labelUrl = response.data['label_url'] as String;
      _logger.i('Label purchased successfully: $labelUrl');

      return labelUrl;
    } on DioException catch (e) {
      _logger.e('Error purchasing label', error: e);
      throw _handleDioError(e);
    } catch (e) {
      _logger.e('Unexpected error purchasing label', error: e);
      throw ShippoServiceException('Unexpected error: $e');
    }
  }
}

/// Custom exception for Shippo service errors
class ShippoServiceException implements Exception {
  final String message;

  ShippoServiceException(this.message);

  @override
  String toString() => message;
}
