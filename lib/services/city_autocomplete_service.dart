import 'dart:async';
import 'package:dio/dio.dart';
import 'package:bockaire/config/api_constants.dart';
import 'package:bockaire/config/ui_strings.dart';

/// Interface for city autocomplete providers
abstract class CityAutocompleteProvider {
  Future<List<CityResult>> searchCities(String query);
}

/// Nominatim/OpenStreetMap implementation
class NominatimCityProvider implements CityAutocompleteProvider {
  final Dio _dio;

  NominatimCityProvider({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConstants.nominatimBaseUrl,
              headers: {'User-Agent': ApiConstants.nominatimUserAgent},
              connectTimeout: Duration(
                seconds: ApiConstants.nominatimTimeoutSeconds,
              ),
              receiveTimeout: Duration(
                seconds: ApiConstants.nominatimTimeoutSeconds,
              ),
            ),
          );

  @override
  Future<List<CityResult>> searchCities(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    // Check if query is a country name - return major cities for that country
    final countryQuery = _countryNameToCode[query.toLowerCase()];
    if (countryQuery != null) {
      return _getMajorCitiesForCountry(countryQuery);
    }

    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': ApiConstants.nominatimSearchLimit.toString(),
          // Removed country restriction - search all countries
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
            .take(ApiConstants.cityAutocompleteMaxResults)
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
      throw Exception('${UIStrings.errorCitySearch}: $e');
    }
  }

  /// Get major shipping cities for a country
  List<CityResult> _getMajorCitiesForCountry(String countryCode) {
    final cities = _majorCitiesByCountry[countryCode] ?? [];
    return cities.map((cityData) {
      return CityResult(
        city: cityData['city']!,
        postalCode: cityData['postal'],
        country: cityData['country']!,
        countryCode: countryCode.toUpperCase(),
        state: cityData['state'],
        displayName: '${cityData['city']}, ${cityData['country']}',
      );
    }).toList();
  }

  /// Country name to country code mapping
  static const Map<String, String> _countryNameToCode = {
    'china': 'cn',
    'germany': 'de',
    'united states': 'us',
    'usa': 'us',
    'france': 'fr',
    'spain': 'es',
    'italy': 'it',
    'united kingdom': 'gb',
    'uk': 'gb',
    'netherlands': 'nl',
    'belgium': 'be',
    'poland': 'pl',
    'czech republic': 'cz',
    'austria': 'at',
    'switzerland': 'ch',
    'canada': 'ca',
    'mexico': 'mx',
    'japan': 'jp',
    'south korea': 'kr',
    'korea': 'kr',
    'australia': 'au',
    'india': 'in',
    'brazil': 'br',
  };

  /// Major cities by country for quick selection
  static final Map<String, List<Map<String, String?>>> _majorCitiesByCountry = {
    'cn': [
      {
        'city': 'Shanghai',
        'postal': '200000',
        'country': 'China',
        'state': null,
      },
      {
        'city': 'Beijing',
        'postal': '100000',
        'country': 'China',
        'state': null,
      },
      {
        'city': 'Guangzhou',
        'postal': '510000',
        'country': 'China',
        'state': null,
      },
      {
        'city': 'Shenzhen',
        'postal': '518000',
        'country': 'China',
        'state': null,
      },
      {
        'city': 'Tianjin',
        'postal': '300000',
        'country': 'China',
        'state': null,
      },
      {
        'city': 'Chongqing',
        'postal': '400000',
        'country': 'China',
        'state': null,
      },
      {
        'city': 'Chengdu',
        'postal': '610000',
        'country': 'China',
        'state': null,
      },
      {
        'city': 'Hangzhou',
        'postal': '310000',
        'country': 'China',
        'state': null,
      },
    ],
    'de': [
      {
        'city': 'Berlin',
        'postal': '10115',
        'country': 'Germany',
        'state': null,
      },
      {
        'city': 'Hamburg',
        'postal': '20095',
        'country': 'Germany',
        'state': null,
      },
      {
        'city': 'Munich',
        'postal': '80331',
        'country': 'Germany',
        'state': null,
      },
      {
        'city': 'Frankfurt',
        'postal': '60311',
        'country': 'Germany',
        'state': null,
      },
      {
        'city': 'Cologne',
        'postal': '50667',
        'country': 'Germany',
        'state': null,
      },
      {
        'city': 'Stuttgart',
        'postal': '70173',
        'country': 'Germany',
        'state': null,
      },
      {
        'city': 'Düsseldorf',
        'postal': '40210',
        'country': 'Germany',
        'state': null,
      },
      {
        'city': 'Bremen',
        'postal': '28195',
        'country': 'Germany',
        'state': null,
      },
    ],
    'us': [
      {
        'city': 'New York',
        'postal': '10001',
        'country': 'United States',
        'state': 'NY',
      },
      {
        'city': 'Los Angeles',
        'postal': '90001',
        'country': 'United States',
        'state': 'CA',
      },
      {
        'city': 'Chicago',
        'postal': '60601',
        'country': 'United States',
        'state': 'IL',
      },
      {
        'city': 'Houston',
        'postal': '77001',
        'country': 'United States',
        'state': 'TX',
      },
      {
        'city': 'Miami',
        'postal': '33101',
        'country': 'United States',
        'state': 'FL',
      },
      {
        'city': 'Atlanta',
        'postal': '30303',
        'country': 'United States',
        'state': 'GA',
      },
      {
        'city': 'San Francisco',
        'postal': '94101',
        'country': 'United States',
        'state': 'CA',
      },
      {
        'city': 'Seattle',
        'postal': '98101',
        'country': 'United States',
        'state': 'WA',
      },
    ],
    'fr': [
      {'city': 'Paris', 'postal': '75001', 'country': 'France', 'state': null},
      {
        'city': 'Marseille',
        'postal': '13001',
        'country': 'France',
        'state': null,
      },
      {'city': 'Lyon', 'postal': '69001', 'country': 'France', 'state': null},
      {
        'city': 'Toulouse',
        'postal': '31000',
        'country': 'France',
        'state': null,
      },
      {'city': 'Nice', 'postal': '06000', 'country': 'France', 'state': null},
      {
        'city': 'Bordeaux',
        'postal': '33000',
        'country': 'France',
        'state': null,
      },
    ],
    'gb': [
      {
        'city': 'London',
        'postal': 'WC2N 5DU',
        'country': 'United Kingdom',
        'state': null,
      },
      {
        'city': 'Manchester',
        'postal': 'M1 1AD',
        'country': 'United Kingdom',
        'state': null,
      },
      {
        'city': 'Birmingham',
        'postal': 'B1 1AA',
        'country': 'United Kingdom',
        'state': null,
      },
      {
        'city': 'Liverpool',
        'postal': 'L1 0AA',
        'country': 'United Kingdom',
        'state': null,
      },
      {
        'city': 'Glasgow',
        'postal': 'G1 1AA',
        'country': 'United Kingdom',
        'state': null,
      },
    ],
  };

  CityResult _parseResult(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    final city = _extractCity(address);
    final countryCode = (address?['country_code'] as String?)?.toUpperCase();
    final state = _extractState(address);

    // Debug logging removed - uncomment if needed for debugging
    // print('DEBUG Nominatim: city="$city", country="$countryCode", state="$state"');

    return CityResult(
      city: city,
      postalCode: address?['postcode'] as String?,
      country: address?['country'] as String?,
      countryCode: countryCode,
      state: state,
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

  String? _extractState(Map<String, dynamic>? address) {
    if (address == null) return null;

    // For US addresses, extract state code from ISO3166-2-lvl4 (e.g., "US-LA" -> "LA")
    final iso = address['ISO3166-2-lvl4'] as String?;
    if (iso != null && iso.contains('-')) {
      return iso.split('-').last;
    }

    // Fallback: try to get state field directly (may be full name like "Louisiana")
    // Note: For US addresses, we should use the ISO code, not the full name
    return null;
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
    this.debounceDuration = const Duration(milliseconds: 100),
  }) : _provider = provider ?? NominatimCityProvider();

  /// Search cities with debouncing
  Future<List<CityResult>> searchCities(
    String query,
    void Function(List<CityResult>) onResults,
  ) async {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Check if query is a country name - return immediately without debounce
    final countryQuery =
        NominatimCityProvider._countryNameToCode[query.toLowerCase()];
    if (countryQuery != null) {
      final results = await _provider.searchCities(query);
      onResults(results);
      return results;
    }

    // Create a completer for the result
    final completer = Completer<List<CityResult>>();

    // Set up new debounce timer for regular searches
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
  final String? state; // State/province code (e.g., "LA" for Louisiana)
  final String displayName;

  // Fallback postal codes for major cities
  static const Map<String, String> _cityPostalFallbacks = {
    // Germany
    'hamburg': '20095',
    'bremen': '28195',
    'berlin': '10115',
    'munich': '80331',
    'frankfurt': '60311',
    'cologne': '50667',
    'düsseldorf': '40210',
    'stuttgart': '70173',
    // China
    'guangzhou': '510000',
    'beijing': '100000',
    'shanghai': '200000',
    'shenzhen': '518000',
    'hong kong': '999077',
    'tianjin': '300000',
    // Czech Republic
    'prague': '110 00',
    'praha': '110 00',
    // Other European cities
    'paris': '75001',
    'london': 'WC2N 5DU',
    'amsterdam': '1012',
    'rome': '00118',
    'barcelona': '08001',
    'vienna': '1010',
    'warsaw': '00-001',
  };

  // Fallback postal codes for US cities (city,state format)
  static const Map<String, String> _usCityPostalFallbacks = {
    'atlanta,ga': '30303',
    'miami,fl': '33101',
    'new york,ny': '10001',
    'los angeles,ca': '90001',
    'chicago,il': '60601',
    'houston,tx': '77001',
    'phoenix,az': '85001',
    'philadelphia,pa': '19101',
    'san antonio,tx': '78201',
    'san diego,ca': '92101',
    'dallas,tx': '75201',
    'san jose,ca': '95101',
    'austin,tx': '78701',
    'jacksonville,fl': '32099',
    'fort worth,tx': '76101',
    'columbus,oh': '43004',
    'charlotte,nc': '28201',
    'san francisco,ca': '94101',
    'indianapolis,in': '46201',
    'seattle,wa': '98101',
    'denver,co': '80201',
    'washington,dc': '20001',
    'boston,ma': '02101',
    'nashville,tn': '37201',
    'detroit,mi': '48201',
    'portland,or': '97201',
    'las vegas,nv': '89101',
  };

  const CityResult({
    required this.city,
    this.postalCode,
    this.country,
    this.countryCode,
    this.state,
    required this.displayName,
  });

  /// Get postal code with fallback for major cities
  String? get effectivePostalCode {
    if (postalCode != null && postalCode!.isNotEmpty) {
      return postalCode;
    }

    // Try US city,state fallback first (more specific)
    if (countryCode == 'US' && state != null) {
      final key = '${city.toLowerCase()},${state!.toLowerCase()}';
      final usPostal = _usCityPostalFallbacks[key];
      if (usPostal != null) return usPostal;
    }

    // Try general city fallback
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
