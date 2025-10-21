import 'package:bockaire/classes/carton.dart';
import 'package:bockaire/classes/optimization_params.dart';
import 'package:bockaire/classes/optimization_result.dart';

/// Abstract interface for packing optimization engine
abstract class OptimizationEngine {
  /// Main optimization method
  ///
  /// Takes a list of cartons and optimization parameters,
  /// applies rule-based optimization strategies, and returns
  /// a detailed result with before/after metrics.
  OptimizationResult optimize(List<Carton> cartons, OptimizationParams params);
}
