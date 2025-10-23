import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:bockaire/config/shippo_config.dart';
import 'package:bockaire/config/feature_flags.dart';
import 'package:bockaire/models/shippo_models.dart';

/// ADMIN-ONLY service for purchasing Shippo shipping labels
///
/// ⚠️ DANGER: This service creates real shipping labels with real money! ⚠️
///
/// Safety features:
/// - Requires ENABLE_SHIPPO_LABELS feature flag
/// - Requires admin mode
/// - Requires explicit confirmation
/// - Logs all purchases for audit
/// - Provides void/refund functionality
///
/// DO NOT use this service for normal rate fetching!
/// Use ShippoRatesService instead for rates-only workflows.
class ShippoLabelService {
  final Dio _dio;
  final Logger _logger = Logger();
  final FeatureFlags _featureFlags = FeatureFlags();

  ShippoLabelService({Dio? dio}) : _dio = dio ?? Dio() {
    _configureClient();
  }

  /// Configure Dio client for Shippo API
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
  }

  /// Purchase a shipping label (ADMIN ONLY - REAL MONEY)
  ///
  /// ⚠️ WARNING: This creates a real label and charges your account! ⚠️
  ///
  /// [rateId] - The Shippo rate object_id to purchase
  /// [confirmation] - User must type exact confirmation text
  ///
  /// Returns transaction details including label URL and tracking number
  Future<LabelTransaction> purchaseLabel({
    required String rateId,
    required String confirmation,
  }) async {
    // SAFETY CHECK 1: Verify feature flag is enabled
    if (!_featureFlags.isShippoLabelsEnabled) {
      throw LabelPurchaseBlockedException(
        'Label purchase is DISABLED. '
        'To enable: Set ENABLE_SHIPPO_LABELS=true in .env',
      );
    }

    // SAFETY CHECK 2: Verify confirmation text
    const requiredConfirmation = 'BUY LABEL';
    if (confirmation != requiredConfirmation) {
      throw LabelPurchaseBlockedException(
        'Confirmation text must be exactly "$requiredConfirmation" (case-sensitive)',
      );
    }

    try {
      _logger.w(
        '⚠️ PURCHASING REAL SHIPPING LABEL - REAL MONEY WILL BE CHARGED ⚠️',
      );
      _logger.i('Rate ID: $rateId');

      // AUDIT LOG
      _logger.w(
        '[AUDIT] LABEL PURCHASE INITIATED at ${DateTime.now()}\n'
        '  Rate ID: $rateId\n'
        '  Confirmation: $confirmation',
      );

      // Create transaction (this charges your account!)
      final response = await _dio.post(
        '/transactions/',
        data: {'rate': rateId, 'label_file_type': 'PDF', 'async': false},
      );

      final transaction = LabelTransaction.fromJson(
        response.data as Map<String, dynamic>,
      );

      // AUDIT LOG
      _logger.w(
        '[AUDIT] LABEL PURCHASED SUCCESSFULLY at ${DateTime.now()}\n'
        '  Transaction ID: ${transaction.objectId}\n'
        '  Label URL: ${transaction.labelUrl}\n'
        '  Tracking: ${transaction.trackingNumber}\n'
        '  Cost: ${transaction.rate?.amount} ${transaction.rate?.currency}',
      );

      _logger.i('✅ Label purchased successfully: ${transaction.labelUrl}');

      return transaction;
    } on DioException catch (e) {
      _logger.e('❌ Label purchase failed: $e');

      // AUDIT LOG
      _logger.e(
        '[AUDIT] LABEL PURCHASE FAILED at ${DateTime.now()}\n'
        '  Rate ID: $rateId\n'
        '  Error: ${e.message}',
      );

      throw LabelPurchaseException(_handleDioError(e));
    } catch (e) {
      _logger.e('❌ Unexpected error during label purchase: $e');
      throw LabelPurchaseException('Unexpected error: $e');
    }
  }

  /// Void/refund a shipping label
  ///
  /// Attempts to void a label and get a refund.
  /// Not all carriers support voids, and some have time limits.
  ///
  /// [transactionId] - The transaction object_id to void
  Future<VoidResult> voidLabel(String transactionId) async {
    try {
      _logger.w('Attempting to void label: $transactionId');

      // AUDIT LOG
      _logger.w(
        '[AUDIT] LABEL VOID REQUESTED at ${DateTime.now()}\n'
        '  Transaction ID: $transactionId',
      );

      final response = await _dio.post('/transactions/$transactionId/refund/');

      final result = VoidResult.fromJson(response.data as Map<String, dynamic>);

      // AUDIT LOG
      _logger.w(
        '[AUDIT] LABEL VOID ${result.success ? 'SUCCESSFUL' : 'FAILED'} at ${DateTime.now()}\n'
        '  Transaction ID: $transactionId\n'
        '  Status: ${result.status}\n'
        '  Message: ${result.message}',
      );

      _logger.i('Void result: ${result.status}');

      return result;
    } on DioException catch (e) {
      _logger.e('Error voiding label: $e');
      throw LabelVoidException(_handleDioError(e));
    }
  }

  /// Handle Dio errors
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        if (data is Map<String, dynamic>) {
          final error = ShippoError.fromJson(data);
          return 'API error ($statusCode): ${error.message}';
        }

        return 'API error ($statusCode): ${e.message}';

      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timed out';

      case DioExceptionType.connectionError:
        return 'Connection error';

      default:
        return 'Network error: ${e.message}';
    }
  }
}

/// Model for a purchased label transaction
class LabelTransaction {
  final String objectId;
  final String status;
  final String? labelUrl;
  final String? trackingNumber;
  final String? trackingStatus;
  final ShippoRate? rate;
  final DateTime createdAt;

  LabelTransaction({
    required this.objectId,
    required this.status,
    this.labelUrl,
    this.trackingNumber,
    this.trackingStatus,
    this.rate,
    required this.createdAt,
  });

  factory LabelTransaction.fromJson(Map<String, dynamic> json) {
    return LabelTransaction(
      objectId: json['object_id'] as String,
      status: json['status'] as String,
      labelUrl: json['label_url'] as String?,
      trackingNumber: json['tracking_number'] as String?,
      trackingStatus: json['tracking_status'] as String?,
      rate: json['rate'] != null
          ? ShippoRate.fromJson(json['rate'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['object_created'] as String),
    );
  }
}

/// Model for void/refund result
class VoidResult {
  final String status;
  final bool success;
  final String? message;

  VoidResult({required this.status, required this.success, this.message});

  factory VoidResult.fromJson(Map<String, dynamic> json) {
    return VoidResult(
      status: json['status'] as String,
      success: (json['status'] as String).toLowerCase() == 'success',
      message: json['message'] as String?,
    );
  }
}

/// Exception when label purchase is blocked by safety checks
class LabelPurchaseBlockedException implements Exception {
  final String message;

  LabelPurchaseBlockedException(this.message);

  @override
  String toString() => 'Label Purchase Blocked: $message';
}

/// Exception when label purchase fails
class LabelPurchaseException implements Exception {
  final String message;

  LabelPurchaseException(this.message);

  @override
  String toString() => 'Label Purchase Error: $message';
}

/// Exception when label void fails
class LabelVoidException implements Exception {
  final String message;

  LabelVoidException(this.message);

  @override
  String toString() => 'Label Void Error: $message';
}
