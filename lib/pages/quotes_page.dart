import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bockaire/themes/theme.dart';
import 'package:bockaire/widgets/modal/modal_card.dart';
import 'package:bockaire/services/calculation_service.dart';
import 'package:bockaire/services/pdf_export_service.dart';
import 'package:bockaire/database/database.dart';
import 'package:bockaire/classes/carton.dart' as models;
import 'package:bockaire/providers/shipment_providers.dart';
import 'package:intl/intl.dart';

class QuotesPage extends ConsumerWidget {
  final String shipmentId;

  const QuotesPage({super.key, required this.shipmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shipmentAsync = ref.watch(shipmentProvider(shipmentId));
    final quotesAsync = ref.watch(quotesProvider(shipmentId));
    final cartonModelsAsync = ref.watch(cartonModelsProvider(shipmentId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: const Text('Shipping Quotes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _exportPDF(context, ref),
            tooltip: 'Export PDF',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.pagePadding),
        children: [
          // Shipment Summary Card
          shipmentAsync.when(
            data: (shipment) => cartonModelsAsync.when(
              data: (cartons) =>
                  _buildShipmentSummary(context, shipment, cartons),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => _buildErrorCard(context, err.toString()),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => _buildErrorCard(context, err.toString()),
          ),
          SizedBox(height: AppTheme.spacingLarge),

          // Quotes Section
          Text(
            'Available Quotes',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppTheme.spacingMedium),

          // Quotes List
          quotesAsync.when(
            data: (quotes) {
              if (quotes.isEmpty) {
                return _buildEmptyState(context);
              }
              return Column(
                children: quotes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final quote = entry.value;
                  final isCheapest = index == 0;
                  return Padding(
                    padding: EdgeInsets.only(bottom: AppTheme.cardSpacing),
                    child: _QuoteCard(
                      quote: quote,
                      isCheapest: isCheapest,
                      shipmentId: shipmentId,
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, stack) => _buildErrorCard(context, err.toString()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/optimizer/$shipmentId'),
        icon: const Icon(Icons.tune),
        label: const Text('Optimize Packing'),
      ),
    );
  }

  Widget _buildShipmentSummary(
    BuildContext context,
    Shipment shipment,
    List<dynamic> cartons,
  ) {
    // Cast to proper type for calculation service
    final cartonList = cartons.cast<models.Carton>();
    final totals = CalculationService.calculateTotals(cartonList);

    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                color: context.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: AppTheme.spacingSmall),
              Text(
                'Shipment Details',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingMedium),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingXSmall),
                    Text(
                      '${shipment.originCity}, ${shipment.originPostal}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: context.colorScheme.primary),
              SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingXSmall),
                    Text(
                      '${shipment.destCity}, ${shipment.destPostal}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingMedium),
          Divider(height: 1, color: context.colorScheme.outlineVariant),
          SizedBox(height: AppTheme.spacingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(
                context,
                icon: Icons.inventory_2_outlined,
                label: 'Cartons',
                value: '${totals.cartonCount}',
              ),
              _buildStat(
                context,
                icon: Icons.scale_outlined,
                label: 'Weight',
                value: '${totals.chargeableKg.toStringAsFixed(1)} kg',
              ),
              if (totals.isOversized)
                Icon(
                  Icons.warning_amber_rounded,
                  color: context.colorScheme.error,
                  size: 24,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: context.colorScheme.onSurfaceVariant),
        SizedBox(height: AppTheme.spacingXSmall),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: AppTheme.spacingXSmall),
        Text(
          value,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ModalCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 64,
                color: context.colorScheme.onSurfaceVariant,
              ),
              SizedBox(height: AppTheme.spacingMedium),
              Text('No quotes available', style: context.textTheme.titleMedium),
              SizedBox(height: AppTheme.spacingSmall),
              Text(
                'Please try again or contact support',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return ModalCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: context.colorScheme.error),
            SizedBox(width: AppTheme.spacingSmall),
            Expanded(
              child: Text(
                'Error: $error',
                style: TextStyle(color: context.colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPDF(BuildContext context, WidgetRef ref) async {
    try {
      final shipment = await ref.read(shipmentProvider(shipmentId).future);
      final quotes = await ref.read(quotesProvider(shipmentId).future);
      final cartons = await ref.read(cartonModelsProvider(shipmentId).future);

      await PDFExportService.exportQuotesPDF(
        shipment: shipment,
        quotes: quotes,
        cartons: cartons,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF exported successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error exporting PDF: $e')));
      }
    }
  }
}

class _QuoteCard extends StatefulWidget {
  final dynamic quote;
  final bool isCheapest;
  final String shipmentId;

  const _QuoteCard({
    required this.quote,
    required this.isCheapest,
    required this.shipmentId,
  });

  @override
  State<_QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<_QuoteCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final quote = widget.quote;
    final currency = NumberFormat.currency(symbol: '€', decimalDigits: 2);

    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isCheapest) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: context.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'CHEAPEST',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppTheme.spacingSmall),
                    ],
                    Text(
                      '${quote.carrier} ${quote.service}',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingXSmall),
                    Text(
                      '${quote.etaMin}-${quote.etaMax} days • ${quote.chargeableKg.toStringAsFixed(1)} kg',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                currency.format(quote.priceEur),
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.primary,
                ),
              ),
            ],
          ),

          // Expandable details
          if (_isExpanded) ...[
            SizedBox(height: AppTheme.spacingMedium),
            Divider(height: 1, color: context.colorScheme.outlineVariant),
            SizedBox(height: AppTheme.spacingMedium),
            Text(
              'Price Breakdown',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppTheme.spacingSmall),
            _buildBreakdownRow(
              context,
              'Chargeable Weight',
              '${quote.chargeableKg.toStringAsFixed(1)} kg',
            ),
            SizedBox(height: AppTheme.spacingXSmall),
            _buildBreakdownRow(
              context,
              'Total Price',
              currency.format(quote.priceEur),
              isBold: true,
            ),
          ],

          SizedBox(height: AppTheme.spacingMedium),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _bookShipment(context),
                  child: const Text('Book This'),
                ),
              ),
              SizedBox(width: AppTheme.spacingSmall),
              OutlinedButton(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                child: Row(
                  children: [
                    Text(_isExpanded ? 'Less' : 'Details'),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 18,
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

  Widget _buildBreakdownRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
            fontWeight: isBold ? FontWeight.bold : null,
          ),
        ),
        Text(
          value,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _bookShipment(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Shipment'),
        content: Text(
          'Book shipment with ${widget.quote.carrier} ${widget.quote.service}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Book'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking feature coming soon!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
