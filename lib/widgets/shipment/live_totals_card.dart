import 'package:flutter/material.dart';
import 'package:bockaire/services/calculation_service.dart';
import 'package:bockaire/themes/theme.dart';
import 'package:bockaire/widgets/modal/modal_card.dart';

/// Live calculation summary card
class LiveTotalsCard extends StatelessWidget {
  final ShipmentTotals totals;

  const LiveTotalsCard({required this.totals, super.key});

  @override
  Widget build(BuildContext context) {
    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calculate_outlined,
                color: context.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: AppTheme.spacingSmall),
              Text(
                'Live Calculations',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingMedium),

          // Carton count
          _buildRow(
            context,
            label: 'Cartons',
            value: '${totals.cartonCount}',
            icon: Icons.inventory_2_outlined,
          ),

          SizedBox(height: AppTheme.spacingSmall),

          // Actual weight
          _buildRow(
            context,
            label: 'Actual Weight',
            value: '${totals.actualKg.toStringAsFixed(1)} kg',
            icon: Icons.scale_outlined,
          ),

          SizedBox(height: AppTheme.spacingSmall),

          // Dimensional weight
          _buildRow(
            context,
            label: 'Dim Weight',
            value: '${totals.dimKg.toStringAsFixed(1)} kg',
            icon: Icons.straighten_outlined,
            subtitle: '(L×W×H)/5000',
          ),

          SizedBox(height: AppTheme.spacingSmall),

          // Chargeable weight (highlighted)
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppTheme.spacingSmall,
              horizontal: AppTheme.spacingSmall,
            ),
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer.withAlpha(50),
              borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
            ),
            child: _buildRow(
              context,
              label: 'Chargeable Weight',
              value: '${totals.chargeableKg.toStringAsFixed(1)} kg',
              icon: Icons.local_shipping_outlined,
              subtitle: 'max(Actual, Dim)',
              valueStyle: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colorScheme.primary,
              ),
            ),
          ),

          SizedBox(height: AppTheme.spacingSmall),

          // Largest side
          _buildRow(
            context,
            label: 'Largest Side',
            value: '${totals.largestSideCm.toStringAsFixed(0)} cm',
            icon: Icons.photo_size_select_large_outlined,
          ),

          // Oversize warning
          if (totals.isOversized) ...[
            SizedBox(height: AppTheme.spacingSmall),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingSmall),
              decoration: BoxDecoration(
                color: context.colorScheme.errorContainer.withAlpha(100),
                borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
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
                      'Oversize (>60cm) - extra fees may apply',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Savings hint
          if (totals.savingsHint != null) ...[
            SizedBox(height: AppTheme.spacingSmall),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingSmall),
              decoration: BoxDecoration(
                color: context.colorScheme.tertiaryContainer.withAlpha(100),
                borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: context.colorScheme.tertiary,
                    size: 20,
                  ),
                  SizedBox(width: AppTheme.spacingSmall),
                  Expanded(
                    child: Text(
                      totals.savingsHint!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    String? subtitle,
    TextStyle? valueStyle,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: context.colorScheme.onSurfaceVariant),
        SizedBox(width: AppTheme.spacingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: context.colorScheme.onSurfaceVariant.withAlpha(150),
                  ),
                ),
            ],
          ),
        ),
        Text(
          value,
          style:
              valueStyle ??
              context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
