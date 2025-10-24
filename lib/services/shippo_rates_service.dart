import 'dart:async';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:bockaire/config/shippo_config.dart';
import 'package:bockaire/models/shippo_models.dart';
import 'package:bockaire/database/database.dart';
import 'package:bockaire/classes/quote.dart' as models;

/// Production-grade Shippo Rates Service
///
/// This service is designed for RATES-ONLY workflows with live Shippo API keys.
/// It NEVER creates or purchases labels unless explicitly enabled via feature flag.
///
/// Safety features:
/// - Rates-only API calls (no /transactions endpoint)
/// - Rate limiting and retry logic with exponential backoff
/// - Response caching to minimize API calls
/// - Comprehensive error handling
/// - Carrier account filtering support
class ShippoRatesService {
  final Dio _dio;
  final Logger _logger = Logger();

  // Cache for rates (signature -> rates, timestamp)
  final Map<String, _CachedRates> _ratesCache = {};

  // Rate limiting
  static const int _maxRetriesOn429 = 3;
  static const Duration _rateCacheExpiry = Duration(seconds: 120);

  ShippoRatesService({Dio? dio}) : _dio = dio ?? Dio() {
    _configureClient();
  }

  /// Configure Dio client with proper headers and interceptors
  void _configureClient() {
    _dio.options = BaseOptions(
      baseUrl: ShippoConfig.baseUrl,
      connectTimeout: const Duration(milliseconds: ShippoConfig.timeoutMs),
      receiveTimeout: const Duration(milliseconds: ShippoConfig.timeoutMs),
      headers: {
        'Authorization': 'ShippoToken ${ShippoConfig.apiKey}',
        'Content-Type': 'application/json',
        'Shippo-API-Version': ShippoConfig.apiVersion,
      },
    );

    // Add logging interceptor (sanitizes sensitive data)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('[Shippo Request] ${options.method} ${options.path}');
          // Never log the full Authorization header
          _logger.d(
            '[Shippo Headers] Content-Type: ${options.headers['Content-Type']}',
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
            '[Shippo Response] ${response.statusCode} ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.e(
            '[Shippo Error] ${error.response?.statusCode} ${error.message}',
          );
          return handler.next(error);
        },
      ),
    );
  }

  /// Get live shipping rates from Shippo API (RATES ONLY - NO LABEL PURCHASE)
  ///
  /// This method:
  /// - Fetches real carrier rates using the live API key
  /// - Implements caching to avoid redundant API calls
  /// - Handles rate limiting with exponential backoff
  /// - NEVER calls /transactions endpoint
  ///
  /// [carrierAccounts] - Optional list of carrier account IDs to filter rates
  /// Returns standardized Quote objects for display in the app
  Future<List<models.Quote>> getLiveRates({
    required String originCity,
    required String originPostal,
    required String originCountry,
    String originState = '',
    required String destCity,
    required String destPostal,
    required String destCountry,
    String destState = '',
    required List<Carton> cartons,
    List<String>? carrierAccounts,
  }) async {
    try {
      _logger.i('🚢 Fetching LIVE rates from Shippo (rates-only, no labels)');
      _logger.d('Route: $originCity, $originCountry → $destCity, $destCountry');
      _logger.d('Cartons: ${cartons.length}');

      // Generate cache key
      final cacheKey = _generateCacheKey(
        originCity: originCity,
        originPostal: originPostal,
        originCountry: originCountry,
        destCity: destCity,
        destPostal: destPostal,
        destCountry: destCountry,
        cartons: cartons,
      );

      // Check cache first
      final cached = _ratesCache[cacheKey];
      if (cached != null && !cached.isExpired) {
        _logger.i('✅ Returning cached rates (${cached.quotes.length} quotes)');
        return cached.quotes;
      }

      // Convert cartons to Shippo parcels (production mode - accurate counts)
      final parcels = _convertCartonsToShippoParcels(cartons);

      // Build shipment request
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
        async: false, // Synchronous request for immediate rates
      );

      // Add carrier account filtering if specified
      final requestData = request.toJson();
      if (carrierAccounts != null && carrierAccounts.isNotEmpty) {
        requestData['carrier_accounts'] = carrierAccounts;
        _logger.d('Filtering to carrier accounts: $carrierAccounts');
      }

      // Make API request with retry logic
      final shippoRates = await _fetchRatesWithRetry(requestData);

      // Convert Shippo rates to Quote objects
      final quotes = _convertShippoRatesToQuotes(shippoRates);

      _logger.i('✅ Retrieved ${quotes.length} live rates');

      // Cache the results
      _ratesCache[cacheKey] = _CachedRates(
        quotes: quotes,
        timestamp: DateTime.now(),
      );

      return quotes;
    } catch (e) {
      _logger.e('❌ Error fetching live rates: $e');
      rethrow;
    }
  }

  /// Fetch rates with retry logic and exponential backoff
  Future<List<ShippoRate>> _fetchRatesWithRetry(
    Map<String, dynamic> requestData, {
    int attempt = 0,
  }) async {
    try {
      _logger.d('API Request attempt ${attempt + 1}');

      final response = await _dio.post('/shipments/', data: requestData);

      _logger.d('Response status: ${response.statusCode}');

      // Parse response
      final shipmentResponse = ShippoShipmentResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Check for errors/warnings in response
      if (shipmentResponse.messages.isNotEmpty) {
        for (final msg in shipmentResponse.messages) {
          _logger.w('Shippo message: ${msg.text} (${msg.code})');
        }
      }

      // Check if we got rates
      if (shipmentResponse.rates.isEmpty) {
        _logger.w('No rates returned. Status: ${shipmentResponse.status}');
        throw ShippoRatesException(
          'No rates available for this route. '
          'Please check addresses and parcel details.',
        );
      }

      return shipmentResponse.rates;
    } on DioException catch (e) {
      // Handle rate limiting (HTTP 429)
      if (e.response?.statusCode == 429 && attempt < _maxRetriesOn429) {
        final waitTime = _calculateBackoff(attempt);
        _logger.w('Rate limited (429). Retrying in ${waitTime.inSeconds}s...');
        await Future.delayed(waitTime);
        return _fetchRatesWithRetry(requestData, attempt: attempt + 1);
      }

      throw _handleDioError(e);
    }
  }

  /// Calculate exponential backoff delay
  Duration _calculateBackoff(int attempt) {
    // Exponential backoff: 2s, 4s, 8s
    final seconds = 2 * (1 << attempt);
    return Duration(seconds: seconds.clamp(2, 10));
  }

  /// Convert app cartons to Shippo parcels (production mode)
  ///
  /// In PRODUCTION mode with LIVE API:
  /// - Creates individual parcels for each quantity (accurate count)
  /// - Real carriers need exact parcel counts for proper pricing
  /// - No consolidation workarounds
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
      'Created ${parcels.length} parcels from ${cartons.length} carton entries',
    );
    return parcels;
  }

  /// Convert Shippo rates to standardized Quote objects
  List<models.Quote> _convertShippoRatesToQuotes(List<ShippoRate> shippoRates) {
    final quotes = <models.Quote>[];

    for (final rate in shippoRates) {
      final priceUsd = double.tryParse(rate.amount) ?? 0.0;
      final priceEur = rate.currency == 'USD'
          ? priceUsd * ShippoConfig.usdToEurRate
          : priceUsd;
      final estimatedDays = rate.estimatedDays ?? 5;

      final quote = models.Quote(
        id: rate.objectId,
        shipmentId: rate.shipmentId ?? '', // Shipment ID from rate
        carrier: rate.provider,
        service: rate.servicelevel.name,
        etaMin: estimatedDays,
        etaMax: estimatedDays,
        priceEur: priceEur,
        chargeableKg: 0.0, // Shippo doesn't return chargeable weight
        // Additional Shippo-specific fields
        provider: 'Shippo Live',
        currency: rate.currency,
        price: priceUsd,
        transitDays: estimatedDays,
        providerToken: rate.objectId,
        carrierAccount: rate.servicelevel.token,
        rawRateId: rate.objectId,
      );
      quotes.add(quote);

      _logger.d(
        'Quote: ${quote.carrier} ${quote.service} - '
        '${quote.price} ${quote.currency} → ${quote.priceEur.toStringAsFixed(2)} EUR '
        '(${quote.transitDays} days)',
      );
    }

    return quotes;
  }

  /// Generate cache key for rates
  String _generateCacheKey({
    required String originCity,
    required String originPostal,
    required String originCountry,
    required String destCity,
    required String destPostal,
    required String destCountry,
    required List<Carton> cartons,
  }) {
    final cartonsSig = cartons
        .map(
          (c) =>
              '${c.lengthCm}x${c.widthCm}x${c.heightCm}:${c.weightKg}:${c.qty}',
        )
        .join(',');

    return '$originPostal:$originCountry->$destPostal:$destCountry:$cartonsSig';
  }

  /// Clear expired cache entries
  void clearExpiredCache() {
    _ratesCache.removeWhere((key, value) => value.isExpired);
    _logger.d('Cleared expired cache entries');
  }

  /// Clear all cached rates
  void clearCache() {
    _ratesCache.clear();
    _logger.d('Cleared all cached rates');
  }

  /// Handle Dio errors and convert to specific exceptions
  ShippoRatesException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ShippoRatesException(
          'Request timed out. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        // Handle specific error codes
        if (statusCode == 429) {
          return ShippoRatesException(
            'Rate limit exceeded. Please try again in a few moments.',
          );
        }

        if (statusCode == 401 || statusCode == 403) {
          return ShippoRatesException(
            'Authentication failed. Please check your Shippo API key.',
          );
        }

        if (statusCode == 400 && data is Map<String, dynamic>) {
          final error = ShippoError.fromJson(data);
          return ShippoRatesException('Invalid request: ${error.message}');
        }

        return ShippoRatesException('API error ($statusCode): ${e.message}');

      case DioExceptionType.cancel:
        return ShippoRatesException('Request was cancelled');

      case DioExceptionType.connectionError:
        return ShippoRatesException(
          'Connection error. Please check your internet connection.',
        );

      default:
        return ShippoRatesException('Network error: ${e.message}');
    }
  }
}

/// Cached rates with timestamp
class _CachedRates {
  final List<models.Quote> quotes;
  final DateTime timestamp;

  _CachedRates({required this.quotes, required this.timestamp});

  bool get isExpired {
    return DateTime.now().difference(timestamp) >
        ShippoRatesService._rateCacheExpiry;
  }
}

/// Custom exception for Shippo rates service errors
class ShippoRatesException implements Exception {
  final String message;

  ShippoRatesException(this.message);

  @override
  String toString() => message;
}
