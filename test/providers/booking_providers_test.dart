import 'package:bockaire/providers/booking_providers.dart';
import 'package:bockaire/models/customs_models.dart' as models;
import 'package:bockaire/database/database.dart';
import 'package:bockaire/get_it.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    // Create in-memory database for testing
    db = AppDatabase.forTesting(NativeDatabase.memory());

    // Setup get_it for database access
    if (getIt.isRegistered<AppDatabase>()) {
      getIt.unregister<AppDatabase>();
    }
    getIt.registerSingleton<AppDatabase>(db);

    container = ProviderContainer();
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    if (getIt.isRegistered<AppDatabase>()) {
      getIt.unregister<AppDatabase>();
    }
  });

  group('saveCustomsProfile', () {
    test('INSERT: new profile is inserted', () async {
      final profile = models.CustomsProfile(
        id: 'profile_123',
        name: 'My Business',
        importerType: models.ImporterType.business,
        vatNumber: 'DE123456789',
        eoriNumber: 'GB123456789000',
        taxId: '12-3456789',
        companyName: 'Test Company GmbH',
        contactName: 'John Doe',
        contactPhone: '+491234567890',
        contactEmail: 'john@test.com',
        defaultIncoterms: models.Incoterms.dap,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      await saveCustomsProfile(profile);

      // Verify it was inserted
      final saved = await (db.select(
        db.customsProfiles,
      )..where((p) => p.id.equals('profile_123'))).getSingle();

      expect(saved.id, 'profile_123');
      expect(saved.name, 'My Business');
      expect(saved.importerType, 'business');
      expect(saved.vatNumber, 'DE123456789');
      expect(saved.eoriNumber, 'GB123456789000');
      expect(saved.taxId, '12-3456789');
      expect(saved.companyName, 'Test Company GmbH');
      expect(saved.contactName, 'John Doe');
      expect(saved.contactPhone, '+491234567890');
      expect(saved.contactEmail, 'john@test.com');
      expect(saved.defaultIncoterms, 'dap');
    });

    test('UPDATE: existing profile is updated', () async {
      // Insert initial profile
      final profile1 = models.CustomsProfile(
        id: 'profile_123',
        name: 'Original Name',
        importerType: models.ImporterType.individual,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      await saveCustomsProfile(profile1);

      // Update profile
      final profile2 = models.CustomsProfile(
        id: 'profile_123',
        name: 'Updated Name',
        importerType: models.ImporterType.business,
        companyName: 'New Company',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 2),
      );

      await saveCustomsProfile(profile2);

      // Verify it was updated, not duplicated
      final allProfiles = await db.select(db.customsProfiles).get();
      expect(allProfiles.length, 1);

      final saved = allProfiles.first;
      expect(saved.name, 'Updated Name');
      expect(saved.importerType, 'business');
      expect(saved.companyName, 'New Company');
    });

    test('handles all optional fields as null', () async {
      final profile = models.CustomsProfile(
        id: 'profile_123',
        name: 'Minimal Profile',
        importerType: models.ImporterType.individual,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      await saveCustomsProfile(profile);

      final saved = await (db.select(
        db.customsProfiles,
      )..where((p) => p.id.equals('profile_123'))).getSingle();

      expect(saved.vatNumber, null);
      expect(saved.eoriNumber, null);
      expect(saved.taxId, null);
      expect(saved.companyName, null);
      expect(saved.contactName, null);
      expect(saved.contactPhone, null);
      expect(saved.contactEmail, null);
    });
  });

  group('saveCustomsPacket', () {
    setUp(() async {
      // Create a test shipment for foreign key constraint
      await db
          .into(db.shipments)
          .insert(
            ShipmentsCompanion.insert(
              id: 'shipment_123',
              createdAt: DateTime(2025, 1, 1),
              originCity: 'Shanghai',
              originPostal: '200000',
              destCity: 'Berlin',
              destPostal: '10115',
            ),
          );
    });

    test('CASCADE DELETE: deletes old commodity lines', () async {
      // Create packet with 3 commodity lines
      final packet1 = models.CustomsPacket(
        id: 'packet_123',
        shipmentId: 'shipment_123',
        items: const [
          models.CommodityLine(
            description: 'Item 1',
            quantity: 1,
            netWeight: 1.0,
            valueAmount: 10.0,
            originCountry: 'CN',
            hsCode: '1234.56',
          ),
          models.CommodityLine(
            description: 'Item 2',
            quantity: 2,
            netWeight: 2.0,
            valueAmount: 20.0,
            originCountry: 'CN',
            hsCode: '7890.12',
          ),
          models.CommodityLine(
            description: 'Item 3',
            quantity: 3,
            netWeight: 3.0,
            valueAmount: 30.0,
            originCountry: 'CN',
            hsCode: '5678.90',
          ),
        ],
        certify: true,
        createdAt: DateTime(2025, 1, 1),
      );

      await saveCustomsPacket(packet1);

      // Verify 3 lines exist
      var lines = await (db.select(
        db.commodityLines,
      )..where((l) => l.customsPacketId.equals('packet_123'))).get();
      expect(lines.length, 3);

      // Update packet with 2 new lines
      final packet2 = models.CustomsPacket(
        id: 'packet_123',
        shipmentId: 'shipment_123',
        items: const [
          models.CommodityLine(
            description: 'New Item 1',
            quantity: 1,
            netWeight: 1.5,
            valueAmount: 15.0,
            originCountry: 'US',
            hsCode: '0000.00',
          ),
          models.CommodityLine(
            description: 'New Item 2',
            quantity: 2,
            netWeight: 2.5,
            valueAmount: 25.0,
            originCountry: 'US',
            hsCode: '1111.11',
          ),
        ],
        certify: true,
        createdAt: DateTime(2025, 1, 1),
      );

      await saveCustomsPacket(packet2);

      // Verify old lines deleted and new ones inserted
      lines = await (db.select(
        db.commodityLines,
      )..where((l) => l.customsPacketId.equals('packet_123'))).get();
      expect(lines.length, 2);
      expect(lines[0].description, 'New Item 1');
      expect(lines[1].description, 'New Item 2');
    });

    test('UUID: generates unique IDs for commodity lines', () async {
      final packet = models.CustomsPacket(
        id: 'packet_123',
        shipmentId: 'shipment_123',
        items: const [
          models.CommodityLine(
            description: 'Item 1',
            quantity: 1,
            netWeight: 1.0,
            valueAmount: 10.0,
            originCountry: 'CN',
            hsCode: '1234.56',
          ),
          models.CommodityLine(
            description: 'Item 2',
            quantity: 2,
            netWeight: 2.0,
            valueAmount: 20.0,
            originCountry: 'CN',
            hsCode: '7890.12',
          ),
          models.CommodityLine(
            description: 'Item 3',
            quantity: 3,
            netWeight: 3.0,
            valueAmount: 30.0,
            originCountry: 'CN',
            hsCode: '5678.90',
          ),
        ],
        certify: true,
        createdAt: DateTime(2025, 1, 1),
      );

      await saveCustomsPacket(packet);

      final lines = await (db.select(
        db.commodityLines,
      )..where((l) => l.customsPacketId.equals('packet_123'))).get();

      // All IDs should be unique
      final ids = lines.map((l) => l.id).toSet();
      expect(ids.length, 3);

      // IDs should be valid UUIDs (basic check)
      for (final id in ids) {
        expect(id.length, 36); // UUID v4 format
        expect(id.contains('-'), true);
      }
    });

    test('saves packet with profile reference', () async {
      // Create profile first
      final profile = models.CustomsProfile(
        id: 'profile_123',
        name: 'Test Profile',
        importerType: models.ImporterType.business,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      await saveCustomsProfile(profile);

      // Create packet with profile
      final packet = models.CustomsPacket(
        id: 'packet_123',
        shipmentId: 'shipment_123',
        profile: profile,
        items: const [],
        certify: true,
        createdAt: DateTime(2025, 1, 1),
      );

      await saveCustomsPacket(packet);

      final saved = await (db.select(
        db.customsPackets,
      )..where((p) => p.id.equals('packet_123'))).getSingle();

      expect(saved.profileId, 'profile_123');
    });

    test('saves packet without profile reference', () async {
      final packet = models.CustomsPacket(
        id: 'packet_123',
        shipmentId: 'shipment_123',
        items: const [],
        certify: true,
        createdAt: DateTime(2025, 1, 1),
      );

      await saveCustomsPacket(packet);

      final saved = await (db.select(
        db.customsPackets,
      )..where((p) => p.id.equals('packet_123'))).getSingle();

      expect(saved.profileId, null);
    });
  });

  group('customsProfiles provider', () {
    test('ASSEMBLY: loads all profiles', () async {
      // Insert test profiles
      await db
          .into(db.customsProfiles)
          .insert(
            CustomsProfilesCompanion.insert(
              id: 'profile_1',
              name: 'Profile 1',
              importerType: 'business',
              createdAt: DateTime(2025, 1, 1),
              updatedAt: DateTime(2025, 1, 1),
            ),
          );

      await db
          .into(db.customsProfiles)
          .insert(
            CustomsProfilesCompanion.insert(
              id: 'profile_2',
              name: 'Profile 2',
              importerType: 'individual',
              createdAt: DateTime(2025, 1, 2),
              updatedAt: DateTime(2025, 1, 2),
            ),
          );

      final profiles = await container.read(customsProfilesProvider.future);

      expect(profiles.length, 2);
      expect(profiles[0].id, 'profile_1');
      expect(profiles[0].name, 'Profile 1');
      expect(profiles[0].importerType, models.ImporterType.business);
      expect(profiles[1].id, 'profile_2');
      expect(profiles[1].name, 'Profile 2');
      expect(profiles[1].importerType, models.ImporterType.individual);
    });

    test('empty database returns empty list', () async {
      final profiles = await container.read(customsProfilesProvider.future);
      expect(profiles, isEmpty);
    });

    test('handles invalid importerType gracefully', () async {
      // Manually insert profile with invalid type
      await db.customsProfiles.insertOne(
        CustomsProfilesCompanion.insert(
          id: 'profile_123',
          name: 'Test',
          importerType: 'invalid_type',
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
      );

      final profiles = await container.read(customsProfilesProvider.future);

      expect(profiles.length, 1);
      expect(
        profiles[0].importerType,
        models.ImporterType.individual,
      ); // Default
    });

    test('handles invalid incoterms gracefully', () async {
      await db.customsProfiles.insertOne(
        CustomsProfilesCompanion.insert(
          id: 'profile_123',
          name: 'Test',
          importerType: 'business',
          defaultIncoterms: const Value('invalid_incoterm'),
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
      );

      final profiles = await container.read(customsProfilesProvider.future);

      expect(profiles.length, 1);
      expect(profiles[0].defaultIncoterms, models.Incoterms.dap); // Default
    });
  });

  group('customsPacket provider', () {
    setUp(() async {
      // Create test shipment
      await db
          .into(db.shipments)
          .insert(
            ShipmentsCompanion.insert(
              id: 'shipment_123',
              createdAt: DateTime(2025, 1, 1),
              originCity: 'Shanghai',
              originPostal: '200000',
              destCity: 'Berlin',
              destPostal: '10115',
            ),
          );

      // Create test profile
      await db
          .into(db.customsProfiles)
          .insert(
            CustomsProfilesCompanion.insert(
              id: 'profile_123',
              name: 'Test Profile',
              importerType: 'business',
              createdAt: DateTime(2025, 1, 1),
              updatedAt: DateTime(2025, 1, 1),
            ),
          );
    });

    test('ASSEMBLY: loads packet with profile and items', () async {
      // Insert packet
      await db
          .into(db.customsPackets)
          .insert(
            CustomsPacketsCompanion.insert(
              id: 'packet_123',
              shipmentId: 'shipment_123',
              profileId: const Value('profile_123'),
              certify: const Value(true),
              createdAt: DateTime(2025, 1, 1),
            ),
          );

      // Insert 3 commodity lines
      await db
          .into(db.commodityLines)
          .insert(
            CommodityLinesCompanion.insert(
              id: 'line_1',
              customsPacketId: 'packet_123',
              description: 'Item 1',
              quantity: 1.0,
              netWeight: 1.0,
              valueAmount: 10.0,
              originCountry: 'CN',
              hsCode: '1234.56',
            ),
          );

      await db
          .into(db.commodityLines)
          .insert(
            CommodityLinesCompanion.insert(
              id: 'line_2',
              customsPacketId: 'packet_123',
              description: 'Item 2',
              quantity: 2.0,
              netWeight: 2.0,
              valueAmount: 20.0,
              originCountry: 'CN',
              hsCode: '7890.12',
            ),
          );

      await db
          .into(db.commodityLines)
          .insert(
            CommodityLinesCompanion.insert(
              id: 'line_3',
              customsPacketId: 'packet_123',
              description: 'Item 3',
              quantity: 3.0,
              netWeight: 3.0,
              valueAmount: 30.0,
              originCountry: 'CN',
              hsCode: '5678.90',
            ),
          );

      final packet = await container.read(
        customsPacketProvider('shipment_123').future,
      );

      expect(packet != null, true);
      expect(packet!.id, 'packet_123');
      expect(packet.profile != null, true);
      expect(packet.profile!.id, 'profile_123');
      expect(packet.items.length, 3);
      expect(packet.items[0].description, 'Item 1');
      expect(packet.items[1].description, 'Item 2');
      expect(packet.items[2].description, 'Item 3');
    });

    test('handles missing profile gracefully', () async {
      // Insert packet with non-existent profile ID
      await db
          .into(db.customsPackets)
          .insert(
            CustomsPacketsCompanion.insert(
              id: 'packet_123',
              shipmentId: 'shipment_123',
              profileId: const Value('non_existent_profile'),
              certify: const Value(true),
              createdAt: DateTime(2025, 1, 1),
            ),
          );

      final packet = await container.read(
        customsPacketProvider('shipment_123').future,
      );

      expect(packet != null, true);
      expect(packet!.profile, null);
    });

    test('returns null for non-existent shipment', () async {
      final packet = await container.read(
        customsPacketProvider('non_existent_shipment').future,
      );

      expect(packet, null);
    });

    test('loads packet without profile', () async {
      // Insert packet without profile
      await db
          .into(db.customsPackets)
          .insert(
            CustomsPacketsCompanion.insert(
              id: 'packet_123',
              shipmentId: 'shipment_123',
              certify: const Value(true),
              createdAt: DateTime(2025, 1, 1),
            ),
          );

      final packet = await container.read(
        customsPacketProvider('shipment_123').future,
      );

      expect(packet != null, true);
      expect(packet!.profile, null);
    });

    test('loads packet with empty items list', () async {
      await db
          .into(db.customsPackets)
          .insert(
            CustomsPacketsCompanion.insert(
              id: 'packet_123',
              shipmentId: 'shipment_123',
              certify: const Value(true),
              createdAt: DateTime(2025, 1, 1),
            ),
          );

      final packet = await container.read(
        customsPacketProvider('shipment_123').future,
      );

      expect(packet != null, true);
      expect(packet!.items, isEmpty);
    });
  });

  group('deleteCustomsProfile', () {
    test('deletes existing profile', () async {
      // Insert profile
      await db
          .into(db.customsProfiles)
          .insert(
            CustomsProfilesCompanion.insert(
              id: 'profile_123',
              name: 'Test Profile',
              importerType: 'business',
              createdAt: DateTime(2025, 1, 1),
              updatedAt: DateTime(2025, 1, 1),
            ),
          );

      // Verify it exists
      var profiles = await db.select(db.customsProfiles).get();
      expect(profiles.length, 1);

      // Delete it
      await deleteCustomsProfile('profile_123');

      // Verify it's gone
      profiles = await db.select(db.customsProfiles).get();
      expect(profiles, isEmpty);
    });

    test('profile not found does not throw', () async {
      // Should not throw even if profile doesn't exist
      await deleteCustomsProfile('non_existent_profile');

      // Verify database is still empty
      final profiles = await db.select(db.customsProfiles).get();
      expect(profiles, isEmpty);
    });

    test('deleting profile does not cascade to packets', () async {
      // Create shipment
      await db
          .into(db.shipments)
          .insert(
            ShipmentsCompanion.insert(
              id: 'shipment_123',
              createdAt: DateTime(2025, 1, 1),
              originCity: 'Shanghai',
              originPostal: '200000',
              destCity: 'Berlin',
              destPostal: '10115',
            ),
          );

      // Create profile
      await db
          .into(db.customsProfiles)
          .insert(
            CustomsProfilesCompanion.insert(
              id: 'profile_123',
              name: 'Test Profile',
              importerType: 'business',
              createdAt: DateTime(2025, 1, 1),
              updatedAt: DateTime(2025, 1, 1),
            ),
          );

      // Create packet referencing profile
      await db
          .into(db.customsPackets)
          .insert(
            CustomsPacketsCompanion.insert(
              id: 'packet_123',
              shipmentId: 'shipment_123',
              profileId: const Value('profile_123'),
              certify: const Value(true),
              createdAt: DateTime(2025, 1, 1),
            ),
          );

      // Delete profile
      await deleteCustomsProfile('profile_123');

      // Packet should still exist (profileId will be orphaned)
      final packets = await db.select(db.customsPackets).get();
      expect(packets.length, 1);
      expect(
        packets[0].profileId,
        'profile_123',
      ); // Still references deleted profile
    });
  });

  group('customsProfile provider (single)', () {
    test('returns profile when exists', () async {
      await db
          .into(db.customsProfiles)
          .insert(
            CustomsProfilesCompanion.insert(
              id: 'profile_123',
              name: 'Test Profile',
              importerType: 'business',
              eoriNumber: const Value('GB123456789000'),
              createdAt: DateTime(2025, 1, 1),
              updatedAt: DateTime(2025, 1, 1),
            ),
          );

      final profile = await container.read(
        customsProfileProvider('profile_123').future,
      );

      expect(profile != null, true);
      expect(profile!.id, 'profile_123');
      expect(profile.name, 'Test Profile');
      expect(profile.eoriNumber, 'GB123456789000');
    });

    test('returns null when profile not found', () async {
      final profile = await container.read(
        customsProfileProvider('non_existent').future,
      );

      expect(profile, null);
    });
  });
}
