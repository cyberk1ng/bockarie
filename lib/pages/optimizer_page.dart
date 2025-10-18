import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bockaire/themes/theme.dart';
import 'package:bockaire/widgets/modal/modal_card.dart';
import 'package:bockaire/services/calculation_service.dart';
import 'package:bockaire/get_it.dart';
import 'package:bockaire/database/database.dart';
import 'package:bockaire/services/quote_calculator_service.dart';
import 'package:bockaire/classes/carton.dart' as models;
import 'package:bockaire/providers/shipment_providers.dart';
import 'package:bockaire/models/transport_method.dart';
import 'package:bockaire/utils/duration_parser.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

class OptimizerPage extends ConsumerWidget {
  final String shipmentId;

  const OptimizerPage({super.key, required this.shipmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartonModelsAsync = ref.watch(cartonModelsProvider(shipmentId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: const Text('Packing Optimizer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showHelpDialog(context),
            tooltip: 'Help',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.pagePadding),
        children: [
          // Current Packing
          Text(
            'Current Packing',
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
                              'Packing Summary',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppTheme.spacingMedium),
                        _buildStatRow(
                          context,
                          'Total Cartons',
                          '${totals.cartonCount}',
                        ),
                        SizedBox(height: AppTheme.spacingSmall),
                        _buildStatRow(
                          context,
                          'Actual Weight',
                          '${totals.actualKg.toStringAsFixed(1)} kg',
                        ),
                        SizedBox(height: AppTheme.spacingSmall),
                        _buildStatRow(
                          context,
                          'Dimensional Weight',
                          '${totals.dimKg.toStringAsFixed(1)} kg',
                        ),
                        SizedBox(height: AppTheme.spacingSmall),
                        _buildStatRow(
                          context,
                          'Chargeable Weight',
                          '${totals.chargeableKg.toStringAsFixed(1)} kg',
                          isBold: true,
                          color: context.colorScheme.primary,
                        ),
                        SizedBox(height: AppTheme.spacingSmall),
                        _buildStatRow(
                          context,
                          'Largest Side',
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
                                    'Oversize detected - extra fees apply',
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

                  // Optimization Suggestions
                  Text(
                    'Optimization Suggestions',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingMedium),

                  if (totals.savingsHint != null)
                    _OptimizationSuggestionCard(
                      hint: totals.savingsHint!,
                      shipmentId: shipmentId,
                      cartons: cartons,
                    )
                  else
                    ModalCard(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 64,
                                color: context.colorScheme.primary,
                              ),
                              SizedBox(height: AppTheme.spacingMedium),
                              Text(
                                'Packing looks optimal!',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: AppTheme.spacingSmall),
                              Text(
                                'Your current packing is efficient. No optimization suggestions at this time.',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: AppTheme.spacingLarge),

                  // Carton List
                  Text(
                    'Carton Details',
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
                                  'Carton ${index + 1}',
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
                              'Dimensions: ${carton.lengthCm}×${carton.widthCm}×${carton.heightCm} cm',
                              style: context.textTheme.bodyMedium,
                            ),
                            SizedBox(height: AppTheme.spacingXSmall),
                            Text(
                              'Weight: ${carton.weightKg} kg',
                              style: context.textTheme.bodyMedium,
                            ),
                            SizedBox(height: AppTheme.spacingXSmall),
                            Text(
                              'Item: ${carton.itemType}',
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
            error: (err, stack) =>
                Center(child: Text('Error loading cartons: $err')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/quotes/$shipmentId'),
        icon: const Icon(Icons.assessment_outlined),
        label: const Text('View Quotes'),
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

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Packing Optimizer'),
        content: const Text(
          'The packing optimizer analyzes your cartons and suggests ways to reduce '
          'shipping costs by optimizing dimensions.\n\n'
          'Key metrics:\n'
          '• Actual Weight: Physical weight of items\n'
          '• Dimensional Weight: Calculated from carton size\n'
          '• Chargeable Weight: Higher of the two\n\n'
          'Tip: Reducing carton height often provides the best savings!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
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
                      'Cost Saving Opportunity',
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
                      : const Text('Apply Suggestion'),
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
          ref.invalidate(cartonModelsProvider(widget.shipmentId));
          ref.invalidate(quotesProvider(widget.shipmentId));

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Optimization applied! Quotes have been recalculated.',
                ),
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error applying suggestion: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }
}
