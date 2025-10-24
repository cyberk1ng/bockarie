import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:bockaire/models/customs_models.dart';
import 'package:bockaire/providers/booking_providers.dart';
import 'package:bockaire/themes/theme.dart';
import 'package:bockaire/widgets/modal/modal_card.dart';

/// Customs Form Page for international shipments
///
/// Collects:
/// - Importer type (Business/Individual)
/// - VAT/EORI/Tax ID numbers
/// - Incoterms
/// - Commodity line items (goods description, value, weight, HS codes)
/// - Optional: Save profile for reuse
class CustomsFormPage extends ConsumerStatefulWidget {
  final String shipmentId;
  final VoidCallback onComplete;

  const CustomsFormPage({
    super.key,
    required this.shipmentId,
    required this.onComplete,
  });

  @override
  ConsumerState<CustomsFormPage> createState() => _CustomsFormPageState();
}

class _CustomsFormPageState extends ConsumerState<CustomsFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _vatController = TextEditingController();
  final _eoriController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  final _notesController = TextEditingController();

  // Form state
  ImporterType _importerType = ImporterType.business;
  Incoterms _selectedIncoterms = Incoterms.dap;
  final ContentsType _contentsType = ContentsType.merchandise;
  bool _saveProfile = false;
  bool _certify = false;
  String? _selectedProfileId;

  // Commodity lines
  final List<CommodityLine> _commodityLines = [];

  @override
  void initState() {
    super.initState();
    _addDefaultCommodityLine();
  }

  @override
  void dispose() {
    _vatController.dispose();
    _eoriController.dispose();
    _taxIdController.dispose();
    _companyNameController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _invoiceNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addDefaultCommodityLine() {
    setState(() {
      _commodityLines.add(
        const CommodityLine(
          description: '',
          quantity: 1.0,
          netWeight: 1.0,
          valueAmount: 1.0,
          originCountry: 'CN', // Default to China
          hsCode: '',
        ),
      );
    });
  }

  void _loadProfile(CustomsProfile profile) {
    setState(() {
      _selectedProfileId = profile.id;
      _importerType = profile.importerType;
      _vatController.text = profile.vatNumber ?? '';
      _eoriController.text = profile.eoriNumber ?? '';
      _taxIdController.text = profile.taxId ?? '';
      _companyNameController.text = profile.companyName ?? '';
      _contactNameController.text = profile.contactName ?? '';
      _contactPhoneController.text = profile.contactPhone ?? '';
      _contactEmailController.text = profile.contactEmail ?? '';
      _selectedIncoterms = profile.defaultIncoterms;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_commodityLines.isEmpty ||
        _commodityLines.any((l) => l.description.isEmpty || l.hsCode.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill in all commodity line items with description and HS code',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_certify) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must certify that the information is accurate'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final uuid = const Uuid();

    // Create customs profile if save is enabled
    CustomsProfile? profile;
    if (_saveProfile) {
      profile = CustomsProfile(
        id: uuid.v4(),
        name: _companyNameController.text.isNotEmpty
            ? _companyNameController.text
            : 'Profile ${DateTime.now().toIso8601String()}',
        importerType: _importerType,
        vatNumber: _vatController.text.isNotEmpty ? _vatController.text : null,
        eoriNumber: _eoriController.text.isNotEmpty
            ? _eoriController.text
            : null,
        taxId: _taxIdController.text.isNotEmpty ? _taxIdController.text : null,
        companyName: _companyNameController.text.isNotEmpty
            ? _companyNameController.text
            : null,
        contactName: _contactNameController.text.isNotEmpty
            ? _contactNameController.text
            : null,
        contactPhone: _contactPhoneController.text.isNotEmpty
            ? _contactPhoneController.text
            : null,
        contactEmail: _contactEmailController.text.isNotEmpty
            ? _contactEmailController.text
            : null,
        defaultIncoterms: _selectedIncoterms,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await saveCustomsProfile(profile);
    } else if (_selectedProfileId != null) {
      // Use existing profile
      profile = await ref.read(
        customsProfileProvider(_selectedProfileId!).future,
      );
    }

    // Create customs packet
    final packet = CustomsPacket(
      id: uuid.v4(),
      shipmentId: widget.shipmentId,
      profile: profile,
      items: _commodityLines,
      incoterms: _selectedIncoterms,
      contentsType: _contentsType,
      invoiceNumber: _invoiceNumberController.text.isNotEmpty
          ? _invoiceNumberController.text
          : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      certify: _certify,
      createdAt: DateTime.now(),
    );

    await saveCustomsPacket(packet);

    // Invalidate customs packet provider to refresh
    ref.invalidate(customsPacketProvider(widget.shipmentId));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customs information saved'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(customsProfilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customs Declaration'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info banner
            _buildInfoBanner(),
            const SizedBox(height: 24),

            // Load saved profile
            if (profilesAsync.hasValue && profilesAsync.value!.isNotEmpty) ...[
              _buildProfileSelector(profilesAsync.value!),
              const SizedBox(height: 24),
            ],

            // Importer Type
            _buildImporterTypeSection(),
            const SizedBox(height: 24),

            // Tax/VAT/EORI Section
            _buildTaxInfoSection(),
            const SizedBox(height: 24),

            // Company/Contact Info
            if (_importerType == ImporterType.business) ...[
              _buildCompanyInfoSection(),
              const SizedBox(height: 24),
            ],

            // Incoterms
            _buildIncotermsSection(),
            const SizedBox(height: 24),

            // Commodity Lines
            _buildCommodityLinesSection(),
            const SizedBox(height: 24),

            // Invoice and Notes
            _buildInvoiceSection(),
            const SizedBox(height: 24),

            // Certify checkbox
            _buildCertifySection(),
            const SizedBox(height: 24),

            // Save profile checkbox
            _buildSaveProfileSection(),
            const SizedBox(height: 24),

            // Submit button
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check_circle),
              label: const Text('Generate Customs Docs'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return ModalCard(
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'International Shipment',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Customs declaration required. This information will be used to generate commercial invoice and CN22/CN23 forms.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSelector(List<CustomsProfile> profiles) {
    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Load Saved Profile',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedProfileId,
            decoration: const InputDecoration(
              labelText: 'Select Profile',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('None (Enter manually)'),
              ),
              ...profiles.map((p) {
                return DropdownMenuItem<String>(
                  value: p.id,
                  child: Text(p.name),
                );
              }),
            ],
            onChanged: (value) {
              if (value != null) {
                final profile = profiles.firstWhere((p) => p.id == value);
                _loadProfile(profile);
              } else {
                setState(() {
                  _selectedProfileId = null;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImporterTypeSection() {
    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Importer Type',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<ImporterType>(
            segments: const [
              ButtonSegment(
                value: ImporterType.business,
                label: Text('Business'),
                icon: Icon(Icons.business),
              ),
              ButtonSegment(
                value: ImporterType.individual,
                label: Text('Individual'),
                icon: Icon(Icons.person),
              ),
            ],
            selected: {_importerType},
            onSelectionChanged: (Set<ImporterType> newSelection) {
              setState(() {
                _importerType = newSelection.first;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaxInfoSection() {
    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tax Identification',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _vatController,
            decoration: const InputDecoration(
              labelText: 'VAT Number (Optional)',
              hintText: 'e.g., DE123456789',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _eoriController,
            decoration: InputDecoration(
              labelText: _importerType == ImporterType.business
                  ? 'EORI Number (Required for EU Business)'
                  : 'EORI Number (Optional)',
              hintText: 'e.g., GB123456789000',
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (_importerType == ImporterType.business &&
                  (value == null || value.isEmpty)) {
                return 'EORI number required for business importers in EU';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _taxIdController,
            decoration: const InputDecoration(
              labelText: 'Tax ID (Optional)',
              hintText: 'e.g., EIN for US',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfoSection() {
    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Company Information',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _companyNameController,
            decoration: const InputDecoration(
              labelText: 'Company Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (_importerType == ImporterType.business &&
                  (value == null || value.isEmpty)) {
                return 'Company name required for business importers';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _contactNameController,
            decoration: const InputDecoration(
              labelText: 'Contact Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _contactPhoneController,
            decoration: const InputDecoration(
              labelText: 'Contact Phone',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _contactEmailController,
            decoration: const InputDecoration(
              labelText: 'Contact Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildIncotermsSection() {
    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Incoterms',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Delivery terms that define responsibilities between buyer and seller.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Incoterms>(
            initialValue: _selectedIncoterms,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: Incoterms.values.map((term) {
              return DropdownMenuItem<Incoterms>(
                value: term,
                child: Text(term.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedIncoterms = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommodityLinesSection() {
    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Goods Declaration',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _addDefaultCommodityLine,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Item'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._commodityLines.asMap().entries.map((entry) {
            final index = entry.key;
            final line = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCommodityLineCard(index, line),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCommodityLineCard(int index, CommodityLine line) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Item ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_commodityLines.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () {
                      setState(() {
                        _commodityLines.removeAt(index);
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: line.description,
              decoration: const InputDecoration(
                labelText: 'Description*',
                hintText: 'e.g., Electronic components',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _commodityLines[index] = line.copyWith(description: value);
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: line.quantity.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Quantity*',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final qty = double.tryParse(value) ?? 1.0;
                      setState(() {
                        _commodityLines[index] = line.copyWith(quantity: qty);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: line.netWeight.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)*',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final weight = double.tryParse(value) ?? 1.0;
                      setState(() {
                        _commodityLines[index] = line.copyWith(
                          netWeight: weight,
                        );
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: line.valueAmount.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Value (USD)*',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final val = double.tryParse(value) ?? 1.0;
                      setState(() {
                        _commodityLines[index] = line.copyWith(
                          valueAmount: val,
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: line.hsCode,
                    decoration: const InputDecoration(
                      labelText: 'HS Code*',
                      hintText: 'e.g., 8542.31',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _commodityLines[index] = line.copyWith(hsCode: value);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: line.originCountry,
                    decoration: const InputDecoration(
                      labelText: 'Origin Country*',
                      hintText: 'e.g., CN, US',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _commodityLines[index] = line.copyWith(
                          originCountry: value.toUpperCase(),
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceSection() {
    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Information',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _invoiceNumberController,
            decoration: const InputDecoration(
              labelText: 'Invoice Number (Optional)',
              hintText: 'e.g., INV-2025-001',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (Optional)',
              hintText: 'Any additional customs information',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildCertifySection() {
    return ModalCard(
      child: CheckboxListTile(
        value: _certify,
        onChanged: (value) {
          setState(() {
            _certify = value ?? false;
          });
        },
        title: const Text(
          'I certify that the information above is accurate and complete',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text(
          'Required for customs declaration. False information may result in penalties.',
          style: TextStyle(fontSize: 12),
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildSaveProfileSection() {
    return ModalCard(
      child: CheckboxListTile(
        value: _saveProfile,
        onChanged: (value) {
          setState(() {
            _saveProfile = value ?? false;
          });
        },
        title: const Text('Save this profile for future shipments'),
        subtitle: const Text(
          'Your VAT/EORI and company details will be encrypted and stored locally',
          style: TextStyle(fontSize: 12),
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
