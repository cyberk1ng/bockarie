import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:bockaire/config/shippo_config.dart';
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

      return shipmentResponse.rates;
    } on DioException catch (e) {
      _logger.e('Shippo API error', error: e);
      throw _handleDioError(e);
    } catch (e) {
      _logger.e('Unexpected error getting rates', error: e);
      throw ShippoServiceException('Unexpected error: $e');
    }
  }

  /// Convert app cartons to Shippo parcels
  ///
  /// If a carton has qty > 1, we create multiple parcels
  List<ShippoParcel> _convertCartonsToShippoParcels(List<Carton> cartons) {
    final parcels = <ShippoParcel>[];

    for (final carton in cartons) {
      // Create parcels based on quantity
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

    return parcels;
  }

  /// Handle Dio errors and convert to ShippoServiceException
  ShippoServiceException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ShippoServiceException(
          'Request timeout. Please check your internet connection.',
        );

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
