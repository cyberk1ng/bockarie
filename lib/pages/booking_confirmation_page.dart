import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bockaire/services/book_shipment_service.dart';
import 'package:bockaire/themes/theme.dart';
import 'package:bockaire/widgets/modal/modal_card.dart';
import 'package:bockaire/database/database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bockaire/l10n/app_localizations.dart';

/// Booking Confirmation Page - Shows result after booking
///
/// Displays:
/// - Shipment ID
/// - Tracking number (if label created)
/// - Label download link
/// - Commercial invoice + CN22/CN23 links
/// - Booking status
class BookingConfirmationPage extends ConsumerWidget {
  final BookingResult result;
  final Quote quote;
  final Shipment shipment;

  const BookingConfirmationPage({
    super.key,
    required this.result,
    required this.quote,
    required this.shipment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.bookingConfirmationTitle),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Success banner
          _buildSuccessBanner(context),
          const SizedBox(height: 24),

          // Shipment summary
          _buildShipmentSummary(context),
          const SizedBox(height: 16),

          // Tracking info (if label created)
          if (result.labelCreated) ...[
            _buildTrackingInfo(context),
            const SizedBox(height: 16),
          ],

          // Documents section
          _buildDocumentsSection(context),
          const SizedBox(height: 16),

          // Messages/warnings
          if (result.messages.isNotEmpty) ...[
            _buildMessagesSection(context),
            const SizedBox(height: 16),
          ],

          // Label status info
          _buildLabelStatusInfo(context),
          const SizedBox(height: 24),

          // Actions
          FilledButton.icon(
            onPressed: () {
              // Pop until we're back at the quotes page
              // This provides a clear, explicit exit path
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.done),
            label: Text(AppLocalizations.of(context)!.bookingReturnToQuotes),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner(BuildContext context) {
    return ModalCard(
      child: Row(
        children: [
          Icon(
            result.labelCreated ? Icons.check_circle : Icons.info_outline,
            color: result.labelCreated ? Colors.green : Colors.blue,
            size: 48,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.labelCreated
                      ? AppLocalizations.of(context)!.bookingShipmentBooked
                      : AppLocalizations.of(context)!.bookingShipmentCreated,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: result.labelCreated ? Colors.green : Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.labelCreated
                      ? AppLocalizations.of(context)!.bookingLabelGenerated
                      : AppLocalizations.of(
                          context,
                        )!.bookingShipmentCreatedNoLabel,
                  style: context.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentSummary(BuildContext context) {
    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.bookingShipmentDetailsTitle,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            Icons.local_shipping,
            AppLocalizations.of(context)!.bookingCarrierLabel,
            '${quote.carrier} ${quote.service}',
          ),
          const Divider(height: 24),
          _buildDetailRow(
            context,
            Icons.schedule,
            AppLocalizations.of(context)!.bookingEstimatedDeliveryLabel,
            AppLocalizations.of(context)!.etaDays(quote.etaMin, quote.etaMax),
          ),
          const Divider(height: 24),
          _buildDetailRow(
            context,
            Icons.euro,
            AppLocalizations.of(context)!.bookingTotalCostLabel,
            '€${quote.priceEur.toStringAsFixed(2)}',
          ),
          const Divider(height: 24),
          _buildDetailRow(
            context,
            Icons.fingerprint,
            AppLocalizations.of(context)!.bookingShipmentIdLabel,
            result.shipmentId,
            isMonospace: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingInfo(BuildContext context) {
    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping, color: context.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.bookingTrackingInformation,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (result.trackingNumber != null) ...[
            Text(
              AppLocalizations.of(context)!.bookingTrackingNumber,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              result.trackingNumber!,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: context.colorScheme.primary,
              ),
            ),
          ],
          if (result.trackingUrlProvider != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _launchUrl(result.trackingUrlProvider!),
              icon: const Icon(Icons.open_in_new),
              label: Text(AppLocalizations.of(context)!.bookingTrackShipment),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(BuildContext context) {
    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: context.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.bookingDocumentsTitle,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (result.labelUrl != null) ...[
            ListTile(
              leading: const Icon(Icons.local_shipping),
              title: Text(AppLocalizations.of(context)!.bookingShippingLabel),
              subtitle: Text(
                AppLocalizations.of(context)!.bookingPdfReadyToPrint,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _launchUrl(result.labelUrl!),
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ],
          if (result.commercialInvoiceUrl != null) ...[
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text(
                AppLocalizations.of(context)!.bookingCommercialInvoice,
              ),
              subtitle: Text(
                AppLocalizations.of(context)!.bookingPdfCustomsDocument,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _launchUrl(result.commercialInvoiceUrl!),
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ],
          if (result.customsDeclarationId != null) ...[
            ListTile(
              leading: const Icon(Icons.public),
              title: Text(
                AppLocalizations.of(context)!.bookingCustomsDeclaration,
              ),
              subtitle: Text('ID: ${result.customsDeclarationId}'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
          if (result.labelUrl == null &&
              result.commercialInvoiceUrl == null) ...[
            Text(
              AppLocalizations.of(context)!.bookingNoDocumentsYet,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessagesSection(BuildContext context) {
    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.bookingImportantInformation,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...result.messages.map((msg) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(msg, style: const TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLabelStatusInfo(BuildContext context) {
    if (result.labelCreated) {
      return ModalCard(
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.bookingLabelGeneratedLiveMode,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.bookingLabelPurchasedMessage,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return ModalCard(
        child: Row(
          children: [
            Icon(Icons.shield, color: Colors.blue.shade700, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.bookingSafeModeNoLabel,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.bookingSafeModeMessage,
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

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool isMonospace = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFamily: isMonospace ? 'monospace' : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
