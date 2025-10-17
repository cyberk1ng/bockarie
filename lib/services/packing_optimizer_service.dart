import 'package:bockaire/classes/carton.dart';
import 'package:bockaire/services/calculation_service.dart';
import 'package:uuid/uuid.dart';

/// Standard carton sizes for optimization
class StandardCarton {
  final double lengthCm;
  final double widthCm;
  final double heightCm;
  final String name;

  const StandardCarton({
    required this.lengthCm,
    required this.widthCm,
    required this.heightCm,
    required this.name,
  });

  double get volumeCm3 => lengthCm * widthCm * heightCm;

  @override
  String toString() => '$name ($lengthCm×$widthCm×$heightCm cm)';
}

/// Packing optimizer service
class PackingOptimizerService {
  /// Default standard carton sizes
  static const standardSizes = [
    StandardCarton(
      lengthCm: 50,
      widthCm: 40,
      heightCm: 40,
      name: 'Standard 50×40×40',
    ),
    StandardCarton(
      lengthCm: 60,
      widthCm: 40,
      heightCm: 40,
      name: 'Standard 60×40×40',
    ),
  ];

  /// Default weight cap per carton in kg
  static const double defaultWeightCapKg = 24.0;

  final double weightCapKg;
  final List<StandardCarton> availableSizes;

  PackingOptimizerService({
    this.weightCapKg = defaultWeightCapKg,
    this.availableSizes = standardSizes,
  });

  /// Optimize packing using greedy bin-packing heuristic
  OptimizationResult optimize({
    required List<Carton> currentCartons,
    required String shipmentId,
  }) {
    if (currentCartons.isEmpty) {
      return OptimizationResult(
        originalCartons: currentCartons,
        optimizedCartons: [],
        savings: PackingSavings.zero,
      );
    }

    // Calculate current totals
    final originalTotals = CalculationService.calculateTotals(currentCartons);

    // Extract all items (expand quantities)
    final allItems = <_Item>[];
    for (final carton in currentCartons) {
      for (var i = 0; i < carton.qty; i++) {
        allItems.add(
          _Item(
            lengthCm: carton.lengthCm,
            widthCm: carton.widthCm,
            heightCm: carton.heightCm,
            weightKg: carton.weightKg,
            itemType: carton.itemType,
          ),
        );
      }
    }

    // Sort items by volume (largest first for better packing)
    allItems.sort((a, b) => b.volumeCm3.compareTo(a.volumeCm3));

    // Pack items into bins (cartons)
    final bins = <_Bin>[];

    for (final item in allItems) {
      var packed = false;

      // Try to fit in existing bin
      for (final bin in bins) {
        if (bin.canFit(item, weightCapKg)) {
          bin.add(item);
          packed = true;
          break;
        }
      }

      // Create new bin if needed
      if (!packed) {
        final bestSize = _findBestSize(item, availableSizes);
        final newBin = _Bin(
          lengthCm: bestSize.lengthCm,
          widthCm: bestSize.widthCm,
          heightCm: bestSize.heightCm,
        );
        newBin.add(item);
        bins.add(newBin);
      }
    }

    // Convert bins to cartons
    const uuid = Uuid();
    final optimizedCartons = bins.map((bin) {
      return Carton(
        id: uuid.v4(),
        shipmentId: shipmentId,
        lengthCm: bin.lengthCm,
        widthCm: bin.widthCm,
        heightCm: bin.heightCm,
        weightKg: bin.totalWeight,
        qty: 1,
        itemType: bin.items.map((i) => i.itemType).toSet().join(', '),
      );
    }).toList();

    // Calculate optimized totals
    final optimizedTotals = CalculationService.calculateTotals(
      optimizedCartons,
    );

    // Calculate savings
    final savings = PackingSavings(
      cartonCountReduction:
          originalTotals.cartonCount - optimizedTotals.cartonCount,
      volumeReduction:
          originalTotals.totalVolumeCm3 - optimizedTotals.totalVolumeCm3,
      chargeableKgReduction:
          originalTotals.chargeableKg - optimizedTotals.chargeableKg,
    );

    return OptimizationResult(
      originalCartons: currentCartons,
      optimizedCartons: optimizedCartons,
      savings: savings,
    );
  }

  /// Find best standard size for an item
  static StandardCarton _findBestSize(_Item item, List<StandardCarton> sizes) {
    // Find smallest size that fits
    for (final size in sizes) {
      if (item.lengthCm <= size.lengthCm &&
          item.widthCm <= size.widthCm &&
          item.heightCm <= size.heightCm) {
        return size;
      }
    }

    // If no standard size fits, use the largest available
    return sizes.last;
  }
}

/// Internal item representation
class _Item {
  final double lengthCm;
  final double widthCm;
  final double heightCm;
  final double weightKg;
  final String itemType;

  _Item({
    required this.lengthCm,
    required this.widthCm,
    required this.heightCm,
    required this.weightKg,
    required this.itemType,
  });

  double get volumeCm3 => lengthCm * widthCm * heightCm;
}

/// Internal bin representation
class _Bin {
  final double lengthCm;
  final double widthCm;
  final double heightCm;
  final List<_Item> items = [];

  _Bin({required this.lengthCm, required this.widthCm, required this.heightCm});

  double get totalWeight => items.fold(0.0, (sum, item) => sum + item.weightKg);

  double get usedVolume => items.fold(0.0, (sum, item) => sum + item.volumeCm3);

  double get capacity => lengthCm * widthCm * heightCm;

  bool canFit(_Item item, double weightCap) {
    // Check weight constraint
    if (totalWeight + item.weightKg > weightCap) {
      return false;
    }

    // Check dimension constraints (simple volume-based for now)
    if (item.lengthCm > lengthCm ||
        item.widthCm > widthCm ||
        item.heightCm > heightCm) {
      return false;
    }

    // Check if there's enough volume left (simplified)
    if (usedVolume + item.volumeCm3 > capacity) {
      return false;
    }

    return true;
  }

  void add(_Item item) {
    items.add(item);
  }
}

/// Optimization result
class OptimizationResult {
  final List<Carton> originalCartons;
  final List<Carton> optimizedCartons;
  final PackingSavings savings;

  const OptimizationResult({
    required this.originalCartons,
    required this.optimizedCartons,
    required this.savings,
  });

  bool get hasImprovement =>
      savings.cartonCountReduction > 0 ||
      savings.volumeReduction > 0 ||
      savings.chargeableKgReduction > 0;
}

/// Packing savings data
class PackingSavings {
  final int cartonCountReduction;
  final double volumeReduction;
  final double chargeableKgReduction;

  const PackingSavings({
    required this.cartonCountReduction,
    required this.volumeReduction,
    required this.chargeableKgReduction,
  });

  static const zero = PackingSavings(
    cartonCountReduction: 0,
    volumeReduction: 0,
    chargeableKgReduction: 0,
  );

  double get volumeReductionPercent {
    if (volumeReduction == 0) return 0;
    return (volumeReduction / (volumeReduction + 1)) * 100;
  }

  @override
  String toString() {
    return 'Savings: $cartonCountReduction cartons, '
        '${volumeReduction.toStringAsFixed(0)} cm³, '
        '${chargeableKgReduction.toStringAsFixed(1)} kg';
  }
}
