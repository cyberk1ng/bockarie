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

  const Quote({
    required this.id,
    required this.shipmentId,
    required this.carrier,
    required this.service,
    required this.etaMin,
    required this.etaMax,
    required this.priceEur,
    required this.chargeableKg,
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
    );
  }
}
