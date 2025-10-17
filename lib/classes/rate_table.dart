import 'package:equatable/equatable.dart';

class RateTable extends Equatable {
  final String id;
  final String carrier;
  final String service;
  final double baseFee;
  final double perKgLow;
  final double perKgHigh;
  final double breakpointKg;
  final double fuelPct;
  final double oversizeFee;
  final int etaMin;
  final int etaMax;
  final String? notes;

  const RateTable({
    required this.id,
    required this.carrier,
    required this.service,
    required this.baseFee,
    required this.perKgLow,
    required this.perKgHigh,
    required this.breakpointKg,
    required this.fuelPct,
    required this.oversizeFee,
    required this.etaMin,
    required this.etaMax,
    this.notes,
  });

  /// Calculate shipping cost for given weight and oversize flag
  double calculateCost({
    required double chargeableKg,
    required bool hasOversize,
  }) {
    double weightCost;
    if (chargeableKg <= breakpointKg) {
      weightCost = chargeableKg * perKgLow;
    } else {
      weightCost = chargeableKg * perKgHigh;
    }

    double subtotal = baseFee + weightCost;
    double fuel = subtotal * (fuelPct / 100);
    double oversize = hasOversize ? oversizeFee : 0;

    return subtotal + fuel + oversize;
  }

  @override
  List<Object?> get props => [
    id,
    carrier,
    service,
    baseFee,
    perKgLow,
    perKgHigh,
    breakpointKg,
    fuelPct,
    oversizeFee,
    etaMin,
    etaMax,
    notes,
  ];

  RateTable copyWith({
    String? id,
    String? carrier,
    String? service,
    double? baseFee,
    double? perKgLow,
    double? perKgHigh,
    double? breakpointKg,
    double? fuelPct,
    double? oversizeFee,
    int? etaMin,
    int? etaMax,
    String? notes,
  }) {
    return RateTable(
      id: id ?? this.id,
      carrier: carrier ?? this.carrier,
      service: service ?? this.service,
      baseFee: baseFee ?? this.baseFee,
      perKgLow: perKgLow ?? this.perKgLow,
      perKgHigh: perKgHigh ?? this.perKgHigh,
      breakpointKg: breakpointKg ?? this.breakpointKg,
      fuelPct: fuelPct ?? this.fuelPct,
      oversizeFee: oversizeFee ?? this.oversizeFee,
      etaMin: etaMin ?? this.etaMin,
      etaMax: etaMax ?? this.etaMax,
      notes: notes ?? this.notes,
    );
  }
}
