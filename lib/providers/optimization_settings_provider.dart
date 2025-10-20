import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bockaire/classes/optimization_params.dart';

/// Provider for optimization parameters
final optimizationParamsProvider =
    StateNotifierProvider<OptimizationParamsNotifier, OptimizationParams>((
      ref,
    ) {
      return OptimizationParamsNotifier();
    });

/// State notifier for managing optimization parameters
class OptimizationParamsNotifier extends StateNotifier<OptimizationParams> {
  OptimizationParamsNotifier() : super(const OptimizationParams()) {
    _loadFromPrefs();
  }

  /// Load settings from shared preferences
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = OptimizationParams(
      maxSideCm: prefs.getInt('opt_max_side_cm') ?? 60,
      perCartonMaxKg: prefs.getDouble('opt_per_carton_max_kg') ?? 24.0,
      minSavingsPct: prefs.getDouble('opt_min_savings_pct') ?? 3.0,
      allowCompression: prefs.getBool('opt_allow_compression') ?? true,
      preferUniformSizes: prefs.getBool('opt_prefer_uniform') ?? true,
    );
  }

  /// Update maximum side dimension
  Future<void> updateMaxSideCm(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('opt_max_side_cm', value);
    state = state.copyWith(maxSideCm: value);
  }

  /// Update maximum weight per carton
  Future<void> updatePerCartonMaxKg(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('opt_per_carton_max_kg', value);
    state = state.copyWith(perCartonMaxKg: value);
  }

  /// Update minimum savings threshold percentage
  Future<void> updateMinSavingsPct(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('opt_min_savings_pct', value);
    state = state.copyWith(minSavingsPct: value);
  }

  /// Update whether compression is allowed
  Future<void> updateAllowCompression(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('opt_allow_compression', value);
    state = state.copyWith(allowCompression: value);
  }

  /// Update whether to prefer uniform sizes
  Future<void> updatePreferUniformSizes(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('opt_prefer_uniform', value);
    state = state.copyWith(preferUniformSizes: value);
  }
}
