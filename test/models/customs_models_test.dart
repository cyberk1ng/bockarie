import 'package:bockaire/models/customs_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommodityLine', () {
    const testCommodity = CommodityLine(
      description: 'Electronic Goods',
      quantity: 2.5,
      netWeight: 5.50,
      valueAmount: 10.99,
      originCountry: 'CN',
      hsCode: '8517.12.00',
      skuCode: 'SKU-123',
    );

    group('Money Calculations', () {
      test('totalValue calculates correctly', () {
        const item = CommodityLine(
          description: 'Test',
          quantity: 2.5,
          netWeight: 1.0,
          valueAmount: 10.00,
          originCountry: 'CN',
          hsCode: '1234.56',
        );

        expect(item.totalValue, 25.00);
      });

      test('large values do not overflow', () {
        const item = CommodityLine(
          description: 'Test',
          quantity: 10000,
          netWeight: 1.0,
          valueAmount: 9999.99,
          originCountry: 'CN',
          hsCode: '1234.56',
        );

        expect(item.totalValue, 99999900.00);
      });

      test('totalWeight calculates correctly', () {
        const item = CommodityLine(
          description: 'Test',
          quantity: 3,
          netWeight: 2.5,
          valueAmount: 10.00,
          originCountry: 'CN',
          hsCode: '1234.56',
        );

        expect(item.totalWeight, 7.5);
      });
    });

    group('JSON Serialization', () {
      test('toJson converts all fields correctly', () {
        final json = testCommodity.toJson();

        expect(json['description'], 'Electronic Goods');
        expect(json['quantity'], 2.5);
        expect(json['net_weight'], '5.50');
        expect(json['value_amount'], '10.99');
        expect(json['value_currency'], 'USD');
        expect(json['origin_country'], 'CN');
        expect(json['tariff_number'], '8517.12.00');
        expect(json['sku_code'], 'SKU-123');
        expect(json['mass_unit'], 'kg');
      });

      test('toJson formats decimals to 2 places', () {
        const item = CommodityLine(
          description: 'Test',
          quantity: 1,
          netWeight: 5.5,
          valueAmount: 10.9,
          originCountry: 'CN',
          hsCode: '1234.56',
        );

        final json = item.toJson();
        expect(json['net_weight'], '5.50');
        expect(json['value_amount'], '10.90');
      });

      test('toJson omits null skuCode', () {
        const item = CommodityLine(
          description: 'Test',
          quantity: 1,
          netWeight: 5.5,
          valueAmount: 10.9,
          originCountry: 'CN',
          hsCode: '1234.56',
        );

        final json = item.toJson();
        expect(json.containsKey('sku_code'), false);
      });

      test('fromJson parses strings to double', () {
        final json = {
          'description': 'Test',
          'quantity': 1,
          'net_weight': '5.50',
          'value_amount': '10.99',
          'origin_country': 'CN',
          'tariff_number': '1234.56',
        };

        final item = CommodityLine.fromJson(json);
        expect(item.netWeight, 5.50);
        expect(item.valueAmount, 10.99);
      });

      test('fromJson handles numeric types', () {
        final json = {
          'description': 'Test',
          'quantity': 2,
          'net_weight': '5.50',
          'value_amount': '10.99',
          'origin_country': 'CN',
          'tariff_number': '1234.56',
        };

        final item = CommodityLine.fromJson(json);
        expect(item.quantity, 2.0);
      });
    });

    group('copyWith', () {
      test('no params returns identical copy', () {
        final copy = testCommodity.copyWith();

        expect(copy, equals(testCommodity));
        expect(copy.description, testCommodity.description);
        expect(copy.quantity, testCommodity.quantity);
        expect(copy.skuCode, testCommodity.skuCode);
      });

      test('partial update preserves other fields', () {
        final copy = testCommodity.copyWith(quantity: 5.0, valueAmount: 20.0);

        expect(copy.quantity, 5.0);
        expect(copy.valueAmount, 20.0);
        expect(copy.description, testCommodity.description);
        expect(copy.netWeight, testCommodity.netWeight);
        expect(copy.skuCode, testCommodity.skuCode);
      });

      test('can update skuCode', () {
        final copy = testCommodity.copyWith(skuCode: 'NEW-SKU');
        expect(copy.skuCode, 'NEW-SKU');
      });
    });

    group('Equatable', () {
      test('two identical CommodityLines are equal', () {
        const item1 = CommodityLine(
          description: 'Test',
          quantity: 1,
          netWeight: 1.0,
          valueAmount: 10.0,
          originCountry: 'CN',
          hsCode: '1234.56',
        );

        const item2 = CommodityLine(
          description: 'Test',
          quantity: 1,
          netWeight: 1.0,
          valueAmount: 10.0,
          originCountry: 'CN',
          hsCode: '1234.56',
        );

        expect(item1, equals(item2));
      });

      test('different CommodityLines are not equal', () {
        const item1 = CommodityLine(
          description: 'Test 1',
          quantity: 1,
          netWeight: 1.0,
          valueAmount: 10.0,
          originCountry: 'CN',
          hsCode: '1234.56',
        );

        const item2 = CommodityLine(
          description: 'Test 2',
          quantity: 1,
          netWeight: 1.0,
          valueAmount: 10.0,
          originCountry: 'CN',
          hsCode: '1234.56',
        );

        expect(item1, isNot(equals(item2)));
      });

      test('hashCode matches for equal objects', () {
        const item1 = CommodityLine(
          description: 'Test',
          quantity: 1,
          netWeight: 1.0,
          valueAmount: 10.0,
          originCountry: 'CN',
          hsCode: '1234.56',
        );

        const item2 = CommodityLine(
          description: 'Test',
          quantity: 1,
          netWeight: 1.0,
          valueAmount: 10.0,
          originCountry: 'CN',
          hsCode: '1234.56',
        );

        expect(item1.hashCode, equals(item2.hashCode));
      });
    });
  });

  group('CustomsProfile', () {
    final testProfile = CustomsProfile(
      id: 'profile_123',
      name: 'My Business',
      importerType: ImporterType.business,
      vatNumber: 'DE123456789',
      eoriNumber: 'GB123456789000',
      taxId: '12-3456789',
      companyName: 'Test Company GmbH',
      contactName: 'John Doe',
      contactPhone: '+491234567890',
      contactEmail: 'john@test.com',
      defaultIncoterms: Incoterms.dap,
      createdAt: DateTime(2025, 1, 1, 12, 0, 0),
      updatedAt: DateTime(2025, 1, 2, 12, 0, 0),
    );

    group('JSON Serialization', () {
      test('toJson converts all fields correctly', () {
        final json = testProfile.toJson();

        expect(json['id'], 'profile_123');
        expect(json['name'], 'My Business');
        expect(json['importer_type'], 'business');
        expect(json['vat_number'], 'DE123456789');
        expect(json['eori_number'], 'GB123456789000');
        expect(json['tax_id'], '12-3456789');
        expect(json['company_name'], 'Test Company GmbH');
        expect(json['contact_name'], 'John Doe');
        expect(json['contact_phone'], '+491234567890');
        expect(json['contact_email'], 'john@test.com');
        expect(json['default_incoterms'], 'dap');
        expect(json['created_at'], '2025-01-01T12:00:00.000');
        expect(json['updated_at'], '2025-01-02T12:00:00.000');
      });

      test('fromJson parses all fields correctly', () {
        final json = {
          'id': 'profile_123',
          'name': 'My Business',
          'importer_type': 'business',
          'vat_number': 'DE123456789',
          'eori_number': 'GB123456789000',
          'tax_id': '12-3456789',
          'company_name': 'Test Company',
          'contact_name': 'John Doe',
          'contact_phone': '+491234567890',
          'contact_email': 'john@test.com',
          'default_incoterms': 'dap',
          'created_at': '2025-01-01T12:00:00.000',
          'updated_at': '2025-01-02T12:00:00.000',
        };

        final profile = CustomsProfile.fromJson(json);

        expect(profile.id, 'profile_123');
        expect(profile.name, 'My Business');
        expect(profile.importerType, ImporterType.business);
        expect(profile.defaultIncoterms, Incoterms.dap);
      });

      test('fromJson defaults invalid importerType', () {
        final json = {
          'id': 'profile_123',
          'name': 'Test',
          'importer_type': 'invalid',
          'default_incoterms': 'dap',
          'created_at': '2025-01-01T12:00:00.000',
          'updated_at': '2025-01-02T12:00:00.000',
        };

        final profile = CustomsProfile.fromJson(json);
        expect(profile.importerType, ImporterType.individual);
      });

      test('fromJson defaults invalid incoterms', () {
        final json = {
          'id': 'profile_123',
          'name': 'Test',
          'importer_type': 'individual',
          'default_incoterms': 'INVALID',
          'created_at': '2025-01-01T12:00:00.000',
          'updated_at': '2025-01-02T12:00:00.000',
        };

        final profile = CustomsProfile.fromJson(json);
        expect(profile.defaultIncoterms, Incoterms.dap);
      });

      test('fromJson parses ISO8601 dates', () {
        final json = {
          'id': 'profile_123',
          'name': 'Test',
          'importer_type': 'individual',
          'default_incoterms': 'dap',
          'created_at': '2025-10-23T12:00:00Z',
          'updated_at': '2025-10-23T14:30:00Z',
        };

        final profile = CustomsProfile.fromJson(json);
        expect(profile.createdAt, DateTime.utc(2025, 10, 23, 12, 0, 0));
        expect(profile.updatedAt, DateTime.utc(2025, 10, 23, 14, 30, 0));
      });
    });

    group('copyWith', () {
      test('updates single field', () {
        final copy = testProfile.copyWith(name: 'Updated Name');

        expect(copy.name, 'Updated Name');
        expect(copy.id, testProfile.id);
        expect(copy.importerType, testProfile.importerType);
      });

      test('updates multiple fields', () {
        final copy = testProfile.copyWith(
          name: 'New Name',
          contactEmail: 'new@test.com',
          defaultIncoterms: Incoterms.ddp,
        );

        expect(copy.name, 'New Name');
        expect(copy.contactEmail, 'new@test.com');
        expect(copy.defaultIncoterms, Incoterms.ddp);
      });
    });

    group('Equatable', () {
      test('two identical profiles are equal', () {
        final profile1 = CustomsProfile(
          id: 'id_123',
          name: 'Test',
          importerType: ImporterType.individual,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        );

        final profile2 = CustomsProfile(
          id: 'id_123',
          name: 'Test',
          importerType: ImporterType.individual,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        );

        expect(profile1, equals(profile2));
      });

      test('different profiles are not equal', () {
        final profile1 = CustomsProfile(
          id: 'id_123',
          name: 'Test 1',
          importerType: ImporterType.individual,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        );

        final profile2 = CustomsProfile(
          id: 'id_123',
          name: 'Test 2',
          importerType: ImporterType.individual,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        );

        expect(profile1, isNot(equals(profile2)));
      });
    });
  });

  group('CustomsPacket', () {
    final testPacket = CustomsPacket(
      id: 'packet_123',
      shipmentId: 'shipment_123',
      items: const [
        CommodityLine(
          description: 'Item 1',
          quantity: 2,
          netWeight: 1.0,
          valueAmount: 10.0,
          originCountry: 'CN',
          hsCode: '1234.56',
        ),
        CommodityLine(
          description: 'Item 2',
          quantity: 1,
          netWeight: 2.0,
          valueAmount: 20.0,
          originCountry: 'CN',
          hsCode: '7890.12',
        ),
        CommodityLine(
          description: 'Item 3',
          quantity: 3,
          netWeight: 0.5,
          valueAmount: 30.0,
          originCountry: 'CN',
          hsCode: '5678.90',
        ),
      ],
      incoterms: Incoterms.dap,
      contentsType: ContentsType.merchandise,
      certify: true,
      createdAt: DateTime(2025, 1, 1),
    );

    group('Total Value Calculations', () {
      test('sums multiple commodity lines', () {
        // 2*10 + 1*20 + 3*30 = 20 + 20 + 90 = 130
        expect(testPacket.totalValue, 130.0);
      });

      test('empty items returns zero', () {
        final emptyPacket = CustomsPacket(
          id: 'packet_123',
          shipmentId: 'shipment_123',
          items: const [],
          certify: true,
          createdAt: DateTime(2025, 1, 1),
        );

        expect(emptyPacket.totalValue, 0.0);
      });

      test('single item calculates correctly', () {
        final singlePacket = CustomsPacket(
          id: 'packet_123',
          shipmentId: 'shipment_123',
          items: const [
            CommodityLine(
              description: 'Item',
              quantity: 5,
              netWeight: 1.0,
              valueAmount: 7.50,
              originCountry: 'CN',
              hsCode: '1234.56',
            ),
          ],
          certify: true,
          createdAt: DateTime(2025, 1, 1),
        );

        expect(singlePacket.totalValue, 37.50);
      });
    });

    group('Total Weight Calculations', () {
      test('sums multiple commodity lines', () {
        // 2*1.0 + 1*2.0 + 3*0.5 = 2 + 2 + 1.5 = 5.5
        expect(testPacket.totalWeight, 5.5);
      });

      test('empty items returns zero', () {
        final emptyPacket = CustomsPacket(
          id: 'packet_123',
          shipmentId: 'shipment_123',
          items: const [],
          certify: true,
          createdAt: DateTime(2025, 1, 1),
        );

        expect(emptyPacket.totalWeight, 0.0);
      });
    });

    group('JSON Serialization', () {
      test('toJson serializes nested profile', () {
        final profile = CustomsProfile(
          id: 'profile_123',
          name: 'Test',
          importerType: ImporterType.business,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        );

        final packet = CustomsPacket(
          id: 'packet_123',
          shipmentId: 'shipment_123',
          profile: profile,
          items: const [],
          certify: true,
          createdAt: DateTime(2025, 1, 1),
        );

        final json = packet.toJson();
        expect(json['profile'], isNotNull);
        expect(json['profile']['id'], 'profile_123');
      });

      test('toJson handles null profile', () {
        final packet = CustomsPacket(
          id: 'packet_123',
          shipmentId: 'shipment_123',
          items: const [],
          certify: true,
          createdAt: DateTime(2025, 1, 1),
        );

        final json = packet.toJson();
        expect(json['profile'], isNull);
      });

      test('fromJson maps items array', () {
        final json = {
          'id': 'packet_123',
          'shipment_id': 'shipment_123',
          'items': [
            {
              'description': 'Item 1',
              'quantity': 1,
              'net_weight': '1.0',
              'value_amount': '10.0',
              'origin_country': 'CN',
              'tariff_number': '1234.56',
            },
            {
              'description': 'Item 2',
              'quantity': 2,
              'net_weight': '2.0',
              'value_amount': '20.0',
              'origin_country': 'CN',
              'tariff_number': '7890.12',
            },
            {
              'description': 'Item 3',
              'quantity': 3,
              'net_weight': '3.0',
              'value_amount': '30.0',
              'origin_country': 'CN',
              'tariff_number': '5678.90',
            },
          ],
          'incoterms': 'DAP',
          'contents_type': 'merchandise',
          'certify': true,
          'created_at': '2025-01-01T12:00:00.000',
        };

        final packet = CustomsPacket.fromJson(json);
        expect(packet.items.length, 3);
        expect(packet.items[0].description, 'Item 1');
        expect(packet.items[1].description, 'Item 2');
        expect(packet.items[2].description, 'Item 3');
      });

      test('fromJson handles case-insensitive incoterms', () {
        final testCases = ['dap', 'DAP', 'DaP', 'dAp'];

        for (final incotermCase in testCases) {
          final json = {
            'id': 'packet_123',
            'shipment_id': 'shipment_123',
            'items': [],
            'incoterms': incotermCase,
            'contents_type': 'merchandise',
            'certify': true,
            'created_at': '2025-01-01T12:00:00.000',
          };

          final packet = CustomsPacket.fromJson(json);
          expect(
            packet.incoterms,
            Incoterms.dap,
            reason: 'Failed for case: $incotermCase',
          );
        }
      });

      test('toJson converts incoterms to uppercase', () {
        final packet = CustomsPacket(
          id: 'packet_123',
          shipmentId: 'shipment_123',
          items: const [],
          incoterms: Incoterms.dap,
          certify: true,
          createdAt: DateTime(2025, 1, 1),
        );

        final json = packet.toJson();
        expect(json['incoterms'], 'DAP');
      });
    });

    group('copyWith', () {
      test('updates items list', () {
        const newItems = [
          CommodityLine(
            description: 'New Item',
            quantity: 1,
            netWeight: 1.0,
            valueAmount: 5.0,
            originCountry: 'US',
            hsCode: '0000.00',
          ),
        ];

        final copy = testPacket.copyWith(items: newItems);

        expect(copy.items.length, 1);
        expect(copy.items[0].description, 'New Item');
        expect(copy.id, testPacket.id);
      });

      test('updates profile', () {
        final newProfile = CustomsProfile(
          id: 'new_profile',
          name: 'New Profile',
          importerType: ImporterType.individual,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        );

        final copy = testPacket.copyWith(profile: newProfile);

        expect(copy.profile?.id, 'new_profile');
        expect(copy.items, testPacket.items);
      });

      test('updates multiple fields', () {
        final copy = testPacket.copyWith(
          incoterms: Incoterms.ddp,
          contentsType: ContentsType.gift,
          invoiceNumber: 'INV-123',
        );

        expect(copy.incoterms, Incoterms.ddp);
        expect(copy.contentsType, ContentsType.gift);
        expect(copy.invoiceNumber, 'INV-123');
        expect(copy.id, testPacket.id);
      });
    });

    group('Equatable', () {
      test('two identical packets are equal', () {
        final packet1 = CustomsPacket(
          id: 'packet_123',
          shipmentId: 'shipment_123',
          items: const [],
          certify: true,
          createdAt: DateTime(2025, 1, 1),
        );

        final packet2 = CustomsPacket(
          id: 'packet_123',
          shipmentId: 'shipment_123',
          items: const [],
          certify: true,
          createdAt: DateTime(2025, 1, 1),
        );

        expect(packet1, equals(packet2));
      });

      test('different packets are not equal', () {
        final packet1 = CustomsPacket(
          id: 'packet_123',
          shipmentId: 'shipment_123',
          items: const [],
          certify: true,
          createdAt: DateTime(2025, 1, 1),
        );

        final packet2 = CustomsPacket(
          id: 'packet_456',
          shipmentId: 'shipment_123',
          items: const [],
          certify: true,
          createdAt: DateTime(2025, 1, 1),
        );

        expect(packet1, isNot(equals(packet2)));
      });
    });
  });
}
