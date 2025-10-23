import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:bockaire/config/shippo_config.dart';
import 'package:bockaire/models/shippo_models.dart';
import 'package:bockaire/models/customs_models.dart';

/// Production-grade Shippo Booking Service
///
/// This service handles the complete "Book This" flow:
/// 1. Creates shipment in Shippo API
/// 2. Generates customs declarations for international shipments
/// 3. Attaches customs to shipment
/// 4. Optionally creates labels (safety-controlled)
///
/// Safety features:
/// - Label creation disabled by default (ENABLE_SHIPPO_LABELS flag)
/// - All operations logged (API keys sanitized)
/// - Comprehensive error handling
/// - Returns tracking info and document URLs
class BookShipmentService {
  final Dio _dio;
  final Logger _logger = Logger();

  BookShipmentService({Dio? dio}) : _dio = dio ?? Dio() {
    _configureClient();
  }

  /// Configure Dio client with proper headers
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
          _logger.d('[Shippo Booking] ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
            '[Shippo Booking Response] ${response.statusCode} ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.e(
            '[Shippo Booking Error] ${error.response?.statusCode} ${error.message}',
          );
          return handler.next(error);
        },
      ),
    );
  }

  /// Book a shipment with full flow
  ///
  /// Steps:
  /// 1. Create shipment
  /// 2. Create customs declaration (if international)
  /// 3. Attach customs to shipment
  /// 4. Create label (if enabled and confirmed)
  ///
  /// Returns [BookingResult] with tracking, documents, and shipment info
  Future<BookingResult> bookShipment({
    required String rateId,
    required ShippoAddress addressFrom,
    required ShippoAddress addressTo,
    required List<ShippoParcel> parcels,
    CustomsPacket? customsPacket,
    bool createLabel = false,
  }) async {
    try {
      _logger.i('🚢 Starting shipment booking flow (Live Shippo API)');
      _logger.d('Rate ID: $rateId');
      _logger.d(
        'From: ${addressFrom.city}, ${addressFrom.country} → To: ${addressTo.city}, ${addressTo.country}',
      );

      // Step 1: Create shipment
      final shipment = await _createShipment(
        addressFrom: addressFrom,
        addressTo: addressTo,
        parcels: parcels,
      );

      _logger.i('✅ Shipment created: ${shipment.objectId}');

      String? customsDeclarationId;
      ShippoCustomsDeclaration? customsDeclaration;

      // Step 2: Create customs declaration (if international)
      if (customsPacket != null && addressFrom.country != addressTo.country) {
        _logger.i('📋 Creating customs declaration...');
        customsDeclaration = await _createCustomsDeclaration(
          customsPacket: customsPacket,
          addressFrom: addressFrom,
          addressTo: addressTo,
        );
        customsDeclarationId = customsDeclaration.objectId;
        _logger.i('✅ Customs declaration created: $customsDeclarationId');

        // Step 3: Attach customs to shipment
        await _attachCustomsToShipment(
          shipmentId: shipment.objectId,
          customsDeclarationId: customsDeclarationId,
        );
        _logger.i('✅ Customs attached to shipment');
      }

      // Step 4: Create label (optional, safety-controlled)
      ShippoTransaction? transaction;
      if (createLabel && ShippoConfig.isLabelPurchaseEnabled) {
        _logger.w('⚠️ Creating REAL label (charges will apply)');
        transaction = await _createTransaction(rateId: rateId);
        _logger.i('✅ Label created: ${transaction.trackingNumber}');
      } else if (createLabel && !ShippoConfig.isLabelPurchaseEnabled) {
        _logger.w(
          '🛡️ Label creation BLOCKED by safety flag (ENABLE_SHIPPO_LABELS=false)',
        );
      }

      return BookingResult(
        shipmentId: shipment.objectId,
        trackingNumber: transaction?.trackingNumber,
        labelUrl: transaction?.labelUrl,
        trackingUrlProvider: transaction?.trackingUrlProvider,
        customsDeclarationId: customsDeclarationId,
        commercialInvoiceUrl: customsDeclaration?.commercialInvoiceUrl,
        status: transaction != null ? 'LABEL_CREATED' : 'SHIPMENT_CREATED',
        labelCreated: transaction != null,
        messages: shipment.messages.map((m) => m.text).toList(),
      );
    } catch (e) {
      _logger.e('❌ Error booking shipment: $e');
      rethrow;
    }
  }

  /// Step 1: Create shipment in Shippo
  Future<ShippoShipmentResponse> _createShipment({
    required ShippoAddress addressFrom,
    required ShippoAddress addressTo,
    required List<ShippoParcel> parcels,
  }) async {
    try {
      final request = ShippoShipmentRequest(
        addressFrom: addressFrom,
        addressTo: addressTo,
        parcels: parcels,
        async: false,
      );

      final response = await _dio.post('/shipments/', data: request.toJson());

      final shipment = ShippoShipmentResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (shipment.messages.isNotEmpty) {
        for (final msg in shipment.messages) {
          _logger.w('Shippo message: ${msg.text} (${msg.code})');
        }
      }

      return shipment;
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to create shipment');
    }
  }

  /// Step 2: Create customs declaration
  Future<ShippoCustomsDeclaration> _createCustomsDeclaration({
    required CustomsPacket customsPacket,
    required ShippoAddress addressFrom,
    required ShippoAddress addressTo,
  }) async {
    try {
      final requestData = {
        'contents_type': customsPacket.contentsType.name,
        'contents_explanation': customsPacket.notes ?? 'Commercial goods',
        'non_delivery_option': 'RETURN',
        'certify': customsPacket.certify,
        'certify_signer': customsPacket.profile?.contactName ?? 'Shipper',
        'incoterm': customsPacket.incoterms.name.toUpperCase(),
        // Exporter address
        'exporter_identification': {
          if (customsPacket.profile?.eoriNumber != null)
            'eori_number': customsPacket.profile!.eoriNumber,
          if (customsPacket.profile?.taxId != null)
            'tax_id': {'number': customsPacket.profile!.taxId, 'type': 'EIN'},
        },
        // Importer address
        'address_importer': addressTo.toJson(),
        // Line items
        'items': customsPacket.items.map((item) => item.toJson()).toList(),
        // Invoice
        if (customsPacket.invoiceNumber != null)
          'invoice': customsPacket.invoiceNumber,
        // References
        if (customsPacket.exporterReference != null)
          'exporter_reference': customsPacket.exporterReference,
        if (customsPacket.importerReference != null)
          'importer_reference': customsPacket.importerReference,
        // Metadata
        'metadata': 'Generated by Bockaire shipping app',
      };

      final response = await _dio.post(
        '/customs/declarations/',
        data: requestData,
      );

      return ShippoCustomsDeclaration.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to create customs declaration');
    }
  }

  /// Step 3: Attach customs declaration to shipment
  Future<void> _attachCustomsToShipment({
    required String shipmentId,
    required String customsDeclarationId,
  }) async {
    try {
      await _dio.patch(
        '/shipments/$shipmentId/',
        data: {'customs_declaration': customsDeclarationId},
      );
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to attach customs to shipment');
    }
  }

  /// Step 4: Create transaction (purchase label)
  Future<ShippoTransaction> _createTransaction({required String rateId}) async {
    try {
      final response = await _dio.post(
        '/transactions/',
        data: {
          'rate': rateId,
          'label_file_type': 'PDF',
          'async': false,
          'metadata': 'Created by Bockaire app',
        },
      );

      return ShippoTransaction.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to create label transaction');
    }
  }

  /// Handle Dio errors and convert to specific exceptions
  BookingException _handleDioError(DioException e, String context) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return BookingException(
          '$context: Request timed out. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        if (statusCode == 429) {
          return BookingException(
            '$context: Rate limit exceeded. Please try again in a few moments.',
          );
        }

        if (statusCode == 401 || statusCode == 403) {
          return BookingException(
            '$context: Authentication failed. Please check your Shippo API key.',
          );
        }

        if (statusCode == 400 && data is Map<String, dynamic>) {
          final error = ShippoError.fromJson(data);
          return BookingException('$context: ${error.message}');
        }

        return BookingException(
          '$context: API error ($statusCode): ${e.message}',
        );

      case DioExceptionType.cancel:
        return BookingException('$context: Request was cancelled');

      case DioExceptionType.connectionError:
        return BookingException(
          '$context: Connection error. Please check your internet connection.',
        );

      default:
        return BookingException('$context: Network error: ${e.message}');
    }
  }
}

/// Result of a shipment booking operation
class BookingResult {
  final String shipmentId;
  final String? trackingNumber;
  final String? labelUrl;
  final String? trackingUrlProvider;
  final String? customsDeclarationId;
  final String? commercialInvoiceUrl;
  final String status;
  final bool labelCreated;
  final List<String> messages;

  BookingResult({
    required this.shipmentId,
    this.trackingNumber,
    this.labelUrl,
    this.trackingUrlProvider,
    this.customsDeclarationId,
    this.commercialInvoiceUrl,
    required this.status,
    required this.labelCreated,
    this.messages = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'shipment_id': shipmentId,
      'tracking_number': trackingNumber,
      'label_url': labelUrl,
      'tracking_url_provider': trackingUrlProvider,
      'customs_declaration_id': customsDeclarationId,
      'commercial_invoice_url': commercialInvoiceUrl,
      'status': status,
      'label_created': labelCreated,
      'messages': messages,
    };
  }
}

/// Shippo customs declaration response model
class ShippoCustomsDeclaration {
  final String objectId;
  final String? commercialInvoiceUrl;
  final List<ShippoMessage> messages;

  ShippoCustomsDeclaration({
    required this.objectId,
    this.commercialInvoiceUrl,
    this.messages = const [],
  });

  factory ShippoCustomsDeclaration.fromJson(Map<String, dynamic> json) {
    return ShippoCustomsDeclaration(
      objectId: json['object_id'] as String? ?? '',
      commercialInvoiceUrl: json['commercial_invoice_url'] as String?,
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((m) => ShippoMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Shippo transaction response model (label creation)
class ShippoTransaction {
  final String objectId;
  final String status;
  final String? trackingNumber;
  final String? trackingUrlProvider;
  final String? labelUrl;
  final List<ShippoMessage> messages;

  ShippoTransaction({
    required this.objectId,
    required this.status,
    this.trackingNumber,
    this.trackingUrlProvider,
    this.labelUrl,
    this.messages = const [],
  });

  factory ShippoTransaction.fromJson(Map<String, dynamic> json) {
    return ShippoTransaction(
      objectId: json['object_id'] as String? ?? '',
      status: json['status'] as String? ?? 'UNKNOWN',
      trackingNumber: json['tracking_number'] as String?,
      trackingUrlProvider: json['tracking_url_provider'] as String?,
      labelUrl: json['label_url'] as String?,
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((m) => ShippoMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Custom exception for booking service errors
class BookingException implements Exception {
  final String message;

  BookingException(this.message);

  @override
  String toString() => message;
}
