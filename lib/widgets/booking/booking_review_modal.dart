import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bockaire/database/database.dart';
import 'package:bockaire/config/shippo_config.dart';
import 'package:bockaire/widgets/modal/modal_card.dart';
import 'package:bockaire/themes/theme.dart';
import 'package:bockaire/providers/currency_provider.dart';

/// Modal sheet for reviewing booking details before commitment
///
/// Displays:
/// - Route information
/// - Carrier and pricing
/// - Customs status (if international)
/// - Safety banner (label enabled/disabled)
/// - Actions: Edit, Cancel, Confirm
class BookingReviewModal extends ConsumerWidget {
  final Quote quote;
  final Shipment shipment;
  final bool isInternational;
  final bool hasCustoms;
  final VoidCallback? onEdit;
  final VoidCallback? onConfirm;

  const BookingReviewModal({
    super.key,
    required this.quote,
    required this.shipment,
    required this.isInternational,
    required this.hasCustoms,
    this.onEdit,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    color: context.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Review Booking',
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Route card
                    _buildRouteCard(context),
                    const SizedBox(height: 16),

                    // Carrier & pricing card
                    _buildCarrierCard(context, ref),
                    const SizedBox(height: 16),

                    // Customs status (if international)
                    if (isInternational) ...[
                      _buildCustomsCard(context),
                      const SizedBox(height: 16),
                    ],

                    // Safety banner
                    _buildSafetyBanner(context),
                    const SizedBox(height: 24),

                    // Actions
                    _buildActions(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context) {
    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Route',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shipment.originCity,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      shipment.originCountry,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: context.colorScheme.primary),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      shipment.destCity,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      shipment.destCountry,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarrierCard(BuildContext context, WidgetRef ref) {
    // Get formatted price in user's preferred currency
    final formattedPrice = ref.watch(formatCurrencyProvider(quote.priceEur));

    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Carrier & Service',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.local_shipping,
                color: context.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${quote.carrier} ${quote.service}',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimated Delivery',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${quote.etaMin}-${quote.etaMax} days',
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Cost',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedPrice,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomsCard(BuildContext context) {
    return ModalCard(
      child: Row(
        children: [
          Icon(
            hasCustoms ? Icons.check_circle : Icons.warning_amber,
            color: hasCustoms ? Colors.green : Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasCustoms
                      ? 'Customs Declaration Ready'
                      : 'Customs Declaration Required',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: hasCustoms ? Colors.green : Colors.orange,
                  ),
                ),
                if (!hasCustoms) ...[
                  const SizedBox(height: 4),
                  Text(
                    'International shipments require customs information',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyBanner(BuildContext context) {
    final isLabelEnabled = ShippoConfig.isLabelPurchaseEnabled;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isLabelEnabled ? Colors.orange : Colors.blue).withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isLabelEnabled ? Colors.orange : Colors.blue).withValues(
            alpha: 0.3,
          ),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isLabelEnabled ? Icons.warning_amber : Icons.shield,
            color: isLabelEnabled ? Colors.orange : Colors.blue,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLabelEnabled
                      ? 'Label Purchase Enabled'
                      : 'Safe Mode (No Labels)',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isLabelEnabled
                        ? Colors.orange.shade800
                        : Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isLabelEnabled
                      ? 'You will be charged for the shipping label'
                      : 'No charges will be made - testing mode',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Confirm button
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Confirm Booking'),
        ),
        const SizedBox(height: 12),

        // Edit button (if provided)
        if (onEdit != null) ...[
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop(false);
              onEdit?.call();
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Shipment Details'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Cancel button
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
