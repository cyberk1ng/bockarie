import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bockaire/classes/supported_language.dart';
import 'package:bockaire/widgets/flags/language_flag.dart';
import 'package:bockaire/l10n/app_localizations.dart';

class LanguageSelectionModal extends ConsumerStatefulWidget {
  const LanguageSelectionModal({required this.currentLanguageCode, super.key});

  final String? currentLanguageCode;

  @override
  ConsumerState<LanguageSelectionModal> createState() =>
      _LanguageSelectionModalState();
}

class _LanguageSelectionModalState
    extends ConsumerState<LanguageSelectionModal> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final languages =
        SupportedLanguage.values
            .where(
              (lang) =>
                  lang.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  lang.code.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  lang
                      .localizedName(context)
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()),
            )
            .toList()
          ..sort(
            (a, b) =>
                a.localizedName(context).compareTo(b.localizedName(context)),
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: localizations.searchHint,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: languages.length + 1, // +1 for "System Default"
            itemBuilder: (context, index) {
              if (index == 0) {
                // System default option
                final isSelected = widget.currentLanguageCode == null;
                return ListTile(
                  leading: const Icon(Icons.phone_android),
                  title: Text(localizations.systemDefaultLanguage),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  selected: isSelected,
                  onTap: () => Navigator.pop(context, null),
                );
              }

              final language = languages[index - 1];
              final isSelected = widget.currentLanguageCode == language.code;

              return ListTile(
                leading: SizedBox(
                  width: 32,
                  height: 24,
                  child: buildLanguageFlag(
                    languageCode: language.code,
                    height: 24,
                    width: 32,
                  ),
                ),
                title: Text(language.localizedName(context)),
                trailing: isSelected ? const Icon(Icons.check) : null,
                selected: isSelected,
                onTap: () => Navigator.pop(context, language),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
