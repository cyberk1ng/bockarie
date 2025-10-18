import 'package:bockaire/classes/carton.dart';

class OptimizedCarton {
  final double lengthCm;
  final double widthCm;
  final double heightCm;
  final double weightKg;
  final List<String> itemTypes;

  const OptimizedCarton({
    required this.lengthCm,
    required this.widthCm,
    required this.heightCm,
    required this.weightKg,
    required this.itemTypes,
  });

  double get volumeCm3 => lengthCm * widthCm * heightCm;

  double get dimensionalWeight => (lengthCm * widthCm * heightCm) / 5000;

  double get chargeableWeight {
    if (weightKg > dimensionalWeight) {
      return weightKg;
    }
    return dimensionalWeight;
  }

  bool get isOversize => lengthCm > 60;
}

class OptimizationResult {
  final List<OptimizedCarton> optimizedCartons;
  final double originalVolume;
  final double optimizedVolume;
  final double volumeSavingsPct;
  final double originalChargeableKg;
  final double optimizedChargeableKg;

  const OptimizationResult({
    required this.optimizedCartons,
    required this.originalVolume,
    required this.optimizedVolume,
    required this.volumeSavingsPct,
    required this.originalChargeableKg,
    required this.optimizedChargeableKg,
  });
}

class PackOptimizer {
  // Standard carton sizes (in cm)
  static const List<Map<String, double>> standardSizes = [
    {'length': 50, 'width': 40, 'height': 40},
    {'length': 60, 'width': 40, 'height': 40},
  ];

  static const double maxWeightPerCartonKg = 24.0;

  /// Optimize cartons by repacking into standard sizes
  OptimizationResult optimize(List<Carton> cartons) {
    // Calculate original metrics
    final originalVolume = cartons.fold<double>(
      0,
      (sum, carton) => sum + carton.volumeCm3,
    );
    final originalChargeableKg = cartons.fold<double>(
      0,
      (sum, carton) => sum + carton.totalChargeableWeight,
    );

    // Group items by type for better packing
    final Map<String, List<Carton>> itemsByType = {};
    for (final carton in cartons) {
      if (!itemsByType.containsKey(carton.itemType)) {
        itemsByType[carton.itemType] = [];
      }
      itemsByType[carton.itemType]!.add(carton);
    }

    // Pack items into standard cartons
    final List<OptimizedCarton> optimizedCartons = [];

    for (final entry in itemsByType.entries) {
      final itemType = entry.key;
      final items = entry.value;

      // Expand items by quantity
      final List<Map<String, dynamic>> expandedItems = [];
      for (final item in items) {
        for (int i = 0; i < item.qty; i++) {
          expandedItems.add({
            'weight': item.weightKg,
            'volume': item.lengthCm * item.widthCm * item.heightCm,
            'type': item.itemType,
          });
        }
      }

      // Sort by density (weight/volume) for better packing
      expandedItems.sort((a, b) {
        final densityA = a['weight'] / a['volume'];
        final densityB = b['weight'] / b['volume'];
        return densityB.compareTo(densityA);
      });

      // Pack into standard cartons
      List<Map<String, dynamic>> currentCarton = [];
      double currentWeight = 0;
      double currentVolume = 0;

      for (final item in expandedItems) {
        final itemWeight = item['weight'] as double;
        final itemVolume = item['volume'] as double;

        // Try smallest standard size first, then larger if needed
        final selectedSize = _selectStandardSize(currentVolume + itemVolume);
        final selectedSizeVolume =
            selectedSize['length']! *
            selectedSize['width']! *
            selectedSize['height']!;

        if (currentWeight + itemWeight <= maxWeightPerCartonKg &&
            currentVolume + itemVolume <= selectedSizeVolume) {
          // Add to current carton
          currentCarton.add(item);
          currentWeight += itemWeight;
          currentVolume += itemVolume;
        } else {
          // Finalize current carton
          if (currentCarton.isNotEmpty) {
            final size = _selectStandardSize(currentVolume);
            optimizedCartons.add(
              OptimizedCarton(
                lengthCm: size['length']!,
                widthCm: size['width']!,
                heightCm: size['height']!,
                weightKg: currentWeight,
                itemTypes: [itemType],
              ),
            );
          }

          // Start new carton
          currentCarton = [item];
          currentWeight = itemWeight;
          currentVolume = itemVolume;
        }
      }

      // Add last carton
      if (currentCarton.isNotEmpty) {
        final size = _selectStandardSize(currentVolume);
        optimizedCartons.add(
          OptimizedCarton(
            lengthCm: size['length']!,
            widthCm: size['width']!,
            heightCm: size['height']!,
            weightKg: currentWeight,
            itemTypes: [itemType],
          ),
        );
      }
    }

    // Calculate optimized metrics
    final optimizedVolume = optimizedCartons.fold<double>(
      0,
      (sum, carton) => sum + carton.volumeCm3,
    );
    final optimizedChargeableKg = optimizedCartons.fold<double>(
      0,
      (sum, carton) => sum + carton.chargeableWeight,
    );

    final volumeSavingsPct = originalVolume > 0
        ? ((originalVolume - optimizedVolume) / originalVolume * 100)
              .clamp(0, 100)
              .toDouble()
        : 0.0;

    return OptimizationResult(
      optimizedCartons: optimizedCartons,
      originalVolume: originalVolume,
      optimizedVolume: optimizedVolume,
      volumeSavingsPct: volumeSavingsPct,
      originalChargeableKg: originalChargeableKg,
      optimizedChargeableKg: optimizedChargeableKg,
    );
  }

  /// Select the smallest standard size that fits the volume
  Map<String, double> _selectStandardSize(double volumeCm3) {
    for (final size in standardSizes) {
      final cartonVolume = size['length']! * size['width']! * size['height']!;
      if (volumeCm3 <= cartonVolume) {
        return size;
      }
    }
    // Return largest size if none fit
    return standardSizes.last;
  }
}
