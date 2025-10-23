import 'package:equatable/equatable.dart';

class Quote extends Equatable {
  final String id;
  final String shipmentId;
  final String carrier;
  final String service;
  final int etaMin;
  final int etaMax;
  final double priceEur;
  final double chargeableKg;

  // Additional fields for Shippo live integration
  final String? provider; // 'Shippo Live', 'Local Rates', etc.
  final String? currency; // Original currency (USD, EUR, etc.)
  final double? price; // Original price before conversion
  final int? transitDays; // Estimated transit days from carrier
  final String? providerToken; // Shippo rate object_id
  final String? carrierAccount; // Carrier account ID
  final String? rawRateId; // Raw rate ID for potential label purchase

  const Quote({
    required this.id,
    required this.shipmentId,
    required this.carrier,
    required this.service,
    required this.etaMin,
    required this.etaMax,
    required this.priceEur,
    required this.chargeableKg,
    this.provider,
    this.currency,
    this.price,
    this.transitDays,
    this.providerToken,
    this.carrierAccount,
    this.rawRateId,
  });

  String get etaRange => '$etaMin-$etaMax days';

  @override
  List<Object?> get props => [
    id,
    shipmentId,
    carrier,
    service,
    etaMin,
    etaMax,
    priceEur,
    chargeableKg,
    provider,
    currency,
    price,
    transitDays,
    providerToken,
    carrierAccount,
    rawRateId,
  ];

  Quote copyWith({
    String? id,
    String? shipmentId,
    String? carrier,
    String? service,
    int? etaMin,
    int? etaMax,
    double? priceEur,
    double? chargeableKg,
    String? provider,
    String? currency,
    double? price,
    int? transitDays,
    String? providerToken,
    String? carrierAccount,
    String? rawRateId,
  }) {
    return Quote(
      id: id ?? this.id,
      shipmentId: shipmentId ?? this.shipmentId,
      carrier: carrier ?? this.carrier,
      service: service ?? this.service,
      etaMin: etaMin ?? this.etaMin,
      etaMax: etaMax ?? this.etaMax,
      priceEur: priceEur ?? this.priceEur,
      chargeableKg: chargeableKg ?? this.chargeableKg,
      provider: provider ?? this.provider,
      currency: currency ?? this.currency,
      price: price ?? this.price,
      transitDays: transitDays ?? this.transitDays,
      providerToken: providerToken ?? this.providerToken,
      carrierAccount: carrierAccount ?? this.carrierAccount,
      rawRateId: rawRateId ?? this.rawRateId,
    );
  }
}
