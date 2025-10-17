import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration class for Shippo API integration
class ShippoConfig {
  /// Shippo API base URL
  static const String baseUrl = 'https://api.goshippo.com';

  /// Get the test API key from environment variables
  static String get testApiKey => dotenv.env['SHIPPO_TEST_API_KEY'] ?? '';

  /// Get the production API key from environment variables
  static String get liveApiKey => dotenv.env['SHIPPO_LIVE_API_KEY'] ?? '';

  /// Check if we should use test mode
  static bool get useTestMode =>
      dotenv.env['USE_TEST_MODE']?.toLowerCase() == 'true';

  /// Get the appropriate API key based on the current mode
  static String get apiKey => useTestMode ? testApiKey : liveApiKey;

  /// API version
  static const String apiVersion = '2018-02-08';

  /// Request timeout in milliseconds
  static const int timeoutMs = 30000;

  /// Simple USD to EUR conversion rate (should be updated regularly or use a conversion API)
  static const double usdToEurRate = 0.92;
}
