import 'package:bockaire/services/city_autocomplete_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('CityResult', () {
    test('effectivePostalCode returns API postal code when available', () {
      const result = CityResult(
        city: 'Munich',
        postalCode: '80331',
        country: 'Germany',
        countryCode: 'de',
        displayName: 'Munich, Germany',
      );

      expect(result.effectivePostalCode, '80331');
    });

    test(
      'effectivePostalCode returns fallback for major city without postal code',
      () {
        const result = CityResult(
          city: 'Hamburg',
          postalCode: null,
          country: 'Germany',
          countryCode: 'de',
          displayName: 'Hamburg, Germany',
        );

        expect(result.effectivePostalCode, '20095');
      },
    );

    test('effectivePostalCode returns fallback for Guangzhou', () {
      const result = CityResult(
        city: 'Guangzhou',
        postalCode: null,
        country: 'China',
        countryCode: 'cn',
        displayName: 'Guangzhou, China',
      );

      expect(result.effectivePostalCode, '510000');
    });

    test('effectivePostalCode returns null for unknown city', () {
      const result = CityResult(
        city: 'SmallTown',
        postalCode: null,
        country: 'Germany',
        countryCode: 'de',
        displayName: 'SmallTown, Germany',
      );

      expect(result.effectivePostalCode, null);
    });

    test('effectivePostalCode is case-insensitive for fallbacks', () {
      const result = CityResult(
        city: 'HAMBURG',
        postalCode: null,
        country: 'Germany',
        countryCode: 'de',
        displayName: 'HAMBURG, Germany',
      );

      expect(result.effectivePostalCode, '20095');
    });

    test('toString includes effective postal code', () {
      const result = CityResult(
        city: 'Hamburg',
        postalCode: null,
        country: 'Germany',
        countryCode: 'de',
        displayName: 'Hamburg, Germany',
      );

      expect(result.toString(), 'Hamburg, 20095, Germany');
    });

    test('equality checks work correctly', () {
      const result1 = CityResult(
        city: 'Hamburg',
        postalCode: '20095',
        country: 'Germany',
        countryCode: 'de',
        displayName: 'Hamburg, Germany',
      );

      const result2 = CityResult(
        city: 'Hamburg',
        postalCode: '20095',
        country: 'Germany',
        countryCode: 'de',
        displayName: 'Hamburg, Germany',
      );

      expect(result1, result2);
      expect(result1.hashCode, result2.hashCode);
    });
  });

  group('NominatimCityProvider', () {
    late MockDio mockDio;
    late NominatimCityProvider provider;

    setUp(() {
      mockDio = MockDio();
      provider = NominatimCityProvider(dio: mockDio);
    });

    test('searchCities returns empty list for empty query', () async {
      final results = await provider.searchCities('');
      expect(results, isEmpty);
    });

    test('searchCities calls API with correct parameters', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          statusCode: 200,
          data: [],
        ),
      );

      await provider.searchCities('Hamburg');

      verify(
        () => mockDio.get(
          '/search',
          queryParameters: {
            'q': 'Hamburg',
            'format': 'json',
            'limit': '20',
            'countrycodes': 'de,cn',
            'addressdetails': '1',
            'accept-language': 'en',
          },
        ),
      ).called(1);
    });

    test('searchCities parses API response correctly', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          statusCode: 200,
          data: [
            {
              'display_name': 'Hamburg, Germany',
              'address': {
                'city': 'Hamburg',
                'postcode': '20095',
                'country': 'Germany',
                'country_code': 'de',
              },
            },
          ],
        ),
      );

      final results = await provider.searchCities('Hamburg');

      expect(results, hasLength(1));
      expect(results[0].city, 'Hamburg');
      expect(results[0].postalCode, '20095');
      expect(results[0].country, 'Germany');
      expect(results[0].countryCode, 'de');
    });

    test('searchCities filters results containing query', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          statusCode: 200,
          data: [
            {
              'display_name': 'Hamburg, Germany',
              'address': {'city': 'Hamburg'},
            },
            {
              'display_name': 'Berlin, Germany',
              'address': {'city': 'Berlin'},
            },
            {
              'display_name': 'Hamburg Township, USA',
              'address': {'town': 'Hamburg Township'},
            },
          ],
        ),
      );

      final results = await provider.searchCities('Hamburg');

      expect(results.length, 2);
      expect(results.any((r) => r.city.contains('Hamburg')), true);
      expect(results.any((r) => r.city == 'Berlin'), false);
    });

    test('searchCities sorts results with exact matches first', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          statusCode: 200,
          data: [
            {
              'display_name': 'Hamburg Township, USA',
              'address': {'town': 'Hamburg Township'},
            },
            {
              'display_name': 'Hamburg, Germany',
              'address': {'city': 'Hamburg'},
            },
            {
              'display_name': 'Hamburger Berg, Germany',
              'address': {'suburb': 'Hamburger Berg'},
            },
          ],
        ),
      );

      final results = await provider.searchCities('Hamburg');

      // Exact match should be first
      expect(results[0].city, 'Hamburg');
    });

    test('searchCities handles empty city names', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          statusCode: 200,
          data: [
            <String, dynamic>{
              'display_name': 'Some Place',
              'address': <String, dynamic>{}, // No city field
            },
            <String, dynamic>{
              'display_name': 'Hamburg, Germany',
              'address': <String, dynamic>{'city': 'Hamburg'},
            },
          ],
        ),
      );

      final results = await provider.searchCities('Hamburg');

      // Should filter out empty city names
      expect(results, hasLength(1));
      expect(results[0].city, 'Hamburg');
    });

    test('searchCities throws exception on API error', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          statusCode: 500,
          data: null,
        ),
      );

      expect(() => provider.searchCities('Hamburg'), throwsA(isA<Exception>()));
    });

    test('searchCities handles network errors', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(() => provider.searchCities('Hamburg'), throwsA(isA<Exception>()));
    });

    test('searchCities limits results to 8', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          statusCode: 200,
          data: List.generate(
            20,
            (i) => {
              'display_name': 'Hamburg $i, Germany',
              'address': {'city': 'Hamburg $i'},
            },
          ),
        ),
      );

      final results = await provider.searchCities('Hamburg');

      expect(results.length, lessThanOrEqualTo(8));
    });

    test('searchCities removes duplicate cities', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          statusCode: 200,
          data: [
            {
              'display_name': 'Hamburg, Germany',
              'address': {'city': 'Hamburg', 'postcode': '20095'},
            },
            {
              'display_name': 'Hamburg, Germany',
              'address': {'city': 'Hamburg', 'postcode': '20095'},
            },
            {
              'display_name': 'Hamburg, Germany',
              'address': {'city': 'Hamburg', 'postcode': '20099'},
            },
          ],
        ),
      );

      final results = await provider.searchCities('Hamburg');

      // Should have at most 2 unique Hamburg entries (different postcodes)
      expect(results.length, lessThanOrEqualTo(2));
    });

    test('searchCities extracts city from various address fields', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          statusCode: 200,
          data: [
            {
              'display_name': 'Town Example',
              'address': {'town': 'TownName'},
            },
            {
              'display_name': 'Village Example',
              'address': {'village': 'VillageName'},
            },
            {
              'display_name': 'Municipality Example',
              'address': {'municipality': 'MunicipalityName'},
            },
          ],
        ),
      );

      final results = await provider.searchCities('Name');

      expect(results.any((r) => r.city == 'TownName'), true);
      expect(results.any((r) => r.city == 'VillageName'), true);
      expect(results.any((r) => r.city == 'MunicipalityName'), true);
    });
  });

  group('CityAutocompleteService', () {
    late CityAutocompleteService service;
    late MockCityProvider mockProvider;

    setUp(() {
      mockProvider = MockCityProvider();
      service = CityAutocompleteService(provider: mockProvider);
    });

    tearDown(() {
      service.dispose();
    });

    test('searchCities debounces requests', () async {
      when(() => mockProvider.searchCities(any())).thenAnswer((_) async => []);

      // Make multiple rapid calls
      service.searchCities('H', (_) {});
      service.searchCities('Ha', (_) {});
      service.searchCities('Ham', (_) {});

      // Wait for debounce
      await Future.delayed(const Duration(milliseconds: 250));

      // Should only call provider once for the last query
      verify(() => mockProvider.searchCities('Ham')).called(1);
      verifyNever(() => mockProvider.searchCities('H'));
      verifyNever(() => mockProvider.searchCities('Ha'));
    });

    test('searchCities calls callback with results', () async {
      const expectedResults = [
        CityResult(
          city: 'Hamburg',
          postalCode: '20095',
          country: 'Germany',
          countryCode: 'de',
          displayName: 'Hamburg, Germany',
        ),
      ];

      when(
        () => mockProvider.searchCities('Hamburg'),
      ).thenAnswer((_) async => expectedResults);

      List<CityResult>? callbackResults;
      await service.searchCities('Hamburg', (results) {
        callbackResults = results;
      });

      await Future.delayed(const Duration(milliseconds: 250));

      expect(callbackResults, expectedResults);
    });

    test('cancel stops pending search', () async {
      when(() => mockProvider.searchCities(any())).thenAnswer((_) async => []);

      service.searchCities('Hamburg', (_) {});
      service.cancel();

      await Future.delayed(const Duration(milliseconds: 250));

      verifyNever(() => mockProvider.searchCities(any()));
    });

    test('dispose cleans up resources', () {
      service.dispose();
      // Should not throw
    });
  });
}

class MockCityProvider extends Mock implements CityAutocompleteProvider {}
