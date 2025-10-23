import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bockaire/config/shippo_config.dart';
import 'dart:convert';

/// Service for managing Shippo carrier accounts
///
/// Carrier accounts allow you to:
/// - Use your own negotiated carrier rates
/// - Filter quotes to specific carriers
/// - Access carrier-specific features
class CarrierAccountsService {
  final Dio _dio;
  final Logger _logger = Logger();
  final SharedPreferences _prefs;

  static const String _prefKeyCarrierAccounts = 'selected_carrier_accounts';

  CarrierAccountsService({Dio? dio, required SharedPreferences prefs})
    : _dio = dio ?? Dio(),
      _prefs = prefs {
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

  /// Fetch all carrier accounts from Shippo
  ///
  /// Returns a list of carrier accounts configured in your Shippo account.
  /// These are the carriers you have set up with your own negotiated rates.
  Future<List<CarrierAccount>> fetchCarrierAccounts() async {
    try {
      _logger.i('Fetching carrier accounts from Shippo...');

      final response = await _dio.get('/carrier_accounts/');

      final List<dynamic> results = response.data['results'] as List<dynamic>;

      final accounts = results
          .map((json) => CarrierAccount.fromJson(json as Map<String, dynamic>))
          .toList();

      _logger.i('Retrieved ${accounts.length} carrier accounts');

      return accounts;
    } on DioException catch (e) {
      _logger.e('Error fetching carrier accounts: $e');
      throw CarrierAccountsException(
        'Failed to fetch carrier accounts: ${e.message}',
      );
    }
  }

  /// Get selected carrier account IDs from local storage
  List<String> getSelectedCarrierAccounts() {
    final String? accountsJson = _prefs.getString(_prefKeyCarrierAccounts);
    if (accountsJson == null) return [];

    try {
      final List<dynamic> accountsList =
          jsonDecode(accountsJson) as List<dynamic>;
      return accountsList.cast<String>();
    } catch (e) {
      _logger.e('Error parsing carrier accounts: $e');
      return [];
    }
  }

  /// Save selected carrier account IDs to local storage
  Future<void> saveSelectedCarrierAccounts(List<String> accountIds) async {
    try {
      final accountsJson = jsonEncode(accountIds);
      await _prefs.setString(_prefKeyCarrierAccounts, accountsJson);
      _logger.i('Saved ${accountIds.length} selected carrier accounts');
    } catch (e) {
      _logger.e('Error saving carrier accounts: $e');
      throw CarrierAccountsException('Failed to save carrier accounts: $e');
    }
  }

  /// Clear all selected carrier accounts
  Future<void> clearSelectedCarrierAccounts() async {
    await _prefs.remove(_prefKeyCarrierAccounts);
    _logger.i('Cleared selected carrier accounts');
  }

  /// Check if any carrier accounts are selected
  bool hasSelectedCarrierAccounts() {
    return getSelectedCarrierAccounts().isNotEmpty;
  }
}

/// Model for Shippo carrier account
class CarrierAccount {
  final String objectId;
  final String carrier;
  final String accountId;
  final bool active;
  final bool test;
  final Map<String, dynamic>? metadata;

  CarrierAccount({
    required this.objectId,
    required this.carrier,
    required this.accountId,
    required this.active,
    required this.test,
    this.metadata,
  });

  factory CarrierAccount.fromJson(Map<String, dynamic> json) {
    return CarrierAccount(
      objectId: json['object_id'] as String,
      carrier: json['carrier'] as String,
      accountId: json['account_id'] as String,
      active: json['active'] as bool? ?? true,
      test: json['test'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'object_id': objectId,
      'carrier': carrier,
      'account_id': accountId,
      'active': active,
      'test': test,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Get display name for the carrier account
  String get displayName {
    final testLabel = test ? ' (Test)' : '';
    return '$carrier - $accountId$testLabel';
  }

  @override
  String toString() => displayName;
}

/// Exception thrown when carrier account operations fail
class CarrierAccountsException implements Exception {
  final String message;

  CarrierAccountsException(this.message);

  @override
  String toString() => message;
}
