/// Models for customs declarations and international shipping
library;

import 'package:equatable/equatable.dart';

/// Importer type for customs declaration
enum ImporterType { business, individual }

/// Incoterms (International Commercial Terms) for customs
enum Incoterms {
  dap, // Delivered At Place (most common for small shipments)
  ddp, // Delivered Duty Paid
  ddu, // Delivered Duty Unpaid (deprecated but still used)
  exw, // Ex Works
  fob, // Free On Board
  cif, // Cost, Insurance & Freight
}

/// Contents type for customs declaration
enum ContentsType { merchandise, documents, gift, sample, returnedGoods }

/// A single commodity/item in the shipment (line item)
class CommodityLine extends Equatable {
  final String description;
  final double quantity;
  final double netWeight; // kg
  final double valueAmount; // USD
  final String originCountry; // ISO country code
  final String hsCode; // Harmonized System code (6-10 digits)
  final String? skuCode;

  const CommodityLine({
    required this.description,
    required this.quantity,
    required this.netWeight,
    required this.valueAmount,
    required this.originCountry,
    required this.hsCode,
    this.skuCode,
  });

  /// Total value for this line (quantity * value)
  double get totalValue => quantity * valueAmount;

  /// Total weight for this line
  double get totalWeight => quantity * netWeight;

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'quantity': quantity,
      'net_weight': netWeight.toStringAsFixed(2),
      'value_amount': valueAmount.toStringAsFixed(2),
      'value_currency': 'USD',
      'origin_country': originCountry,
      'tariff_number': hsCode,
      if (skuCode != null) 'sku_code': skuCode,
      'mass_unit': 'kg',
    };
  }

  factory CommodityLine.fromJson(Map<String, dynamic> json) {
    return CommodityLine(
      description: json['description'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      netWeight: double.parse(json['net_weight'] as String),
      valueAmount: double.parse(json['value_amount'] as String),
      originCountry: json['origin_country'] as String,
      hsCode: json['tariff_number'] as String,
      skuCode: json['sku_code'] as String?,
    );
  }

  CommodityLine copyWith({
    String? description,
    double? quantity,
    double? netWeight,
    double? valueAmount,
    String? originCountry,
    String? hsCode,
    String? skuCode,
  }) {
    return CommodityLine(
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      netWeight: netWeight ?? this.netWeight,
      valueAmount: valueAmount ?? this.valueAmount,
      originCountry: originCountry ?? this.originCountry,
      hsCode: hsCode ?? this.hsCode,
      skuCode: skuCode ?? this.skuCode,
    );
  }

  @override
  List<Object?> get props => [
    description,
    quantity,
    netWeight,
    valueAmount,
    originCountry,
    hsCode,
    skuCode,
  ];
}

/// Customs profile for reusable importer/exporter information
class CustomsProfile extends Equatable {
  final String id;
  final String name; // Profile name (e.g., "My Business", "Personal")
  final ImporterType importerType;
  final String? vatNumber; // Value Added Tax number
  final String?
  eoriNumber; // Economic Operators Registration and Identification
  final String? taxId; // Generic tax ID for non-EU countries
  final String? companyName; // For business importers
  final String? contactName;
  final String? contactPhone;
  final String? contactEmail;
  final Incoterms defaultIncoterms;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomsProfile({
    required this.id,
    required this.name,
    required this.importerType,
    this.vatNumber,
    this.eoriNumber,
    this.taxId,
    this.companyName,
    this.contactName,
    this.contactPhone,
    this.contactEmail,
    this.defaultIncoterms = Incoterms.dap,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'importer_type': importerType.name,
      'vat_number': vatNumber,
      'eori_number': eoriNumber,
      'tax_id': taxId,
      'company_name': companyName,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'default_incoterms': defaultIncoterms.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CustomsProfile.fromJson(Map<String, dynamic> json) {
    return CustomsProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      importerType: ImporterType.values.firstWhere(
        (e) => e.name == json['importer_type'],
        orElse: () => ImporterType.individual,
      ),
      vatNumber: json['vat_number'] as String?,
      eoriNumber: json['eori_number'] as String?,
      taxId: json['tax_id'] as String?,
      companyName: json['company_name'] as String?,
      contactName: json['contact_name'] as String?,
      contactPhone: json['contact_phone'] as String?,
      contactEmail: json['contact_email'] as String?,
      defaultIncoterms: Incoterms.values.firstWhere(
        (e) => e.name == json['default_incoterms'],
        orElse: () => Incoterms.dap,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  CustomsProfile copyWith({
    String? id,
    String? name,
    ImporterType? importerType,
    String? vatNumber,
    String? eoriNumber,
    String? taxId,
    String? companyName,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    Incoterms? defaultIncoterms,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomsProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      importerType: importerType ?? this.importerType,
      vatNumber: vatNumber ?? this.vatNumber,
      eoriNumber: eoriNumber ?? this.eoriNumber,
      taxId: taxId ?? this.taxId,
      companyName: companyName ?? this.companyName,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      defaultIncoterms: defaultIncoterms ?? this.defaultIncoterms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    importerType,
    vatNumber,
    eoriNumber,
    taxId,
    companyName,
    contactName,
    contactPhone,
    contactEmail,
    defaultIncoterms,
    createdAt,
    updatedAt,
  ];
}

/// Complete customs declaration packet for a shipment
class CustomsPacket extends Equatable {
  final String id;
  final String shipmentId;
  final CustomsProfile? profile; // Optional saved profile used
  final List<CommodityLine> items;
  final Incoterms incoterms;
  final ContentsType contentsType;
  final String? invoiceNumber;
  final String? exporterReference;
  final String? importerReference;
  final bool certify; // Certify that information is accurate
  final String? notes;
  final DateTime createdAt;

  const CustomsPacket({
    required this.id,
    required this.shipmentId,
    this.profile,
    required this.items,
    this.incoterms = Incoterms.dap,
    this.contentsType = ContentsType.merchandise,
    this.invoiceNumber,
    this.exporterReference,
    this.importerReference,
    this.certify = false,
    this.notes,
    required this.createdAt,
  });

  /// Total declared value of all items
  double get totalValue =>
      items.fold(0.0, (sum, item) => sum + item.totalValue);

  /// Total weight of all items
  double get totalWeight =>
      items.fold(0.0, (sum, item) => sum + item.totalWeight);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shipment_id': shipmentId,
      'profile': profile?.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'incoterms': incoterms.name.toUpperCase(),
      'contents_type': contentsType.name,
      'invoice_number': invoiceNumber,
      'exporter_reference': exporterReference,
      'importer_reference': importerReference,
      'certify': certify,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CustomsPacket.fromJson(Map<String, dynamic> json) {
    return CustomsPacket(
      id: json['id'] as String,
      shipmentId: json['shipment_id'] as String,
      profile: json['profile'] != null
          ? CustomsProfile.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
      items: (json['items'] as List<dynamic>)
          .map((item) => CommodityLine.fromJson(item as Map<String, dynamic>))
          .toList(),
      incoterms: Incoterms.values.firstWhere(
        (e) =>
            e.name.toLowerCase() == (json['incoterms'] as String).toLowerCase(),
        orElse: () => Incoterms.dap,
      ),
      contentsType: ContentsType.values.firstWhere(
        (e) => e.name == json['contents_type'],
        orElse: () => ContentsType.merchandise,
      ),
      invoiceNumber: json['invoice_number'] as String?,
      exporterReference: json['exporter_reference'] as String?,
      importerReference: json['importer_reference'] as String?,
      certify: json['certify'] as bool? ?? false,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  CustomsPacket copyWith({
    String? id,
    String? shipmentId,
    CustomsProfile? profile,
    List<CommodityLine>? items,
    Incoterms? incoterms,
    ContentsType? contentsType,
    String? invoiceNumber,
    String? exporterReference,
    String? importerReference,
    bool? certify,
    String? notes,
    DateTime? createdAt,
  }) {
    return CustomsPacket(
      id: id ?? this.id,
      shipmentId: shipmentId ?? this.shipmentId,
      profile: profile ?? this.profile,
      items: items ?? this.items,
      incoterms: incoterms ?? this.incoterms,
      contentsType: contentsType ?? this.contentsType,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      exporterReference: exporterReference ?? this.exporterReference,
      importerReference: importerReference ?? this.importerReference,
      certify: certify ?? this.certify,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    shipmentId,
    profile,
    items,
    incoterms,
    contentsType,
    invoiceNumber,
    exporterReference,
    importerReference,
    certify,
    notes,
    createdAt,
  ];
}
