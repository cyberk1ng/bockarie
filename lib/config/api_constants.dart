/// API configuration constants
class ApiConstants {
  ApiConstants._();

  // Nominatim (OpenStreetMap) API
  static const String nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
  static const String nominatimUserAgent = 'Bockaire-Shipping-App/1.0';
  static const int nominatimTimeoutSeconds = 10;
  static const int nominatimSearchLimit = 20;
  static const int cityAutocompleteMaxResults = 8;
  static const int cityAutocompleteDebouncMs = 100;
}
