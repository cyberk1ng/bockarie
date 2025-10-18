import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bockaire/widgets/modal/modal_utils.dart';
import 'package:bockaire/widgets/modal/modal_card.dart';
import 'package:bockaire/pages/new_shipment_page.dart';
import 'package:bockaire/providers/shipment_providers.dart';
import 'package:bockaire/themes/theme.dart';
import 'package:bockaire/get_it.dart';
import 'package:bockaire/database/database.dart';
import 'package:intl/intl.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  void _openNewShipmentModal(BuildContext context) {
    ModalUtils.showSinglePageModal(
      context: context,
      title: 'New Shipment',
      builder: (modalContext) => const NewShipmentContent(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shipmentsAsync = ref.watch(recentShipmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bockaire'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Recent Shipments',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppTheme.spacingMedium),
            Expanded(
              child: shipmentsAsync.when(
                data: (shipments) {
                  if (shipments.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return ListView.separated(
                    itemCount: shipments.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: AppTheme.cardSpacing),
                    itemBuilder: (context, index) {
                      final shipment = shipments[index];
                      return _ShipmentCard(
                        shipment: shipment,
                        onDelete: () => _deleteShipment(context, ref, shipment),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: context.colorScheme.error,
                      ),
                      SizedBox(height: AppTheme.spacingMedium),
                      Text(
                        'Error loading shipments',
                        style: context.textTheme.titleMedium,
                      ),
                      SizedBox(height: AppTheme.spacingSmall),
                      Text(
                        err.toString(),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNewShipmentModal(context),
        icon: const Icon(Icons.add),
        label: const Text('New Shipment'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 80,
            color: context.colorScheme.onSurfaceVariant.withAlpha(100),
          ),
          SizedBox(height: AppTheme.spacingMedium),
          Text(
            'No shipments yet',
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppTheme.spacingSmall),
          Text(
            'Create your first shipment to get started',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteShipment(
    BuildContext context,
    WidgetRef ref,
    Shipment shipment,
  ) async {
    final confirm = await ModalUtils.showSinglePageModal<bool>(
      context: context,
      title: 'Delete Shipment',
      showCloseButton: true,
      barrierDismissible: true,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      stickyActionBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ),
          ],
        ),
      ),
      builder: (modalContext) {
        return Text(
          'Are you sure you want to delete the shipment from ${shipment.originCity} to ${shipment.destCity}?',
          style: Theme.of(modalContext).textTheme.bodyLarge,
        );
      },
    );

    if (confirm == true) {
      try {
        final db = getIt<AppDatabase>();

        // Delete quotes first (foreign key constraint)
        await (db.delete(
          db.quotes,
        )..where((q) => q.shipmentId.equals(shipment.id))).go();

        // Delete cartons
        await (db.delete(
          db.cartons,
        )..where((c) => c.shipmentId.equals(shipment.id))).go();

        // Delete shipment
        await (db.delete(
          db.shipments,
        )..where((s) => s.id.equals(shipment.id))).go();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Shipment deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting shipment: $e')),
          );
        }
      }
    }
  }
}

class _ShipmentCard extends ConsumerWidget {
  final Shipment shipment;
  final VoidCallback onDelete;

  const _ShipmentCard({required this.shipment, required this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM dd');
    final cheapestQuoteAsync = ref.watch(cheapestQuoteProvider(shipment.id));

    return Dismissible(
      key: Key(shipment.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: context.colorScheme.error,
          borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        ),
        child: Icon(Icons.delete_outline, color: context.colorScheme.onError),
      ),
      confirmDismiss: (direction) async {
        onDelete();
        return false; // Don't auto-dismiss, let onDelete handle it
      },
      child: ModalCard(
        child: InkWell(
          onTap: () => context.push('/quotes/${shipment.id}'),
          borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            color: context.colorScheme.primary,
                            size: 20,
                          ),
                          SizedBox(width: AppTheme.spacingSmall),
                          Expanded(
                            child: Text(
                              '${shipment.originCity} → ${shipment.destCity}',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      dateFormat.format(shipment.createdAt),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.spacingSmall),
                cheapestQuoteAsync.when(
                  data: (quote) {
                    if (quote == null) {
                      return Text(
                        'Calculating quotes...',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      );
                    }
                    final currency = NumberFormat.currency(
                      symbol: '€',
                      decimalDigits: 0,
                    );
                    return Row(
                      children: [
                        Text(
                          '${quote.chargeableKg.toStringAsFixed(1)} kg • from ${currency.format(quote.priceEur)}',
                          style: context.textTheme.bodyMedium,
                        ),
                      ],
                    );
                  },
                  loading: () => Text(
                    'Loading...',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  error: (_, __) => Text(
                    'No quotes available',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.error,
                    ),
                  ),
                ),
                SizedBox(height: AppTheme.spacingMedium),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.push('/quotes/${shipment.id}'),
                        child: const Text('View Quotes'),
                      ),
                    ),
                    SizedBox(width: AppTheme.spacingSmall),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            context.push('/optimizer/${shipment.id}'),
                        child: const Text('Optimize'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
