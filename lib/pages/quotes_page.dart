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
import 'package:bockaire/models/transport_method.dart';
import 'package:intl/intl.dart';

enum QuoteSortOption { priceLowHigh, priceHighLow, speedFastest, speedSlowest }

class QuotesPage extends ConsumerStatefulWidget {
  final String shipmentId;

  const QuotesPage({super.key, required this.shipmentId});

  @override
  ConsumerState<QuotesPage> createState() => _QuotesPageState();
}

class _QuotesPageState extends ConsumerState<QuotesPage> {
  TransportMethod? _selectedTransportFilter;
  QuoteSortOption _sortOption = QuoteSortOption.priceLowHigh;
  bool _groupByTransportMethod = false;

  @override
  Widget build(BuildContext context) {
    final shipmentAsync = ref.watch(shipmentProvider(widget.shipmentId));
    final quotesAsync = ref.watch(quotesProvider(widget.shipmentId));
    final cartonModelsAsync = ref.watch(
      cartonModelsProvider(widget.shipmentId),
    );

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
          const SizedBox(height: 24),

          // Filter and Sort Controls
          quotesAsync.when(
            data: (quotes) {
              if (quotes.isEmpty) return const SizedBox.shrink();
              return _buildFilterSortControls(quotes);
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 16),

          // Quotes Section
          quotesAsync.when(
            data: (quotes) {
              if (quotes.isEmpty) {
                return _buildEmptyState(context);
              }

              final filteredAndSorted = _filterAndSortQuotes(quotes);

              if (_groupByTransportMethod) {
                return _buildGroupedQuotes(filteredAndSorted);
              } else {
                return _buildQuotesList(filteredAndSorted);
              }
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
        onPressed: () => context.push('/optimizer/${widget.shipmentId}'),
        icon: const Icon(Icons.tune),
        label: const Text('Optimize Packing'),
      ),
    );
  }

  Widget _buildFilterSortControls(List<Quote> quotes) {
    // Get available transport methods from quotes
    final availableTransportMethods = <TransportMethod>{};
    for (final quote in quotes) {
      final methodName = quote.transportMethod;
      if (methodName != null) {
        try {
          final method = TransportMethod.values.firstWhere(
            (e) => e.name == methodName,
          );
          availableTransportMethods.add(method);
        } catch (e) {
          // Invalid method, skip
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row with Sort and Group Toggle
        Row(
          children: [
            Text(
              'Available Quotes',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            // Group Toggle
            IconButton(
              icon: Icon(
                _groupByTransportMethod
                    ? Icons.view_list_rounded
                    : Icons.view_module_rounded,
              ),
              onPressed: () {
                setState(() {
                  _groupByTransportMethod = !_groupByTransportMethod;
                });
              },
              tooltip: _groupByTransportMethod
                  ? 'List View'
                  : 'Group by Transport Method',
            ),
            // Sort Dropdown
            PopupMenuButton<QuoteSortOption>(
              icon: const Icon(Icons.sort_rounded),
              tooltip: 'Sort',
              onSelected: (option) {
                setState(() {
                  _sortOption = option;
                });
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: QuoteSortOption.priceLowHigh,
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_money_rounded,
                        size: 20,
                        color: context.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 12),
                      const Text('Price: Low to High'),
                      if (_sortOption == QuoteSortOption.priceLowHigh)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.check, size: 18),
                        ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: QuoteSortOption.priceHighLow,
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_money_rounded,
                        size: 20,
                        color: context.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 12),
                      const Text('Price: High to Low'),
                      if (_sortOption == QuoteSortOption.priceHighLow)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.check, size: 18),
                        ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: QuoteSortOption.speedFastest,
                  child: Row(
                    children: [
                      Icon(
                        Icons.speed_rounded,
                        size: 20,
                        color: context.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 12),
                      const Text('Speed: Fastest First'),
                      if (_sortOption == QuoteSortOption.speedFastest)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.check, size: 18),
                        ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: QuoteSortOption.speedSlowest,
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 20,
                        color: context.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 12),
                      const Text('Speed: Slowest First'),
                      if (_sortOption == QuoteSortOption.speedSlowest)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.check, size: 18),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Transport Method Filter Chips
        if (availableTransportMethods.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // All Quotes Chip
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: _selectedTransportFilter == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedTransportFilter = null;
                      });
                    },
                    avatar: _selectedTransportFilter == null
                        ? null
                        : const Icon(Icons.check, size: 18),
                  ),
                ),
                // Transport Method Chips
                ...availableTransportMethods.map((method) {
                  final info = transportMethods[method]!;
                  final isSelected = _selectedTransportFilter == method;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(info.icon),
                          const SizedBox(width: 6),
                          Text(info.displayName),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTransportFilter = selected ? method : null;
                        });
                      },
                      backgroundColor: _getTransportMethodColor(
                        method,
                      ).withValues(alpha: 0.1),
                      selectedColor: _getTransportMethodColor(
                        method,
                      ).withValues(alpha: 0.3),
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  List<Quote> _filterAndSortQuotes(List<Quote> quotes) {
    var filtered = quotes.toList();

    // Apply filter
    if (_selectedTransportFilter != null) {
      filtered = filtered.where((quote) {
        final methodName = quote.transportMethod;
        if (methodName == null) return false;
        try {
          final method = TransportMethod.values.firstWhere(
            (e) => e.name == methodName,
          );
          return method == _selectedTransportFilter;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    // Apply sort
    switch (_sortOption) {
      case QuoteSortOption.priceLowHigh:
        filtered.sort((a, b) => a.priceEur.compareTo(b.priceEur));
        break;
      case QuoteSortOption.priceHighLow:
        filtered.sort((a, b) => b.priceEur.compareTo(a.priceEur));
        break;
      case QuoteSortOption.speedFastest:
        filtered.sort((a, b) => a.etaMin.compareTo(b.etaMin));
        break;
      case QuoteSortOption.speedSlowest:
        filtered.sort((a, b) => b.etaMax.compareTo(a.etaMax));
        break;
    }

    return filtered;
  }

  Widget _buildQuotesList(List<Quote> quotes) {
    // Find cheapest and fastest
    Quote? cheapest;
    Quote? fastest;

    if (quotes.isNotEmpty) {
      cheapest = quotes.reduce((a, b) => a.priceEur < b.priceEur ? a : b);
      fastest = quotes.reduce((a, b) => a.etaMin < b.etaMin ? a : b);
    }

    return Column(
      children: quotes.map((quote) {
        final isCheapest = cheapest?.id == quote.id;
        final isFastest = fastest?.id == quote.id;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _QuoteCard(
            quote: quote,
            isCheapest: isCheapest,
            isFastest: isFastest,
            shipmentId: widget.shipmentId,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGroupedQuotes(List<Quote> quotes) {
    // Group by transport method
    final grouped = <TransportMethod, List<Quote>>{};
    for (final quote in quotes) {
      final methodName = quote.transportMethod;
      TransportMethod? method;
      if (methodName != null) {
        try {
          method = TransportMethod.values.firstWhere(
            (e) => e.name == methodName,
          );
        } catch (e) {
          method = TransportMethod.standardAir; // Default
        }
      } else {
        method = TransportMethod.standardAir;
      }
      grouped.putIfAbsent(method, () => []).add(quote);
    }

    // Sort groups by speed (fastest first)
    final sortedGroups = grouped.entries.toList()
      ..sort((a, b) {
        final aInfo = transportMethods[a.key]!;
        final bInfo = transportMethods[b.key]!;
        return aInfo.minDays.compareTo(bInfo.minDays);
      });

    return Column(
      children: sortedGroups.map((entry) {
        final method = entry.key;
        final methodQuotes = entry.value;
        final info = transportMethods[method]!;

        // Find cheapest in this category
        final cheapestInCategory = methodQuotes.reduce(
          (a, b) => a.priceEur < b.priceEur ? a : b,
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _buildTransportMethodSection(
            method: method,
            info: info,
            quotes: methodQuotes,
            cheapestId: cheapestInCategory.id,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTransportMethodSection({
    required TransportMethod method,
    required TransportMethodInfo info,
    required List<Quote> quotes,
    required String cheapestId,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getTransportMethodColor(method).withValues(alpha: 0.8),
                _getTransportMethodColor(method),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: [
              Text(info.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.displayName,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${info.description} • ${info.minDays}-${info.maxDays} days',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${quotes.length} ${quotes.length == 1 ? 'option' : 'options'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Quotes in this category
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _getTransportMethodColor(method).withValues(alpha: 0.3),
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
          ),
          child: Column(
            children: quotes.map((quote) {
              final isCheapestInCategory = quote.id == cheapestId;

              return Container(
                decoration: BoxDecoration(
                  border: quotes.last != quote
                      ? Border(
                          bottom: BorderSide(
                            color: context.colorScheme.outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                        )
                      : null,
                ),
                child: _QuoteCard(
                  quote: quote,
                  isCheapest: isCheapestInCategory,
                  isFastest: false,
                  shipmentId: widget.shipmentId,
                  showTransportChip: false,
                  isCheapestInCategory: isCheapestInCategory,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _getTransportMethodColor(TransportMethod method) {
    switch (method) {
      case TransportMethod.expressAir:
        return Colors.purple;
      case TransportMethod.standardAir:
        return Colors.blue;
      case TransportMethod.airFreight:
        return Colors.teal;
      case TransportMethod.seaFreightLCL:
      case TransportMethod.seaFreightFCL:
        return Colors.indigo;
      case TransportMethod.roadFreight:
        return Colors.orange;
    }
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
              const SizedBox(width: 8),
              Text(
                'Shipment Details',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                    const SizedBox(height: 4),
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
              const SizedBox(width: 12),
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
                    const SizedBox(height: 4),
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
          const SizedBox(height: 16),
          Divider(height: 1, color: context.colorScheme.outlineVariant),
          const SizedBox(height: 16),
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
        const SizedBox(height: 4),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
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
              const SizedBox(height: 16),
              Text('No quotes available', style: context.textTheme.titleMedium),
              const SizedBox(height: 8),
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
            const SizedBox(width: 8),
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
      final shipment = await ref.read(
        shipmentProvider(widget.shipmentId).future,
      );
      final quotes = await ref.read(quotesProvider(widget.shipmentId).future);
      final cartons = await ref.read(
        cartonModelsProvider(widget.shipmentId).future,
      );

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
  final Quote quote;
  final bool isCheapest;
  final bool isFastest;
  final String shipmentId;
  final bool showTransportChip;
  final bool isCheapestInCategory;

  const _QuoteCard({
    required this.quote,
    required this.isCheapest,
    required this.isFastest,
    required this.shipmentId,
    this.showTransportChip = true,
    this.isCheapestInCategory = false,
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
          // Header with badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badges Row
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (widget.isCheapest)
                          _buildBadge(
                            context,
                            icon: Icons.star,
                            label: 'CHEAPEST',
                            color: Colors.green,
                          ),
                        if (widget.isFastest)
                          _buildBadge(
                            context,
                            icon: Icons.bolt,
                            label: 'FASTEST',
                            color: Colors.orange,
                          ),
                        if (widget.isCheapestInCategory && !widget.isCheapest)
                          _buildBadge(
                            context,
                            icon: Icons.star_half,
                            label: 'BEST IN CATEGORY',
                            color: Colors.blue,
                          ),
                        if (widget.showTransportChip)
                          _buildTransportMethodChip(context, quote),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Carrier and Service
                    Text(
                      '${quote.carrier} ${quote.service}',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // ETA and Weight
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${quote.etaMin}-${quote.etaMax} days',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.scale,
                          size: 14,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${quote.chargeableKg.toStringAsFixed(1)} kg',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Price
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
            const SizedBox(height: 16),
            Divider(height: 1, color: context.colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(
              'Price Breakdown',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildBreakdownRow(
              context,
              'Chargeable Weight',
              '${quote.chargeableKg.toStringAsFixed(1)} kg',
            ),
            const SizedBox(height: 4),
            _buildBreakdownRow(
              context,
              'Total Price',
              currency.format(quote.priceEur),
              isBold: true,
            ),
          ],

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _bookShipment(context),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Book This'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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

  Widget _buildBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportMethodChip(BuildContext context, Quote quote) {
    // Get transport method from quote
    final transportMethodName = quote.transportMethod;

    // Parse transport method
    TransportMethod? transportMethod;
    TransportMethodInfo? methodInfo;

    if (transportMethodName != null) {
      try {
        transportMethod = TransportMethod.values.firstWhere(
          (e) => e.name == transportMethodName,
        );
        methodInfo = transportMethods[transportMethod];
      } catch (e) {
        // Invalid transport method, use default
      }
    }

    // Default if not found
    methodInfo ??= transportMethods[TransportMethod.standardAir]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getTransportMethodColor(
          transportMethod ?? TransportMethod.standardAir,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(methodInfo.icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            methodInfo.displayName,
            style: context.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTransportMethodColor(TransportMethod method) {
    switch (method) {
      case TransportMethod.expressAir:
        return Colors.purple;
      case TransportMethod.standardAir:
        return Colors.blue;
      case TransportMethod.airFreight:
        return Colors.teal;
      case TransportMethod.seaFreightLCL:
      case TransportMethod.seaFreightFCL:
        return Colors.indigo;
      case TransportMethod.roadFreight:
        return Colors.orange;
    }
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
