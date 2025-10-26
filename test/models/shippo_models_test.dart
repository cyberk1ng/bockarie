import 'package:bockaire/models/shippo_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShippoAddress', () {
    test('toJson includes all required fields', () {
      final address = ShippoAddress(
        name: 'John Doe',
        street1: '123 Main St',
        city: 'New York',
        state: 'NY',
        zip: '10001',
        country: 'US',
      );

      final json = address.toJson();
      expect(json['name'], 'John Doe');
      expect(json['street1'], '123 Main St');
      expect(json['city'], 'New York');
      expect(json['state'], 'NY');
      expect(json['zip'], '10001');
      expect(json['country'], 'US');
    });

    test('toJson includes street2 when provided', () {
      final address = ShippoAddress(
        name: 'John Doe',
        street1: '123 Main St',
        street2: 'Apt 4B',
        city: 'New York',
        state: 'NY',
        zip: '10001',
        country: 'US',
      );

      final json = address.toJson();
      expect(json['street2'], 'Apt 4B');
    });

    test('toJson excludes street2 when null', () {
      final address = ShippoAddress(
        name: 'John Doe',
        street1: '123 Main St',
        city: 'New York',
        state: 'NY',
        zip: '10001',
        country: 'US',
      );

      final json = address.toJson();
      expect(json.containsKey('street2'), false);
    });

    test('toJson handles empty state string', () {
      final address = ShippoAddress(
        name: 'Sender',
        street1: 'Street 1',
        city: 'Shanghai',
        state: '',
        zip: '200000',
        country: 'CN',
      );

      final json = address.toJson();
      expect(json['state'], '');
    });
  });

  group('ShippoParcel', () {
    test('toJson includes all fields with correct format', () {
      final parcel = ShippoParcel(
        length: '40',
        width: '30',
        height: '20',
        weight: '5.50',
      );

      final json = parcel.toJson();
      expect(json['length'], '40');
      expect(json['width'], '30');
      expect(json['height'], '20');
      expect(json['distance_unit'], 'cm');
      expect(json['weight'], '5.50');
      expect(json['mass_unit'], 'kg');
    });

    test('toJson uses default distance_unit and mass_unit', () {
      final parcel = ShippoParcel(
        length: '100',
        width: '50',
        height: '30',
        weight: '10.00',
      );

      final json = parcel.toJson();
      expect(json['distance_unit'], 'cm');
      expect(json['mass_unit'], 'kg');
    });

    test('toJson respects custom units', () {
      final parcel = ShippoParcel(
        length: '40',
        width: '30',
        height: '20',
        weight: '12.12',
        distanceUnit: 'in',
        massUnit: 'lb',
      );

      final json = parcel.toJson();
      expect(json['distance_unit'], 'in');
      expect(json['mass_unit'], 'lb');
    });
  });

  group('ShippoShipmentRequest', () {
    test('toJson serializes complete request', () {
      final request = ShippoShipmentRequest(
        addressFrom: ShippoAddress(
          name: 'Sender',
          street1: '123 Main St',
          city: 'New York',
          state: 'NY',
          zip: '10001',
          country: 'US',
        ),
        addressTo: ShippoAddress(
          name: 'Recipient',
          street1: '456 Oak Ave',
          city: 'Atlanta',
          state: 'GA',
          zip: '30303',
          country: 'US',
        ),
        parcels: [
          ShippoParcel(length: '40', width: '30', height: '20', weight: '5.50'),
        ],
      );

      final json = request.toJson();
      expect(json['address_from'], isA<Map<String, dynamic>>());
      expect(json['address_to'], isA<Map<String, dynamic>>());
      expect(json['parcels'], isA<List>());
      expect(json['async'], false);
    });

    test('toJson handles multiple parcels', () {
      final request = ShippoShipmentRequest(
        addressFrom: ShippoAddress(
          name: 'Sender',
          street1: '123 Main St',
          city: 'New York',
          state: 'NY',
          zip: '10001',
          country: 'US',
        ),
        addressTo: ShippoAddress(
          name: 'Recipient',
          street1: '456 Oak Ave',
          city: 'Atlanta',
          state: 'GA',
          zip: '30303',
          country: 'US',
        ),
        parcels: [
          ShippoParcel(length: '40', width: '30', height: '20', weight: '5.50'),
          ShippoParcel(
            length: '50',
            width: '40',
            height: '30',
            weight: '10.00',
          ),
        ],
      );

      final json = request.toJson();
      final parcels = json['parcels'] as List;
      expect(parcels, hasLength(2));
    });

    test('toJson respects async parameter', () {
      final request = ShippoShipmentRequest(
        addressFrom: ShippoAddress(
          name: 'Sender',
          street1: '123 Main St',
          city: 'New York',
          state: 'NY',
          zip: '10001',
          country: 'US',
        ),
        addressTo: ShippoAddress(
          name: 'Recipient',
          street1: '456 Oak Ave',
          city: 'Atlanta',
          state: 'GA',
          zip: '30303',
          country: 'US',
        ),
        parcels: [],
        async: true,
      );

      final json = request.toJson();
      expect(json['async'], true);
    });
  });

  group('ShippoServiceLevel', () {
    test('fromJson handles complete data', () {
      final json = {'name': 'Priority Mail', 'token': 'usps_priority'};

      final serviceLevel = ShippoServiceLevel.fromJson(json);
      expect(serviceLevel.name, 'Priority Mail');
      expect(serviceLevel.token, 'usps_priority');
    });

    test('fromJson uses fallback for missing name', () {
      final json = <String, dynamic>{'token': 'usps_priority'};

      final serviceLevel = ShippoServiceLevel.fromJson(json);
      expect(serviceLevel.name, 'Unknown Service');
      expect(serviceLevel.token, 'usps_priority');
    });

    test('fromJson handles missing token', () {
      final json = {'name': 'Express'};

      final serviceLevel = ShippoServiceLevel.fromJson(json);
      expect(serviceLevel.name, 'Express');
      expect(serviceLevel.token, null);
    });

    test('fromJson handles empty JSON', () {
      final json = <String, dynamic>{};

      final serviceLevel = ShippoServiceLevel.fromJson(json);
      expect(serviceLevel.name, 'Unknown Service');
      expect(serviceLevel.token, null);
    });
  });

  group('ShippoRate', () {
    test('fromJson handles complete data', () {
      final json = {
        'object_id': 'rate_123',
        'provider': 'USPS',
        'servicelevel': {'name': 'Priority Mail', 'token': 'usps_priority'},
        'amount': '25.50',
        'currency': 'USD',
        'estimated_days': 2,
        'duration_terms': '1-3 business days',
      };

      final rate = ShippoRate.fromJson(json);
      expect(rate.objectId, 'rate_123');
      expect(rate.provider, 'USPS');
      expect(rate.servicelevel.name, 'Priority Mail');
      expect(rate.amount, '25.50');
      expect(rate.currency, 'USD');
      expect(rate.estimatedDays, 2);
      expect(rate.durationTerms, '1-3 business days');
    });

    test('fromJson handles missing object_id with fallback', () {
      final json = <String, dynamic>{'provider': 'USPS', 'amount': '25.50'};

      final rate = ShippoRate.fromJson(json);
      expect(rate.objectId, '');
    });

    test('fromJson handles missing provider with fallback', () {
      final json = <String, dynamic>{
        'object_id': 'rate_123',
        'amount': '25.50',
      };

      final rate = ShippoRate.fromJson(json);
      expect(rate.provider, 'Unknown');
    });

    test('fromJson handles missing servicelevel with default', () {
      final json = <String, dynamic>{
        'object_id': 'rate_123',
        'provider': 'USPS',
        'amount': '25.50',
      };

      final rate = ShippoRate.fromJson(json);
      expect(rate.servicelevel.name, 'Standard');
      expect(rate.servicelevel.token, null);
    });

    test('fromJson handles missing amount with fallback', () {
      final json = <String, dynamic>{
        'object_id': 'rate_123',
        'provider': 'USPS',
      };

      final rate = ShippoRate.fromJson(json);
      expect(rate.amount, '0.0');
    });

    test('fromJson handles missing currency with fallback', () {
      final json = <String, dynamic>{
        'object_id': 'rate_123',
        'provider': 'USPS',
        'amount': '25.50',
      };

      final rate = ShippoRate.fromJson(json);
      expect(rate.currency, 'USD');
    });

    test('fromJson handles missing estimatedDays as null', () {
      final json = <String, dynamic>{
        'object_id': 'rate_123',
        'provider': 'USPS',
        'amount': '25.50',
      };

      final rate = ShippoRate.fromJson(json);
      expect(rate.estimatedDays, null);
    });

    test('fromJson handles missing durationTerms as null', () {
      final json = <String, dynamic>{
        'object_id': 'rate_123',
        'provider': 'USPS',
        'amount': '25.50',
      };

      final rate = ShippoRate.fromJson(json);
      expect(rate.durationTerms, null);
    });

    test('fromJson handles completely empty JSON with all defaults', () {
      final json = <String, dynamic>{};

      final rate = ShippoRate.fromJson(json);
      expect(rate.objectId, '');
      expect(rate.provider, 'Unknown');
      expect(rate.servicelevel.name, 'Standard');
      expect(rate.amount, '0.0');
      expect(rate.currency, 'USD');
      expect(rate.estimatedDays, null);
      expect(rate.durationTerms, null);
    });

    test('toPriceEur converts USD to EUR correctly', () {
      final rate = ShippoRate(
        objectId: 'rate_1',
        provider: 'USPS',
        servicelevel: ShippoServiceLevel(name: 'Priority'),
        amount: '100.00',
        currency: 'USD',
      );

      final eurPrice = rate.toPriceEur(0.92);
      expect(eurPrice, 92.0);
    });

    test('toPriceEur handles decimal amounts', () {
      final rate = ShippoRate(
        objectId: 'rate_1',
        provider: 'USPS',
        servicelevel: ShippoServiceLevel(name: 'Priority'),
        amount: '25.50',
        currency: 'USD',
      );

      final eurPrice = rate.toPriceEur(0.92);
      expect(eurPrice, closeTo(23.46, 0.01));
    });

    test('toPriceEur handles invalid amount string', () {
      final rate = ShippoRate(
        objectId: 'rate_1',
        provider: 'USPS',
        servicelevel: ShippoServiceLevel(name: 'Priority'),
        amount: 'invalid',
        currency: 'USD',
      );

      final eurPrice = rate.toPriceEur(0.92);
      expect(eurPrice, 0.0);
    });

    test('toPriceEur handles zero amount', () {
      final rate = ShippoRate(
        objectId: 'rate_1',
        provider: 'USPS',
        servicelevel: ShippoServiceLevel(name: 'Priority'),
        amount: '0.0',
        currency: 'USD',
      );

      final eurPrice = rate.toPriceEur(0.92);
      expect(eurPrice, 0.0);
    });

    test('toPriceEur handles empty amount string', () {
      final rate = ShippoRate(
        objectId: 'rate_1',
        provider: 'USPS',
        servicelevel: ShippoServiceLevel(name: 'Priority'),
        amount: '',
        currency: 'USD',
      );

      final eurPrice = rate.toPriceEur(0.92);
      expect(eurPrice, 0.0);
    });

    test('toPriceEur uses amount_local when currency_local is EUR', () {
      final rate = ShippoRate(
        objectId: 'rate_1',
        provider: 'UPS',
        servicelevel: ShippoServiceLevel(name: 'Expedited'),
        amount: '2897.18', // CNY
        currency: 'CNY',
        amountLocal: '349.87', // EUR
        currencyLocal: 'EUR',
      );

      final eurPrice = rate.toPriceEur(0.92);
      expect(eurPrice, 349.87); // Should use amount_local directly
    });

    test('toPriceEur uses amount when currency is EUR', () {
      final rate = ShippoRate(
        objectId: 'rate_1',
        provider: 'DHL',
        servicelevel: ShippoServiceLevel(name: 'Express'),
        amount: '125.50',
        currency: 'EUR',
      );

      final eurPrice = rate.toPriceEur(0.92);
      expect(eurPrice, 125.50); // Should use amount directly
    });

    test('toPriceEur converts USD correctly when no amount_local', () {
      final rate = ShippoRate(
        objectId: 'rate_1',
        provider: 'USPS',
        servicelevel: ShippoServiceLevel(name: 'Priority'),
        amount: '100.00',
        currency: 'USD',
      );

      final eurPrice = rate.toPriceEur(0.92);
      expect(eurPrice, 92.0);
    });

    test('toPriceEur falls back to amount_local for unknown currencies', () {
      final rate = ShippoRate(
        objectId: 'rate_1',
        provider: 'UPS',
        servicelevel: ShippoServiceLevel(name: 'Standard'),
        amount: '500.00', // JPY or some other currency
        currency: 'JPY',
        amountLocal: '50.00', // Hopefully in EUR
      );

      final eurPrice = rate.toPriceEur(0.92);
      expect(eurPrice, 50.0); // Should use amount_local as fallback
    });

    test('toPriceEur currencyLocal=GBP with currency=JPY uses amountLocal', () {
      final rate = ShippoRate(
        objectId: 'rate_1',
        provider: 'UPS',
        servicelevel: ShippoServiceLevel(name: 'Standard'),
        amount: '10000.00',
        currency: 'JPY', // Non-USD, non-EUR currency
        amountLocal: '85.00',
        currencyLocal: 'GBP',
      );

      final eurPrice = rate.toPriceEur(0.92);
      expect(eurPrice, 85.0); // Should use amount_local as fallback
    });

    test('toPriceEur invalid amount AND amountLocal strings return 0.0', () {
      final rate = ShippoRate(
        objectId: 'rate_1',
        provider: 'USPS',
        servicelevel: ShippoServiceLevel(name: 'Priority'),
        amount: 'invalid',
        currency: 'USD',
        amountLocal: 'also_invalid',
        currencyLocal: 'GBP',
      );

      final eurPrice = rate.toPriceEur(0.92);
      expect(eurPrice, 0.0);
    });

    test('toPriceEur negative amounts handled gracefully', () {
      final rate = ShippoRate(
        objectId: 'rate_1',
        provider: 'USPS',
        servicelevel: ShippoServiceLevel(name: 'Priority'),
        amount: '-50.00',
        currency: 'USD',
      );

      final eurPrice = rate.toPriceEur(0.92);
      expect(eurPrice, -46.0); // -50 * 0.92
    });

    test('toPriceEur zero amounts return 0.0', () {
      final rate = ShippoRate(
        objectId: 'rate_1',
        provider: 'USPS',
        servicelevel: ShippoServiceLevel(name: 'Priority'),
        amount: '0.00',
        currency: 'USD',
      );

      final eurPrice = rate.toPriceEur(0.92);
      expect(eurPrice, 0.0);
    });

    test('toPriceEur missing both amount and amountLocal returns 0.0', () {
      final rate = ShippoRate(
        objectId: 'rate_1',
        provider: 'USPS',
        servicelevel: ShippoServiceLevel(name: 'Priority'),
        amount: '',
        currency: 'USD',
        amountLocal: null,
      );

      final eurPrice = rate.toPriceEur(0.92);
      expect(eurPrice, 0.0);
    });

    test(
      'toPriceEur priority chain: currencyLocal=EUR > currency=EUR > currency=USD > amountLocal',
      () {
        // Test Priority 1: currencyLocal=EUR
        final rate1 = ShippoRate(
          objectId: 'rate_1',
          provider: 'UPS',
          servicelevel: ShippoServiceLevel(name: 'Standard'),
          amount: '100.00',
          currency: 'USD',
          amountLocal: '85.00',
          currencyLocal: 'EUR',
        );
        expect(rate1.toPriceEur(0.92), 85.0);

        // Test Priority 2: currency=EUR
        final rate2 = ShippoRate(
          objectId: 'rate_2',
          provider: 'DHL',
          servicelevel: ShippoServiceLevel(name: 'Express'),
          amount: '90.00',
          currency: 'EUR',
        );
        expect(rate2.toPriceEur(0.92), 90.0);

        // Test Priority 3: currency=USD
        final rate3 = ShippoRate(
          objectId: 'rate_3',
          provider: 'USPS',
          servicelevel: ShippoServiceLevel(name: 'Priority'),
          amount: '100.00',
          currency: 'USD',
        );
        expect(rate3.toPriceEur(0.92), 92.0);

        // Test Priority 4: amountLocal fallback
        final rate4 = ShippoRate(
          objectId: 'rate_4',
          provider: 'UPS',
          servicelevel: ShippoServiceLevel(name: 'Standard'),
          amount: '10000.00',
          currency: 'JPY',
          amountLocal: '75.00',
        );
        expect(rate4.toPriceEur(0.92), 75.0);
      },
    );

    test('toPriceEur CNY currency uses amountLocal if available', () {
      final rate = ShippoRate(
        objectId: 'rate_1',
        provider: 'UPS',
        servicelevel: ShippoServiceLevel(name: 'Standard'),
        amount: '700.00',
        currency: 'CNY',
        amountLocal: '85.00',
      );

      final eurPrice = rate.toPriceEur(0.92);
      expect(eurPrice, 85.0); // Should use amount_local
    });

    test('toPriceEur JPY currency uses amountLocal if available', () {
      final rate = ShippoRate(
        objectId: 'rate_1',
        provider: 'UPS',
        servicelevel: ShippoServiceLevel(name: 'Standard'),
        amount: '12000.00',
        currency: 'JPY',
        amountLocal: '90.00',
      );

      final eurPrice = rate.toPriceEur(0.92);
      expect(eurPrice, 90.0); // Should use amount_local
    });

    test('toPriceEur empty string amounts return 0.0', () {
      final rate = ShippoRate(
        objectId: 'rate_1',
        provider: 'USPS',
        servicelevel: ShippoServiceLevel(name: 'Priority'),
        amount: '',
        currency: 'USD',
      );

      final eurPrice = rate.toPriceEur(0.92);
      expect(eurPrice, 0.0);
    });
  });

  group('ShippoShipmentResponse', () {
    test('fromJson handles complete data', () {
      final json = {
        'object_id': 'shipment_123',
        'object_state': 'VALID',
        'status': 'SUCCESS',
        'rates': [
          {
            'object_id': 'rate_1',
            'provider': 'USPS',
            'servicelevel': {'name': 'Priority', 'token': 'usps_priority'},
            'amount': '25.50',
            'currency': 'USD',
          },
          {
            'object_id': 'rate_2',
            'provider': 'FedEx',
            'servicelevel': {'name': 'Ground', 'token': 'fedex_ground'},
            'amount': '30.00',
            'currency': 'USD',
          },
        ],
      };

      final response = ShippoShipmentResponse.fromJson(json);
      expect(response.objectId, 'shipment_123');
      expect(response.objectState, 'VALID');
      expect(response.status, 'SUCCESS');
      expect(response.rates, hasLength(2));
      expect(response.rates[0].provider, 'USPS');
      expect(response.rates[1].provider, 'FedEx');
    });

    test('fromJson handles empty rates array', () {
      final json = {
        'object_id': 'shipment_456',
        'object_state': 'VALID',
        'rates': <dynamic>[],
      };

      final response = ShippoShipmentResponse.fromJson(json);
      expect(response.rates, isEmpty);
    });

    test('fromJson handles missing rates with fallback to empty list', () {
      final json = {'object_id': 'shipment_789', 'object_state': 'VALID'};

      final response = ShippoShipmentResponse.fromJson(json);
      expect(response.rates, isEmpty);
    });

    test('fromJson handles missing object_id with fallback', () {
      final json = <String, dynamic>{
        'object_state': 'VALID',
        'rates': <dynamic>[],
      };

      final response = ShippoShipmentResponse.fromJson(json);
      expect(response.objectId, '');
    });

    test('fromJson handles missing object_state with fallback', () {
      final json = {'object_id': 'shipment_123', 'rates': <dynamic>[]};

      final response = ShippoShipmentResponse.fromJson(json);
      expect(response.objectState, 'UNKNOWN');
    });

    test('fromJson handles missing status as null', () {
      final json = {
        'object_id': 'shipment_123',
        'object_state': 'VALID',
        'rates': <dynamic>[],
      };

      final response = ShippoShipmentResponse.fromJson(json);
      expect(response.status, null);
    });
  });

  group('ShippoError', () {
    test('fromJson uses message field', () {
      final json = {
        'message': 'Invalid address format',
        'code': 'INVALID_ADDRESS',
      };

      final error = ShippoError.fromJson(json);
      expect(error.message, 'Invalid address format');
      expect(error.code, 'INVALID_ADDRESS');
    });

    test('fromJson falls back to detail field when message missing', () {
      final json = {'detail': 'Detailed error description', 'code': 'ERR_456'};

      final error = ShippoError.fromJson(json);
      expect(error.message, 'Detailed error description');
      expect(error.code, 'ERR_456');
    });

    test(
      'fromJson uses default message when both message and detail missing',
      () {
        final json = {'code': 'ERR_789'};

        final error = ShippoError.fromJson(json);
        expect(error.message, 'Unknown error');
        expect(error.code, 'ERR_789');
      },
    );

    test('fromJson handles missing code as null', () {
      final json = {'message': 'Some error occurred'};

      final error = ShippoError.fromJson(json);
      expect(error.message, 'Some error occurred');
      expect(error.code, null);
    });

    test('fromJson handles completely empty JSON', () {
      final json = <String, dynamic>{};

      final error = ShippoError.fromJson(json);
      expect(error.message, 'Unknown error');
      expect(error.code, null);
    });

    test('toString includes code when present', () {
      final error = ShippoError(message: 'Error occurred', code: 'ERR_123');

      expect(error.toString(), 'ERR_123: Error occurred');
    });

    test('toString excludes code when null', () {
      final error = ShippoError(message: 'Error occurred');

      expect(error.toString(), 'Error occurred');
    });

    test('toString handles empty code string', () {
      final error = ShippoError(message: 'Error occurred', code: '');

      // Empty string is still truthy, so it will be included
      expect(error.toString(), ': Error occurred');
    });
  });
}
