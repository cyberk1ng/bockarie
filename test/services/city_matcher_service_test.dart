import 'package:bockaire/services/city_autocomplete_service.dart';
import 'package:bockaire/services/city_matcher_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCityAutocompleteService extends Mock
    implements CityAutocompleteService {}

void main() {
  late MockCityAutocompleteService mockCityService;
  late CityMatcherService service;

  setUp(() {
    mockCityService = MockCityAutocompleteService();
    service = CityMatcherService(cityService: mockCityService);
  });

  tearDown(() {
    service.dispose();
  });

  group('CityMatcherService', () {
    test('findCity returns exact match when available', () async {
      final mockResults = [
        const CityResult(
          city: 'London',
          postalCode: 'EC1A',
          country: 'United Kingdom',
          countryCode: 'GB',
          displayName: 'London, United Kingdom',
        ),
        const CityResult(
          city: 'London',
          postalCode: 'N1',
          country: 'United Kingdom',
          countryCode: 'GB',
          displayName: 'London, United Kingdom',
        ),
      ];

      when(() => mockCityService.searchCities('London', any())).thenAnswer((
        invocation,
      ) async {
        final callback =
            invocation.positionalArguments[1] as Function(List<CityResult>);
        callback(mockResults);
        return mockResults;
      });

      final result = await service.findCity('London');

      expect(result, isNotNull);
      expect(result!.city, 'London');
      expect(result.postal, 'EC1A');
      expect(result.country, 'GB');
    });

    test('findCity is case-insensitive for exact match', () async {
      final mockResults = [
        const CityResult(
          city: 'Hamburg',
          postalCode: '20095',
          country: 'Germany',
          countryCode: 'DE',
          displayName: 'Hamburg, Germany',
        ),
      ];

      when(() => mockCityService.searchCities('HAMBURG', any())).thenAnswer((
        invocation,
      ) async {
        final callback =
            invocation.positionalArguments[1] as Function(List<CityResult>);
        callback(mockResults);
        return mockResults;
      });

      final result = await service.findCity('HAMBURG');

      expect(result, isNotNull);
      expect(result!.city, 'Hamburg');
    });

    test('findCity returns starts-with match when no exact match', () async {
      final mockResults = [
        const CityResult(
          city: 'New York',
          postalCode: '10001',
          country: 'United States',
          countryCode: 'US',
          displayName: 'New York, NY, USA',
          state: 'NY',
        ),
        const CityResult(
          city: 'Newark',
          postalCode: '07101',
          country: 'United States',
          countryCode: 'US',
          displayName: 'Newark, NJ, USA',
          state: 'NJ',
        ),
      ];

      when(() => mockCityService.searchCities('New', any())).thenAnswer((
        invocation,
      ) async {
        final callback =
            invocation.positionalArguments[1] as Function(List<CityResult>);
        callback(mockResults);
        return mockResults;
      });

      final result = await service.findCity('New');

      expect(result, isNotNull);
      expect(result!.city, 'New York');
    });

    test(
      'findCity returns first result when no exact or starts-with match',
      () async {
        final mockResults = [
          const CityResult(
            city: 'Shanghai',
            postalCode: '200000',
            country: 'China',
            countryCode: 'CN',
            displayName: 'Shanghai, China',
          ),
        ];

        when(() => mockCityService.searchCities('hai', any())).thenAnswer((
          invocation,
        ) async {
          final callback =
              invocation.positionalArguments[1] as Function(List<CityResult>);
          callback(mockResults);
          return mockResults;
        });

        final result = await service.findCity('hai');

        expect(result, isNotNull);
        expect(result!.city, 'Shanghai');
      },
    );

    test('findCity returns null when no results found', () async {
      when(() => mockCityService.searchCities('XYZ123', any())).thenAnswer((
        invocation,
      ) async {
        final callback =
            invocation.positionalArguments[1] as Function(List<CityResult>);
        callback([]);
        return [];
      });

      final result = await service.findCity('XYZ123');

      expect(result, isNull);
    });

    test('findCity returns null when city has no postal code', () async {
      final mockResults = [
        const CityResult(
          city: 'SmallTown',
          postalCode: null, // No postal code
          country: 'Unknown',
          countryCode: 'UN',
          displayName: 'SmallTown',
        ),
      ];

      when(() => mockCityService.searchCities('SmallTown', any())).thenAnswer((
        invocation,
      ) async {
        final callback =
            invocation.positionalArguments[1] as Function(List<CityResult>);
        callback(mockResults);
        return mockResults;
      });

      final result = await service.findCity('SmallTown');

      expect(result, isNull);
    });

    test('findCity returns null when postal code is empty string', () async {
      final mockResults = [
        const CityResult(
          city: 'SmallTown',
          postalCode: '', // Empty postal code
          country: 'Unknown',
          countryCode: 'UN',
          displayName: 'SmallTown',
        ),
      ];

      when(() => mockCityService.searchCities('SmallTown', any())).thenAnswer((
        invocation,
      ) async {
        final callback =
            invocation.positionalArguments[1] as Function(List<CityResult>);
        callback(mockResults);
        return mockResults;
      });

      final result = await service.findCity('SmallTown');

      expect(result, isNull);
    });

    test('findCity returns null when city has no country code', () async {
      final mockResults = [
        const CityResult(
          city: 'Mystery City',
          postalCode: '12345',
          country: 'Unknown',
          countryCode: null, // No country code
          displayName: 'Mystery City',
        ),
      ];

      when(() => mockCityService.searchCities('Mystery', any())).thenAnswer((
        invocation,
      ) async {
        final callback =
            invocation.positionalArguments[1] as Function(List<CityResult>);
        callback(mockResults);
        return mockResults;
      });

      final result = await service.findCity('Mystery');

      expect(result, isNull);
    });

    test('findCity returns null when country code is empty string', () async {
      final mockResults = [
        const CityResult(
          city: 'Mystery City',
          postalCode: '12345',
          country: 'Unknown',
          countryCode: '', // Empty country code
          displayName: 'Mystery City',
        ),
      ];

      when(() => mockCityService.searchCities('Mystery', any())).thenAnswer((
        invocation,
      ) async {
        final callback =
            invocation.positionalArguments[1] as Function(List<CityResult>);
        callback(mockResults);
        return mockResults;
      });

      final result = await service.findCity('Mystery');

      expect(result, isNull);
    });

    test('findCity includes state in result when available', () async {
      final mockResults = [
        const CityResult(
          city: 'Miami',
          postalCode: '33101',
          country: 'United States',
          countryCode: 'US',
          state: 'FL',
          displayName: 'Miami, FL, USA',
        ),
      ];

      when(() => mockCityService.searchCities('Miami', any())).thenAnswer((
        invocation,
      ) async {
        final callback =
            invocation.positionalArguments[1] as Function(List<CityResult>);
        callback(mockResults);
        return mockResults;
      });

      final result = await service.findCity('Miami');

      expect(result, isNotNull);
      expect(result!.city, 'Miami');
      expect(result.state, 'FL');
      expect(result.postal, '33101');
      expect(result.country, 'US');
    });

    test('findCity sets empty state when not available', () async {
      final mockResults = [
        const CityResult(
          city: 'Berlin',
          postalCode: '10115',
          country: 'Germany',
          countryCode: 'DE',
          state: null,
          displayName: 'Berlin, Germany',
        ),
      ];

      when(() => mockCityService.searchCities('Berlin', any())).thenAnswer((
        invocation,
      ) async {
        final callback =
            invocation.positionalArguments[1] as Function(List<CityResult>);
        callback(mockResults);
        return mockResults;
      });

      final result = await service.findCity('Berlin');

      expect(result, isNotNull);
      expect(result!.state, '');
    });

    test('findCity handles multi-word city names', () async {
      final mockResults = [
        const CityResult(
          city: 'Los Angeles',
          postalCode: '90001',
          country: 'United States',
          countryCode: 'US',
          state: 'CA',
          displayName: 'Los Angeles, CA, USA',
        ),
      ];

      when(() => mockCityService.searchCities('Los Angeles', any())).thenAnswer(
        (invocation) async {
          final callback =
              invocation.positionalArguments[1] as Function(List<CityResult>);
          callback(mockResults);
          return mockResults;
        },
      );

      final result = await service.findCity('Los Angeles');

      expect(result, isNotNull);
      expect(result!.city, 'Los Angeles');
    });

    test('findCity handles special characters in city names', () async {
      final mockResults = [
        const CityResult(
          city: 'São Paulo',
          postalCode: '01000',
          country: 'Brazil',
          countryCode: 'BR',
          displayName: 'São Paulo, Brazil',
        ),
      ];

      when(() => mockCityService.searchCities('São Paulo', any())).thenAnswer((
        invocation,
      ) async {
        final callback =
            invocation.positionalArguments[1] as Function(List<CityResult>);
        callback(mockResults);
        return mockResults;
      });

      final result = await service.findCity('São Paulo');

      expect(result, isNotNull);
      expect(result!.city, 'São Paulo');
    });

    test('findCity returns null on service error', () async {
      when(
        () => mockCityService.searchCities('Error', any()),
      ).thenThrow(Exception('Service error'));

      final result = await service.findCity('Error');

      expect(result, isNull);
    });

    test('MatchedCity toString returns formatted string', () {
      const city = MatchedCity(
        city: 'Hamburg',
        postal: '20095',
        country: 'DE',
        state: 'HH',
      );

      expect(
        city.toString(),
        'MatchedCity(city: Hamburg, postal: 20095, country: DE, state: HH)',
      );
    });

    test('dispose calls dispose on city service', () {
      service.dispose();
      verify(() => mockCityService.dispose()).called(1);
    });
  });
}
