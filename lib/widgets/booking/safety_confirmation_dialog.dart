import 'package:flutter/material.dart';
import 'package:bockaire/config/shippo_config.dart';
import 'package:bockaire/l10n/app_localizations.dart';

/// Safety confirmation dialog for label purchase
///
/// Shows warning and requires user to type "BOOK" to confirm
class SafetyConfirmationDialog extends StatefulWidget {
  const SafetyConfirmationDialog({super.key});

  @override
  State<SafetyConfirmationDialog> createState() =>
      _SafetyConfirmationDialogState();
}

class _SafetyConfirmationDialogState extends State<SafetyConfirmationDialog> {
  final _controller = TextEditingController();
  bool _canConfirm = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red.shade700,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.safetyConfirmLabelPurchase,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.credit_card,
                      color: Colors.red.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.safetyWillChargeAccount,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.safetyRealLabelGenerated,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.safetyTypeBookToConfirm,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.safetyTypeBookHint,
              border: const OutlineInputBorder(),
              suffixIcon: _canConfirm
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _canConfirm = value.trim().toUpperCase() == 'BOOK';
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(AppLocalizations.of(context)!.buttonCancel),
        ),
        FilledButton(
          onPressed: _canConfirm ? () => Navigator.of(context).pop(true) : null,
          style: FilledButton.styleFrom(
            backgroundColor: _canConfirm ? Colors.red : null,
          ),
          child: Text(
            AppLocalizations.of(context)!.safetyConfirmPurchaseButton,
          ),
        ),
      ],
    );
  }
}

/// Safety warning banner widget
class SafetyBanner extends StatelessWidget {
  const SafetyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final labelsEnabled = ShippoConfig.isLabelPurchaseEnabled;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: labelsEnabled
            ? Colors.orange.withValues(alpha: 0.1)
            : Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: labelsEnabled
              ? Colors.orange.withValues(alpha: 0.5)
              : Colors.blue.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            labelsEnabled ? Icons.warning_amber_rounded : Icons.shield,
            color: labelsEnabled
                ? Colors.orange.shade700
                : Colors.blue.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labelsEnabled
                      ? AppLocalizations.of(context)!.safetyLiveMode
                      : AppLocalizations.of(context)!.safetySafeMode,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: labelsEnabled
                        ? Colors.orange.shade700
                        : Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  labelsEnabled
                      ? AppLocalizations.of(context)!.safetyLiveModeMessage
                      : AppLocalizations.of(context)!.safetySafeModeMessage,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
