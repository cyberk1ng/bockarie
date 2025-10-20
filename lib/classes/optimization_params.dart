/// Parameters for rule-based packing optimization
class OptimizationParams {
  final int maxSideCm; // Default: 60
  final double perCartonMaxKg; // Default: 24.0
  final List<StandardSize> standardSizes; // e.g., [50×40×40, 60×40×40]
  final double minSavingsPct; // Default: 3.0
  final bool allowCompression; // Default: true
  final bool preferUniformSizes; // Default: true

  const OptimizationParams({
    this.maxSideCm = 60,
    this.perCartonMaxKg = 24.0,
    this.standardSizes = const [
      StandardSize(length: 50, width: 40, height: 40),
      StandardSize(length: 60, width: 40, height: 40),
    ],
    this.minSavingsPct = 3.0,
    this.allowCompression = true,
    this.preferUniformSizes = true,
  });

  OptimizationParams copyWith({
    int? maxSideCm,
    double? perCartonMaxKg,
    List<StandardSize>? standardSizes,
    double? minSavingsPct,
    bool? allowCompression,
    bool? preferUniformSizes,
  }) {
    return OptimizationParams(
      maxSideCm: maxSideCm ?? this.maxSideCm,
      perCartonMaxKg: perCartonMaxKg ?? this.perCartonMaxKg,
      standardSizes: standardSizes ?? this.standardSizes,
      minSavingsPct: minSavingsPct ?? this.minSavingsPct,
      allowCompression: allowCompression ?? this.allowCompression,
      preferUniformSizes: preferUniformSizes ?? this.preferUniformSizes,
    );
  }
}

/// Standard carton sizes for optimization
class StandardSize {
  final double length;
  final double width;
  final double height;

  const StandardSize({
    required this.length,
    required this.width,
    required this.height,
  });

  double get volume => length * width * height;

  @override
  String toString() => '$length×$width×$height';
}
