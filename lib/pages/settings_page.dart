import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bockaire/themes/theme.dart';
import 'package:bockaire/providers/theme_providers.dart';
import 'package:bockaire/widgets/modal/modal_card.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.pagePadding),
        children: [
          // Theme Section
          Text(
            'Appearance',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          ModalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme Mode',
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                SegmentedButton<ThemeMode>(
                  selected: {themeMode},
                  showSelectedIcon: false,
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(newSelection.first);
                  },
                  segments: const [
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      label: Icon(Icons.wb_sunny),
                      tooltip: 'Light Mode',
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      label: Icon(Icons.brightness_auto),
                      tooltip: 'System Default',
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      label: Icon(Icons.nightlight_round),
                      tooltip: 'Dark Mode',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingLarge),
          const Divider(),
          const SizedBox(height: AppTheme.spacingLarge),

          // Other Settings
          Text(
            'Configuration',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Rate Tables'),
            subtitle: const Text('Manage carrier rates'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to rate tables
            },
          ),
          ListTile(
            leading: const Icon(Icons.psychology),
            title: const Text('AI Providers'),
            subtitle: const Text('Configure AI models'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to AI providers
            },
          ),

          const SizedBox(height: AppTheme.spacingLarge),
          const Divider(),
          const SizedBox(height: AppTheme.spacingMedium),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('Bockaire v1.0.0'),
          ),
        ],
      ),
    );
  }
}
