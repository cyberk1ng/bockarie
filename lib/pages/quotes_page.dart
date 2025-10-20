import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bockaire/themes/theme.dart';
import 'package:bockaire/widgets/modal/modal_card.dart';
import 'package:bockaire/widgets/modal/modal_utils.dart';
import 'package:bockaire/widgets/shipment/city_autocomplete_field.dart';
import 'package:bockaire/services/calculation_service.dart';
import 'package:bockaire/services/pdf_export_service.dart';
import 'package:bockaire/services/quote_calculator_service.dart';
import 'package:bockaire/database/database.dart';
import 'package:bockaire/classes/carton.dart' as models;
import 'package:bockaire/providers/shipment_providers.dart';
import 'package:bockaire/models/transport_method.dart';
import 'package:bockaire/utils/duration_parser.dart';
import 'package:bockaire/get_it.dart';
import 'package:bockaire/config/route_constants.dart';
import 'package:bockaire/config/validation_constants.dart';
import 'package:bockaire/config/color_constants.dart';
import 'package:bockaire/config/ui_constants.dart';
import 'package:bockaire/config/shippo_config.dart';
import 'package:bockaire/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import 'package:bockaire/providers/currency_provider.dart';

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

  String _getLocalizedTransportMethodName(TransportMethod method) {
    final localizations = AppLocalizations.of(context)!;
    switch (method) {
      case TransportMethod.expressAir:
        return localizations.transportExpressAir;
      case TransportMethod.standardAir:
        return localizations.transportStandardAir;
      case TransportMethod.airFreight:
        return localizations.transportAirFreight;
      case TransportMethod.seaFreightLCL:
        return localizations.transportSeaFreightLCL;
      case TransportMethod.seaFreightFCL:
        return localizations.transportSeaFreightFCL;
      case TransportMethod.roadFreight:
        return localizations.transportRoadFreight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
          tooltip: localizations.tooltipBack,
        ),
        title: Text(localizations.titleShippingQuotes),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _exportPDF(context, ref),
            tooltip: localizations.actionExportPdf,
          ),
        ],
      ),
      body: Column(
        children: [
          // TEST MODE BANNER
          if (ShippoConfig.useTestMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.orange.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.science, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '🧪 ${localizations.shippoTestModeWarning}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.pagePadding),
              children: [
                // Shipment Summary Card
                shipmentAsync.when(
                  data: (shipment) => cartonModelsAsync.when(
                    data: (cartons) =>
                        _buildShipmentSummary(context, shipment, cartons),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) =>
                        _buildErrorCard(context, err.toString()),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) =>
                      _buildErrorCard(context, err.toString()),
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

                const SizedBox(height: 24),

                // Quotes Section
                quotesAsync.when(
                  data: (quotes) {
                    if (quotes.isEmpty) {
                      return _buildEmptyState(context, cartonModelsAsync);
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
                  error: (err, stack) =>
                      _buildErrorCard(context, err.toString()),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push(RouteConstants.optimizerWithId(widget.shipmentId)),
        icon: const Icon(Icons.tune),
        label: Text(localizations.actionOptimizePacking),
      ),
    );
  }

  Widget _buildFilterSortControls(List<Quote> quotes) {
    final localizations = AppLocalizations.of(context)!;
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
              localizations.titleAvailableQuotes,
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
                  ? localizations.tooltipListView
                  : localizations.tooltipGroupByTransportMethod,
            ),
            // Sort Dropdown
            PopupMenuButton<QuoteSortOption>(
              icon: const Icon(Icons.sort_rounded),
              tooltip: localizations.tooltipSort,
              onSelected: (option) {
                setState(() {
                  _sortOption = option;
                });
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: QuoteSortOption.priceLowHigh,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.attach_money_rounded,
                        size: 20,
                        color: context.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 12),
                      Flexible(child: Text(localizations.sortPriceLowHigh)),
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.attach_money_rounded,
                        size: 20,
                        color: context.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 12),
                      Flexible(child: Text(localizations.sortPriceHighLow)),
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.speed_rounded,
                        size: 20,
                        color: context.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 12),
                      Flexible(child: Text(localizations.sortSpeedFastest)),
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 20,
                        color: context.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 12),
                      Flexible(child: Text(localizations.sortSpeedSlowest)),
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
                    label: Text(localizations.filterAll),
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
                          Text(_getLocalizedTransportMethodName(method)),
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
                      ).withValues(alpha: ColorConstants.alphaLightest),
                      selectedColor: _getTransportMethodColor(
                        method,
                      ).withValues(alpha: ColorConstants.alphaMedium),
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
    final localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getTransportMethodColor(
                  method,
                ).withValues(alpha: ColorConstants.alphaHigh),
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
                      _getLocalizedTransportMethodName(method),
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${info.description} • ${localizations.etaDays(info.minDays, info.maxDays)}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(
                          alpha: ColorConstants.alphaVeryHigh,
                        ),
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
                  color: Colors.white.withValues(
                    alpha: ColorConstants.alphaLight,
                  ),
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
              color: _getTransportMethodColor(
                method,
              ).withValues(alpha: ColorConstants.alphaMedium),
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
                                .withValues(
                                  alpha: ColorConstants.alphaMediumHigh,
                                ),
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
        return ColorConstants.transportExpressAir;
      case TransportMethod.standardAir:
        return ColorConstants.transportStandardAir;
      case TransportMethod.airFreight:
        return ColorConstants.transportAirFreight;
      case TransportMethod.seaFreightLCL:
      case TransportMethod.seaFreightFCL:
        return ColorConstants.transportSeaFreight;
      case TransportMethod.roadFreight:
        return ColorConstants.transportRoadFreight;
    }
  }

  Widget _buildShipmentSummary(
    BuildContext context,
    Shipment shipment,
    List<dynamic> cartons,
  ) {
    final localizations = AppLocalizations.of(context)!;
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
                localizations.titleShipmentDetails,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                localizations.hintClickToEdit,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () =>
                      _showEditAddressDialog(context, shipment, isOrigin: true),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              localizations.labelFrom,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.edit_outlined,
                              size: 14,
                              color: context.colorScheme.primary,
                            ),
                          ],
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward,
                  color: context.colorScheme.primary,
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _showEditAddressDialog(
                    context,
                    shipment,
                    isOrigin: false,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              localizations.labelTo,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.edit_outlined,
                              size: 14,
                              color: context.colorScheme.primary,
                            ),
                          ],
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
              _buildClickableStat(
                context,
                icon: Icons.inventory_2_outlined,
                label: localizations.labelCartons,
                value: '${totals.cartonCount}',
                onTap: () async {
                  final navContext = context;
                  final quotes = await ref.read(
                    quotesProvider(widget.shipmentId).future,
                  );
                  if (mounted && navContext.mounted) {
                    _showEditDimensionsDialog(
                      navContext,
                      shipment,
                      cartonList,
                      quotes,
                    );
                  }
                },
              ),
              _buildStat(
                context,
                icon: Icons.scale_outlined,
                label: localizations.labelWeight,
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

  void _showEditAddressDialog(
    BuildContext context,
    Shipment shipment, {
    required bool isOrigin,
  }) {
    final localizations = AppLocalizations.of(context)!;
    final cityController = TextEditingController(
      text: isOrigin ? shipment.originCity : shipment.destCity,
    );
    final postalController = TextEditingController(
      text: isOrigin ? shipment.originPostal : shipment.destPostal,
    );
    final countryController = TextEditingController(
      text: isOrigin ? shipment.originCountry : shipment.destCountry,
    );
    final stateController = TextEditingController(
      text: isOrigin ? shipment.originState : shipment.destState,
    );

    ModalUtils.showSinglePageModal(
      context: context,
      title: isOrigin
          ? localizations.editOriginTitle
          : localizations.editDestinationTitle,
      showCloseButton: true,
      barrierDismissible: true,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      stickyActionBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localizations.buttonCancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () async {
                  final db = getIt<AppDatabase>();

                  try {
                    // Update address
                    if (isOrigin) {
                      await (db.update(
                        db.shipments,
                      )..where((s) => s.id.equals(widget.shipmentId))).write(
                        ShipmentsCompanion(
                          originCity: drift.Value(cityController.text),
                          originPostal: drift.Value(postalController.text),
                          originCountry: drift.Value(countryController.text),
                          originState: drift.Value(stateController.text),
                        ),
                      );
                    } else {
                      await (db.update(
                        db.shipments,
                      )..where((s) => s.id.equals(widget.shipmentId))).write(
                        ShipmentsCompanion(
                          destCity: drift.Value(cityController.text),
                          destPostal: drift.Value(postalController.text),
                          destCountry: drift.Value(countryController.text),
                          destState: drift.Value(stateController.text),
                        ),
                      );
                    }

                    // Fetch updated shipment and cartons for quote recalculation
                    final updatedShipment =
                        await (db.select(db.shipments)
                              ..where((s) => s.id.equals(widget.shipmentId)))
                            .getSingle();

                    final cartons =
                        await (db.select(db.cartons)..where(
                              (c) => c.shipmentId.equals(widget.shipmentId),
                            ))
                            .get();

                    // Convert to model cartons for calculation
                    final cartonModels = cartons
                        .map(
                          (c) => models.Carton(
                            id: c.id,
                            shipmentId: c.shipmentId,
                            lengthCm: c.lengthCm,
                            widthCm: c.widthCm,
                            heightCm: c.heightCm,
                            weightKg: c.weightKg,
                            qty: c.qty,
                            itemType: c.itemType,
                          ),
                        )
                        .toList();

                    final totals = CalculationService.calculateTotals(
                      cartonModels,
                    );

                    // Regenerate quotes with new address
                    final quoteService = getIt<QuoteCalculatorService>();
                    final newQuotes = await quoteService.calculateAllQuotes(
                      chargeableKg: totals.chargeableKg,
                      isOversized: totals.isOversized,
                      originCity: updatedShipment.originCity,
                      originPostal: updatedShipment.originPostal,
                      originCountry: updatedShipment.originCountry,
                      originState: updatedShipment.originState,
                      destCity: updatedShipment.destCity,
                      destPostal: updatedShipment.destPostal,
                      destCountry: updatedShipment.destCountry,
                      destState: updatedShipment.destState,
                      cartons: cartons,
                      useShippoApi: true,
                      fallbackToLocalRates:
                          false, // Don't use China-Europe rates for other routes
                    );

                    // Delete old quotes
                    await (db.delete(
                          db.quotes,
                        )..where((q) => q.shipmentId.equals(widget.shipmentId)))
                        .go();

                    // Save new quotes
                    for (final quote in newQuotes) {
                      final (etaMin, etaMax) = parseDuration(
                        quote.estimatedDays,
                        quote.durationTerms,
                      );

                      final transportMethod = classifyTransportMethod(
                        quote.carrier,
                        quote.service,
                        quote.estimatedDays ?? 5,
                      );

                      await db
                          .into(db.quotes)
                          .insert(
                            QuotesCompanion(
                              id: drift.Value(const Uuid().v4()),
                              shipmentId: drift.Value(widget.shipmentId),
                              carrier: drift.Value(quote.carrier),
                              service: drift.Value(quote.service),
                              etaMin: drift.Value(etaMin),
                              etaMax: drift.Value(etaMax),
                              priceEur: drift.Value(quote.total),
                              chargeableKg: drift.Value(quote.chargeableKg),
                              transportMethod: drift.Value(
                                transportMethod.name,
                              ),
                            ),
                          );
                    }

                    // Invalidate providers to refresh UI
                    ref.invalidate(shipmentProvider(widget.shipmentId));
                    ref.invalidate(quotesProvider(widget.shipmentId));

                    if (context.mounted) {
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            newQuotes.isNotEmpty
                                ? localizations.successAddressUpdated(
                                    newQuotes.length,
                                  )
                                : localizations.warningNoQuotesConfigureShippo,
                          ),
                          backgroundColor: newQuotes.isNotEmpty
                              ? Colors.green
                              : Colors.orange,
                          duration: Duration(
                            seconds: newQuotes.isEmpty
                                ? UIConstants.snackBarDurationLong
                                : UIConstants.snackBarDurationMedium,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${localizations.errorUpdatingAddress}: $e',
                          ),
                        ),
                      );
                    }
                  }
                },
                child: Text(localizations.buttonSave),
              ),
            ),
          ],
        ),
      ),
      builder: (modalContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CityAutocompleteField(
              cityController: cityController,
              postalController: postalController,
              countryController: countryController,
              stateController: stateController,
              label: localizations.labelCity,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: postalController,
              decoration: InputDecoration(
                labelText: localizations.labelPostalCode,
                border: const OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: countryController,
                    decoration: InputDecoration(
                      labelText: localizations.labelCountry,
                      border: const OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: stateController,
                    decoration: InputDecoration(
                      labelText: localizations.labelState,
                      border: const OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              localizations.autoFillNote,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(modalContext).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditDimensionsDialog(
    BuildContext context,
    Shipment shipment,
    List<models.Carton> cartons,
    List<Quote> originalQuotes,
  ) {
    final localizations = AppLocalizations.of(context)!;
    ModalUtils.showSinglePageModal(
      context: context,
      title: localizations.editDimensionsTitle,
      showCloseButton: true,
      barrierDismissible: true,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      builder: (modalContext) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.editDimensionsSubtitle,
                style: Theme.of(modalContext).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(modalContext).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              _EditableCartonsList(
                shipmentId: widget.shipmentId,
                shipment: shipment,
                originalCartons: cartons,
                originalQuotes: originalQuotes,
                onQuotesUpdated: () {
                  ref.invalidate(cartonModelsProvider(widget.shipmentId));
                  ref.invalidate(quotesProvider(widget.shipmentId));
                  Navigator.pop(modalContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClickableStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: context.colorScheme.primary.withValues(
              alpha: ColorConstants.alphaMedium,
            ),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: context.colorScheme.primary),
                const SizedBox(width: 4),
                Icon(
                  Icons.edit_outlined,
                  size: 14,
                  color: context.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colorScheme.primary,
              ),
            ),
          ],
        ),
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

  Widget _buildEmptyState(
    BuildContext context,
    AsyncValue<List<models.Carton>> cartonModelsAsync,
  ) {
    final localizations = AppLocalizations.of(context)!;
    return ModalCard(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 72,
              color: Colors.orange.shade300,
            ),
            const SizedBox(height: 20),
            Text(
              localizations.emptyStateNoQuotes,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _getNoQuotesMessage(cartonModelsAsync, context),
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(
                  alpha: ColorConstants.alphaLightest,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withValues(
                    alpha: ColorConstants.alphaMedium,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 20,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        localizations.shippoHowToGetRealQuotes,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStep('1', localizations.shippoStep1),
                  const SizedBox(height: 8),
                  _buildStep('2', localizations.shippoStep2),
                  const SizedBox(height: 8),
                  _buildStep('3', localizations.shippoStep3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ),
      ],
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

  String _getNoQuotesMessage(
    AsyncValue<List<models.Carton>> cartonModelsAsync,
    BuildContext context,
  ) {
    final localizations = AppLocalizations.of(context)!;

    // Check if we're in test mode with multiple parcels
    if (ShippoConfig.useTestMode) {
      final cartons = cartonModelsAsync.valueOrNull;
      if (cartons != null) {
        final totalParcels = cartons.fold<int>(0, (sum, c) => sum + c.qty);
        if (totalParcels > 1) {
          return localizations.shippoTestMultiParcelLimitation;
        }
      }

      return localizations.shippoTestNoQuotes;
    }

    // Production mode - use existing message
    return localizations.emptyStateNoQuotes;
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
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.successPdfExported)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${localizations.errorExportingPdf}: $e')),
        );
      }
    }
  }
}

class _QuoteCard extends ConsumerStatefulWidget {
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
  ConsumerState<_QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends ConsumerState<_QuoteCard> {
  bool _isExpanded = false;

  String _getLocalizedTransportMethodName(TransportMethod method) {
    final localizations = AppLocalizations.of(context)!;
    switch (method) {
      case TransportMethod.expressAir:
        return localizations.transportExpressAir;
      case TransportMethod.standardAir:
        return localizations.transportStandardAir;
      case TransportMethod.airFreight:
        return localizations.transportAirFreight;
      case TransportMethod.seaFreightLCL:
        return localizations.transportSeaFreightLCL;
      case TransportMethod.seaFreightFCL:
        return localizations.transportSeaFreightFCL;
      case TransportMethod.roadFreight:
        return localizations.transportRoadFreight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final quote = widget.quote;
    final currency = ref.watch(currencyNotifierProvider);
    final currencyService = ref.watch(currencyServiceProvider);

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
                            label: localizations.badgeCheapest,
                            color: ColorConstants.badgeCheapest,
                          ),
                        if (widget.isFastest)
                          _buildBadge(
                            context,
                            icon: Icons.bolt,
                            label: localizations.badgeFastest,
                            color: ColorConstants.badgeFastest,
                          ),
                        if (widget.isCheapestInCategory && !widget.isCheapest)
                          _buildBadge(
                            context,
                            icon: Icons.star_half,
                            label: localizations.badgeBestInCategory,
                            color: ColorConstants.badgeBest,
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
                          localizations.etaDays(quote.etaMin, quote.etaMax),
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
                currencyService.formatAmount(
                  amountInEur: quote.priceEur,
                  currency: currency,
                ),
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
              localizations.quoteDetailsPriceBreakdown,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildBreakdownRow(
              context,
              localizations.quoteDetailsChargeableWeight,
              '${quote.chargeableKg.toStringAsFixed(1)} kg',
            ),
            const SizedBox(height: 4),
            _buildBreakdownRow(
              context,
              localizations.quoteDetailsTotalPrice,
              currencyService.formatAmount(
                amountInEur: quote.priceEur,
                currency: currency,
              ),
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
                  label: Text(localizations.buttonBookThis),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isExpanded
                          ? localizations.buttonLess
                          : localizations.buttonDetails,
                    ),
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
        color: color.withValues(alpha: ColorConstants.alphaLightest),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withValues(alpha: ColorConstants.alphaMedium),
        ),
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
    transportMethod ??= TransportMethod.standardAir;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getTransportMethodColor(transportMethod),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(methodInfo.icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            _getLocalizedTransportMethodName(transportMethod),
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
        return ColorConstants.transportExpressAir;
      case TransportMethod.standardAir:
        return ColorConstants.transportStandardAir;
      case TransportMethod.airFreight:
        return ColorConstants.transportAirFreight;
      case TransportMethod.seaFreightLCL:
      case TransportMethod.seaFreightFCL:
        return ColorConstants.transportSeaFreight;
      case TransportMethod.roadFreight:
        return ColorConstants.transportRoadFreight;
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
    final localizations = AppLocalizations.of(context)!;
    final confirm = await ModalUtils.showSinglePageModal<bool>(
      context: context,
      title: localizations.bookShipmentTitle,
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
                child: Text(localizations.buttonBook),
              ),
            ),
          ],
        ),
      ),
      builder: (modalContext) {
        return Text(
          localizations.bookShipmentMessage(
            widget.quote.carrier,
            widget.quote.service,
          ),
          style: Theme.of(modalContext).textTheme.bodyLarge,
        );
      },
    );

    if (confirm == true && context.mounted) {
      final localizations2 = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations2.bookingFeatureComingSoon),
          duration: Duration(seconds: UIConstants.snackBarDurationShort),
        ),
      );
    }
  }
}

// ============================================================================
// EditableCarton Model
// ============================================================================

class EditableCarton {
  final String id;
  final String shipmentId;
  double lengthCm;
  double widthCm;
  double heightCm;
  double weightKg;
  int qty;
  String itemType;

  EditableCarton({
    required this.id,
    required this.shipmentId,
    required this.lengthCm,
    required this.widthCm,
    required this.heightCm,
    required this.weightKg,
    required this.qty,
    required this.itemType,
  });

  factory EditableCarton.fromCarton(models.Carton carton) {
    return EditableCarton(
      id: carton.id,
      shipmentId: carton.shipmentId,
      lengthCm: carton.lengthCm,
      widthCm: carton.widthCm,
      heightCm: carton.heightCm,
      weightKg: carton.weightKg,
      qty: carton.qty,
      itemType: carton.itemType,
    );
  }

  models.Carton toCarton() {
    return models.Carton(
      id: id,
      shipmentId: shipmentId,
      lengthCm: lengthCm,
      widthCm: widthCm,
      heightCm: heightCm,
      weightKg: weightKg,
      qty: qty,
      itemType: itemType,
    );
  }

  EditableCarton copyWith({
    double? lengthCm,
    double? widthCm,
    double? heightCm,
    double? weightKg,
    int? qty,
    String? itemType,
  }) {
    return EditableCarton(
      id: id,
      shipmentId: shipmentId,
      lengthCm: lengthCm ?? this.lengthCm,
      widthCm: widthCm ?? this.widthCm,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      qty: qty ?? this.qty,
      itemType: itemType ?? this.itemType,
    );
  }
}

// ============================================================================
// _EditableCartonsList Widget
// ============================================================================

class _EditableCartonsList extends ConsumerStatefulWidget {
  final String shipmentId;
  final Shipment shipment;
  final List<models.Carton> originalCartons;
  final List<Quote> originalQuotes;
  final VoidCallback onQuotesUpdated;

  const _EditableCartonsList({
    required this.shipmentId,
    required this.shipment,
    required this.originalCartons,
    required this.originalQuotes,
    required this.onQuotesUpdated,
  });

  @override
  ConsumerState<_EditableCartonsList> createState() =>
      _EditableCartonsListState();
}

class _EditableCartonsListState extends ConsumerState<_EditableCartonsList> {
  List<EditableCarton> _editedCartons = [];
  bool _isRecalculating = false;

  @override
  void initState() {
    super.initState();
    _loadOriginalCartons();
  }

  void _loadOriginalCartons() {
    setState(() {
      _editedCartons = widget.originalCartons
          .map((c) => EditableCarton.fromCarton(c))
          .toList();
    });
  }

  void _resetToOriginal() {
    setState(() {
      _editedCartons = widget.originalCartons
          .map((c) => EditableCarton.fromCarton(c))
          .toList();
    });
  }

  Future<void> _recalculateQuotes() async {
    setState(() => _isRecalculating = true);

    try {
      // Convert edited cartons to Carton models
      final cartonModels = _editedCartons.map((e) => e.toCarton()).toList();

      // Calculate new totals
      final totals = CalculationService.calculateTotals(cartonModels);

      // Create Carton objects with the edited dimensions for API call
      final editedDbCartons = _editedCartons
          .map(
            (e) => Carton(
              id: e.id,
              shipmentId: e.shipmentId,
              lengthCm: e.lengthCm,
              widthCm: e.widthCm,
              heightCm: e.heightCm,
              weightKg: e.weightKg,
              qty: e.qty,
              itemType: e.itemType,
            ),
          )
          .toList();

      // Debug logging (commented out for production)
      // print('DEBUG: Recalculating quotes with ${editedDbCartons.length} cartons');
      // for (var i = 0; i < editedDbCartons.length; i++) {
      //   final c = editedDbCartons[i];
      //   final dimWeight = (c.lengthCm * c.widthCm * c.heightCm) / 5000;
      //   print('DEBUG: Carton $i: ${c.lengthCm}x${c.widthCm}x${c.heightCm}cm, actual=${c.weightKg}kg, dim=${dimWeight.toStringAsFixed(2)}kg, qty=${c.qty}');
      // }
      // print('DEBUG: Totals - Actual: ${totals.actualKg.toStringAsFixed(2)}kg, Dim: ${totals.dimKg.toStringAsFixed(2)}kg, Chargeable: ${totals.chargeableKg.toStringAsFixed(2)}kg');
      // print('DEBUG: Origin: ${widget.shipment.originCity}, ${widget.shipment.originPostal}, ${widget.shipment.originCountry}');
      // print('DEBUG: Dest: ${widget.shipment.destCity}, ${widget.shipment.destPostal}, ${widget.shipment.destCountry}');

      // Call Shippo API with new dimensions
      final quoteService = getIt<QuoteCalculatorService>();
      final shippingQuotes = await quoteService.calculateAllQuotes(
        chargeableKg: totals.chargeableKg,
        isOversized: totals.isOversized,
        originCity: widget.shipment.originCity,
        originPostal: widget.shipment.originPostal,
        originCountry: widget.shipment.originCountry,
        originState: widget.shipment.originState,
        destCity: widget.shipment.destCity,
        destPostal: widget.shipment.destPostal,
        destCountry: widget.shipment.destCountry,
        destState: widget.shipment.destState,
        cartons: editedDbCartons,
        useShippoApi: true,
        fallbackToLocalRates:
            false, // Don't use China-Europe rates for other routes
      );

      // print('DEBUG: Received ${shippingQuotes.length} quotes from API');

      // No notification needed - the comparison dialog will show the empty state

      if (mounted) {
        await _showQuoteComparisonDialog(shippingQuotes, cartonModels);
      }
    } catch (e) {
      // print('DEBUG ERROR: $e');
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.errorRecalculating}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRecalculating = false);
      }
    }
  }

  Future<void> _showQuoteComparisonDialog(
    List<ShippingQuote> newShippingQuotes,
    List<models.Carton> newCartonModels,
  ) async {
    final localizations = AppLocalizations.of(context)!;
    final selectedCurrency = ref.read(currencyNotifierProvider);
    final currencyService = ref.read(currencyServiceProvider);
    final oldCheapest = widget.originalQuotes.isEmpty
        ? null
        : widget.originalQuotes.reduce(
            (a, b) => a.priceEur < b.priceEur ? a : b,
          );
    final newCheapest = newShippingQuotes.isEmpty
        ? null
        : newShippingQuotes.reduce((a, b) => a.total < b.total ? a : b);
    final savings = oldCheapest != null && newCheapest != null
        ? oldCheapest.priceEur - newCheapest.total
        : 0.0;

    final result = await ModalUtils.showSinglePageModal<bool>(
      context: context,
      title: localizations.titleQuoteComparison,
      showCloseButton: true,
      barrierDismissible: true,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      stickyActionBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(localizations.buttonDiscard),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(localizations.buttonSaveChanges),
              ),
            ),
          ],
        ),
      ),
      builder: (modalContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Comparison summary
            if (oldCheapest != null && newCheapest != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: savings > 0
                      ? Colors.green.withValues(
                          alpha: ColorConstants.alphaLightest,
                        )
                      : savings < 0
                      ? Colors.red.withValues(
                          alpha: ColorConstants.alphaLightest,
                        )
                      : Colors.grey.withValues(
                          alpha: ColorConstants.alphaLightest,
                        ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: savings > 0
                        ? Colors.green.withValues(
                            alpha: ColorConstants.alphaMedium,
                          )
                        : savings < 0
                        ? Colors.red.withValues(
                            alpha: ColorConstants.alphaMedium,
                          )
                        : Colors.grey.withValues(
                            alpha: ColorConstants.alphaMedium,
                          ),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      savings > 0
                          ? localizations.quoteComparisonPotentialSavings
                          : savings < 0
                          ? localizations.quoteComparisonCostIncrease
                          : localizations.quoteComparisonNoChange,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${savings > 0
                          ? '-'
                          : savings < 0
                          ? '+'
                          : ''}${currencyService.formatAmount(amountInEur: savings.abs(), currency: selectedCurrency)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: savings > 0
                            ? Colors.green
                            : savings < 0
                            ? Colors.red
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizations.cheapestPriceChange(
                        currencyService.formatAmount(
                          amountInEur: oldCheapest.priceEur,
                          currency: selectedCurrency,
                        ),
                        currencyService.formatAmount(
                          amountInEur: newCheapest.total,
                          currency: selectedCurrency,
                        ),
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              newShippingQuotes.isEmpty
                  ? localizations.quoteComparisonNoQuotesAvailable
                  : localizations.quoteComparisonAvailableQuotes(
                      newShippingQuotes.length,
                    ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (newShippingQuotes.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(
                    alpha: ColorConstants.alphaLightest,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(
                      alpha: ColorConstants.alphaMedium,
                    ),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.orange.shade700,
                      size: 56,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizations.emptyStateNoQuotes,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      localizations.shippoTestLimitationShort,
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(
                          alpha: ColorConstants.alphaLightest,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                localizations.shippoInfoToGetRealQuotes,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${localizations.shippoInfoStep1}\n'
                            '${localizations.shippoInfoStep2}\n'
                            '${localizations.shippoInfoStep3}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ...newShippingQuotes.map((quote) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.withValues(
                        alpha: ColorConstants.alphaMedium,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${quote.carrier} ${quote.service}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (quote.estimatedDays != null)
                              Text(
                                '${quote.estimatedDays} days',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    modalContext,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        currencyService.formatAmount(
                          amountInEur: quote.total,
                          currency: selectedCurrency,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(modalContext).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );

    if (result == true && mounted) {
      await _saveChanges(newShippingQuotes, newCartonModels);
    }
  }

  Future<void> _saveChanges(
    List<ShippingQuote> newShippingQuotes,
    List<models.Carton> newCartonModels,
  ) async {
    final db = getIt<AppDatabase>();
    final uuid = const Uuid();

    try {
      // 1. Update cartons in database
      for (final editedCarton in _editedCartons) {
        await (db.update(
          db.cartons,
        )..where((c) => c.id.equals(editedCarton.id))).write(
          CartonsCompanion(
            lengthCm: drift.Value(editedCarton.lengthCm),
            widthCm: drift.Value(editedCarton.widthCm),
            heightCm: drift.Value(editedCarton.heightCm),
            weightKg: drift.Value(editedCarton.weightKg),
            qty: drift.Value(editedCarton.qty),
            itemType: drift.Value(editedCarton.itemType),
          ),
        );
      }

      // 2. Delete old quotes
      await (db.delete(
        db.quotes,
      )..where((q) => q.shipmentId.equals(widget.shipmentId))).go();

      // 3. Save new quotes
      // print('DEBUG: Saving ${newShippingQuotes.length} new quotes');
      for (final shippingQuote in newShippingQuotes) {
        // print('DEBUG: Saving quote: ${shippingQuote.carrier} ${shippingQuote.service} - €${shippingQuote.total.toStringAsFixed(2)}, chargeableKg=${shippingQuote.chargeableKg.toStringAsFixed(2)}');
        await db
            .into(db.quotes)
            .insert(
              QuotesCompanion.insert(
                id: uuid.v4(),
                shipmentId: widget.shipmentId,
                carrier: shippingQuote.carrier,
                service: shippingQuote.service,
                etaMin: shippingQuote.estimatedDays ?? 0,
                etaMax: shippingQuote.estimatedDays ?? 0,
                priceEur: shippingQuote.total,
                chargeableKg: shippingQuote.chargeableKg,
                transportMethod: drift.Value(
                  _determineTransportMethod(shippingQuote).name,
                ),
              ),
            );
      }

      // 4. Notify parent to refresh
      widget.onQuotesUpdated();

      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.successChangesSaved),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.errorSavingChanges}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  TransportMethod _determineTransportMethod(ShippingQuote quote) {
    final serviceLower = quote.service.toLowerCase();
    final carrierLower = quote.carrier.toLowerCase();

    if (serviceLower.contains('express') || carrierLower.contains('express')) {
      return TransportMethod.expressAir;
    } else if (serviceLower.contains('air')) {
      return TransportMethod.airFreight;
    } else if (serviceLower.contains('sea') || serviceLower.contains('ocean')) {
      return TransportMethod.seaFreightLCL;
    } else if (serviceLower.contains('road') ||
        serviceLower.contains('truck')) {
      return TransportMethod.roadFreight;
    }
    return TransportMethod.standardAir;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Live totals preview
        _buildLiveTotalsPreview(),

        const SizedBox(height: 16),

        // Editable carton fields
        ..._editedCartons.asMap().entries.map((entry) {
          final index = entry.key;
          final carton = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildEditableCartonCard(index, carton),
          );
        }),

        const SizedBox(height: 16),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: Text(localizations.buttonResetToOriginal),
                onPressed: _resetToOriginal,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                icon: _isRecalculating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.calculate_rounded),
                label: Text(localizations.buttonRecalculateQuotes),
                onPressed: _isRecalculating ? null : _recalculateQuotes,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLiveTotalsPreview() {
    final localizations = AppLocalizations.of(context)!;
    final cartonModels = _editedCartons.map((e) => e.toCarton()).toList();
    final totals = CalculationService.calculateTotals(cartonModels);

    return ModalCard(
      child: Column(
        children: [
          Text(
            localizations.liveTotalsUpdated,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatChip(
                localizations.labelCartons,
                '${totals.cartonCount}',
              ),
              _buildStatChip(
                localizations.liveTotalsActual,
                '${totals.actualKg.toStringAsFixed(1)} kg',
              ),
              _buildStatChip(
                localizations.liveTotalsDim,
                '${totals.dimKg.toStringAsFixed(1)} kg',
              ),
              _buildStatChip(
                localizations.liveTotalsChargeable,
                '${totals.chargeableKg.toStringAsFixed(1)} kg',
                isPrimary: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizations.liveTotalsInfoNote,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (totals.isOversized) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(
                  alpha: ColorConstants.alphaLightest,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withValues(
                    alpha: ColorConstants.alphaMedium,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    localizations.liveTotalsOversizeWarning,
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, {bool isPrimary = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isPrimary ? context.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableCartonCard(int index, EditableCarton carton) {
    final localizations = AppLocalizations.of(context)!;
    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.labelCartonNumber(index + 1),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),

          // Dimensions row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: ValueKey('length_$index'),
                  initialValue: carton.lengthCm.toStringAsFixed(1),
                  decoration: InputDecoration(
                    labelText: localizations.labelLength,
                    border: const OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final newValue = double.tryParse(value);
                    if (newValue != null &&
                        newValue >= ValidationConstants.minDimensionCm) {
                      setState(() {
                        _editedCartons[index].lengthCm = newValue;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextFormField(
                  key: ValueKey('width_$index'),
                  initialValue: carton.widthCm.toStringAsFixed(1),
                  decoration: InputDecoration(
                    labelText: localizations.labelWidth,
                    border: const OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final newValue = double.tryParse(value);
                    if (newValue != null &&
                        newValue >= ValidationConstants.minDimensionCm) {
                      setState(() {
                        _editedCartons[index].widthCm = newValue;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextFormField(
                  key: ValueKey('height_$index'),
                  initialValue: carton.heightCm.toStringAsFixed(1),
                  decoration: InputDecoration(
                    labelText: localizations.labelHeight,
                    border: const OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final newValue = double.tryParse(value);
                    if (newValue != null &&
                        newValue >= ValidationConstants.minDimensionCm) {
                      setState(() {
                        _editedCartons[index].heightCm = newValue;
                      });
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Weight and Quantity row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  key: ValueKey('weight_$index'),
                  initialValue: carton.weightKg.toStringAsFixed(1),
                  decoration: InputDecoration(
                    labelText: localizations.labelWeightKg,
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final newValue = double.tryParse(value);
                    if (newValue != null &&
                        newValue >= ValidationConstants.minWeightKg) {
                      setState(() {
                        _editedCartons[index].weightKg = newValue;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextFormField(
                  key: ValueKey('qty_$index'),
                  initialValue: carton.qty.toString(),
                  decoration: InputDecoration(
                    labelText: localizations.labelQuantity,
                    border: const OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final newValue = int.tryParse(value);
                    if (newValue != null &&
                        newValue >= ValidationConstants.minQuantity) {
                      setState(() {
                        _editedCartons[index].qty = newValue;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
