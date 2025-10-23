import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

/// Feature flags for controlling label purchase safety
///
/// IMPORTANT SAFETY RULE:
/// Label purchase is DISABLED by default to prevent accidental charges.
/// The app fetches real rates but won't create labels unless explicitly enabled.
class FeatureFlags {
  static const String _keyEnableShippoLabels = 'ENABLE_SHIPPO_LABELS';

  // Singleton instance
  static final FeatureFlags _instance = FeatureFlags._internal();
  factory FeatureFlags() => _instance;
  FeatureFlags._internal();

  final Logger _logger = Logger();

  SharedPreferences? _prefs;

  /// Initialize feature flags (call this in main())
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Check if Shippo label purchase is enabled
  ///
  /// SAFETY: This is FALSE by default to prevent accidental charges.
  /// The app can fetch live rates but won't create labels until this is enabled.
  ///
  /// To enable label purchase:
  /// Set ENABLE_SHIPPO_LABELS=true in .env
  bool get isShippoLabelsEnabled {
    // Check environment variable
    final envFlag = dotenv.env[_keyEnableShippoLabels]?.toLowerCase() == 'true';
    if (envFlag) return true;

    // Check runtime override (session setting)
    return _prefs?.getBool(_keyEnableShippoLabels) ?? false;
  }

  /// Enable or disable Shippo label purchase
  ///
  /// CAUTION: Enabling this allows real label purchases with real money.
  /// Only enable when you intend to actually purchase a shipping label.
  ///
  /// [enabled] - true to enable label purchase, false to disable
  Future<void> setShippoLabelsEnabled(bool enabled) async {
    await _prefs?.setBool(_keyEnableShippoLabels, enabled);

    // Log the change for audit purposes
    _logger.w(
      '[AUDIT] Shippo labels ${enabled ? 'ENABLED' : 'DISABLED'} at ${DateTime.now()}',
    );
  }

  /// Reset to safe defaults (disable label purchase)
  Future<void> resetToSafeDefaults() async {
    await _prefs?.setBool(_keyEnableShippoLabels, false);
    _logger.i(
      '[AUDIT] Feature flags reset to safe defaults at ${DateTime.now()}',
    );
  }

  /// Get a human-readable status of feature flags
  Map<String, dynamic> getStatus() {
    return {
      'shippo_labels_enabled': isShippoLabelsEnabled,
      'mode': 'LIVE PRODUCTION',
      'environment': {
        'ENABLE_SHIPPO_LABELS': dotenv.env[_keyEnableShippoLabels] ?? 'false',
      },
    };
  }
}

/// Exception thrown when feature flag operations fail
class FeatureFlagException implements Exception {
  final String message;

  FeatureFlagException(this.message);

  @override
  String toString() => message;
}
