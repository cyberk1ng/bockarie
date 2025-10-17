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

    test('effectivePostalCode uses US city+state fallback', () {
      const result = CityResult(
        city: 'Atlanta',
        postalCode: null,
        country: 'United States',
        countryCode: 'US',
        state: 'GA',
        displayName: 'Atlanta, GA, USA',
      );

      expect(result.effectivePostalCode, '30303');
    });

    test('effectivePostalCode uses US fallback for Miami', () {
      const result = CityResult(
        city: 'Miami',
        postalCode: null,
        country: 'United States',
        countryCode: 'US',
        state: 'FL',
        displayName: 'Miami, FL, USA',
      );

      expect(result.effectivePostalCode, '33101');
    });

    test('effectivePostalCode is case insensitive for US city+state', () {
      const result = CityResult(
        city: 'ATLANTA',
        postalCode: null,
        country: 'United States',
        countryCode: 'US',
        state: 'ga',
        displayName: 'ATLANTA, GA, USA',
      );

      expect(result.effectivePostalCode, '30303');
    });

    test('effectivePostalCode prioritizes API postal over US fallback', () {
      const result = CityResult(
        city: 'Atlanta',
        postalCode: '30301', // Different from fallback 30303
        country: 'United States',
        countryCode: 'US',
        state: 'GA',
        displayName: 'Atlanta, GA, USA',
      );

      // Should use API value, not fallback
      expect(result.effectivePostalCode, '30301');
    });

    test('effectivePostalCode tries US fallback before general fallback', () {
      // Hamburg is in general fallback, but if it had a US state,
      // it should try US fallback first
      const result = CityResult(
        city: 'San Francisco',
        postalCode: null,
        country: 'United States',
        countryCode: 'US',
        state: 'CA',
        displayName: 'San Francisco, CA, USA',
      );

      expect(result.effectivePostalCode, '94101');
    });

    test('effectivePostalCode returns null for US city without state', () {
      const result = CityResult(
        city: 'Atlanta',
        postalCode: null,
        country: 'United States',
        countryCode: 'US',
        state: null, // No state
        displayName: 'Atlanta, USA',
      );

      // Without state, can't use US fallback, and Atlanta isn't in general fallback
      expect(result.effectivePostalCode, null);
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

      final captured =
          verify(
                () => mockDio.get(
                  '/search',
                  queryParameters: captureAny(named: 'queryParameters'),
                ),
              ).captured.first
              as Map<String, dynamic>;

      // Should NOT contain 'countrycodes' parameter (country restriction removed)
      expect(captured.containsKey('countrycodes'), false);
      expect(captured['q'], 'Hamburg');
      expect(captured['format'], 'json');
      expect(captured['limit'], '20');
      expect(captured['addressdetails'], '1');
      expect(captured['accept-language'], 'en');
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
      expect(results[0].countryCode, 'DE');
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

    test('searchCities returns major cities for country name', () async {
      final results = await provider.searchCities('germany');

      expect(results.isNotEmpty, true);
      expect(results.any((r) => r.city == 'Berlin'), true);
      expect(results.any((r) => r.city == 'Hamburg'), true);
      expect(results.any((r) => r.city == 'Munich'), true);
      expect(results[0].postalCode, isNotNull); // Should have postal codes
      expect(results[0].countryCode, 'DE');
    });

    test('searchCities returns major cities for China', () async {
      final results = await provider.searchCities('china');

      expect(results.isNotEmpty, true);
      expect(results.any((r) => r.city == 'Shanghai'), true);
      expect(results.any((r) => r.city == 'Beijing'), true);
      expect(results.any((r) => r.city == 'Guangzhou'), true);
      expect(results[0].postalCode, isNotNull);
      expect(results[0].countryCode, 'CN');
    });

    test('searchCities returns major cities for USA', () async {
      final results = await provider.searchCities('usa');

      expect(results.isNotEmpty, true);
      expect(results.any((r) => r.city == 'New York'), true);
      expect(results.any((r) => r.city == 'Los Angeles'), true);
      expect(results.any((r) => r.city == 'Chicago'), true);
      expect(results[0].postalCode, isNotNull);
      expect(results[0].countryCode, 'US');
      expect(results[0].state, isNotNull); // US cities have state codes
    });

    test('searchCities is case insensitive for country names', () async {
      final results1 = await provider.searchCities('CHINA');
      final results2 = await provider.searchCities('china');
      final results3 = await provider.searchCities('China');

      expect(results1.length, results2.length);
      expect(results1.length, results3.length);
      expect(results1[0].city, results2[0].city);
    });

    test('searchCities does not match partial country names', () async {
      // "german" should not match "germany"
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

      await provider.searchCities('german');

      // Should call API (not return major cities)
      verify(
        () => mockDio.get(
          '/search',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).called(1);
    });

    test('searchCities extracts US state from ISO3166-2-lvl4', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(),
          statusCode: 200,
          data: [
            {
              'display_name': 'Atlanta, GA, USA',
              'address': {
                'city': 'Atlanta',
                'country': 'United States',
                'country_code': 'us',
                'ISO3166-2-lvl4': 'US-GA',
              },
            },
          ],
        ),
      );

      final results = await provider.searchCities('Atlanta');

      expect(results, hasLength(1));
      expect(results[0].city, 'Atlanta');
      expect(results[0].state, 'GA');
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

    test('searchCities bypasses debounce for country queries', () async {
      const expectedResults = [
        CityResult(
          city: 'Berlin',
          postalCode: '10115',
          country: 'Germany',
          countryCode: 'DE',
          displayName: 'Berlin, Germany',
        ),
      ];

      when(
        () => mockProvider.searchCities('germany'),
      ).thenAnswer((_) async => expectedResults);

      List<CityResult>? callbackResults;
      final startTime = DateTime.now();

      // Should return immediately without debounce
      await service.searchCities('germany', (results) {
        callbackResults = results;
      });

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      // Should complete before debounce delay (100ms)
      expect(duration.inMilliseconds, lessThan(50));
      expect(callbackResults, expectedResults);
      verify(() => mockProvider.searchCities('germany')).called(1);
    });

    test('searchCities uses debounce for regular queries', () async {
      when(() => mockProvider.searchCities(any())).thenAnswer((_) async => []);

      service.searchCities('ham', (_) {}); // Triggers debounce
      await Future.delayed(const Duration(milliseconds: 50));

      // Should not have called provider yet (within debounce period)
      verifyNever(() => mockProvider.searchCities('ham'));

      // Wait for debounce to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Now should have called provider
      verify(() => mockProvider.searchCities('ham')).called(1);
    });

    test('searchCities bypasses debounce for country aliases', () async {
      const expectedResults = [
        CityResult(
          city: 'New York',
          postalCode: '10001',
          country: 'United States',
          countryCode: 'US',
          state: 'NY',
          displayName: 'New York, NY, USA',
        ),
      ];

      when(
        () => mockProvider.searchCities('usa'),
      ).thenAnswer((_) async => expectedResults);

      List<CityResult>? callbackResults;
      final startTime = DateTime.now();

      await service.searchCities('usa', (results) {
        callbackResults = results;
      });

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      expect(duration.inMilliseconds, lessThan(50));
      expect(callbackResults, expectedResults);
    });

    test(
      'searchCities is case insensitive for country debounce bypass',
      () async {
        when(
          () => mockProvider.searchCities(any()),
        ).thenAnswer((_) async => []);

        final startTime = DateTime.now();
        await service.searchCities('GERMANY', (_) {});
        final endTime = DateTime.now();

        // Should bypass debounce even with uppercase
        expect(endTime.difference(startTime).inMilliseconds, lessThan(50));
      },
    );
  });
}

class MockCityProvider extends Mock implements CityAutocompleteProvider {}
