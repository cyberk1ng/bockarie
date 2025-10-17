import 'dart:async';
import 'package:dio/dio.dart';

/// Interface for city autocomplete providers
abstract class CityAutocompleteProvider {
  Future<List<CityResult>> searchCities(String query);
}

/// Nominatim/OpenStreetMap implementation
class NominatimCityProvider implements CityAutocompleteProvider {
  static const String baseUrl = 'https://nominatim.openstreetmap.org';
  static const String userAgent = 'Bockaire-Shipping-App/1.0';

  final Dio _dio;

  NominatimCityProvider({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              headers: {'User-Agent': userAgent},
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  @override
  Future<List<CityResult>> searchCities(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': '20',
          'countrycodes': 'de,cn',
          'addressdetails': '1',
          'accept-language': 'en',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        // Parse and filter results
        final results = data
            .map((item) => _parseResult(item))
            .where((result) {
              // Only include results that have a city name
              if (result.city.isEmpty) return false;

              // Filter for cities that contain the query (more flexible than startsWith)
              final cityLower = result.city.toLowerCase();
              final queryLower = query.toLowerCase();
              return cityLower.contains(queryLower);
            })
            .toSet() // Remove duplicates
            .take(8)
            .toList();

        // Sort: exact matches first, then startsWith, then contains
        results.sort((a, b) {
          final aLower = a.city.toLowerCase();
          final bLower = b.city.toLowerCase();
          final queryLower = query.toLowerCase();

          if (aLower == queryLower) return -1;
          if (bLower == queryLower) return 1;
          if (aLower.startsWith(queryLower) && !bLower.startsWith(queryLower)) {
            return -1;
          }
          if (bLower.startsWith(queryLower) && !aLower.startsWith(queryLower)) {
            return 1;
          }
          return a.city.compareTo(b.city);
        });

        return results;
      } else {
        throw Exception('Failed to search cities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('City search error: $e');
    }
  }

  CityResult _parseResult(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;

    return CityResult(
      city: _extractCity(address),
      postalCode: address?['postcode'] as String?,
      country: address?['country'] as String?,
      countryCode: address?['country_code'] as String?,
      displayName: json['display_name'] as String? ?? '',
    );
  }

  String _extractCity(Map<String, dynamic>? address) {
    if (address == null) return '';

    // Try different city fields in order of preference
    return address['city'] as String? ??
        address['town'] as String? ??
        address['village'] as String? ??
        address['municipality'] as String? ??
        '';
  }

  void dispose() {
    _dio.close();
  }
}

/// City autocomplete service with debouncing
class CityAutocompleteService {
  final CityAutocompleteProvider _provider;
  final Duration debounceDuration;

  Timer? _debounceTimer;

  CityAutocompleteService({
    CityAutocompleteProvider? provider,
    this.debounceDuration = const Duration(milliseconds: 200),
  }) : _provider = provider ?? NominatimCityProvider();

  /// Search cities with debouncing
  Future<List<CityResult>> searchCities(
    String query,
    void Function(List<CityResult>) onResults,
  ) async {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Create a completer for the result
    final completer = Completer<List<CityResult>>();

    // Set up new debounce timer
    _debounceTimer = Timer(debounceDuration, () async {
      try {
        final results = await _provider.searchCities(query);
        onResults(results);
        completer.complete(results);
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  /// Cancel any pending searches
  void cancel() {
    _debounceTimer?.cancel();
  }

  void dispose() {
    _debounceTimer?.cancel();
    if (_provider is NominatimCityProvider) {
      _provider.dispose();
    }
  }
}

/// City search result
class CityResult {
  final String city;
  final String? postalCode;
  final String? country;
  final String? countryCode;
  final String displayName;

  // Fallback postal codes for major cities
  static const Map<String, String> _cityPostalFallbacks = {
    'hamburg': '20095',
    'bremen': '28195',
    'berlin': '10115',
    'munich': '80331',
    'frankfurt': '60311',
    'cologne': '50667',
    'düsseldorf': '40210',
    'stuttgart': '70173',
    'guangzhou': '510000',
    'beijing': '100000',
    'shanghai': '200000',
    'shenzhen': '518000',
    'hong kong': '999077',
    'tianjin': '300000',
  };

  const CityResult({
    required this.city,
    this.postalCode,
    this.country,
    this.countryCode,
    required this.displayName,
  });

  /// Get postal code with fallback for major cities
  String? get effectivePostalCode {
    if (postalCode != null && postalCode!.isNotEmpty) {
      return postalCode;
    }
    // Try fallback for major cities
    return _cityPostalFallbacks[city.toLowerCase()];
  }

  @override
  String toString() {
    final parts = <String>[city];
    final postal = effectivePostalCode;
    if (postal != null) parts.add(postal);
    if (country != null) parts.add(country!);
    return parts.join(', ');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityResult &&
          runtimeType == other.runtimeType &&
          city == other.city &&
          postalCode == other.postalCode &&
          country == other.country;

  @override
  int get hashCode => city.hashCode ^ postalCode.hashCode ^ country.hashCode;
}
