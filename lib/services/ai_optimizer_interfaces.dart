import 'package:bockaire/classes/carton.dart';

/// Context for AI optimization request
class OptimizationContext {
  final List<Carton> cartons;
  final String? itemDescription; // e.g., "cotton t-shirts"
  final String? materialType; // e.g., "cotton", "polyester", "leather"
  final bool allowCompression;
  final double maxWeightPerBox;

  const OptimizationContext({
    required this.cartons,
    this.itemDescription,
    this.materialType,
    this.allowCompression = true,
    this.maxWeightPerBox = 24.0,
  });
}

/// AI-generated packing recommendations
class PackingRecommendation {
  final int recommendedBoxCount;
  final String compressionAdvice;
  final double estimatedSavingsPercent;
  final List<String> warnings;
  final List<String> tips;
  final String explanation;
  final Map<String, dynamic>? structuredData; // For applying recommendations

  const PackingRecommendation({
    required this.recommendedBoxCount,
    required this.compressionAdvice,
    required this.estimatedSavingsPercent,
    required this.warnings,
    required this.tips,
    required this.explanation,
    this.structuredData,
  });

  factory PackingRecommendation.fromJson(Map<String, dynamic> json) {
    return PackingRecommendation(
      recommendedBoxCount: json['recommendedBoxCount'] as int,
      compressionAdvice: json['compressionAdvice'] as String,
      estimatedSavingsPercent: (json['estimatedSavingsPercent'] as num)
          .toDouble(),
      warnings: (json['warnings'] as List?)?.cast<String>() ?? [],
      tips: (json['tips'] as List?)?.cast<String>() ?? [],
      explanation: json['explanation'] as String,
      structuredData: json['structuredData'] as Map<String, dynamic>?,
    );
  }
}

/// Base interface for AI-powered packing optimizers
abstract class PackingOptimizerAI {
  String get name;
  bool get isAvailable;

  /// Get AI-powered optimization recommendations
  Future<PackingRecommendation> getRecommendations({
    required OptimizationContext context,
  });
}
