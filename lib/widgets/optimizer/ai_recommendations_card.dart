import 'package:flutter/material.dart';
import 'package:bockaire/services/ai_optimizer_interfaces.dart';
import 'package:bockaire/l10n/app_localizations.dart';
import 'package:bockaire/themes/theme.dart';

class AiRecommendationsCard extends StatelessWidget {
  final PackingRecommendation recommendation;
  final VoidCallback? onApply;

  const AiRecommendationsCard({
    required this.recommendation,
    this.onApply,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(AppTheme.spacingMedium),
      child: ExpansionTile(
        leading: const Icon(Icons.auto_awesome, color: Colors.purple, size: 32),
        title: Text(
          localizations.optimizerAIRecommendations,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${recommendation.estimatedSavingsPercent.toStringAsFixed(0)}% estimated savings',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recommended Box Count
                _buildInfoSection(
                  context: context,
                  icon: Icons.inventory_2,
                  title: localizations.optimizerRecommendedBoxCount,
                  content: recommendation.recommendedBoxCount.toString(),
                  color: Colors.blue,
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                // Estimated Savings
                _buildInfoSection(
                  context: context,
                  icon: Icons.savings,
                  title: localizations.optimizerEstimatedSavings,
                  content:
                      '${recommendation.estimatedSavingsPercent.toStringAsFixed(1)}%',
                  color: Colors.green,
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                // Explanation
                _buildInfoSection(
                  context: context,
                  icon: Icons.info_outline,
                  title: localizations.optimizerExplanation,
                  content: recommendation.explanation,
                  color: Colors.purple,
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                // Compression Advice
                _buildInfoSection(
                  context: context,
                  icon: Icons.compress,
                  title: localizations.optimizerCompressionAdvice,
                  content: recommendation.compressionAdvice,
                  color: Colors.orange,
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                // Tips
                if (recommendation.tips.isNotEmpty) ...[
                  _buildListSection(
                    context: context,
                    icon: Icons.lightbulb_outline,
                    title: localizations.optimizerTips,
                    items: recommendation.tips,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                ],

                // Warnings
                if (recommendation.warnings.isNotEmpty) ...[
                  _buildListSection(
                    context: context,
                    icon: Icons.warning_amber,
                    title: localizations.optimizerWarnings,
                    items: recommendation.warnings,
                    color: Colors.red,
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                ],

                // Apply Button (if callback provided)
                if (onApply != null) ...[
                  const Divider(),
                  const SizedBox(height: AppTheme.spacingSmall),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onApply,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Apply Recommendations'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    final theme = Theme.of(context);

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
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildListSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required List<String> items,
    required Color color,
  }) {
    final theme = Theme.of(context);

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
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: color)),
                  Expanded(
                    child: Text(item, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
