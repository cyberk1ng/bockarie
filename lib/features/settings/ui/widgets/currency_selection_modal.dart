import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bockaire/classes/supported_currency.dart';
import 'package:bockaire/l10n/app_localizations.dart';
import 'package:bockaire/widgets/currency/currency_flag.dart';

class CurrencySelectionModal extends ConsumerWidget {
  const CurrencySelectionModal({required this.currentCurrency, super.key});

  final SupportedCurrency currentCurrency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final currencies = SupportedCurrency.values;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  localizations.settingsCurrencyTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const Divider(),
          ...currencies.map((currency) {
            final isSelected = currency == currentCurrency;

            return ListTile(
              leading: SizedBox(
                width: 40,
                height: 30,
                child: buildCurrencyFlag(
                  currency: currency,
                  height: 30,
                  width: 40,
                ),
              ),
              title: Text(currency.localizedName(context)),
              subtitle: Text('${currency.symbol} ${currency.code}'),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              selected: isSelected,
              selectedTileColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              onTap: () => Navigator.pop(context, currency),
            );
          }),
        ],
      ),
    );
  }
}
