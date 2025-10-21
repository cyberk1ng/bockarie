import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bockaire/providers/optimization_settings_provider.dart';
import 'package:bockaire/themes/theme.dart';

/// Settings page for rule-based packing optimization parameters
class OptimizationSettingsPage extends ConsumerWidget {
  const OptimizationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = ref.watch(optimizationParamsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Optimization Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.pagePadding),
        children: [
          Text(
            'Rule-Based Optimizer Configuration',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          Text(
            'Configure constraints and thresholds for the deterministic packing optimizer',
            style: context.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: AppTheme.spacingLarge),

          // Max Side Dimension
          _buildSliderSetting(
            context: context,
            title: 'Max Side Dimension',
            subtitle: 'Maximum allowed dimension for any carton side (cm)',
            value: params.maxSideCm.toDouble(),
            min: 50,
            max: 70,
            divisions: 20,
            displayValue: '${params.maxSideCm} cm',
            onChanged: (value) {
              ref
                  .read(optimizationParamsProvider.notifier)
                  .updateMaxSideCm(value.round());
            },
            icon: Icons.straighten,
            color: Colors.blue,
          ),

          const SizedBox(height: AppTheme.spacingMedium),

          // Max Weight per Carton
          _buildSliderSetting(
            context: context,
            title: 'Max Weight per Carton',
            subtitle: 'Maximum weight allowed per individual carton (kg)',
            value: params.perCartonMaxKg,
            min: 20,
            max: 30,
            divisions: 20,
            displayValue: '${params.perCartonMaxKg.toStringAsFixed(1)} kg',
            onChanged: (value) {
              final rounded = (value * 2).round() / 2; // Round to 0.5
              ref
                  .read(optimizationParamsProvider.notifier)
                  .updatePerCartonMaxKg(rounded);
            },
            icon: Icons.scale,
            color: Colors.orange,
          ),

          const SizedBox(height: AppTheme.spacingMedium),

          // Min Savings Threshold
          _buildSliderSetting(
            context: context,
            title: 'Min Savings Threshold',
            subtitle:
                'Minimum savings percentage required for optimization to be actionable',
            value: params.minSavingsPct,
            min: 1,
            max: 10,
            divisions: 18,
            displayValue: '${params.minSavingsPct.toStringAsFixed(1)}%',
            onChanged: (value) {
              final rounded = (value * 2).round() / 2; // Round to 0.5
              ref
                  .read(optimizationParamsProvider.notifier)
                  .updateMinSavingsPct(rounded);
            },
            icon: Icons.trending_down,
            color: Colors.green,
          ),

          const SizedBox(height: AppTheme.spacingLarge),
          const Divider(),
          const SizedBox(height: AppTheme.spacingMedium),

          // Optimization Strategies Section
          Text(
            'Optimization Strategies',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          Text(
            'Enable or disable specific optimization techniques',
            style: context.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          // Allow Compression Switch
          _buildSwitchSetting(
            context: context,
            title: 'Allow Compression',
            subtitle:
                'Enable height reduction for soft goods (apparel, clothing)',
            value: params.allowCompression,
            onChanged: (value) {
              ref
                  .read(optimizationParamsProvider.notifier)
                  .updateAllowCompression(value);
            },
            icon: Icons.compress,
            color: Colors.purple,
          ),

          const SizedBox(height: AppTheme.spacingSmall),

          // Prefer Uniform Sizes Switch
          _buildSwitchSetting(
            context: context,
            title: 'Prefer Uniform Sizes',
            subtitle:
                'Standardize cartons to common sizes (50×40×40, 60×40×40)',
            value: params.preferUniformSizes,
            onChanged: (value) {
              ref
                  .read(optimizationParamsProvider.notifier)
                  .updatePreferUniformSizes(value);
            },
            icon: Icons.grid_view,
            color: Colors.teal,
          ),

          const SizedBox(height: AppTheme.spacingLarge),

          // Info Card
          Card(
            color: Colors.blue.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About Rule-Based Optimization',
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'The rule-based optimizer uses deterministic algorithms to reduce shipping costs by:\n'
                          '• Compressing soft goods to reduce dimensional weight\n'
                          '• Consolidating under-filled cartons\n'
                          '• Standardizing to optimal carton sizes\n\n'
                          'Changes to these settings will apply immediately to future optimizations.',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting({
    required BuildContext context,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    required ValueChanged<double> onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    displayValue,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: color,
                inactiveTrackColor: color.withValues(alpha: 0.2),
                thumbColor: color,
                overlayColor: color.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchSetting({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: context.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        value: value,
        onChanged: onChanged,
        activeTrackColor: color,
      ),
    );
  }
}
