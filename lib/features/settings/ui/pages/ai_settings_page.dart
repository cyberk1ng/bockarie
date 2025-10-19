import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bockaire/providers/transcription_provider.dart';
import 'package:bockaire/l10n/app_localizations.dart';
import 'package:bockaire/themes/theme.dart';

// Provider model info
class ProviderModel {
  final String name;
  final String description;
  final bool isRecommended;

  const ProviderModel({
    required this.name,
    required this.description,
    this.isRecommended = false,
  });
}

class AiSettingsPage extends ConsumerStatefulWidget {
  const AiSettingsPage({super.key});

  @override
  ConsumerState<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends ConsumerState<AiSettingsPage> {
  TranscriptionProviderType? _expandedProvider;

  // Available models for each provider
  final Map<TranscriptionProviderType, List<ProviderModel>> _providerModels = {
    TranscriptionProviderType.gemini: [
      const ProviderModel(
        name: 'gemini-2.0-flash-exp',
        description: 'Fastest model with excellent audio transcription',
        isRecommended: true,
      ),
      const ProviderModel(
        name: 'gemini-1.5-pro',
        description: 'Previous generation, more powerful but slower',
      ),
    ],
    TranscriptionProviderType.whisper: [
      const ProviderModel(
        name: 'whisper-large-v3',
        description: 'Most accurate local transcription model',
        isRecommended: true,
      ),
      const ProviderModel(
        name: 'whisper-medium',
        description: 'Faster but less accurate',
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final currentProvider = ref.watch(transcriptionProviderProvider);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.settingsAiProviders)),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.pagePadding),
        children: [
          Text(
            'Voice Transcription Provider',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          Text(
            'Choose which AI provider to use for voice-to-text transcription',
            style: context.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          // Gemini Option
          _buildProviderTile(
            context: context,
            ref: ref,
            provider: TranscriptionProviderType.gemini,
            title: 'Google Gemini',
            subtitle: 'Cloud-based, fast and accurate transcription',
            icon: Icons.auto_awesome,
            isSelected: currentProvider == TranscriptionProviderType.gemini,
            color: Colors.blue,
          ),

          const SizedBox(height: AppTheme.spacingSmall),

          // Whisper Option
          _buildProviderTile(
            context: context,
            ref: ref,
            provider: TranscriptionProviderType.whisper,
            title: 'Local Whisper',
            subtitle: 'Privacy-first offline transcription',
            icon: Icons.mic_none,
            isSelected: currentProvider == TranscriptionProviderType.whisper,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildProviderTile({
    required BuildContext context,
    required WidgetRef ref,
    required TranscriptionProviderType provider,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Color color,
  }) {
    final isExpanded = _expandedProvider == provider;
    final models = _providerModels[provider] ?? [];

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? color.withOpacity(0.1) : null,
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.2)
                    : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Text(subtitle, style: context.textTheme.bodySmall),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Active',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey,
                ),
              ],
            ),
            onTap: () {
              setState(() {
                if (_expandedProvider == provider) {
                  _expandedProvider = null;
                } else {
                  _expandedProvider = provider;
                }
              });
            },
          ),

          // Expanded section showing models
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Available Models',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...models.map(
                    (model) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: model.isRecommended
                              ? color.withOpacity(0.05)
                              : Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: model.isRecommended
                                ? color.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              model.isRecommended ? Icons.star : Icons.memory,
                              size: 16,
                              color: model.isRecommended ? color : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        model.name,
                                        style: context.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'monospace',
                                            ),
                                      ),
                                      if (model.isRecommended) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: const Text(
                                            'RECOMMENDED',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    model.description,
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(transcriptionProviderProvider.notifier)
                          .setProvider(provider);
                      setState(() => _expandedProvider = null);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 44),
                    ),
                    child: Text(
                      isSelected ? 'Currently Selected' : 'Select $title',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
