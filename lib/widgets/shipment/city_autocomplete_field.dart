import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:bockaire/services/city_autocomplete_service.dart';
import 'package:bockaire/themes/theme.dart';
import 'package:bockaire/l10n/app_localizations.dart';

/// City autocomplete text field with dropdown
class CityAutocompleteField extends StatefulWidget {
  final TextEditingController cityController;
  final TextEditingController postalController;
  final TextEditingController? countryController;
  final TextEditingController? stateController;
  final String label;
  final CityAutocompleteService? service;
  final String? Function(String?)? validator;

  const CityAutocompleteField({
    required this.cityController,
    required this.postalController,
    this.countryController,
    this.stateController,
    required this.label,
    this.service,
    this.validator,
    super.key,
  });

  @override
  State<CityAutocompleteField> createState() => _CityAutocompleteFieldState();
}

class _CityAutocompleteFieldState extends State<CityAutocompleteField> {
  final Logger _logger = Logger();
  late final CityAutocompleteService _service;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  List<CityResult> _suggestions = [];
  bool _isLoading = false;
  OverlayEntry? _overlayEntry;
  bool _validSelectionMade = false; // Track if user selected from dropdown

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? CityAutocompleteService();
    widget.cityController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.cityController.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _hideOverlay();
    _service.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final query = widget.cityController.text;

    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
        _validSelectionMade = false;
      });
      // Clear country/state when city is cleared
      widget.countryController?.clear();
      widget.stateController?.clear();
      _hideOverlay();
      return;
    }

    // User is typing - invalidate previous selection
    setState(() {
      _isLoading = true;
      _validSelectionMade = false;
    });

    // Clear country/state until a new selection is made
    widget.countryController?.clear();
    widget.stateController?.clear();

    _service.searchCities(query, (results) {
      if (mounted) {
        setState(() {
          _suggestions = results;
          _isLoading = false;
        });

        if (results.isNotEmpty && _focusNode.hasFocus) {
          _showOverlay();
        } else {
          _hideOverlay();
        }
      }
    });
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      // Add delay to allow tap to register before hiding overlay
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted && !_focusNode.hasFocus) {
          _hideOverlay();
        }
      });
    } else if (_suggestions.isNotEmpty) {
      _showOverlay();
    }
  }

  void _showOverlay() {
    _hideOverlay();

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final city = _suggestions[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.location_city,
                      size: 20,
                      color: context.colorScheme.primary,
                    ),
                    title: Text(
                      city.city,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      _buildLocationSubtitle(city),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: city.countryCode != null
                        ? Text(
                            _getCountryFlag(city.countryCode!),
                            style: const TextStyle(fontSize: 24),
                          )
                        : null,
                    onTap: () => _selectCity(city),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectCity(CityResult city) {
    widget.cityController.text = city.city;

    final effectivePostal = city.effectivePostalCode;
    if (effectivePostal != null && effectivePostal.isNotEmpty) {
      widget.postalController.text = effectivePostal;
    }

    // Populate country code (uppercase ISO code like "US", "CN", "DE")
    if (widget.countryController != null) {
      if (city.countryCode != null && city.countryCode!.isNotEmpty) {
        widget.countryController!.text = city.countryCode!;
        _logger.d('Set country to ${city.countryCode}');
      } else {
        _logger.w('City ${city.city} has no country code!');
        widget.countryController!.text = '';
      }
    }

    // Populate state code (for US addresses)
    if (widget.stateController != null) {
      final stateCode = city.state ?? '';
      widget.stateController!.text = stateCode;
      _logger.d('Set state to "$stateCode"');
    }

    _hideOverlay();
    _focusNode.unfocus();

    setState(() {
      _suggestions = [];
      _validSelectionMade = true; // Mark that a valid selection was made
    });
  }

  void _clearField() {
    widget.cityController.clear();
    widget.postalController.clear();
    widget.countryController?.clear();
    widget.stateController?.clear();
    setState(() {
      _validSelectionMade = false;
    });
    _hideOverlay();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: widget.cityController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.label,
          helperText: _validSelectionMade
              ? null
              : localizations.helperSelectFromDropdown,
          helperStyle: TextStyle(
            color: context.colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_validSelectionMade && !_isLoading)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.check_circle,
                    size: 20,
                    color: context.colorScheme.primary,
                  ),
                ),
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.colorScheme.primary,
                    ),
                  ),
                ),
              if (widget.cityController.text.isNotEmpty &&
                  !_isLoading &&
                  !_validSelectionMade)
                IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: _clearField,
                ),
            ],
          ),
        ),
        validator: (value) {
          // First run the custom validator if provided
          final customError = widget.validator?.call(value);
          if (customError != null) return customError;

          // Then check if a valid selection was made (country must be populated)
          if (widget.countryController != null) {
            final country = widget.countryController!.text;
            if (country.isEmpty) {
              return localizations.validationSelectFromDropdown;
            }
          }

          return null;
        },
      ),
    );
  }

  /// Build a professional location subtitle for the dropdown
  String _buildLocationSubtitle(CityResult city) {
    final parts = <String>[];

    // Add state with full name if available
    if (city.state != null) {
      final stateName = _getStateName(city.state!, city.countryCode);
      if (stateName != null) {
        parts.add('$stateName (${city.state})');
      } else {
        parts.add(city.state!);
      }
    }

    // Add country
    if (city.country != null) {
      parts.add(city.country!);
    }

    // Add postal code at the end if available
    if (city.effectivePostalCode != null) {
      parts.add('📮 ${city.effectivePostalCode}');
    }

    return parts.join(' • ');
  }

  /// Get full state/province name from code
  String? _getStateName(String stateCode, String? countryCode) {
    if (countryCode == 'US') {
      return _usStateNames[stateCode];
    }
    // Add more countries as needed
    return null;
  }

  /// Get country flag emoji from country code
  String _getCountryFlag(String countryCode) {
    final code = countryCode.toUpperCase();
    // Convert country code to flag emoji
    // Each letter becomes a regional indicator symbol
    return String.fromCharCodes(code.codeUnits.map((c) => 0x1F1E6 + c - 0x41));
  }

  /// US state names mapping
  static const Map<String, String> _usStateNames = {
    'AL': 'Alabama',
    'AK': 'Alaska',
    'AZ': 'Arizona',
    'AR': 'Arkansas',
    'CA': 'California',
    'CO': 'Colorado',
    'CT': 'Connecticut',
    'DE': 'Delaware',
    'FL': 'Florida',
    'GA': 'Georgia',
    'HI': 'Hawaii',
    'ID': 'Idaho',
    'IL': 'Illinois',
    'IN': 'Indiana',
    'IA': 'Iowa',
    'KS': 'Kansas',
    'KY': 'Kentucky',
    'LA': 'Louisiana',
    'ME': 'Maine',
    'MD': 'Maryland',
    'MA': 'Massachusetts',
    'MI': 'Michigan',
    'MN': 'Minnesota',
    'MS': 'Mississippi',
    'MO': 'Missouri',
    'MT': 'Montana',
    'NE': 'Nebraska',
    'NV': 'Nevada',
    'NH': 'New Hampshire',
    'NJ': 'New Jersey',
    'NM': 'New Mexico',
    'NY': 'New York',
    'NC': 'North Carolina',
    'ND': 'North Dakota',
    'OH': 'Ohio',
    'OK': 'Oklahoma',
    'OR': 'Oregon',
    'PA': 'Pennsylvania',
    'RI': 'Rhode Island',
    'SC': 'South Carolina',
    'SD': 'South Dakota',
    'TN': 'Tennessee',
    'TX': 'Texas',
    'UT': 'Utah',
    'VT': 'Vermont',
    'VA': 'Virginia',
    'WA': 'Washington',
    'WV': 'West Virginia',
    'WI': 'Wisconsin',
    'WY': 'Wyoming',
    'DC': 'District of Columbia',
  };
}
