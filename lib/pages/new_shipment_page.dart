import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:bockaire/database/database.dart';
import 'package:bockaire/get_it.dart';
import 'package:drift/drift.dart' as drift;

class NewShipmentPage extends StatefulWidget {
  const NewShipmentPage({super.key});

  @override
  State<NewShipmentPage> createState() => _NewShipmentPageState();
}

class _NewShipmentPageState extends State<NewShipmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _originCityController = TextEditingController(text: 'Guangzhou');
  final _originPostalController = TextEditingController(text: '510000');
  final _destCityController = TextEditingController(text: 'Hamburg');
  final _destPostalController = TextEditingController(text: '20095');
  final _notesController = TextEditingController();

  final List<CartonInput> _cartons = [];

  @override
  void dispose() {
    _originCityController.dispose();
    _originPostalController.dispose();
    _destCityController.dispose();
    _destPostalController.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one carton')),
      );
      return;
    }

    final db = getIt<AppDatabase>();
    final shipmentId = const Uuid().v4();

    try {
      // Save shipment
      await db.into(db.shipments).insert(
            ShipmentsCompanion(
              id: drift.Value(shipmentId),
              createdAt: drift.Value(DateTime.now()),
              originCity: drift.Value(_originCityController.text),
              originPostal: drift.Value(_originPostalController.text),
              destCity: drift.Value(_destCityController.text),
              destPostal: drift.Value(_destPostalController.text),
              notes: drift.Value(_notesController.text.isEmpty
                  ? null
                  : _notesController.text),
            ),
          );

      // Save cartons
      for (final carton in _cartons) {
        await db.into(db.cartons).insert(
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
          const SnackBar(content: Text('Shipment saved successfully')),
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving shipment: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Shipment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveShipment,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text(
              'Shipment Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _originCityController,
                    decoration: const InputDecoration(
                      labelText: 'Origin City',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _originPostalController,
                    decoration: const InputDecoration(
                      labelText: 'Origin Postal',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _destCityController,
                    decoration: const InputDecoration(
                      labelText: 'Destination City',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _destPostalController,
                    decoration: const InputDecoration(
                      labelText: 'Destination Postal',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cartons',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _addCarton,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Carton'),
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
                            'Carton ${index + 1}',
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
                              decoration: const InputDecoration(
                                labelText: 'Length (cm)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Required';
                                if (double.tryParse(value!) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                carton.lengthCm =
                                    double.tryParse(value) ?? 0.0;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Width (cm)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Required';
                                if (double.tryParse(value!) == null) {
                                  return 'Invalid';
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
                              decoration: const InputDecoration(
                                labelText: 'Height (cm)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Required';
                                if (double.tryParse(value!) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                carton.heightCm =
                                    double.tryParse(value) ?? 0.0;
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
                              decoration: const InputDecoration(
                                labelText: 'Weight (kg)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Required';
                                if (double.tryParse(value!) == null) {
                                  return 'Invalid';
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
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Required';
                                if (int.tryParse(value!) == null) {
                                  return 'Invalid';
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
                              decoration: const InputDecoration(
                                labelText: 'Item Type',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
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
