import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bockaire/providers/transcription_provider.dart';
import 'package:bockaire/providers/image_analysis_provider.dart';
import 'package:bockaire/providers/optimizer_provider.dart';
import 'package:bockaire/l10n/app_localizations.dart';
import 'package:bockaire/themes/theme.dart';
import 'package:bockaire/get_it.dart';
import 'package:bockaire/services/whisper_server_manager.dart';

class AiSettingsPage extends ConsumerStatefulWidget {
  const AiSettingsPage({super.key});

  @override
  ConsumerState<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends ConsumerState<AiSettingsPage> {
  TranscriptionProviderType? _expandedProvider;
  ImageAnalysisProviderType? _expandedImageProvider;
  OptimizerProviderType? _expandedOptimizerProvider;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final currentProvider = ref.watch(transcriptionProviderProvider);
    final currentImageProvider = ref.watch(imageAnalysisProviderProvider);
    final currentOptimizerProvider = ref.watch(
      optimizerProviderNotifierProvider,
    );

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

          const SizedBox(height: AppTheme.spacingLarge),
          const Divider(),
          const SizedBox(height: AppTheme.spacingLarge),

          // Image Analysis Section
          Text(
            'Image Analysis Provider',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          Text(
            'Choose which AI provider to use for packing list image recognition',
            style: context.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          // Gemini Vision Option
          _buildImageProviderTile(
            context: context,
            ref: ref,
            provider: ImageAnalysisProviderType.gemini,
            title: 'Google Gemini Vision',
            subtitle: 'Cloud-based vision AI, fast and accurate',
            icon: Icons.photo_camera,
            isSelected:
                currentImageProvider == ImageAnalysisProviderType.gemini,
            color: Colors.blue,
          ),

          const SizedBox(height: AppTheme.spacingSmall),

          // Ollama Vision Option
          _buildImageProviderTile(
            context: context,
            ref: ref,
            provider: ImageAnalysisProviderType.ollama,
            title: 'Ollama Vision (Local)',
            subtitle: 'Privacy-first local vision models (LLaVA, MiniCPM-V)',
            icon: Icons.image_search,
            isSelected:
                currentImageProvider == ImageAnalysisProviderType.ollama,
            color: Colors.green,
          ),

          const SizedBox(height: AppTheme.spacingLarge),
          const Divider(),
          const SizedBox(height: AppTheme.spacingLarge),

          // Packing Optimizer Section
          Text(
            'Packing Optimizer Provider',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          Text(
            'Choose which AI provider to use for intelligent packing optimization',
            style: context.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          // Gemini Optimizer Option
          _buildOptimizerProviderTile(
            context: context,
            ref: ref,
            provider: OptimizerProviderType.gemini,
            title: 'Google Gemini',
            subtitle: 'Cloud-based optimization with advanced logistics AI',
            icon: Icons.inventory_2,
            isSelected:
                currentOptimizerProvider == OptimizerProviderType.gemini,
            color: Colors.purple,
          ),

          const SizedBox(height: AppTheme.spacingSmall),

          // Ollama Optimizer Option
          _buildOptimizerProviderTile(
            context: context,
            ref: ref,
            provider: OptimizerProviderType.ollama,
            title: 'Ollama (Local)',
            subtitle: 'Privacy-first local optimization (LLaMA, Qwen, Mistral)',
            icon: Icons.psychology,
            isSelected:
                currentOptimizerProvider == OptimizerProviderType.ollama,
            color: Colors.orange,
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

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? color.withValues(alpha: 0.1) : null,
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.2)
                    : color.withValues(alpha: 0.1),
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

          // Expanded section showing model selectors
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  if (provider == TranscriptionProviderType.gemini) ...[
                    Text(
                      'Google Gemini Audio',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Cloud-based audio transcription with multiple models. Requires internet connection and API key configured in .env file.',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Select Model:',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildGeminiAudioModelSelector(ref, color),
                  ] else ...[
                    Text(
                      'Local Whisper Configuration',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Privacy-first offline transcription. Runs locally on your device. Larger models are more accurate but slower.',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Select Model:',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildWhisperModelSelector(ref, color),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'Server Status:',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<bool>(
                      future: getIt<WhisperServerManager>().checkHealth(),
                      builder: (context, snapshot) {
                        final isRunning = snapshot.data ?? false;
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (isRunning ? Colors.green : Colors.orange)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isRunning ? Colors.green : Colors.orange,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isRunning ? Icons.check_circle : Icons.warning,
                                color: isRunning ? Colors.green : Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isRunning
                                      ? 'Server running on http://127.0.0.1:8089'
                                      : 'Server will start automatically when needed',
                                  style: context.textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
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

  Widget _buildImageProviderTile({
    required BuildContext context,
    required WidgetRef ref,
    required ImageAnalysisProviderType provider,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Color color,
  }) {
    final isExpanded = _expandedImageProvider == provider;

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? color.withValues(alpha: 0.1) : null,
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.2)
                    : color.withValues(alpha: 0.1),
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
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
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
                if (_expandedImageProvider == provider) {
                  _expandedImageProvider = null;
                } else {
                  _expandedImageProvider = provider;
                }
              });
            },
          ),

          // Expanded section
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  if (provider == ImageAnalysisProviderType.ollama) ...[
                    Text(
                      'Ollama Configuration',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This requires Ollama to be running locally. Install vision models like llava:13b, minicpm-v:8b, or bakllava:7b.',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.link, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Base URL:',
                                style: context.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ref.watch(ollamaBaseUrlProvider),
                            style: TextStyle(
                              fontFamily: 'monospace',
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Select Model:',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildOllamaModelSelector(ref, color),
                  ] else ...[
                    Text(
                      'Google Gemini Vision',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Cloud-based vision AI with multiple models. Requires internet connection and API key configured in .env file.',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Select Model:',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildGeminiModelSelector(ref, color),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(imageAnalysisProviderProvider.notifier)
                          .setProvider(provider);
                      setState(() => _expandedImageProvider = null);
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

  Widget _buildGeminiModelSelector(WidgetRef ref, Color color) {
    final currentModel = ref.watch(geminiVisionModelProvider);
    final availableModels = GeminiVisionModelNotifier.availableModels;

    return Column(
      children: availableModels.map((model) {
        final isSelected = currentModel == model;
        return InkWell(
          onTap: () {
            ref.read(geminiVisionModelProvider.notifier).setModel(model);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? color : Colors.grey.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected ? color : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    model,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? color : null,
                    ),
                  ),
                ),
                if (isSelected) Icon(Icons.check, color: color, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOllamaModelSelector(WidgetRef ref, Color color) {
    final currentModel = ref.watch(ollamaVisionModelProvider);
    final availableModels = OllamaVisionModelNotifier.availableModels;

    return Column(
      children: availableModels.map((model) {
        final isSelected = currentModel == model;
        return InkWell(
          onTap: () {
            ref.read(ollamaVisionModelProvider.notifier).setModel(model);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? color : Colors.grey.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected ? color : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    model,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? color : null,
                    ),
                  ),
                ),
                if (isSelected) Icon(Icons.check, color: color, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGeminiAudioModelSelector(WidgetRef ref, Color color) {
    final currentModel = ref.watch(geminiAudioModelProvider);
    final availableModels = GeminiAudioModelNotifier.availableModels;

    return Column(
      children: availableModels.map((model) {
        final isSelected = currentModel == model;
        return InkWell(
          onTap: () {
            ref.read(geminiAudioModelProvider.notifier).setModel(model);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? color : Colors.grey.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected ? color : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    model,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? color : null,
                    ),
                  ),
                ),
                if (isSelected) Icon(Icons.check, color: color, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWhisperModelSelector(WidgetRef ref, Color color) {
    final currentModel = ref.watch(whisperModelProvider);
    final availableModels = WhisperModelNotifier.availableModels;

    return Column(
      children: availableModels.map((model) {
        final isSelected = currentModel == model;
        return InkWell(
          onTap: () {
            ref.read(whisperModelProvider.notifier).setModel(model);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? color : Colors.grey.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected ? color : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    model,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? color : null,
                    ),
                  ),
                ),
                if (isSelected) Icon(Icons.check, color: color, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOptimizerProviderTile({
    required BuildContext context,
    required WidgetRef ref,
    required OptimizerProviderType provider,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Color color,
  }) {
    final isExpanded = _expandedOptimizerProvider == provider;

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? color.withValues(alpha: 0.1) : null,
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.2)
                    : color.withValues(alpha: 0.1),
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
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
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
                if (_expandedOptimizerProvider == provider) {
                  _expandedOptimizerProvider = null;
                } else {
                  _expandedOptimizerProvider = provider;
                }
              });
            },
          ),

          // Expanded section
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  if (provider == OptimizerProviderType.ollama) ...[
                    Text(
                      'Ollama Optimizer Configuration',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This requires Ollama to be running locally. Recommended models: llama3.1:8b, qwen2.5:14b, mistral:7b.',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.link, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Base URL:',
                                style: context.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ref.watch(ollamaOptimizerBaseUrlProvider),
                            style: TextStyle(
                              fontFamily: 'monospace',
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Select Model:',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildOllamaOptimizerModelSelector(ref, color),
                  ] else ...[
                    Text(
                      'Google Gemini Optimizer',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Cloud-based packing optimization using advanced AI. Analyzes material properties, compression limits, and shipping regulations. Requires internet connection and API key configured in .env file.',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Model: gemini-2.0-flash-exp (optimized for logistics)',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(optimizerProviderNotifierProvider.notifier)
                          .setProvider(provider);
                      setState(() => _expandedOptimizerProvider = null);
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

  Widget _buildOllamaOptimizerModelSelector(WidgetRef ref, Color color) {
    final currentModel = ref.watch(ollamaOptimizerModelProvider);
    const availableModels = ['llama3.1:8b', 'qwen2.5:14b', 'mistral:7b'];

    return Column(
      children: availableModels.map((model) {
        final isSelected = currentModel == model;
        return InkWell(
          onTap: () {
            ref.read(ollamaOptimizerModelProvider.notifier).setModel(model);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? color : Colors.grey.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected ? color : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    model,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? color : null,
                    ),
                  ),
                ),
                if (isSelected) Icon(Icons.check, color: color, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
