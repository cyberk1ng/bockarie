import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bockaire/widgets/modal/modal_utils.dart';
import 'package:bockaire/pages/new_shipment_page.dart';
import 'package:bockaire/providers/shipment_providers.dart';
import 'package:bockaire/themes/theme.dart';
import 'package:bockaire/themes/neon_theme.dart';
import 'package:bockaire/get_it.dart';
import 'package:bockaire/database/database.dart';
import 'package:bockaire/l10n/app_localizations.dart';
import 'package:bockaire/providers/currency_provider.dart';
import 'package:bockaire/widgets/neon/neon_widgets.dart';
import 'package:bockaire/widgets/neon/sparkle_decoration.dart';
import 'dart:math' as math;

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  void _openNewShipmentModal(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    ModalUtils.showSinglePageModal(
      context: context,
      title: localizations.titleNewShipment,
      builder: (modalContext) => const NewShipmentContent(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final shipmentsAsync = ref.watch(recentShipmentsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: Image.asset(
          'assets/images/bockarie_logo_cropped.png',
          height: 42,
          fit: BoxFit.contain,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Sparkle background decoration
          if (isDark)
            Positioned.fill(child: SparkleDecoration(sparkleCount: 30)),

          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localizations.titleRecentShipments,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    // Plus button
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: NeonColors.cyan, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: NeonColors.cyanGlow,
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.add, color: NeonColors.cyan),
                        onPressed: () => _openNewShipmentModal(context),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: shipmentsAsync.when(
                  data: (shipments) {
                    if (shipments.isEmpty) {
                      return _buildEmptyState(context);
                    }
                    return ListView.builder(
                      padding: EdgeInsets.only(bottom: 20),
                      itemCount: shipments.length,
                      itemBuilder: (context, index) {
                        final shipment = shipments[index];
                        return _buildNeonShipmentCard(
                          context,
                          ref,
                          shipment,
                          index,
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
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
                          localizations.errorLoadingShipments,
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
        ],
      ),
    );
  }

  Widget _buildNeonShipmentCard(
    BuildContext context,
    WidgetRef ref,
    Shipment shipment,
    int index,
  ) {
    final cheapestQuoteAsync = ref.watch(cheapestQuoteProvider(shipment.id));
    final currency = ref.watch(currencyNotifierProvider);
    final currencyService = ref.watch(currencyServiceProvider);

    // Cycle through colors for variety
    final colors = [NeonColors.cyan, NeonColors.green, NeonColors.purple];
    final routeColor = colors[index % colors.length];

    // Determine status (simplified for now)
    final random = math.Random(shipment.id.hashCode);
    final status = random.nextBool()
        ? ShipmentStatus.inTransit
        : ShipmentStatus.delivered;

    return Dismissible(
      key: Key(shipment.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: context.colorScheme.error,
          borderRadius: BorderRadius.circular(NeonTheme.borderRadius),
        ),
        child: Icon(Icons.delete_outline, color: context.colorScheme.onError),
      ),
      confirmDismiss: (direction) async {
        await _deleteShipment(context, ref, shipment);
        return false; // Don't auto-dismiss, let _deleteShipment handle it
      },
      child: cheapestQuoteAsync.when(
        data: (quote) {
          final price = quote != null
              ? double.parse(
                  currencyService
                      .formatAmount(
                        amountInEur: quote.priceEur,
                        currency: currency,
                        decimals: 0,
                      )
                      .replaceAll(RegExp(r'[^\d.]'), ''),
                )
              : 0.0;

          final weight = quote?.chargeableKg ?? 0.0;

          return ShipmentCard(
            data: ShipmentCardData(
              originCity: shipment.originCity,
              originCountry: shipment.originCountry,
              destinationCity: shipment.destCity,
              destinationCountry: shipment.destCountry,
              weight: weight,
              price: price,
              currency: currency.code,
              status: status,
              routeColor: routeColor,
            ),
            onViewQuotes: () => context.push('/quotes/${shipment.id}'),
            onOptimize: () => context.push('/optimizer/${shipment.id}'),
          );
        },
        loading: () => ShimmerShipmentCard(routeColor: routeColor),
        error: (_, __) => ShipmentCard(
          data: ShipmentCardData(
            originCity: shipment.originCity,
            originCountry: shipment.originCountry,
            destinationCity: shipment.destCity,
            destinationCountry: shipment.destCountry,
            weight: 0,
            price: 0,
            currency: currency.code,
            status: status,
            routeColor: routeColor,
          ),
          onViewQuotes: () => context.push('/quotes/${shipment.id}'),
          onOptimize: () => context.push('/optimizer/${shipment.id}'),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
            localizations.emptyStateNoShipments,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppTheme.spacingSmall),
          Text(
            localizations.emptyStateCreateFirst,
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
    final localizations = AppLocalizations.of(context)!;
    final confirm = await ModalUtils.showSinglePageModal<bool>(
      context: context,
      title: localizations.deleteShipmentTitle,
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
                child: Text(localizations.buttonCancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(localizations.buttonDelete),
              ),
            ),
          ],
        ),
      ),
      builder: (modalContext) {
        return Text(
          localizations.deleteShipmentMessage(
            shipment.originCity,
            shipment.destCity,
          ),
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
          final localizations = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.successShipmentDeleted)),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${AppLocalizations.of(context)!.errorDeletingShipment}: $e',
              ),
            ),
          );
        }
      }
    }
  }
}

/// Shimmer loading placeholder for shipment card
class ShimmerShipmentCard extends StatelessWidget {
  final Color routeColor;

  const ShimmerShipmentCard({super.key, required this.routeColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? NeonColors.darkCard : NeonColors.lightCard;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(NeonTheme.borderRadius),
        border: Border.all(
          color: routeColor.withValues(alpha: 0.2),
          width: NeonTheme.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 24,
            width: 200,
            decoration: BoxDecoration(
              color: routeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: routeColor.withValues(alpha: 0.1),
                ),
              ),
              Expanded(
                child: Container(
                  height: 2,
                  color: routeColor.withValues(alpha: 0.1),
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: routeColor.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            height: 16,
            width: 150,
            decoration: BoxDecoration(
              color: routeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
