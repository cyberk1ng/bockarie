import 'package:bockaire/classes/carton.dart';
import 'package:bockaire/classes/optimization_params.dart';
import 'package:bockaire/classes/optimization_result.dart';
import 'package:bockaire/services/optimization_engine.dart';

/// Rule-based implementation of the optimization engine
///
/// Uses a 3-pass approach:
/// 1. Compression - reduce height of soft goods
/// 2. Consolidation - combine under-filled cartons
/// 3. Standardization - map to standard sizes
class OptimizationEngineImpl implements OptimizationEngine {
  @override
  OptimizationResult optimize(List<Carton> cartons, OptimizationParams params) {
    if (cartons.isEmpty) {
      return OptimizationResult(
        beforeCartons: cartons,
        afterCartons: cartons,
        beforeChargeableKg: 0.0,
        afterChargeableKg: 0.0,
        savingsPercent: 0.0,
        warnings: [],
        isActionable: false,
        rationale: 'No cartons to optimize',
        appliedStrategies: [],
      );
    }

    // Store original cartons
    final beforeCartons = List<Carton>.from(cartons);
    final beforeKg = _calculateTotalChargeableWeight(beforeCartons);

    // Track which strategies were attempted and succeeded
    final attemptedStrategies = <String, bool>{};
    final appliedStrategies = <String>[];
    final warnings = <String>[];

    // Working copy for optimization
    List<Carton> workingCartons = List<Carton>.from(cartons);

    // Pass 1: Compression
    if (params.allowCompression) {
      final compressionResult = _applyCompression(workingCartons, params);
      attemptedStrategies['compression'] = compressionResult.improved;
      if (compressionResult.improved) {
        workingCartons = compressionResult.cartons;
        appliedStrategies.add('Compression (${compressionResult.description})');
        warnings.addAll(compressionResult.warnings);
      }
    }

    // Pass 2: Consolidation
    final consolidationResult = _applyConsolidation(workingCartons, params);
    attemptedStrategies['consolidation'] = consolidationResult.improved;
    if (consolidationResult.improved) {
      workingCartons = consolidationResult.cartons;
      appliedStrategies.add(
        'Consolidation (${consolidationResult.description})',
      );
      warnings.addAll(consolidationResult.warnings);
    }

    // Pass 3: Standardization
    if (params.preferUniformSizes) {
      final standardizationResult = _applyStandardization(
        workingCartons,
        params,
      );
      attemptedStrategies['standardization'] = standardizationResult.improved;
      if (standardizationResult.improved) {
        workingCartons = standardizationResult.cartons;
        appliedStrategies.add(
          'Standardization (${standardizationResult.description})',
        );
        warnings.addAll(standardizationResult.warnings);
      }
    }

    // Calculate final metrics
    final afterKg = _calculateTotalChargeableWeight(workingCartons);
    final savingsPct = beforeKg > 0
        ? ((beforeKg - afterKg) / beforeKg) * 100
        : 0.0;
    final isActionable = savingsPct >= params.minSavingsPct;

    // Generate rationale
    String rationale;
    if (isActionable) {
      rationale =
          'Reduced chargeable weight by ${savingsPct.toStringAsFixed(1)}% through ${appliedStrategies.join(", ")}';
    } else {
      rationale = _generateNoOptimizationRationale(
        beforeCartons,
        params,
        attemptedStrategies,
      );
    }

    return OptimizationResult(
      beforeCartons: beforeCartons,
      afterCartons: workingCartons,
      beforeChargeableKg: beforeKg,
      afterChargeableKg: afterKg,
      savingsPercent: savingsPct,
      warnings: warnings,
      isActionable: isActionable,
      rationale: rationale,
      appliedStrategies: appliedStrategies,
    );
  }

  /// Pass 1: Compression of soft goods
  _OptimizationPass _applyCompression(
    List<Carton> cartons,
    OptimizationParams params,
  ) {
    final result = <Carton>[];
    final warnings = <String>[];
    var totalReduction = 0.0;
    var compressedCount = 0;

    for (var carton in cartons) {
      if (_isSoftGoods(carton.itemType)) {
        // Try to compress height
        var bestCarton = carton;
        var bestWeight = carton.chargeableWeight;

        // Try reducing height in 1-2cm steps
        for (
          var reduction = 1.0;
          reduction <= carton.heightCm - 10;
          reduction += 1.0
        ) {
          final newHeight = carton.heightCm - reduction;

          // Never reduce below 10cm
          if (newHeight < 10) break;

          final testCarton = carton.copyWith(heightCm: newHeight);

          // Check constraints
          if (testCarton.lengthCm > params.maxSideCm ||
              testCarton.widthCm > params.maxSideCm ||
              testCarton.heightCm > params.maxSideCm) {
            continue;
          }

          final testWeight = testCarton.chargeableWeight;
          if (testWeight < bestWeight) {
            bestCarton = testCarton;
            bestWeight = testWeight;
          } else {
            // No further improvement
            break;
          }
        }

        if (bestCarton != carton) {
          totalReduction += carton.heightCm - bestCarton.heightCm;
          compressedCount++;
        }
        result.add(bestCarton);
      } else {
        result.add(carton);
      }
    }

    final improved = compressedCount > 0;
    final description = improved
        ? '$compressedCount carton${compressedCount > 1 ? "s" : ""}, avg ${(totalReduction / compressedCount).toStringAsFixed(1)}cm reduction'
        : '';

    return _OptimizationPass(
      cartons: result,
      improved: improved,
      description: description,
      warnings: warnings,
    );
  }

  /// Pass 2: Consolidation of under-filled cartons
  _OptimizationPass _applyConsolidation(
    List<Carton> cartons,
    OptimizationParams params,
  ) {
    if (cartons.length <= 1) {
      return _OptimizationPass(
        cartons: cartons,
        improved: false,
        description: '',
        warnings: [],
      );
    }

    // Sort cartons by weight (heaviest first)
    final sortedCartons = List<Carton>.from(cartons)
      ..sort((a, b) => b.weightKg.compareTo(a.weightKg));

    final result = <Carton>[];
    final merged = <int>{}; // Track which indices were merged
    final warnings = <String>[];
    var consolidatedCount = 0;

    for (var i = 0; i < sortedCartons.length; i++) {
      if (merged.contains(i)) continue;

      var currentCarton = sortedCartons[i];

      // Try to absorb items from lighter cartons
      for (var j = i + 1; j < sortedCartons.length; j++) {
        if (merged.contains(j)) continue;

        final candidateCarton = sortedCartons[j];

        // Check if we can merge (same dimensions, total weight under limit)
        if (currentCarton.lengthCm == candidateCarton.lengthCm &&
            currentCarton.widthCm == candidateCarton.widthCm &&
            currentCarton.heightCm == candidateCarton.heightCm) {
          final combinedWeight =
              currentCarton.weightKg + candidateCarton.weightKg;

          if (combinedWeight <= params.perCartonMaxKg) {
            // Merge the cartons
            currentCarton = currentCarton.copyWith(
              qty: currentCarton.qty + candidateCarton.qty,
              weightKg: combinedWeight,
            );
            merged.add(j);
            consolidatedCount++;

            if (combinedWeight > params.perCartonMaxKg * 0.9) {
              warnings.add(
                'Carton ${currentCarton.id.substring(0, 8)}... is now ${combinedWeight.toStringAsFixed(1)}kg - close to ${params.perCartonMaxKg}kg limit',
              );
            }
          }
        }
      }

      result.add(currentCarton);
    }

    final improved = consolidatedCount > 0;
    final description = improved
        ? '$consolidatedCount carton${consolidatedCount > 1 ? "s" : ""} merged'
        : '';

    return _OptimizationPass(
      cartons: result,
      improved: improved,
      description: description,
      warnings: warnings,
    );
  }

  /// Pass 3: Standardization to common sizes
  _OptimizationPass _applyStandardization(
    List<Carton> cartons,
    OptimizationParams params,
  ) {
    final result = <Carton>[];
    final warnings = <String>[];
    var standardizedCount = 0;

    for (var carton in cartons) {
      var bestCarton = carton;
      var bestVolume = carton.lengthCm * carton.widthCm * carton.heightCm;

      // Try each standard size
      for (var stdSize in params.standardSizes) {
        // Check if this carton could fit in the standard size
        final dims = [carton.lengthCm, carton.widthCm, carton.heightCm]..sort();
        final stdDims = [stdSize.length, stdSize.width, stdSize.height]..sort();

        // Check if carton dimensions fit within standard size
        if (dims[0] <= stdDims[0] &&
            dims[1] <= stdDims[1] &&
            dims[2] <= stdDims[2]) {
          // Check constraints
          if (stdSize.length > params.maxSideCm ||
              stdSize.width > params.maxSideCm ||
              stdSize.height > params.maxSideCm) {
            continue;
          }

          final testCarton = carton.copyWith(
            lengthCm: stdSize.length,
            widthCm: stdSize.width,
            heightCm: stdSize.height,
          );

          // Check weight constraint
          if (testCarton.weightKg <= params.perCartonMaxKg) {
            final testVolume = stdSize.volume;
            // Only apply if volume doesn't increase too much
            if (testVolume <= bestVolume) {
              bestCarton = testCarton;
              bestVolume = testVolume;
            }
          }
        }
      }

      if (bestCarton != carton) {
        standardizedCount++;
      }
      result.add(bestCarton);
    }

    final improved = standardizedCount > 0;
    final description = improved
        ? '$standardizedCount carton${standardizedCount > 1 ? "s" : ""} standardized'
        : '';

    return _OptimizationPass(
      cartons: result,
      improved: improved,
      description: description,
      warnings: warnings,
    );
  }

  /// Generate clear rationale when no optimization is possible
  String _generateNoOptimizationRationale(
    List<Carton> cartons,
    OptimizationParams params,
    Map<String, bool> attemptedStrategies,
  ) {
    final reasons = <String>[];

    // Check why compression didn't work
    if (attemptedStrategies['compression'] == false) {
      final softGoodsCount = cartons
          .where((c) => _isSoftGoods(c.itemType))
          .length;
      if (softGoodsCount == 0) {
        reasons.add('No compressible items (all rigid goods)');
      } else {
        reasons.add('Soft goods already compressed to minimum safe height');
      }
    }

    // Check why consolidation didn't work
    if (attemptedStrategies['consolidation'] == false) {
      final totalWeight = cartons.fold(0.0, (sum, c) => sum + c.weightKg);
      final avgWeight = totalWeight / cartons.length;
      if (avgWeight > params.perCartonMaxKg * 0.8) {
        reasons.add(
          'All cartons are dense (avg ${avgWeight.toStringAsFixed(1)}kg); consolidation would exceed ${params.perCartonMaxKg}kg limit',
        );
      } else {
        reasons.add(
          'Cartons cannot be consolidated without exceeding weight limits',
        );
      }
    }

    // Check why standardization didn't work
    if (attemptedStrategies['standardization'] == false) {
      reasons.add(
        'Standardizing to standard sizes would increase total volume',
      );
    }

    // Check if already optimal sizes
    final oversizeCount = cartons.where((c) => c.isOversize).length;
    if (oversizeCount == 0 && reasons.isEmpty) {
      reasons.add(
        'All cartons already ≤ ${params.maxSideCm}cm (no oversize penalties)',
      );
    }

    return reasons.take(3).join('; ');
  }

  /// Calculate total chargeable weight for a list of cartons
  double _calculateTotalChargeableWeight(List<Carton> cartons) {
    return cartons.fold(0.0, (sum, c) => sum + c.totalChargeableWeight);
  }

  /// Check if an item type is soft goods (compressible)
  bool _isSoftGoods(String itemType) {
    final soft = [
      't-shirt',
      'tshirt',
      'hoodie',
      'sweatpants',
      'pants',
      'jeans',
      'jacket',
      'sweater',
      'dress',
      'shirt',
      'shorts',
      'apparel',
      'clothing',
      'garment',
    ];
    final lower = itemType.toLowerCase();
    return soft.any((keyword) => lower.contains(keyword));
  }
}

/// Internal class to track optimization pass results
class _OptimizationPass {
  final List<Carton> cartons;
  final bool improved;
  final String description;
  final List<String> warnings;

  _OptimizationPass({
    required this.cartons,
    required this.improved,
    required this.description,
    required this.warnings,
  });
}
