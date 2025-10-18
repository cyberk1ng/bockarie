import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import 'package:bockaire/database/database.dart';
import 'package:bockaire/get_it.dart';
import 'package:bockaire/themes/theme.dart';
import 'package:bockaire/widgets/modal/modal_card.dart';
import 'package:bockaire/widgets/shipment/city_autocomplete_field.dart';
import 'package:bockaire/widgets/shipment/live_totals_card.dart';
import 'package:bockaire/services/calculation_service.dart';
import 'package:bockaire/services/quote_calculator_service.dart';
import 'package:bockaire/classes/carton.dart' as models;
import 'package:bockaire/models/transport_method.dart';
import 'package:bockaire/utils/duration_parser.dart';
import 'package:bockaire/config/route_constants.dart';
import 'package:bockaire/config/ui_constants.dart';
import 'package:bockaire/config/ui_strings.dart';
import 'package:bockaire/config/validation_constants.dart';
import 'package:bockaire/l10n/app_localizations.dart';
import 'package:drift/drift.dart' as drift;

class NewShipmentPage extends StatefulWidget {
  const NewShipmentPage({super.key});

  @override
  State<NewShipmentPage> createState() => _NewShipmentPageState();
}

class _NewShipmentPageState extends State<NewShipmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _originCityController = TextEditingController();
  final _originPostalController = TextEditingController();
  final _originCountryController = TextEditingController();
  final _originStateController = TextEditingController();
  final _destCityController = TextEditingController();
  final _destPostalController = TextEditingController();
  final _destCountryController = TextEditingController();
  final _destStateController = TextEditingController();
  final _notesController = TextEditingController();

  final List<CartonInput> _cartons = [];

  @override
  void dispose() {
    _originCityController.dispose();
    _originPostalController.dispose();
    _originCountryController.dispose();
    _originStateController.dispose();
    _destCityController.dispose();
    _destPostalController.dispose();
    _destCountryController.dispose();
    _destStateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addCarton() {
    setState(() {
      _cartons.add(CartonInput());
    });
  }

  void _removeCarton(int index) {
    setState(() {
      _cartons.removeAt(index);
    });
  }

  Future<void> _saveShipment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_cartons.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(UIStrings.errorAddCartons)));
      return;
    }

    final db = getIt<AppDatabase>();
    final shipmentId = const Uuid().v4();

    try {
      // Save shipment
      await db
          .into(db.shipments)
          .insert(
            ShipmentsCompanion(
              id: drift.Value(shipmentId),
              createdAt: drift.Value(DateTime.now()),
              originCity: drift.Value(_originCityController.text),
              originPostal: drift.Value(_originPostalController.text),
              originCountry: drift.Value(_originCountryController.text),
              originState: drift.Value(_originStateController.text),
              destCity: drift.Value(_destCityController.text),
              destPostal: drift.Value(_destPostalController.text),
              destCountry: drift.Value(_destCountryController.text),
              destState: drift.Value(_destStateController.text),
              notes: drift.Value(
                _notesController.text.isEmpty ? null : _notesController.text,
              ),
            ),
          );

      // Save cartons
      for (final carton in _cartons) {
        await db
            .into(db.cartons)
            .insert(
              CartonsCompanion(
                id: drift.Value(const Uuid().v4()),
                shipmentId: drift.Value(shipmentId),
                lengthCm: drift.Value(carton.lengthCm),
                widthCm: drift.Value(carton.widthCm),
                heightCm: drift.Value(carton.heightCm),
                weightKg: drift.Value(carton.weightKg),
                qty: drift.Value(carton.qty),
                itemType: drift.Value(carton.itemType),
              ),
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(UIStrings.successShipmentSaved)),
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${UIStrings.errorSavingShipment}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.titleNewShipment),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveShipment),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              localizations.titleShipmentDetails,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CityAutocompleteField(
                    cityController: _originCityController,
                    postalController: _originPostalController,
                    countryController: _originCountryController,
                    stateController: _originStateController,
                    label: localizations.labelOriginCity,
                    validator: (value) => value?.isEmpty ?? true
                        ? localizations.validationRequired
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _originPostalController,
                    decoration: InputDecoration(
                      labelText: localizations.labelOriginPostal,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true
                        ? localizations.validationRequired
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CityAutocompleteField(
                    cityController: _destCityController,
                    postalController: _destPostalController,
                    countryController: _destCountryController,
                    stateController: _destStateController,
                    label: localizations.labelDestinationCity,
                    validator: (value) => value?.isEmpty ?? true
                        ? localizations.validationRequired
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _destPostalController,
                    decoration: InputDecoration(
                      labelText: localizations.labelDestinationPostal,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true
                        ? localizations.validationRequired
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: localizations.labelNotes,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizations.labelCartons,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addCarton,
                  icon: const Icon(Icons.add),
                  label: Text(localizations.buttonAddCarton),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._cartons.asMap().entries.map((entry) {
              final index = entry.key;
              final carton = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            localizations.labelCartonNumber(index + 1),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeCarton(index),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: localizations.labelLength,
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return localizations.validationRequired;
                                }
                                if (double.tryParse(value!) == null) {
                                  return localizations.validationInvalid;
                                }
                                return null;
                              },
                              onChanged: (value) {
                                carton.lengthCm = double.tryParse(value) ?? 0.0;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: localizations.labelWidth,
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return localizations.validationRequired;
                                }
                                if (double.tryParse(value!) == null) {
                                  return localizations.validationInvalid;
                                }
                                return null;
                              },
                              onChanged: (value) {
                                carton.widthCm = double.tryParse(value) ?? 0.0;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: localizations.labelHeight,
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return localizations.validationRequired;
                                }
                                if (double.tryParse(value!) == null) {
                                  return localizations.validationInvalid;
                                }
                                return null;
                              },
                              onChanged: (value) {
                                carton.heightCm = double.tryParse(value) ?? 0.0;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: localizations.labelWeightKg,
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return localizations.validationRequired;
                                }
                                if (double.tryParse(value!) == null) {
                                  return localizations.validationInvalid;
                                }
                                return null;
                              },
                              onChanged: (value) {
                                carton.weightKg = double.tryParse(value) ?? 0.0;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: localizations.labelQuantity,
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return localizations.validationRequired;
                                }
                                if (int.tryParse(value!) == null) {
                                  return localizations.validationInvalid;
                                }
                                return null;
                              },
                              onChanged: (value) {
                                carton.qty = int.tryParse(value) ?? 1;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: localizations.labelItemType,
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) => value?.isEmpty ?? true
                                  ? localizations.validationRequired
                                  : null,
                              onChanged: (value) {
                                carton.itemType = value;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class CartonInput {
  double lengthCm = 0;
  double widthCm = 0;
  double heightCm = 0;
  double weightKg = 0;
  int qty = 1;
  String itemType = '';
}

// Modal content widget that can be reused
class NewShipmentContent extends StatefulWidget {
  const NewShipmentContent({super.key});

  @override
  State<NewShipmentContent> createState() => _NewShipmentContentState();
}

class _NewShipmentContentState extends State<NewShipmentContent> {
  final Logger _logger = Logger();
  final _formKey = GlobalKey<FormState>();
  final _originCityController = TextEditingController();
  final _originPostalController = TextEditingController();
  final _originCountryController = TextEditingController();
  final _originStateController = TextEditingController();
  final _destCityController = TextEditingController();
  final _destPostalController = TextEditingController();
  final _destCountryController = TextEditingController();
  final _destStateController = TextEditingController();
  final _notesController = TextEditingController();

  final List<CartonInput> _cartons = [];

  ShipmentTotals _totals = const ShipmentTotals(
    cartonCount: 0,
    actualKg: 0,
    dimKg: 0,
    chargeableKg: 0,
    largestSideCm: 0,
    isOversized: false,
    totalVolumeCm3: 0,
  );

  Timer? _debounceTimer;

  @override
  void dispose() {
    _originCityController.dispose();
    _originPostalController.dispose();
    _originCountryController.dispose();
    _originStateController.dispose();
    _destCityController.dispose();
    _destPostalController.dispose();
    _destCountryController.dispose();
    _destStateController.dispose();
    _notesController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _addCarton() {
    setState(() {
      _cartons.add(CartonInput());
      _updateTotals();
    });
  }

  void _removeCarton(int index) {
    setState(() {
      _cartons.removeAt(index);
      _updateTotals();
    });
  }

  void _onCartonChanged() {
    // Debounce to avoid too many calculations
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: UIConstants.cartonInputDebounceMs),
      () {
        _updateTotals();
      },
    );
  }

  void _updateTotals() {
    setState(() {
      final cartonModels = _cartons
          .where(
            (c) =>
                c.lengthCm >= ValidationConstants.minDimensionCm &&
                c.widthCm >= ValidationConstants.minDimensionCm &&
                c.heightCm >= ValidationConstants.minDimensionCm &&
                c.weightKg >= ValidationConstants.minWeightKg,
          )
          .map(
            (c) => models.Carton(
              id: '',
              shipmentId: '',
              lengthCm: c.lengthCm,
              widthCm: c.widthCm,
              heightCm: c.heightCm,
              weightKg: c.weightKg,
              qty: c.qty,
              itemType: c.itemType,
            ),
          )
          .toList();

      _totals = CalculationService.calculateTotals(cartonModels);
    });
  }

  Future<void> _saveShipment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_cartons.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(UIStrings.errorAddCartons)));
      return;
    }

    final db = getIt<AppDatabase>();
    final shipmentId = const Uuid().v4();

    try {
      // Show loading indicator
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.statusSavingShipment),
            duration: const Duration(
              seconds: UIConstants.snackBarDurationShort,
            ),
          ),
        );
      }

      // Save shipment
      await db
          .into(db.shipments)
          .insert(
            ShipmentsCompanion(
              id: drift.Value(shipmentId),
              createdAt: drift.Value(DateTime.now()),
              originCity: drift.Value(_originCityController.text),
              originPostal: drift.Value(_originPostalController.text),
              originCountry: drift.Value(_originCountryController.text),
              originState: drift.Value(_originStateController.text),
              destCity: drift.Value(_destCityController.text),
              destPostal: drift.Value(_destPostalController.text),
              destCountry: drift.Value(_destCountryController.text),
              destState: drift.Value(_destStateController.text),
              notes: drift.Value(
                _notesController.text.isEmpty ? null : _notesController.text,
              ),
            ),
          );

      // Save cartons
      for (final carton in _cartons) {
        await db
            .into(db.cartons)
            .insert(
              CartonsCompanion(
                id: drift.Value(const Uuid().v4()),
                shipmentId: drift.Value(shipmentId),
                lengthCm: drift.Value(carton.lengthCm),
                widthCm: drift.Value(carton.widthCm),
                heightCm: drift.Value(carton.heightCm),
                weightKg: drift.Value(carton.weightKg),
                qty: drift.Value(carton.qty),
                itemType: drift.Value(carton.itemType),
              ),
            );
      }

      // Generate quotes
      try {
        // Fetch saved cartons for Shippo API
        final savedCartons = await (db.select(
          db.cartons,
        )..where((c) => c.shipmentId.equals(shipmentId))).get();

        _logger.d('Generating quotes for shipment $shipmentId');
        _logger.d(
          'Origin: ${_originCityController.text}, ${_originPostalController.text}',
        );
        _logger.d(
          'Dest: ${_destCityController.text}, ${_destPostalController.text}',
        );
        _logger.d('Cartons: ${savedCartons.length}');

        final quoteService = getIt<QuoteCalculatorService>();
        final quotes = await quoteService.calculateAllQuotes(
          chargeableKg: _totals.chargeableKg,
          isOversized: _totals.isOversized,
          originCity: _originCityController.text,
          originPostal: _originPostalController.text,
          originCountry: _originCountryController.text,
          originState: _originStateController.text,
          destCity: _destCityController.text,
          destPostal: _destPostalController.text,
          destCountry: _destCountryController.text,
          destState: _destStateController.text,
          cartons: savedCartons,
        );

        _logger.d('Received ${quotes.length} quotes');

        // Save quotes to database
        for (final quote in quotes) {
          _logger.d(
            'Saving quote: ${quote.carrier} ${quote.service} - €${quote.total}',
          );

          // Parse duration from quote
          final (etaMin, etaMax) = parseDuration(
            quote.estimatedDays,
            quote.durationTerms,
          );

          // Classify transport method
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
                  shipmentId: drift.Value(shipmentId),
                  carrier: drift.Value(quote.carrier),
                  service: drift.Value(quote.service),
                  etaMin: drift.Value(etaMin),
                  etaMax: drift.Value(etaMax),
                  priceEur: drift.Value(quote.total),
                  chargeableKg: drift.Value(quote.chargeableKg),
                  transportMethod: drift.Value(transportMethod.name),
                ),
              );
        }
        _logger.d('Successfully saved ${quotes.length} quotes to database');

        // Small delay to ensure database writes are committed
        await Future.delayed(
          const Duration(milliseconds: UIConstants.databaseCommitDelayMs),
        );
      } catch (e, stackTrace) {
        // Continue even if quote generation fails
        _logger.e(
          'Failed to generate quotes',
          error: e,
          stackTrace: stackTrace,
        );
        if (mounted) {
          final localizations = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizations.warningCouldNotGenerateQuotes(e.toString()),
              ),
              duration: const Duration(
                seconds: UIConstants.snackBarDurationLong,
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      if (mounted) {
        // Close the modal
        Navigator.of(context).pop();
        // Navigate to quotes page
        context.push(RouteConstants.quotesWithId(shipmentId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${UIStrings.errorSavingShipment}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              localizations.titleShipmentDetails,
              style: context.textTheme.titleLarge,
            ),
            SizedBox(height: AppTheme.spacingMedium),
            ModalCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CityAutocompleteField(
                          cityController: _originCityController,
                          postalController: _originPostalController,
                          countryController: _originCountryController,
                          stateController: _originStateController,
                          label: localizations.labelOriginCity,
                          validator: (value) => value?.isEmpty ?? true
                              ? localizations.validationRequired
                              : null,
                        ),
                      ),
                      SizedBox(width: AppTheme.spacingMedium),
                      Expanded(
                        child: TextFormField(
                          controller: _originPostalController,
                          decoration: InputDecoration(
                            labelText: localizations.labelOriginPostal,
                          ),
                          validator: (value) => value?.isEmpty ?? true
                              ? localizations.validationRequired
                              : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacingMedium),
                  Row(
                    children: [
                      Expanded(
                        child: CityAutocompleteField(
                          cityController: _destCityController,
                          postalController: _destPostalController,
                          countryController: _destCountryController,
                          stateController: _destStateController,
                          label: localizations.labelDestinationCity,
                          validator: (value) => value?.isEmpty ?? true
                              ? localizations.validationRequired
                              : null,
                        ),
                      ),
                      SizedBox(width: AppTheme.spacingMedium),
                      Expanded(
                        child: TextFormField(
                          controller: _destPostalController,
                          decoration: InputDecoration(
                            labelText: localizations.labelDestinationPostal,
                          ),
                          validator: (value) => value?.isEmpty ?? true
                              ? localizations.validationRequired
                              : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacingMedium),
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: localizations.labelNotes,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTheme.spacingLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizations.labelCartons,
                  style: context.textTheme.titleLarge,
                ),
                ElevatedButton.icon(
                  onPressed: _addCarton,
                  icon: const Icon(Icons.add),
                  label: Text(localizations.buttonAddCarton),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacingMedium),
            // Live totals card
            if (_cartons.isNotEmpty) ...[
              LiveTotalsCard(totals: _totals),
              SizedBox(height: AppTheme.spacingLarge),
            ],
            ..._cartons.asMap().entries.map((entry) {
              final index = entry.key;
              final carton = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: AppTheme.cardSpacing),
                child: ModalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            localizations.labelCartonNumber(index + 1),
                            style: context.textTheme.titleMedium,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _removeCarton(index),
                            color: context.colorScheme.error,
                          ),
                        ],
                      ),
                      SizedBox(height: AppTheme.spacingMedium),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: localizations.labelLength,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return localizations.validationRequired;
                                }
                                if (double.tryParse(value!) == null) {
                                  return localizations.validationInvalid;
                                }
                                return null;
                              },
                              onChanged: (value) {
                                carton.lengthCm = double.tryParse(value) ?? 0.0;
                                _onCartonChanged();
                              },
                            ),
                          ),
                          SizedBox(width: AppTheme.spacingSmall),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: localizations.labelWidth,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return localizations.validationRequired;
                                }
                                if (double.tryParse(value!) == null) {
                                  return localizations.validationInvalid;
                                }
                                return null;
                              },
                              onChanged: (value) {
                                carton.widthCm = double.tryParse(value) ?? 0.0;
                                _onCartonChanged();
                              },
                            ),
                          ),
                          SizedBox(width: AppTheme.spacingSmall),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: localizations.labelHeight,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return localizations.validationRequired;
                                }
                                if (double.tryParse(value!) == null) {
                                  return localizations.validationInvalid;
                                }
                                return null;
                              },
                              onChanged: (value) {
                                carton.heightCm = double.tryParse(value) ?? 0.0;
                                _onCartonChanged();
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppTheme.spacingMedium),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: localizations.labelWeightKg,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return localizations.validationRequired;
                                }
                                if (double.tryParse(value!) == null) {
                                  return localizations.validationInvalid;
                                }
                                return null;
                              },
                              onChanged: (value) {
                                carton.weightKg = double.tryParse(value) ?? 0.0;
                                _onCartonChanged();
                              },
                            ),
                          ),
                          SizedBox(width: AppTheme.spacingSmall),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: localizations.labelQuantity,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return localizations.validationRequired;
                                }
                                if (int.tryParse(value!) == null) {
                                  return localizations.validationInvalid;
                                }
                                return null;
                              },
                              onChanged: (value) {
                                carton.qty = int.tryParse(value) ?? 1;
                                _onCartonChanged();
                              },
                            ),
                          ),
                          SizedBox(width: AppTheme.spacingSmall),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: localizations.labelItemType,
                              ),
                              validator: (value) => value?.isEmpty ?? true
                                  ? localizations.validationRequired
                                  : null,
                              onChanged: (value) {
                                carton.itemType = value;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(height: AppTheme.spacingLarge),
            SizedBox(
              height: AppTheme.buttonHeight,
              child: ElevatedButton(
                onPressed: _saveShipment,
                child: Text(localizations.buttonSaveShipment),
              ),
            ),
            SizedBox(height: AppTheme.spacingMedium),
          ],
        ),
      ),
    );
  }
}
