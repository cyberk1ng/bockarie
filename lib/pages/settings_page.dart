import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bockaire/themes/theme.dart';
import 'package:bockaire/providers/theme_providers.dart';
import 'package:bockaire/providers/locale_provider.dart';
import 'package:bockaire/widgets/modal/modal_card.dart';
import 'package:bockaire/classes/supported_language.dart';
import 'package:bockaire/widgets/flags/language_flag.dart';
import 'package:bockaire/features/settings/ui/widgets/language_selection_modal.dart';
import 'package:bockaire/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:bockaire/providers/currency_provider.dart';
import 'package:bockaire/widgets/currency/currency_flag.dart';
import 'package:bockaire/features/settings/ui/widgets/currency_selection_modal.dart';
import 'package:bockaire/features/settings/ui/pages/ai_settings_page.dart';

import '../classes/supported_currency.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.pagePadding),
        children: [
          // Language Section
          Text(
            localizations.settingsLanguageTitle,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(localizations.settingsLanguageTitle),
            subtitle: Text(localizations.settingsLanguageSubtitle),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (currentLocale != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: buildLanguageFlag(
                      languageCode: currentLocale.languageCode,
                      height: 20,
                      width: 28,
                    ),
                  ),
                Text(
                  currentLocale != null
                      ? SupportedLanguage.fromCode(
                              currentLocale.languageCode,
                            )?.localizedName(context) ??
                            localizations.systemDefaultLanguage
                      : localizations.systemDefaultLanguage,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () async {
              final selectedLanguage =
                  await showModalBottomSheet<SupportedLanguage?>(
                    context: context,
                    builder: (context) => SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: LanguageSelectionModal(
                        currentLanguageCode: currentLocale?.languageCode,
                      ),
                    ),
                  );

              if (selectedLanguage != null) {
                ref
                    .read(localeNotifierProvider.notifier)
                    .setLocale(Locale(selectedLanguage.code));
              } else if (selectedLanguage == null &&
                  currentLocale != null &&
                  context.mounted) {
                // User explicitly selected system default
                ref.read(localeNotifierProvider.notifier).setLocale(null);
              }
            },
          ),

          // Currency Setting
          Consumer(
            builder: (context, ref, child) {
              final localizations = AppLocalizations.of(context)!;
              final currentCurrency = ref.watch(currencyNotifierProvider);

              return ListTile(
                leading: const Icon(Icons.payments),
                title: Text(localizations.settingsCurrencyTitle),
                subtitle: Text(localizations.settingsCurrencySubtitle),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 32,
                      height: 24,
                      child: buildCurrencyFlag(
                        currency: currentCurrency,
                        height: 24,
                        width: 32,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${currentCurrency.symbol} ${currentCurrency.code}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () async {
                  final selectedCurrency =
                      await showModalBottomSheet<SupportedCurrency>(
                        context: context,
                        builder: (context) => CurrencySelectionModal(
                          currentCurrency: currentCurrency,
                        ),
                      );

                  if (selectedCurrency != null) {
                    ref
                        .read(currencyNotifierProvider.notifier)
                        .setCurrency(selectedCurrency);
                  }
                },
              );
            },
          ),

          const SizedBox(height: AppTheme.spacingLarge),
          const Divider(),
          const SizedBox(height: AppTheme.spacingLarge),

          // Theme Section
          Text(
            localizations.settingsAppearance,
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
                  localizations.settingsThemeMode,
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
                  segments: [
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      label: const Icon(Icons.wb_sunny),
                      tooltip: localizations.settingsThemeLightTooltip,
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      label: const Icon(Icons.brightness_auto),
                      tooltip: localizations.settingsThemeSystemTooltip,
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      label: const Icon(Icons.nightlight_round),
                      tooltip: localizations.settingsThemeDarkTooltip,
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
            localizations.settingsConfiguration,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          ListTile(
            leading: const Icon(Icons.table_chart),
            title: Text(localizations.settingsRateTables),
            subtitle: Text(localizations.settingsRateTablesSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to rate tables
            },
          ),
          ListTile(
            leading: const Icon(Icons.psychology),
            title: Text(localizations.settingsAiProviders),
            subtitle: Text(localizations.settingsAiProvidersSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AiSettingsPage()),
              );
            },
          ),

          const SizedBox(height: AppTheme.spacingLarge),
          const Divider(),
          const SizedBox(height: AppTheme.spacingMedium),

          FutureBuilder<PackageInfo>(
            future: _packageInfoFuture,
            builder: (context, snapshot) {
              final versionText = snapshot.hasData
                  ? 'Bockaire v${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                  : 'Bockaire';

              return ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(localizations.settingsAbout),
                subtitle: Text(versionText),
              );
            },
          ),
        ],
      ),
    );
  }
}
