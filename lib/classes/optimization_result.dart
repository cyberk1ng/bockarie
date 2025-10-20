import 'package:bockaire/classes/carton.dart';

/// Result of a packing optimization attempt
class OptimizationResult {
  final List<Carton> beforeCartons;
  final List<Carton> afterCartons;
  final double beforeChargeableKg;
  final double afterChargeableKg;
  final double savingsPercent;
  final List<String> warnings;
  final bool isActionable; // true if savings >= threshold
  final String rationale; // Human-readable summary
  final List<String>
  appliedStrategies; // e.g., ["Compression", "Consolidation"]

  const OptimizationResult({
    required this.beforeCartons,
    required this.afterCartons,
    required this.beforeChargeableKg,
    required this.afterChargeableKg,
    required this.savingsPercent,
    required this.warnings,
    required this.isActionable,
    required this.rationale,
    required this.appliedStrategies,
  });

  /// Total number of cartons before optimization
  int get beforeCartonCount => beforeCartons.fold(0, (sum, c) => sum + c.qty);

  /// Total number of cartons after optimization
  int get afterCartonCount => afterCartons.fold(0, (sum, c) => sum + c.qty);

  /// Total volume before optimization (cm³)
  double get beforeVolumeCm3 => beforeCartons.fold(
    0.0,
    (sum, c) => sum + (c.lengthCm * c.widthCm * c.heightCm * c.qty),
  );

  /// Total volume after optimization (cm³)
  double get afterVolumeCm3 => afterCartons.fold(
    0.0,
    (sum, c) => sum + (c.lengthCm * c.widthCm * c.heightCm * c.qty),
  );
}
