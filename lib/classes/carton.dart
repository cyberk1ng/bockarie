import 'package:equatable/equatable.dart';

class Carton extends Equatable {
  final String id;
  final String shipmentId;
  final double lengthCm;
  final double widthCm;
  final double heightCm;
  final double weightKg;
  final int qty;
  final String itemType;

  const Carton({
    required this.id,
    required this.shipmentId,
    required this.lengthCm,
    required this.widthCm,
    required this.heightCm,
    required this.weightKg,
    required this.qty,
    required this.itemType,
  });

  /// Calculate dimensional weight: (L×W×H)/5000
  double get dimensionalWeight => (lengthCm * widthCm * heightCm) / 5000;

  /// Chargeable weight per carton: max(actual, dimensional)
  double get chargeableWeight {
    if (weightKg > dimensionalWeight) {
      return weightKg;
    }
    return dimensionalWeight;
  }

  /// Total chargeable weight for all quantities
  double get totalChargeableWeight => chargeableWeight * qty;

  /// Check if carton is oversize (length > 60cm)
  bool get isOversize => lengthCm > 60;

  /// Total volume in cubic cm
  double get volumeCm3 => lengthCm * widthCm * heightCm * qty;

  @override
  List<Object?> get props => [
        id,
        shipmentId,
        lengthCm,
        widthCm,
        heightCm,
        weightKg,
        qty,
        itemType,
      ];

  Carton copyWith({
    String? id,
    String? shipmentId,
    double? lengthCm,
    double? widthCm,
    double? heightCm,
    double? weightKg,
    int? qty,
    String? itemType,
  }) {
    return Carton(
      id: id ?? this.id,
      shipmentId: shipmentId ?? this.shipmentId,
      lengthCm: lengthCm ?? this.lengthCm,
      widthCm: widthCm ?? this.widthCm,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      qty: qty ?? this.qty,
      itemType: itemType ?? this.itemType,
    );
  }
}
