import 'package:flutter/material.dart';
import 'package:bockaire/classes/carton.dart';
import 'package:bockaire/services/packing_optimizer_service.dart';
import 'package:bockaire/services/calculation_service.dart';
import 'package:bockaire/themes/theme.dart';
import 'package:bockaire/widgets/modal/modal_card.dart';
import 'package:bockaire/widgets/modal/modal_utils.dart';
import 'package:bockaire/l10n/app_localizations.dart';

/// Show optimize packing modal
Future<List<Carton>?> showOptimizePackingModal({
  required BuildContext context,
  required List<Carton> currentCartons,
  required String shipmentId,
}) async {
  final optimizer = PackingOptimizerService();
  final result = optimizer.optimize(
    currentCartons: currentCartons,
    shipmentId: shipmentId,
  );

  final localizations = AppLocalizations.of(context)!;
  return ModalUtils.showSinglePageModal<List<Carton>>(
    context: context,
    title: localizations.actionOptimizePacking,
    builder: (modalContext) => _OptimizePackingContent(result: result),
  );
}

class _OptimizePackingContent extends StatelessWidget {
  final OptimizationResult result;

  const _OptimizePackingContent({required this.result});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final originalTotals = CalculationService.calculateTotals(
      result.originalCartons,
    );
    final optimizedTotals = CalculationService.calculateTotals(
      result.optimizedCartons,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (result.hasImprovement) ...[
            // Savings summary
            Container(
              padding: const EdgeInsets.all(AppTheme.cardPadding),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(30),
                borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
                border: Border.all(
                  color: Colors.green.withAlpha(100),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 48,
                  ),
                  SizedBox(height: AppTheme.spacingSmall),
                  Text(
                    localizations.optimizationFoundTitle,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingSmall),
                  if (result.savings.cartonCountReduction > 0)
                    Text(
                      localizations.fewerCartons(
                        result.savings.cartonCountReduction,
                      ),
                      style: context.textTheme.bodyMedium,
                    ),
                  if (result.savings.chargeableKgReduction > 0)
                    Text(
                      localizations.lessChargeableWeight(
                        result.savings.chargeableKgReduction.toStringAsFixed(1),
                      ),
                      style: context.textTheme.bodyMedium,
                    ),
                ],
              ),
            ),
            SizedBox(height: AppTheme.spacingLarge),
          ] else ...[
            // No improvement message
            Container(
              padding: const EdgeInsets.all(AppTheme.cardPadding),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: context.colorScheme.primary,
                    size: 48,
                  ),
                  SizedBox(height: AppTheme.spacingSmall),
                  Text(
                    localizations.currentPackingOptimal,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTheme.spacingLarge),
          ],

          // Before/After comparison
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ComparisonColumn(
                  title: localizations.comparisonCurrent,
                  cartons: result.originalCartons,
                  totals: originalTotals,
                  color: Colors.orange,
                ),
              ),
              SizedBox(width: AppTheme.spacingMedium),
              Icon(
                Icons.arrow_forward,
                color: context.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: _ComparisonColumn(
                  title: localizations.comparisonOptimized,
                  cartons: result.optimizedCartons,
                  totals: optimizedTotals,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.spacingLarge),

          // Action buttons
          if (result.hasImprovement) ...[
            SizedBox(
              height: AppTheme.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: () =>
                    Navigator.of(context).pop(result.optimizedCartons),
                icon: const Icon(Icons.check),
                label: Text(localizations.buttonApplyOptimization),
              ),
            ),
            SizedBox(height: AppTheme.spacingMedium),
          ],
          SizedBox(
            height: AppTheme.buttonHeight,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(
                result.hasImprovement
                    ? localizations.buttonKeepOriginal
                    : localizations.buttonClose,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonColumn extends StatelessWidget {
  final String title;
  final List<Carton> cartons;
  final ShipmentTotals totals;
  final Color color;

  const _ComparisonColumn({
    required this.title,
    required this.cartons,
    required this.totals,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: AppTheme.spacingSmall),
        ModalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStat(
                context,
                localizations.statCartons,
                '${totals.cartonCount}',
                Icons.inventory_2_outlined,
              ),
              SizedBox(height: AppTheme.spacingSmall),
              _buildStat(
                context,
                localizations.statChargeable,
                '${totals.chargeableKg.toStringAsFixed(1)} kg',
                Icons.local_shipping_outlined,
              ),
              SizedBox(height: AppTheme.spacingSmall),
              _buildStat(
                context,
                localizations.statVolume,
                '${(totals.totalVolumeCm3 / 1000000).toStringAsFixed(2)} m³',
                Icons.view_in_ar_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.colorScheme.onSurfaceVariant),
        SizedBox(width: AppTheme.spacingSmall),
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
