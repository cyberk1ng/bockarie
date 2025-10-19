import 'package:bockaire/services/city_autocomplete_service.dart';
import 'package:logger/logger.dart';

/// Matched city with full details (city, postal, country, state)
class MatchedCity {
  final String city;
  final String postal;
  final String country;
  final String state;

  const MatchedCity({
    required this.city,
    required this.postal,
    required this.country,
    required this.state,
  });

  @override
  String toString() {
    return 'MatchedCity(city: $city, postal: $postal, country: $country, state: $state)';
  }
}

/// Service to match city names from voice to CityResult with postal codes
class CityMatcherService {
  final CityAutocompleteService _cityService;
  final Logger _logger = Logger();

  CityMatcherService({CityAutocompleteService? cityService})
    : _cityService = cityService ?? CityAutocompleteService();

  /// Find best matching city from city name
  /// Returns MatchedCity with city, postal, country, and state
  Future<MatchedCity?> findCity(String cityName) async {
    try {
      _logger.i('🔍 Searching for city: "$cityName"');

      final results = await _cityService.searchCities(
        cityName,
        (results) {}, // Empty callback since we're using the return value
      );

      if (results.isEmpty) {
        _logger.w('❌ No results found for "$cityName"');
        return null;
      }

      // Find best match
      CityResult? bestMatch;

      // 1. Try exact match (case-insensitive)
      final exactMatch = results
          .where((r) => r.city.toLowerCase() == cityName.toLowerCase())
          .toList();

      if (exactMatch.isNotEmpty) {
        bestMatch = exactMatch.first;
        _logger.d('✅ Exact match found: ${bestMatch.city}');
      } else {
        // 2. Try starts with
        final startsWithMatch = results
            .where(
              (r) => r.city.toLowerCase().startsWith(cityName.toLowerCase()),
            )
            .toList();

        if (startsWithMatch.isNotEmpty) {
          bestMatch = startsWithMatch.first;
          _logger.d('✅ Starts-with match found: ${bestMatch.city}');
        } else {
          // 3. Use first result (closest match)
          bestMatch = results.first;
          _logger.d('✅ Best match found: ${bestMatch.city}');
        }
      }

      final postal = bestMatch.effectivePostalCode;
      if (postal == null || postal.isEmpty) {
        _logger.w('⚠️ City "${bestMatch.city}" has no postal code');
        return null;
      }

      final country = bestMatch.countryCode;
      if (country == null || country.isEmpty) {
        _logger.w('⚠️ City "${bestMatch.city}" has no country code');
        return null;
      }

      final matchedCity = MatchedCity(
        city: bestMatch.city,
        postal: postal,
        country: country,
        state: bestMatch.state ?? '',
      );

      _logger.i('✅ Matched city: $matchedCity');
      return matchedCity;
    } catch (e) {
      _logger.e('❌ Failed to match city "$cityName": $e');
      return null;
    }
  }

  void dispose() {
    _cityService.dispose();
  }
}
