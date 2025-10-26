import 'package:bockaire/models/shippo_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShippoCustomsItem', () {
    test('toJson() includes all required fields', () {
      final item = ShippoCustomsItem(
        description: 'Electronics',
        quantity: 2,
        netWeight: '10.50',
        massUnit: 'kg',
        valueAmount: '500.00',
        valueCurrency: 'USD',
        originCountry: 'CN',
        tariffNumber: '8517.12.00',
      );

      final json = item.toJson();

      expect(json['description'], 'Electronics');
      expect(json['quantity'], 2);
      expect(json['net_weight'], '10.50');
      expect(json['mass_unit'], 'kg');
      expect(json['value_amount'], '500.00');
      expect(json['value_currency'], 'USD');
      expect(json['origin_country'], 'CN');
      expect(json['tariff_number'], '8517.12.00');
    });

    test('toJson() omits null tariffNumber', () {
      final item = ShippoCustomsItem(
        description: 'General Merchandise',
        quantity: 1,
        netWeight: '5.00',
        valueAmount: '100.00',
        originCountry: 'US',
        tariffNumber: null, // Null tariff number
      );

      final json = item.toJson();

      expect(json.containsKey('tariff_number'), isFalse);
      expect(json['description'], 'General Merchandise');
      expect(json['quantity'], 1);
    });

    test('Numeric values formatted as strings', () {
      final item = ShippoCustomsItem(
        description: 'Test Item',
        quantity: 3,
        netWeight: '15.75',
        valueAmount: '1234.56',
        originCountry: 'DE',
      );

      final json = item.toJson();

      // Ensure weight and value are strings
      expect(json['net_weight'], isA<String>());
      expect(json['value_amount'], isA<String>());
      expect(json['net_weight'], '15.75');
      expect(json['value_amount'], '1234.56');
    });

    test('Currency defaults to USD', () {
      final item = ShippoCustomsItem(
        description: 'Test Item',
        quantity: 1,
        netWeight: '5.00',
        valueAmount: '100.00',
        originCountry: 'US',
      );

      final json = item.toJson();

      expect(json['value_currency'], 'USD');
    });

    test('Mass unit defaults to kg', () {
      final item = ShippoCustomsItem(
        description: 'Test Item',
        quantity: 1,
        netWeight: '5.00',
        valueAmount: '100.00',
        originCountry: 'US',
      );

      final json = item.toJson();

      expect(json['mass_unit'], 'kg');
    });
  });

  group('ShippoCustomsDeclaration', () {
    test('toJson() serializes all fields correctly', () {
      final declaration = ShippoCustomsDeclaration(
        contentsType: 'MERCHANDISE',
        contentsExplanation: 'Electronics and clothing',
        nonDeliveryOption: 'RETURN',
        certify: true,
        certifySigner: 'John Doe',
        items: [
          ShippoCustomsItem(
            description: 'Laptop',
            quantity: 1,
            netWeight: '2.50',
            valueAmount: '1000.00',
            originCountry: 'US',
            tariffNumber: '8517.12.00',
          ),
        ],
      );

      final json = declaration.toJson();

      expect(json['contents_type'], 'MERCHANDISE');
      expect(json['contents_explanation'], 'Electronics and clothing');
      expect(json['non_delivery_option'], 'RETURN');
      expect(json['certify'], true);
      expect(json['certify_signer'], 'John Doe');
      expect(json['items'], isA<List>());
      expect(json['items'], hasLength(1));
    });

    test('Items array mapped to JSON array', () {
      final declaration = ShippoCustomsDeclaration(
        contentsType: 'MERCHANDISE',
        contentsExplanation: 'Multiple items',
        certifySigner: 'Test User',
        items: [
          ShippoCustomsItem(
            description: 'Item 1',
            quantity: 2,
            netWeight: '5.00',
            valueAmount: '200.00',
            originCountry: 'CN',
          ),
          ShippoCustomsItem(
            description: 'Item 2',
            quantity: 3,
            netWeight: '7.50',
            valueAmount: '300.00',
            originCountry: 'CN',
          ),
        ],
      );

      final json = declaration.toJson();
      final items = json['items'] as List;

      expect(items, hasLength(2));
      expect(items[0]['description'], 'Item 1');
      expect(items[0]['quantity'], 2);
      expect(items[1]['description'], 'Item 2');
      expect(items[1]['quantity'], 3);
    });

    test('Empty items list handled', () {
      final declaration = ShippoCustomsDeclaration(
        contentsType: 'DOCUMENTS',
        contentsExplanation: 'Business documents',
        certifySigner: 'Test User',
        items: [], // Empty items list
      );

      final json = declaration.toJson();

      expect(json['items'], isA<List>());
      expect(json['items'], isEmpty);
    });

    test('nonDeliveryOption defaults to "RETURN"', () {
      final declaration = ShippoCustomsDeclaration(
        contentsType: 'MERCHANDISE',
        contentsExplanation: 'Test',
        certifySigner: 'Test User',
        items: [],
      );

      final json = declaration.toJson();

      expect(json['non_delivery_option'], 'RETURN');
    });

    test('certify defaults to true', () {
      final declaration = ShippoCustomsDeclaration(
        contentsType: 'MERCHANDISE',
        contentsExplanation: 'Test',
        certifySigner: 'Test User',
        items: [],
      );

      final json = declaration.toJson();

      expect(json['certify'], true);
    });

    test('certifySigner field included', () {
      final declaration = ShippoCustomsDeclaration(
        contentsType: 'MERCHANDISE',
        contentsExplanation: 'Test',
        certifySigner: 'Alice Smith',
        items: [],
      );

      final json = declaration.toJson();

      expect(json['certify_signer'], 'Alice Smith');
    });

    test('contentsType field included', () {
      final declaration = ShippoCustomsDeclaration(
        contentsType: 'GIFT',
        contentsExplanation: 'Birthday present',
        certifySigner: 'Test User',
        items: [],
      );

      final json = declaration.toJson();

      expect(json['contents_type'], 'GIFT');
    });
  });

  group('ShippoShipmentRequest with customs', () {
    test('customsDeclaration included when provided', () {
      final request = ShippoShipmentRequest(
        addressFrom: ShippoAddress(
          name: 'Sender',
          street1: 'Street 1',
          city: 'Shanghai',
          state: '',
          zip: '200000',
          country: 'CN',
        ),
        addressTo: ShippoAddress(
          name: 'Recipient',
          street1: 'Street 1',
          city: 'Berlin',
          state: '',
          zip: '10115',
          country: 'DE',
        ),
        parcels: [
          ShippoParcel(length: '40', width: '30', height: '20', weight: '5.50'),
        ],
        customsDeclaration: ShippoCustomsDeclaration(
          contentsType: 'MERCHANDISE',
          contentsExplanation: 'Electronics',
          certifySigner: 'Test User',
          items: [
            ShippoCustomsItem(
              description: 'Laptop',
              quantity: 1,
              netWeight: '5.50',
              valueAmount: '1000.00',
              originCountry: 'CN',
            ),
          ],
        ),
      );

      final json = request.toJson();

      expect(json.containsKey('customs_declaration'), isTrue);
      expect(json['customs_declaration'], isNotNull);
      expect(json['customs_declaration'], isA<Map<String, dynamic>>());
    });

    test('customsDeclaration omitted when null', () {
      final request = ShippoShipmentRequest(
        addressFrom: ShippoAddress(
          name: 'Sender',
          street1: 'Street 1',
          city: 'New York',
          state: 'NY',
          zip: '10001',
          country: 'US',
        ),
        addressTo: ShippoAddress(
          name: 'Recipient',
          street1: 'Street 1',
          city: 'Los Angeles',
          state: 'CA',
          zip: '90001',
          country: 'US',
        ),
        parcels: [
          ShippoParcel(length: '40', width: '30', height: '20', weight: '5.50'),
        ],
        customsDeclaration: null, // No customs for domestic
      );

      final json = request.toJson();

      expect(json.containsKey('customs_declaration'), isFalse);
    });

    test('JSON structure matches Shippo API spec', () {
      final request = ShippoShipmentRequest(
        addressFrom: ShippoAddress(
          name: 'Sender Name',
          street1: 'Origin Street',
          city: 'Shanghai',
          state: '',
          zip: '200000',
          country: 'CN',
        ),
        addressTo: ShippoAddress(
          name: 'Recipient Name',
          street1: 'Dest Street',
          city: 'Berlin',
          state: '',
          zip: '10115',
          country: 'DE',
        ),
        parcels: [
          ShippoParcel(
            length: '40',
            width: '30',
            height: '20',
            weight: '5.50',
            distanceUnit: 'cm',
            massUnit: 'kg',
          ),
        ],
        async: false,
        customsDeclaration: ShippoCustomsDeclaration(
          contentsType: 'MERCHANDISE',
          contentsExplanation: 'Electronics',
          nonDeliveryOption: 'RETURN',
          certify: true,
          certifySigner: 'John Doe',
          items: [
            ShippoCustomsItem(
              description: 'Laptop',
              quantity: 1,
              netWeight: '5.50',
              massUnit: 'kg',
              valueAmount: '1000.00',
              valueCurrency: 'USD',
              originCountry: 'CN',
              tariffNumber: '8517.12.00',
            ),
          ],
        ),
      );

      final json = request.toJson();

      // Verify top-level structure
      expect(json.containsKey('address_from'), isTrue);
      expect(json.containsKey('address_to'), isTrue);
      expect(json.containsKey('parcels'), isTrue);
      expect(json.containsKey('async'), isTrue);
      expect(json.containsKey('customs_declaration'), isTrue);

      // Verify customs declaration structure
      final customs = json['customs_declaration'] as Map<String, dynamic>;
      expect(customs.containsKey('contents_type'), isTrue);
      expect(customs.containsKey('contents_explanation'), isTrue);
      expect(customs.containsKey('non_delivery_option'), isTrue);
      expect(customs.containsKey('certify'), isTrue);
      expect(customs.containsKey('certify_signer'), isTrue);
      expect(customs.containsKey('items'), isTrue);

      // Verify items structure
      final items = customs['items'] as List;
      expect(items, hasLength(1));
      final item = items[0] as Map<String, dynamic>;
      expect(item.containsKey('description'), isTrue);
      expect(item.containsKey('quantity'), isTrue);
      expect(item.containsKey('net_weight'), isTrue);
      expect(item.containsKey('mass_unit'), isTrue);
      expect(item.containsKey('value_amount'), isTrue);
      expect(item.containsKey('value_currency'), isTrue);
      expect(item.containsKey('origin_country'), isTrue);
      expect(item.containsKey('tariff_number'), isTrue);
    });
  });
}
