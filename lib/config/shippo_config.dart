import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration class for Shippo API integration (LIVE PRODUCTION MODE ONLY)
///
/// This app uses the live Shippo API for real carrier rates worldwide.
/// No test/sandbox mode - all requests go to production endpoints.
class ShippoConfig {
  /// Shippo API base URL (LIVE PRODUCTION)
  static const String baseUrl = 'https://api.goshippo.com';

  /// Get the live production API key from environment variables
  /// Format: shippo_live_xxxxxxxxxxxxxxxxxxxxx
  static String get apiKey => dotenv.env['SHIPPO_API_KEY'] ?? '';

  /// API version
  static const String apiVersion = '2018-02-08';

  /// Request timeout in milliseconds
  static const int timeoutMs = 30000;

  /// Simple USD to EUR conversion rate (should be updated regularly or use a conversion API)
  static const double usdToEurRate = 0.92;

  /// Check if label purchase is enabled (safety flag)
  static bool get isLabelPurchaseEnabled =>
      dotenv.env['ENABLE_SHIPPO_LABELS']?.toLowerCase() == 'true';
}
