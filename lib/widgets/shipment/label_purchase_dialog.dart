import 'package:flutter/material.dart';
import 'package:bockaire/classes/quote.dart';
import 'package:bockaire/services/shippo_label_service.dart';
import 'package:logger/logger.dart';

/// Dialog for admin-only label purchase with typed confirmation
///
/// Safety features:
/// - Requires typing exact confirmation text "BUY LABEL"
/// - Shows estimated cost and carrier details
/// - Displays warning about real charges
/// - Provides label URL and tracking number on success
class LabelPurchaseDialog extends StatefulWidget {
  final Quote quote;

  const LabelPurchaseDialog({super.key, required this.quote});

  @override
  State<LabelPurchaseDialog> createState() => _LabelPurchaseDialogState();
}

class _LabelPurchaseDialogState extends State<LabelPurchaseDialog> {
  final TextEditingController _confirmationController = TextEditingController();
  final Logger _logger = Logger();
  bool _isPurchasing = false;
  LabelTransaction? _purchasedLabel;
  String? _errorMessage;

  static const String _requiredConfirmation = 'BUY LABEL';

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _purchaseLabel() async {
    if (_confirmationController.text != _requiredConfirmation) {
      setState(() {
        _errorMessage =
            'Please type "$_requiredConfirmation" exactly (case-sensitive)';
      });
      return;
    }

    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
    });

    try {
      final labelService = ShippoLabelService();

      final transaction = await labelService.purchaseLabel(
        rateId: widget.quote.rawRateId!,
        confirmation: _confirmationController.text,
      );

      setState(() {
        _purchasedLabel = transaction;
        _isPurchasing = false;
      });
    } catch (e) {
      _logger.e('Label purchase error: $e');
      setState(() {
        _errorMessage = e.toString();
        _isPurchasing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_purchasedLabel != null) {
      return _buildSuccessDialog(context);
    }

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red.shade700,
            size: 32,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '⚠️ Purchase Label',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning
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
                  Text(
                    'REAL MONEY WILL BE CHARGED',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This will create a real shipping label and charge your Shippo account. '
                    'This action cannot be undone (but may be voidable within carrier time limits).',
                    style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Rate details
            Text(
              'Label Details:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Carrier:', widget.quote.carrier),
            _buildDetailRow('Service:', widget.quote.service),
            _buildDetailRow(
              'Cost:',
              '${widget.quote.price?.toStringAsFixed(2) ?? '0.00'} ${widget.quote.currency ?? 'USD'}',
            ),
            _buildDetailRow(
              'Transit:',
              '${widget.quote.transitDays ?? widget.quote.etaMin} days',
            ),

            const SizedBox(height: 16),

            // Confirmation input
            Text(
              'Type "$_requiredConfirmation" to confirm:',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmationController,
              enabled: !_isPurchasing,
              decoration: InputDecoration(
                hintText: _requiredConfirmation,
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
                errorMaxLines: 3,
              ),
              autocorrect: false,
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isPurchasing ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isPurchasing ? null : _purchaseLabel,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isPurchasing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Purchase Label'),
        ),
      ],
    );
  }

  Widget _buildSuccessDialog(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade700, size: 32),
          const SizedBox(width: 12),
          const Text('Label Purchased'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your shipping label has been created successfully!',
              style: TextStyle(fontSize: 14, color: Colors.green.shade700),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Transaction ID:', _purchasedLabel!.objectId),
            _buildDetailRow(
              'Tracking #:',
              _purchasedLabel!.trackingNumber ?? 'N/A',
            ),
            _buildDetailRow('Status:', _purchasedLabel!.status),
            _buildDetailRow(
              'Cost:',
              '${_purchasedLabel!.rate?.amount ?? '0.00'} ${_purchasedLabel!.rate?.currency ?? 'USD'}',
            ),

            const SizedBox(height: 16),

            // Label URL button
            if (_purchasedLabel!.labelUrl != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Open label URL in browser
                    _logger.i('Opening label: ${_purchasedLabel!.labelUrl}');
                  },
                  icon: const Icon(Icons.file_download),
                  label: const Text('Download Label'),
                ),
              ),

            const SizedBox(height: 8),

            // Void option
            TextButton.icon(
              onPressed: () => _showVoidConfirmation(context),
              icon: const Icon(Icons.cancel, color: Colors.red),
              label: const Text(
                'Void Label (if eligible)',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_purchasedLabel),
          child: const Text('Done'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _showVoidConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Void Label?'),
        content: const Text(
          'This will attempt to void the label and refund your account. '
          'Not all carriers support voids, and some have strict time limits.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Void Label'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _voidLabel();
    }
  }

  Future<void> _voidLabel() async {
    try {
      final labelService = ShippoLabelService();
      final result = await labelService.voidLabel(_purchasedLabel!.objectId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.success
                ? 'Label voided successfully'
                : 'Void failed: ${result.message}',
          ),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );

      if (result.success) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Void error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

/// Show label purchase dialog
Future<LabelTransaction?> showLabelPurchaseDialog({
  required BuildContext context,
  required Quote quote,
}) async {
  return showDialog<LabelTransaction>(
    context: context,
    barrierDismissible: false,
    builder: (context) => LabelPurchaseDialog(quote: quote),
  );
}
