import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bockaire/services/book_shipment_service.dart';
import 'package:bockaire/models/customs_models.dart' as models;
import 'package:bockaire/database/database.dart';
import 'package:bockaire/get_it.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

part 'booking_providers.g.dart';

/// Provider for BookShipmentService
@riverpod
BookShipmentService bookShipmentService(ref) {
  return BookShipmentService();
}

/// Provider for customs profiles from database
@riverpod
Future<List<models.CustomsProfile>> customsProfiles(ref) async {
  final db = getIt<AppDatabase>();
  final profiles = await db.select(db.customsProfiles).get();

  return profiles.map((p) {
    return models.CustomsProfile(
      id: p.id,
      name: p.name,
      importerType: models.ImporterType.values.firstWhere(
        (e) => e.name == p.importerType,
        orElse: () => models.ImporterType.individual,
      ),
      vatNumber: p.vatNumber,
      eoriNumber: p.eoriNumber,
      taxId: p.taxId,
      companyName: p.companyName,
      contactName: p.contactName,
      contactPhone: p.contactPhone,
      contactEmail: p.contactEmail,
      defaultIncoterms: models.Incoterms.values.firstWhere(
        (e) => e.name == p.defaultIncoterms,
        orElse: () => models.Incoterms.dap,
      ),
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    );
  }).toList();
}

/// Provider for a single customs profile by ID
@riverpod
Future<models.CustomsProfile?> customsProfile(ref, String profileId) async {
  final db = getIt<AppDatabase>();
  final profile = await (db.select(
    db.customsProfiles,
  )..where((p) => p.id.equals(profileId))).getSingleOrNull();

  if (profile == null) return null;

  return models.CustomsProfile(
    id: profile.id,
    name: profile.name,
    importerType: models.ImporterType.values.firstWhere(
      (e) => e.name == profile.importerType,
      orElse: () => models.ImporterType.individual,
    ),
    vatNumber: profile.vatNumber,
    eoriNumber: profile.eoriNumber,
    taxId: profile.taxId,
    companyName: profile.companyName,
    contactName: profile.contactName,
    contactPhone: profile.contactPhone,
    contactEmail: profile.contactEmail,
    defaultIncoterms: models.Incoterms.values.firstWhere(
      (e) => e.name == profile.defaultIncoterms,
      orElse: () => models.Incoterms.dap,
    ),
    createdAt: profile.createdAt,
    updatedAt: profile.updatedAt,
  );
}

/// Provider for customs packet by shipment ID
@riverpod
Future<models.CustomsPacket?> customsPacket(ref, String shipmentId) async {
  final db = getIt<AppDatabase>();
  final packet = await (db.select(
    db.customsPackets,
  )..where((p) => p.shipmentId.equals(shipmentId))).getSingleOrNull();

  if (packet == null) return null;

  // Get associated profile if exists
  models.CustomsProfile? profile;
  if (packet.profileId != null) {
    profile = await ref.read(customsProfileProvider(packet.profileId!).future);
  }

  // Get commodity lines
  final lines = await (db.select(
    db.commodityLines,
  )..where((l) => l.customsPacketId.equals(packet.id))).get();

  final items = lines.map((line) {
    return models.CommodityLine(
      description: line.description,
      quantity: line.quantity,
      netWeight: line.netWeight,
      valueAmount: line.valueAmount,
      originCountry: line.originCountry,
      hsCode: line.hsCode,
      skuCode: line.skuCode,
    );
  }).toList();

  return models.CustomsPacket(
    id: packet.id,
    shipmentId: packet.shipmentId,
    profile: profile,
    items: items,
    incoterms: models.Incoterms.values.firstWhere(
      (e) => e.name == packet.incoterms,
      orElse: () => models.Incoterms.dap,
    ),
    contentsType: models.ContentsType.values.firstWhere(
      (e) => e.name == packet.contentsType,
      orElse: () => models.ContentsType.merchandise,
    ),
    invoiceNumber: packet.invoiceNumber,
    exporterReference: packet.exporterReference,
    importerReference: packet.importerReference,
    certify: packet.certify,
    notes: packet.notes,
    createdAt: packet.createdAt,
  );
}

/// Save a customs profile to database
Future<void> saveCustomsProfile(models.CustomsProfile profile) async {
  final db = getIt<AppDatabase>();

  await db
      .into(db.customsProfiles)
      .insertOnConflictUpdate(
        CustomsProfilesCompanion.insert(
          id: profile.id,
          name: profile.name,
          importerType: profile.importerType.name,
          vatNumber: drift.Value(profile.vatNumber),
          eoriNumber: drift.Value(profile.eoriNumber),
          taxId: drift.Value(profile.taxId),
          companyName: drift.Value(profile.companyName),
          contactName: drift.Value(profile.contactName),
          contactPhone: drift.Value(profile.contactPhone),
          contactEmail: drift.Value(profile.contactEmail),
          defaultIncoterms: drift.Value(profile.defaultIncoterms.name),
          createdAt: profile.createdAt,
          updatedAt: profile.updatedAt,
        ),
      );
}

/// Save a customs packet with commodity lines to database
Future<void> saveCustomsPacket(models.CustomsPacket packet) async {
  final db = getIt<AppDatabase>();
  final uuid = const Uuid();

  // Save customs packet
  await db
      .into(db.customsPackets)
      .insertOnConflictUpdate(
        CustomsPacketsCompanion.insert(
          id: packet.id,
          shipmentId: packet.shipmentId,
          profileId: drift.Value(packet.profile?.id),
          incoterms: drift.Value(packet.incoterms.name),
          contentsType: drift.Value(packet.contentsType.name),
          invoiceNumber: drift.Value(packet.invoiceNumber),
          exporterReference: drift.Value(packet.exporterReference),
          importerReference: drift.Value(packet.importerReference),
          certify: drift.Value(packet.certify),
          notes: drift.Value(packet.notes),
          createdAt: packet.createdAt,
        ),
      );

  // Delete existing commodity lines for this packet
  await (db.delete(
    db.commodityLines,
  )..where((l) => l.customsPacketId.equals(packet.id))).go();

  // Insert new commodity lines
  for (final item in packet.items) {
    await db
        .into(db.commodityLines)
        .insert(
          CommodityLinesCompanion.insert(
            id: uuid.v4(),
            customsPacketId: packet.id,
            description: item.description,
            quantity: item.quantity,
            netWeight: item.netWeight,
            valueAmount: item.valueAmount,
            originCountry: item.originCountry,
            hsCode: item.hsCode,
            skuCode: drift.Value(item.skuCode),
          ),
        );
  }
}

/// Delete a customs profile
Future<void> deleteCustomsProfile(String profileId) async {
  final db = getIt<AppDatabase>();
  await (db.delete(
    db.customsProfiles,
  )..where((p) => p.id.equals(profileId))).go();
}
