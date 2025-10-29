import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bockaire/themes/theme.dart';
import 'package:bockaire/widgets/modal/modal_card.dart';
import 'package:bockaire/widgets/modal/modal_utils.dart';
import 'package:bockaire/services/calculation_service.dart';
import 'package:bockaire/services/ai_optimizer_interfaces.dart';
import 'package:bockaire/services/gemini_packing_optimizer_service.dart';
import 'package:bockaire/services/ollama_packing_optimizer_service.dart';
import 'package:bockaire/providers/optimizer_provider.dart';
import 'package:bockaire/get_it.dart';
import 'package:bockaire/database/database.dart';
import 'package:bockaire/services/quote_calculator_service.dart';
import 'package:bockaire/classes/carton.dart' as models;
import 'package:bockaire/providers/shipment_providers.dart';
import 'package:bockaire/models/transport_method.dart';
import 'package:bockaire/utils/duration_parser.dart';
import 'package:bockaire/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import 'package:bockaire/services/optimization_engine_impl.dart';
import 'package:bockaire/classes/optimization_result.dart';
import 'package:bockaire/providers/optimization_settings_provider.dart';

class OptimizerPage extends ConsumerStatefulWidget {
  final String shipmentId;

  const OptimizerPage({super.key, required this.shipmentId});

  @override
  ConsumerState<OptimizerPage> createState() => _OptimizerPageState();
}

class _OptimizerPageState extends ConsumerState<OptimizerPage> {
  PackingRecommendation? _aiRecommendation;
  bool _isLoadingRecommendation = false;
  OptimizationResult? _ruleBasedResult;
  bool _isOptimizing = false;

  // Smart state detection
  bool get shouldShowRuleBasedResult =>
      _ruleBasedResult != null && _ruleBasedResult!.isActionable;

  bool get hasAiSuggestions =>
      _aiRecommendation != null &&
      _aiRecommendation!.estimatedSavingsPercent >= 1.0;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final cartonModelsAsync = ref.watch(
      cartonModelsProvider(widget.shipmentId),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: localizations.tooltipBack,
        ),
        title: Text(localizations.titlePackingOptimizer),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showHelpDialog(context),
            tooltip: localizations.tooltipHelp,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.pagePadding),
        children: [
          // Current Packing
          Text(
            localizations.optimizerCurrentPacking,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppTheme.spacingMedium),

          cartonModelsAsync.when(
            data: (cartons) {
              final totals = CalculationService.calculateTotals(cartons);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Current stats card
                  ModalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              color: context.colorScheme.primary,
                            ),
                            SizedBox(width: AppTheme.spacingSmall),
                            Text(
                              localizations.optimizerPackingSummary,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppTheme.spacingMedium),
                        _buildStatRow(
                          context,
                          localizations.optimizerTotalCartons,
                          '${totals.cartonCount}',
                        ),
                        SizedBox(height: AppTheme.spacingSmall),
                        _buildStatRow(
                          context,
                          localizations.optimizerActualWeight,
                          '${totals.actualKg.toStringAsFixed(1)} kg',
                        ),
                        SizedBox(height: AppTheme.spacingSmall),
                        _buildStatRow(
                          context,
                          localizations.optimizerDimensionalWeight,
                          '${totals.dimKg.toStringAsFixed(1)} kg',
                        ),
                        SizedBox(height: AppTheme.spacingSmall),
                        _buildStatRow(
                          context,
                          localizations.optimizerChargeableWeight,
                          '${totals.chargeableKg.toStringAsFixed(1)} kg',
                          isBold: true,
                          color: context.colorScheme.primary,
                        ),
                        SizedBox(height: AppTheme.spacingSmall),
                        _buildStatRow(
                          context,
                          localizations.optimizerLargestSide,
                          '${totals.largestSideCm.toStringAsFixed(0)} cm',
                        ),
                        if (totals.isOversized) ...[
                          SizedBox(height: AppTheme.spacingSmall),
                          Container(
                            padding: const EdgeInsets.all(
                              AppTheme.spacingSmall,
                            ),
                            decoration: BoxDecoration(
                              color: context.colorScheme.errorContainer
                                  .withAlpha(100),
                              borderRadius: BorderRadius.circular(
                                AppTheme.inputBorderRadius,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: context.colorScheme.error,
                                  size: 20,
                                ),
                                SizedBox(width: AppTheme.spacingSmall),
                                Expanded(
                                  child: Text(
                                    localizations.optimizerOversizeWarning,
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(
                                          color: context.colorScheme.error,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: AppTheme.spacingLarge),

                  // Packing Optimization Section (Unified)
                  Text(
                    'Packing Optimization',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingMedium),

                  // Smart optimizer button
                  Center(child: _buildSmartOptimizerButton(cartons)),

                  SizedBox(height: AppTheme.spacingMedium),

                  // Smart result display
                  if (shouldShowRuleBasedResult)
                    _buildRuleBasedResultCard(
                      _ruleBasedResult!,
                      cartons,
                      totals,
                    )
                  else if (hasAiSuggestions)
                    _buildAiResultCard(_aiRecommendation!, cartons)
                  else if (_ruleBasedResult != null &&
                      !_ruleBasedResult!.isActionable)
                    _buildNoOptimizationCard(cartons)
                  else
                    _buildInitialStateCard(),

                  SizedBox(height: AppTheme.spacingLarge),

                  // Optimization Suggestions (from totals)
                  if (totals.savingsHint != null) ...[
                    Text(
                      localizations.optimizerSuggestions,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingMedium),
                    _OptimizationSuggestionCard(
                      hint: totals.savingsHint!,
                      shipmentId: widget.shipmentId,
                      cartons: cartons,
                    ),
                    SizedBox(height: AppTheme.spacingLarge),
                  ],

                  SizedBox(height: AppTheme.spacingLarge),

                  // Carton List
                  Text(
                    localizations.optimizerCartonDetails,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingMedium),

                  ...cartons.asMap().entries.map((entry) {
                    final index = entry.key;
                    final carton = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: AppTheme.cardSpacing),
                      child: ModalCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  localizations.labelCartonNumber(index + 1),
                                  style: context.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '×${carton.qty}',
                                  style: context.textTheme.titleSmall?.copyWith(
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppTheme.spacingSmall),
                            Text(
                              localizations.optimizerDimensions(
                                carton.lengthCm,
                                carton.widthCm,
                                carton.heightCm,
                              ),
                              style: context.textTheme.bodyMedium,
                            ),
                            SizedBox(height: AppTheme.spacingXSmall),
                            Text(
                              localizations.optimizerWeight(carton.weightKg),
                              style: context.textTheme.bodyMedium,
                            ),
                            SizedBox(height: AppTheme.spacingXSmall),
                            Text(
                              localizations.optimizerItem(carton.itemType),
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) {
              final localizations2 = AppLocalizations.of(context)!;
              return Center(
                child: Text('${localizations2.errorLoadingCartons}: $err'),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/quotes/${widget.shipmentId}'),
        icon: const Icon(Icons.assessment_outlined),
        label: Text(localizations.buttonViewQuotes),
      ),
    );
  }

  Future<void> _getAIRecommendations(
    BuildContext context,
    List<models.Carton> cartons,
  ) async {
    final localizations = AppLocalizations.of(context)!;

    if (cartons.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.errorNoCartonsToOptimize)),
        );
      }
      return;
    }

    setState(() {
      _isLoadingRecommendation = true;
    });

    try {
      // Get selected provider
      final providerType = ref.read(optimizerProviderNotifierProvider);

      PackingOptimizerAI optimizer;
      if (providerType == OptimizerProviderType.gemini) {
        optimizer = getIt<GeminiPackingOptimizer>();
      } else {
        final baseUrl = ref.read(ollamaOptimizerBaseUrlProvider);
        final model = ref.read(ollamaOptimizerModelProvider);
        optimizer = OllamaPackingOptimizer(baseUrl: baseUrl, model: model);
      }

      // Get recommendations
      final optimizationContext = OptimizationContext(
        cartons: cartons,
        itemDescription: 'clothing items',
        allowCompression: true,
      );

      final recommendations = await optimizer.getRecommendations(
        context: optimizationContext,
      );

      if (mounted) {
        setState(() {
          _aiRecommendation = recommendations;
          _isLoadingRecommendation = false;
        });

        // Show recommendations in dialog
        _showRecommendationsDialog(cartons, recommendations);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRecommendation = false;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
      }
    }
  }

  Future<void> _showRecommendationsDialog(
    List<models.Carton> cartons,
    PackingRecommendation recommendation,
  ) async {
    final localizations = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.purple),
            SizedBox(width: 8),
            Expanded(child: Text(localizations.optimizerAIRecommendations)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recommended Box Count
              _buildDialogSection(
                icon: Icons.inventory_2,
                title: localizations.optimizerRecommendedBoxCount,
                content: recommendation.recommendedBoxCount.toString(),
                color: Colors.blue,
              ),
              SizedBox(height: 12),

              // Estimated Savings
              _buildDialogSection(
                icon: Icons.savings,
                title: localizations.optimizerEstimatedSavings,
                content:
                    '${recommendation.estimatedSavingsPercent.toStringAsFixed(1)}%',
                color: Colors.green,
              ),
              SizedBox(height: 12),

              // Explanation
              _buildDialogSection(
                icon: Icons.info_outline,
                title: localizations.optimizerExplanation,
                content: recommendation.explanation,
                color: Colors.purple,
              ),
              SizedBox(height: 12),

              // Compression Advice
              _buildDialogSection(
                icon: Icons.compress,
                title: localizations.optimizerCompressionAdvice,
                content: recommendation.compressionAdvice,
                color: Colors.orange,
              ),

              // Tips
              if (recommendation.tips.isNotEmpty) ...[
                SizedBox(height: 12),
                _buildDialogListSection(
                  icon: Icons.lightbulb_outline,
                  title: localizations.optimizerTips,
                  items: recommendation.tips,
                  color: Colors.amber,
                ),
              ],

              // Warnings
              if (recommendation.warnings.isNotEmpty) ...[
                SizedBox(height: 12),
                _buildDialogListSection(
                  icon: Icons.warning_amber,
                  title: localizations.optimizerWarnings,
                  items: recommendation.warnings,
                  color: Colors.red,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _applyAIRecommendations(cartons);
            },
            icon: Icon(Icons.check_circle),
            label: Text('Apply Recommendations'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(content, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDialogListSection({
    required IconData icon,
    required String title,
    required List<String> items,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: color)),
                  Expanded(child: Text(item, style: TextStyle(fontSize: 14))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _hasStructuralChanges({
    required List<models.Carton> before,
    required int afterBoxCount,
    required double estimatedSavingsPercent,
  }) async {
    // Compare total carton count
    final beforeCount = before.fold(0, (sum, c) => sum + c.qty);

    if (beforeCount != afterBoxCount) return true;

    // If box count same and estimated savings < 1%, consider it "no real change"
    return estimatedSavingsPercent >= 1.0;
  }

  Future<void> _applyAIRecommendations(
    List<models.Carton> currentCartons,
  ) async {
    if (_aiRecommendation == null) {
      return;
    }

    // Check if AI actually found meaningful changes
    final hasChanges = await _hasStructuralChanges(
      before: currentCartons,
      afterBoxCount: _aiRecommendation!.recommendedBoxCount,
      estimatedSavingsPercent: _aiRecommendation!.estimatedSavingsPercent,
    );

    if (!hasChanges) {
      setState(() {
        _isLoadingRecommendation = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'AI found your packing is already optimal. No changes needed.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
      return; // Don't regenerate quotes
    }

    // Show confirmation dialog
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply AI Recommendations?'),
        content: Text(
          'This will restructure your packing to ${_aiRecommendation!.recommendedBoxCount} boxes based on AI recommendations. Your current packing will be replaced.\n\nEstimated savings: ${_aiRecommendation!.estimatedSavingsPercent.toStringAsFixed(1)}%',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isLoadingRecommendation = true;
    });

    try {
      final db = getIt<AppDatabase>();
      final structuredData = _aiRecommendation!.structuredData;

      // Calculate totals from current cartons
      final totalWeight = currentCartons.fold<double>(
        0,
        (sum, c) => sum + (c.weightKg * c.qty),
      );

      // Get suggested dimensions or use average from current cartons
      double newLength = 50.0;
      double newWidth = 40.0;
      double newHeight = 40.0;

      if (structuredData != null &&
          structuredData['suggestedBoxDimensions'] is List) {
        final dims = structuredData['suggestedBoxDimensions'] as List;
        if (dims.length >= 3) {
          newLength = (dims[0] as num).toDouble();
          newWidth = (dims[1] as num).toDouble();
          newHeight = (dims[2] as num).toDouble();
        }
      } else {
        // Calculate average dimensions from current cartons
        newLength =
            currentCartons.fold<double>(0, (sum, c) => sum + c.lengthCm) /
            currentCartons.length;
        newWidth =
            currentCartons.fold<double>(0, (sum, c) => sum + c.widthCm) /
            currentCartons.length;
        newHeight =
            currentCartons.fold<double>(0, (sum, c) => sum + c.heightCm) /
            currentCartons.length;

        // Apply compression if suggested
        if (structuredData != null &&
            structuredData['compressionRatio'] is num) {
          final compressionRatio = (structuredData['compressionRatio'] as num)
              .toDouble();
          // Apply compression primarily to height
          newHeight = newHeight * compressionRatio;
        }
      }

      final recommendedBoxCount = _aiRecommendation!.recommendedBoxCount;
      final weightPerBox = totalWeight / recommendedBoxCount;

      // Get first carton's item type or use generic
      final itemType = currentCartons.isNotEmpty
          ? currentCartons.first.itemType
          : 'Mixed';

      // Delete all existing cartons for this shipment
      await (db.delete(
        db.cartons,
      )..where((c) => c.shipmentId.equals(widget.shipmentId))).go();
      // Insert new optimized cartons
      for (int i = 0; i < recommendedBoxCount; i++) {
        await db
            .into(db.cartons)
            .insert(
              CartonsCompanion(
                id: drift.Value(const Uuid().v4()),
                shipmentId: drift.Value(widget.shipmentId),
                lengthCm: drift.Value(newLength),
                widthCm: drift.Value(newWidth),
                heightCm: drift.Value(newHeight),
                weightKg: drift.Value(weightPerBox),
                qty: drift.Value(1),
                itemType: drift.Value('$itemType (AI Optimized)'),
              ),
            );
      }

      // Fetch updated cartons
      final updatedCartons = await (db.select(
        db.cartons,
      )..where((c) => c.shipmentId.equals(widget.shipmentId))).get();

      // Convert to model cartons
      final cartonModels = updatedCartons
          .map(
            (c) => models.Carton(
              id: c.id,
              shipmentId: c.shipmentId,
              lengthCm: c.lengthCm,
              widthCm: c.widthCm,
              heightCm: c.heightCm,
              weightKg: c.weightKg,
              qty: c.qty,
              itemType: c.itemType,
            ),
          )
          .toList();

      final totals = CalculationService.calculateTotals(cartonModels);

      // Fetch shipment
      final shipment = await (db.select(
        db.shipments,
      )..where((s) => s.id.equals(widget.shipmentId))).getSingle();
      // Regenerate quotes
      final quoteService = getIt<QuoteCalculatorService>();
      final newQuotes = await quoteService.calculateAllQuotes(
        chargeableKg: totals.chargeableKg,
        isOversized: totals.isOversized,
        originCity: shipment.originCity,
        originPostal: shipment.originPostal,
        originCountry: shipment.originCountry,
        originState: shipment.originState,
        destCity: shipment.destCity,
        destPostal: shipment.destPostal,
        destCountry: shipment.destCountry,
        destState: shipment.destState,
        cartons: updatedCartons,
      );

      // Delete old quotes
      await (db.delete(
        db.quotes,
      )..where((q) => q.shipmentId.equals(widget.shipmentId))).go();

      // Save new quotes
      for (final quote in newQuotes) {
        // Parse duration from quote
        final (etaMin, etaMax) = parseDuration(
          quote.estimatedDays,
          quote.durationTerms,
        );

        // Classify transport method
        final transportMethod = classifyTransportMethod(
          quote.carrier,
          quote.service,
          quote.estimatedDays ?? 5,
        );

        await db
            .into(db.quotes)
            .insert(
              QuotesCompanion(
                id: drift.Value(const Uuid().v4()),
                shipmentId: drift.Value(widget.shipmentId),
                carrier: drift.Value(quote.carrier),
                service: drift.Value(quote.service),
                etaMin: drift.Value(etaMin),
                etaMax: drift.Value(etaMax),
                priceEur: drift.Value(quote.total),
                chargeableKg: drift.Value(quote.chargeableKg),
                transportMethod: drift.Value(transportMethod.name),
              ),
            );
      }

      // Invalidate providers to refresh UI
      // Must invalidate cartonsProvider first, as cartonModelsProvider depends on it
      ref.invalidate(cartonsProvider(widget.shipmentId));
      ref.invalidate(cartonModelsProvider(widget.shipmentId));
      ref.invalidate(quotesProvider(widget.shipmentId));

      if (mounted) {
        setState(() {
          _isLoadingRecommendation = false;
          _aiRecommendation = null; // Clear recommendations after applying
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Applied AI recommendations: $recommendedBoxCount boxes created',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRecommendation = false;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error applying recommendations: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildSmartOptimizerButton(List<models.Carton> cartons) {
    if (_ruleBasedResult == null) {
      // First click: Run rule-based optimizer
      return ElevatedButton.icon(
        onPressed: _isOptimizing ? null : () => _runRuleBasedOptimizer(cartons),
        icon: _isOptimizing
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.bolt),
        label: Text(_isOptimizing ? 'Analyzing...' : 'Optimize Packing'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      );
    } else if (!_ruleBasedResult!.isActionable && _aiRecommendation == null) {
      // Suggest trying AI optimizer
      return ElevatedButton.icon(
        onPressed: _isLoadingRecommendation
            ? null
            : () => _getAIRecommendations(context, cartons),
        icon: _isLoadingRecommendation
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.auto_awesome),
        label: Text(
          _isLoadingRecommendation
              ? 'Getting AI Suggestions...'
              : 'Try AI Optimizer',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      );
    } else {
      // Re-optimize button
      return ElevatedButton.icon(
        onPressed: _isOptimizing
            ? null
            : () {
                setState(() {
                  _ruleBasedResult = null;
                  _aiRecommendation = null;
                });
                _runRuleBasedOptimizer(cartons);
              },
        icon: _isOptimizing
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.refresh),
        label: Text(_isOptimizing ? 'Analyzing...' : 'Re-optimize'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      );
    }
  }

  Widget _buildInitialStateCard() {
    return ModalCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 64,
                color: context.colorScheme.primary,
              ),
              SizedBox(height: AppTheme.spacingMedium),
              Text(
                'Run Optimizer to See Suggestions',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppTheme.spacingSmall),
              Text(
                'Click the button above to analyze your packing and get optimization suggestions.',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoOptimizationCard(List<models.Carton> cartons) {
    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.info_outline, color: Colors.orange, size: 24),
              ),
              SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: Text(
                  'No Optimization Possible',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingMedium),
          Text(
            'Reasons:',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppTheme.spacingSmall),
          Text(
            _ruleBasedResult!.rationale,
            style: context.textTheme.bodyMedium,
          ),
          SizedBox(height: AppTheme.spacingMedium),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _getAIRecommendations(context, cartons),
              icon: Icon(Icons.auto_awesome),
              label: Text('Try AI Suggestions'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.purple),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiResultCard(
    PackingRecommendation recommendation,
    List<models.Carton> cartons,
  ) {
    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.auto_awesome, color: Colors.purple, size: 24),
              ),
              SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: Text(
                  'AI Advanced Analysis',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingMedium),
          _buildStatRow(
            context,
            'Recommended Box Count',
            '${recommendation.recommendedBoxCount}',
          ),
          SizedBox(height: AppTheme.spacingXSmall),
          _buildStatRow(
            context,
            'Estimated Savings',
            '${recommendation.estimatedSavingsPercent.toStringAsFixed(1)}%',
            isBold: true,
            color: Colors.green,
          ),
          SizedBox(height: AppTheme.spacingMedium),
          Text(
            'Explanation:',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppTheme.spacingSmall),
          Text(recommendation.explanation, style: context.textTheme.bodyMedium),
          if (recommendation.warnings.isNotEmpty) ...[
            SizedBox(height: AppTheme.spacingMedium),
            Text(
              'Warnings:',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: AppTheme.spacingSmall),
            ...recommendation.warnings.map(
              (warning) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warning,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(height: AppTheme.spacingMedium),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      _showRecommendationsDialog(cartons, recommendation),
                  child: Text('View Details'),
                ),
              ),
              SizedBox(width: AppTheme.spacingSmall),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _applyAIRecommendations(cartons),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Apply Plan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _runRuleBasedOptimizer(List<models.Carton> cartons) async {
    setState(() => _isOptimizing = true);

    try {
      final params = ref.read(optimizationParamsProvider);
      final engine = OptimizationEngineImpl();

      final result = await Future.microtask(
        () => engine.optimize(cartons, params),
      );

      if (mounted) {
        setState(() {
          _ruleBasedResult = result;
          _isOptimizing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isOptimizing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Optimization error: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildRuleBasedResultCard(
    OptimizationResult result,
    List<models.Carton> cartons,
    dynamic totals,
  ) {
    // Actionable result (only called when isActionable is true)
    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.check_circle, color: Colors.green, size: 24),
              ),
              SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: Text(
                  'Optimization Found',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingMedium),
          _buildStatRow(
            context,
            'Before',
            '${result.beforeCartonCount} cartons, ${result.beforeChargeableKg.toStringAsFixed(1)}kg',
          ),
          SizedBox(height: AppTheme.spacingXSmall),
          _buildStatRow(
            context,
            'After',
            '${result.afterCartonCount} cartons, ${result.afterChargeableKg.toStringAsFixed(1)}kg',
          ),
          SizedBox(height: AppTheme.spacingXSmall),
          _buildStatRow(
            context,
            'Savings',
            '${result.savingsPercent.toStringAsFixed(1)}%',
            isBold: true,
            color: Colors.green,
          ),
          SizedBox(height: AppTheme.spacingMedium),
          Text(
            'Applied: ${result.appliedStrategies.join(", ")}',
            style: context.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
          if (result.warnings.isNotEmpty) ...[
            SizedBox(height: AppTheme.spacingSmall),
            ...result.warnings.map(
              (warning) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warning,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(height: AppTheme.spacingMedium),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showOptimizationDetails(result),
                  child: Text('Details'),
                ),
              ),
              SizedBox(width: AppTheme.spacingSmall),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _applyRuleBasedPlan(result),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Apply Plan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOptimizationDetails(OptimizationResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Optimization Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildComparisonTable(result),
              SizedBox(height: 16),
              Text(
                'Applied Strategies:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ...result.appliedStrategies.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $s'),
                ),
              ),
              if (result.warnings.isNotEmpty) ...[
                SizedBox(height: 16),
                Text(
                  'Warnings:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 8),
                ...result.warnings.map(
                  (w) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $w', style: TextStyle(color: Colors.orange)),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable(OptimizationResult result) {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        TableRow(
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Metric',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Before',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'After',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(padding: EdgeInsets.all(8), child: Text('Cartons')),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text('${result.beforeCartonCount}'),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text('${result.afterCartonCount}'),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(padding: EdgeInsets.all(8), child: Text('Chargeable Wt')),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text('${result.beforeChargeableKg.toStringAsFixed(1)} kg'),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text('${result.afterChargeableKg.toStringAsFixed(1)} kg'),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(padding: EdgeInsets.all(8), child: Text('Volume')),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                '${(result.beforeVolumeCm3 / 1000000).toStringAsFixed(2)} m³',
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                '${(result.afterVolumeCm3 / 1000000).toStringAsFixed(2)} m³',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _applyRuleBasedPlan(OptimizationResult result) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply Optimization Plan?'),
        content: Text(
          'This will update your packing from ${result.beforeCartonCount} to ${result.afterCartonCount} cartons.\n\n'
          'Estimated savings: ${result.savingsPercent.toStringAsFixed(1)}%\n\n'
          'Your current packing will be replaced.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _isOptimizing = true);

    try {
      final db = getIt<AppDatabase>();

      // Delete all existing cartons for this shipment
      await (db.delete(
        db.cartons,
      )..where((c) => c.shipmentId.equals(widget.shipmentId))).go();

      // Insert optimized cartons
      for (final carton in result.afterCartons) {
        await db
            .into(db.cartons)
            .insert(
              CartonsCompanion(
                id: drift.Value(carton.id),
                shipmentId: drift.Value(widget.shipmentId),
                lengthCm: drift.Value(carton.lengthCm),
                widthCm: drift.Value(carton.widthCm),
                heightCm: drift.Value(carton.heightCm),
                weightKg: drift.Value(carton.weightKg),
                qty: drift.Value(carton.qty),
                itemType: drift.Value(carton.itemType),
              ),
            );
      }

      // Fetch updated cartons
      final updatedCartons = await (db.select(
        db.cartons,
      )..where((c) => c.shipmentId.equals(widget.shipmentId))).get();

      // Convert to model cartons
      final cartonModels = updatedCartons
          .map(
            (c) => models.Carton(
              id: c.id,
              shipmentId: c.shipmentId,
              lengthCm: c.lengthCm,
              widthCm: c.widthCm,
              heightCm: c.heightCm,
              weightKg: c.weightKg,
              qty: c.qty,
              itemType: c.itemType,
            ),
          )
          .toList();

      final totals = CalculationService.calculateTotals(cartonModels);

      // Fetch shipment
      final shipment = await (db.select(
        db.shipments,
      )..where((s) => s.id.equals(widget.shipmentId))).getSingle();

      // Regenerate quotes
      final quoteService = getIt<QuoteCalculatorService>();
      final newQuotes = await quoteService.calculateAllQuotes(
        chargeableKg: totals.chargeableKg,
        isOversized: totals.isOversized,
        originCity: shipment.originCity,
        originPostal: shipment.originPostal,
        originCountry: shipment.originCountry,
        originState: shipment.originState,
        destCity: shipment.destCity,
        destPostal: shipment.destPostal,
        destCountry: shipment.destCountry,
        destState: shipment.destState,
        cartons: updatedCartons,
      );

      // Delete old quotes
      await (db.delete(
        db.quotes,
      )..where((q) => q.shipmentId.equals(widget.shipmentId))).go();

      // Save new quotes
      for (final quote in newQuotes) {
        final (etaMin, etaMax) = parseDuration(
          quote.estimatedDays,
          quote.durationTerms,
        );

        final transportMethod = classifyTransportMethod(
          quote.carrier,
          quote.service,
          quote.estimatedDays ?? 5,
        );

        await db
            .into(db.quotes)
            .insert(
              QuotesCompanion(
                id: drift.Value(const Uuid().v4()),
                shipmentId: drift.Value(widget.shipmentId),
                carrier: drift.Value(quote.carrier),
                service: drift.Value(quote.service),
                etaMin: drift.Value(etaMin),
                etaMax: drift.Value(etaMax),
                priceEur: drift.Value(quote.total),
                chargeableKg: drift.Value(quote.chargeableKg),
                transportMethod: drift.Value(transportMethod.name),
              ),
            );
      }

      // Invalidate providers to refresh UI
      // Must invalidate cartonsProvider first, as cartonModelsProvider depends on it
      ref.invalidate(cartonsProvider(widget.shipmentId));
      ref.invalidate(cartonModelsProvider(widget.shipmentId));
      ref.invalidate(quotesProvider(widget.shipmentId));

      if (mounted) {
        setState(() {
          _isOptimizing = false;
          _ruleBasedResult = null; // Clear result after applying
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Optimization applied: ${result.afterCartonCount} cartons created',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isOptimizing = false);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error applying optimization: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showHelpDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    ModalUtils.showSinglePageModal(
      context: context,
      title: localizations.optimizerHelpTitle,
      showCloseButton: true,
      barrierDismissible: true,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      stickyActionBar: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.buttonGotIt),
        ),
      ),
      builder: (modalContext) {
        return Text(localizations.optimizerHelpContent);
      },
    );
  }
}

class _OptimizationSuggestionCard extends ConsumerStatefulWidget {
  final String hint;
  final String shipmentId;
  final List<dynamic> cartons;

  const _OptimizationSuggestionCard({
    required this.hint,
    required this.shipmentId,
    required this.cartons,
  });

  @override
  ConsumerState<_OptimizationSuggestionCard> createState() =>
      _OptimizationSuggestionCardState();
}

class _OptimizationSuggestionCardState
    extends ConsumerState<_OptimizationSuggestionCard> {
  bool _isApplying = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: context.colorScheme.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.optimizerCostSavingOpportunity,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingXSmall),
                    Text(widget.hint, style: context.textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingMedium),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isApplying ? null : _applySuggestion,
                  child: _isApplying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(localizations.buttonApplySuggestion),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _applySuggestion() async {
    setState(() => _isApplying = true);

    try {
      final db = getIt<AppDatabase>();

      // Find the tallest carton and reduce its height by 5cm
      final sortedCartons = List.from(widget.cartons)
        ..sort((a, b) => b.heightCm.compareTo(a.heightCm));

      if (sortedCartons.isNotEmpty) {
        final tallest = sortedCartons.first;
        final newHeight = tallest.heightCm - 5.0;

        if (newHeight > 0) {
          // Update the carton in database
          await (db.update(db.cartons)..where((c) => c.id.equals(tallest.id)))
              .write(CartonsCompanion(heightCm: drift.Value(newHeight)));

          // Fetch updated cartons for recalculation
          final updatedCartons = await (db.select(
            db.cartons,
          )..where((c) => c.shipmentId.equals(widget.shipmentId))).get();

          // Convert to model cartons for calculation
          final cartonModels = updatedCartons
              .map(
                (c) => models.Carton(
                  id: c.id,
                  shipmentId: c.shipmentId,
                  lengthCm: c.lengthCm,
                  widthCm: c.widthCm,
                  heightCm: c.heightCm,
                  weightKg: c.weightKg,
                  qty: c.qty,
                  itemType: c.itemType,
                ),
              )
              .toList();

          final totals = CalculationService.calculateTotals(cartonModels);

          // Fetch shipment to get address information
          final shipment = await (db.select(
            db.shipments,
          )..where((s) => s.id.equals(widget.shipmentId))).getSingle();

          // Regenerate quotes with new dimensions
          final quoteService = getIt<QuoteCalculatorService>();
          final newQuotes = await quoteService.calculateAllQuotes(
            chargeableKg: totals.chargeableKg,
            isOversized: totals.isOversized,
            originCity: shipment.originCity,
            originPostal: shipment.originPostal,
            originCountry: shipment.originCountry,
            originState: shipment.originState,
            destCity: shipment.destCity,
            destPostal: shipment.destPostal,
            destCountry: shipment.destCountry,
            destState: shipment.destState,
            cartons: updatedCartons,
          );

          // Delete old quotes
          await (db.delete(
            db.quotes,
          )..where((q) => q.shipmentId.equals(widget.shipmentId))).go();

          // Save new quotes
          for (final quote in newQuotes) {
            // Parse duration from quote
            final (etaMin, etaMax) = parseDuration(
              quote.estimatedDays,
              quote.durationTerms,
            );

            // Classify transport method
            final transportMethod = classifyTransportMethod(
              quote.carrier,
              quote.service,
              quote.estimatedDays ?? 5,
            );

            await db
                .into(db.quotes)
                .insert(
                  QuotesCompanion(
                    id: drift.Value(const Uuid().v4()),
                    shipmentId: drift.Value(widget.shipmentId),
                    carrier: drift.Value(quote.carrier),
                    service: drift.Value(quote.service),
                    etaMin: drift.Value(etaMin),
                    etaMax: drift.Value(etaMax),
                    priceEur: drift.Value(quote.total),
                    chargeableKg: drift.Value(quote.chargeableKg),
                    transportMethod: drift.Value(transportMethod.name),
                  ),
                );
          }

          // Refresh the page by invalidating providers
          // Must invalidate cartonsProvider first, as cartonModelsProvider depends on it
          ref.invalidate(cartonsProvider(widget.shipmentId));
          ref.invalidate(cartonModelsProvider(widget.shipmentId));
          ref.invalidate(quotesProvider(widget.shipmentId));

          if (mounted) {
            final localizations = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.successOptimizationApplied),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${localizations.errorApplySuggestion}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }
}
