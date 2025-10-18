import 'package:bockaire/classes/carton.dart';
import 'package:bockaire/config/shipping_constants.dart';

/// Service for calculating shipping weights and costs
class CalculationService {
  /// Dimensional weight divisor (standard for air freight)
  static const double dimWeightDivisor =
      ShippingConstants.dimensionalWeightDivisor;

  /// Default oversize threshold in cm
  static const double defaultOversizeThreshold =
      ShippingConstants.oversizeThresholdCm;

  /// Calculate dimensional weight for a single carton in kg
  /// Formula: (L × W × H) / 5000
  static double calculateDimWeight({
    required double lengthCm,
    required double widthCm,
    required double heightCm,
  }) {
    return (lengthCm * widthCm * heightCm) / dimWeightDivisor;
  }

  /// Calculate actual weight total for cartons
  static double calculateActualWeight(List<Carton> cartons) {
    return cartons.fold(
      0.0,
      (sum, carton) => sum + (carton.weightKg * carton.qty),
    );
  }

  /// Calculate dimensional weight total for cartons
  static double calculateTotalDimWeight(List<Carton> cartons) {
    return cartons.fold(
      0.0,
      (sum, carton) =>
          sum +
          (calculateDimWeight(
                lengthCm: carton.lengthCm,
                widthCm: carton.widthCm,
                heightCm: carton.heightCm,
              ) *
              carton.qty),
    );
  }

  /// Calculate chargeable weight (max of actual and dimensional)
  static double calculateChargeableWeight(List<Carton> cartons) {
    final actualWeight = calculateActualWeight(cartons);
    final dimWeight = calculateTotalDimWeight(cartons);
    return actualWeight > dimWeight ? actualWeight : dimWeight;
  }

  /// Get the largest side dimension across all cartons
  static double getLargestSide(List<Carton> cartons) {
    if (cartons.isEmpty) return 0.0;

    return cartons.fold(0.0, (max, carton) {
      final maxSide = [
        carton.lengthCm,
        carton.widthCm,
        carton.heightCm,
      ].reduce((a, b) => a > b ? a : b);
      return maxSide > max ? maxSide : max;
    });
  }

  /// Check if any carton is oversized
  static bool isOversized(
    List<Carton> cartons, {
    double threshold = defaultOversizeThreshold,
  }) {
    return getLargestSide(cartons) > threshold;
  }

  /// Calculate total volume across all cartons (in cubic cm)
  static double calculateTotalVolume(List<Carton> cartons) {
    return cartons.fold(
      0.0,
      (sum, carton) =>
          sum +
          (carton.lengthCm * carton.widthCm * carton.heightCm * carton.qty),
    );
  }

  /// Suggest dimension reduction for savings
  /// Returns a hint like "Reduce H by 5cm → 8% less dim weight"
  static String? suggestDimensionReduction(List<Carton> cartons) {
    if (cartons.isEmpty) return null;

    final currentDimWeight = calculateTotalDimWeight(cartons);
    if (currentDimWeight == 0) return null;

    // Find carton with largest height that could be reduced
    final sortedByHeight = List<Carton>.from(cartons)
      ..sort((a, b) => b.heightCm.compareTo(a.heightCm));

    if (sortedByHeight.isEmpty) return null;

    final tallest = sortedByHeight.first;
    final reduction = ShippingConstants.suggestedDimensionReductionCm;

    if (tallest.heightCm <= reduction) return null;

    // Calculate potential new dim weight
    final newDimWeight =
        calculateDimWeight(
          lengthCm: tallest.lengthCm,
          widthCm: tallest.widthCm,
          heightCm: tallest.heightCm - reduction,
        ) *
        tallest.qty;

    final oldDimWeight =
        calculateDimWeight(
          lengthCm: tallest.lengthCm,
          widthCm: tallest.widthCm,
          heightCm: tallest.heightCm,
        ) *
        tallest.qty;

    final savedWeight = oldDimWeight - newDimWeight;
    final percentSaved = (savedWeight / currentDimWeight * 100).round();

    if (percentSaved > 0) {
      return 'Reduce H by ${reduction.toInt()}cm → ~$percentSaved% less dim weight';
    }

    return null;
  }

  /// Calculate totals summary
  static ShipmentTotals calculateTotals(List<Carton> cartons) {
    return ShipmentTotals(
      cartonCount: cartons.length,
      actualKg: calculateActualWeight(cartons),
      dimKg: calculateTotalDimWeight(cartons),
      chargeableKg: calculateChargeableWeight(cartons),
      largestSideCm: getLargestSide(cartons),
      isOversized: isOversized(cartons),
      totalVolumeCm3: calculateTotalVolume(cartons),
      savingsHint: suggestDimensionReduction(cartons),
    );
  }
}

/// Immutable totals data class
class ShipmentTotals {
  final int cartonCount;
  final double actualKg;
  final double dimKg;
  final double chargeableKg;
  final double largestSideCm;
  final bool isOversized;
  final double totalVolumeCm3;
  final String? savingsHint;

  const ShipmentTotals({
    required this.cartonCount,
    required this.actualKg,
    required this.dimKg,
    required this.chargeableKg,
    required this.largestSideCm,
    required this.isOversized,
    required this.totalVolumeCm3,
    this.savingsHint,
  });

  @override
  String toString() {
    return 'ShipmentTotals(cartons: $cartonCount, actual: ${actualKg.toStringAsFixed(1)}kg, '
        'dim: ${dimKg.toStringAsFixed(1)}kg, chargeable: ${chargeableKg.toStringAsFixed(1)}kg, '
        'oversized: $isOversized)';
  }
}
