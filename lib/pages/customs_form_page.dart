import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:bockaire/models/customs_models.dart';
import 'package:bockaire/providers/booking_providers.dart';
import 'package:bockaire/themes/theme.dart';
import 'package:bockaire/widgets/modal/modal_card.dart';
import 'package:bockaire/l10n/app_localizations.dart';

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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.customsFillAllItemsError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_certify) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.customsMustCertifyError),
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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.customsInformationSaved),
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
        title: Text(AppLocalizations.of(context)!.customsDeclarationTitle),
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
              label: Text(
                AppLocalizations.of(context)!.customsGenerateDocsButton,
              ),
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
                  AppLocalizations.of(context)!.customsInternationalShipment,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(
                    context,
                  )!.customsDeclarationRequiredMessage,
                  style: const TextStyle(fontSize: 12),
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
            AppLocalizations.of(context)!.customsLoadSavedProfile,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedProfileId,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.customsSelectProfile,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text(
                  AppLocalizations.of(context)!.customsNoneEnterManually,
                ),
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
            AppLocalizations.of(context)!.customsImporterType,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<ImporterType>(
            segments: [
              ButtonSegment(
                value: ImporterType.business,
                label: Text(AppLocalizations.of(context)!.customsBusinessLabel),
                icon: const Icon(Icons.business),
              ),
              ButtonSegment(
                value: ImporterType.individual,
                label: Text(
                  AppLocalizations.of(context)!.customsIndividualLabel,
                ),
                icon: const Icon(Icons.person),
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
            AppLocalizations.of(context)!.customsTaxIdentification,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _vatController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.customsVatNumberOptional,
              hintText: AppLocalizations.of(context)!.customsVatNumberHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _eoriController,
            decoration: InputDecoration(
              labelText: _importerType == ImporterType.business
                  ? AppLocalizations.of(context)!.customsEoriRequired
                  : AppLocalizations.of(context)!.customsEoriOptional,
              hintText: AppLocalizations.of(context)!.customsEoriHint,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (_importerType == ImporterType.business &&
                  (value == null || value.isEmpty)) {
                return AppLocalizations.of(
                  context,
                )!.customsEoriRequiredValidation;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _taxIdController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.customsTaxIdOptional,
              hintText: AppLocalizations.of(context)!.customsTaxIdHint,
              border: const OutlineInputBorder(),
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
            AppLocalizations.of(context)!.customsCompanyInformation,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _companyNameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.customsCompanyName,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (_importerType == ImporterType.business &&
                  (value == null || value.isEmpty)) {
                return AppLocalizations.of(context)!.customsCompanyNameRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _contactNameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.customsContactName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _contactPhoneController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.customsContactPhone,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _contactEmailController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.customsContactEmail,
              border: const OutlineInputBorder(),
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
            AppLocalizations.of(context)!.customsIncotermsTitle,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.customsIncotermsSubtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                  AppLocalizations.of(context)!.customsGoodsDeclaration,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _addDefaultCommodityLine,
                icon: const Icon(Icons.add, size: 18),
                label: Text(AppLocalizations.of(context)!.customsAddItem),
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
                  AppLocalizations.of(context)!.customsItemNumber(index + 1),
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
              decoration: InputDecoration(
                labelText: AppLocalizations.of(
                  context,
                )!.customsDescriptionRequired,
                hintText: AppLocalizations.of(context)!.customsDescriptionHint,
                border: const OutlineInputBorder(),
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
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(
                        context,
                      )!.customsQuantityRequired,
                      border: const OutlineInputBorder(),
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
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(
                        context,
                      )!.customsWeightKgRequired,
                      border: const OutlineInputBorder(),
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
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(
                        context,
                      )!.customsValueUsdRequired,
                      border: const OutlineInputBorder(),
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
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(
                        context,
                      )!.customsHsCodeRequired,
                      hintText: AppLocalizations.of(context)!.customsHsCodeHint,
                      border: const OutlineInputBorder(),
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
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(
                        context,
                      )!.customsOriginCountryRequired,
                      hintText: AppLocalizations.of(
                        context,
                      )!.customsOriginCountryHint,
                      border: const OutlineInputBorder(),
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
            AppLocalizations.of(context)!.customsAdditionalInformation,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _invoiceNumberController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(
                context,
              )!.customsInvoiceNumberOptional,
              hintText: AppLocalizations.of(context)!.customsInvoiceNumberHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.customsNotesOptional,
              hintText: AppLocalizations.of(context)!.customsNotesHint,
              border: const OutlineInputBorder(),
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
        title: Text(
          AppLocalizations.of(context)!.customsCertifyAccurate,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          AppLocalizations.of(context)!.customsCertifySubtitle,
          style: const TextStyle(fontSize: 12),
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
        title: Text(AppLocalizations.of(context)!.customsSaveProfileFuture),
        subtitle: Text(
          AppLocalizations.of(context)!.customsSaveProfileSubtitle,
          style: const TextStyle(fontSize: 12),
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
