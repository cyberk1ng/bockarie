import 'package:flutter/material.dart';
import 'package:bockaire/services/city_autocomplete_service.dart';
import 'package:bockaire/themes/theme.dart';

/// City autocomplete text field with dropdown
class CityAutocompleteField extends StatefulWidget {
  final TextEditingController cityController;
  final TextEditingController postalController;
  final String label;
  final CityAutocompleteService? service;
  final String? Function(String?)? validator;

  const CityAutocompleteField({
    required this.cityController,
    required this.postalController,
    required this.label,
    this.service,
    this.validator,
    super.key,
  });

  @override
  State<CityAutocompleteField> createState() => _CityAutocompleteFieldState();
}

class _CityAutocompleteFieldState extends State<CityAutocompleteField> {
  late final CityAutocompleteService _service;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  List<CityResult> _suggestions = [];
  bool _isLoading = false;
  OverlayEntry? _overlayEntry;

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
      });
      _hideOverlay();
      return;
    }

    setState(() {
      _isLoading = true;
    });

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
                    title: Text(city.city, style: context.textTheme.bodyMedium),
                    subtitle: Text(
                      [
                        if (city.effectivePostalCode != null)
                          city.effectivePostalCode!,
                        if (city.country != null) city.country!,
                      ].join(', '),
                      style: context.textTheme.bodySmall,
                    ),
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

    _hideOverlay();
    _focusNode.unfocus();

    setState(() {
      _suggestions = [];
    });
  }

  void _clearField() {
    widget.cityController.clear();
    widget.postalController.clear();
    _hideOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: widget.cityController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.label,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              if (widget.cityController.text.isNotEmpty && !_isLoading)
                IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: _clearField,
                ),
            ],
          ),
        ),
        validator: widget.validator,
      ),
    );
  }
}
