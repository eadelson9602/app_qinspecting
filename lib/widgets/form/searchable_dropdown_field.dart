import 'package:flutter/material.dart';
import 'package:app_qinspecting/ui/input_decorations.dart';

/// Widget reutilizable para campos de búsqueda con autocompletado
/// Reemplaza DropdownButtonFormField con funcionalidad de búsqueda
class SearchableDropdownField<T extends Object> extends StatefulWidget {
  final String labelText;
  final IconData? prefixIcon;
  final List<T> items;
  final String Function(T) getDisplayText;
  final T? Function(String)? getValueFromText;
  final String? initialValue;
  final String? Function(String?)? validator;
  final void Function(T?)? onChanged;
  final BuildContext? context;

  const SearchableDropdownField({
    Key? key,
    required this.labelText,
    this.prefixIcon,
    required this.items,
    required this.getDisplayText,
    this.getValueFromText,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.context,
  }) : super(key: key);

  @override
  State<SearchableDropdownField<T>> createState() =>
      _SearchableDropdownFieldState<T>();
}

class _SearchableDropdownFieldState<T extends Object>
    extends State<SearchableDropdownField<T>> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void didUpdateWidget(SearchableDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<T>(
      displayStringForOption: widget.getDisplayText,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return widget.items;
        }
        final query = textEditingValue.text.toLowerCase();
        return widget.items.where((item) {
          final displayText = widget.getDisplayText(item).toLowerCase();
          return displayText.contains(query);
        });
      },
      onSelected: (T selection) {
        setState(() {
          _controller.text = widget.getDisplayText(selection);
        });
        widget.onChanged?.call(selection);
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        // Sincronizar controladores
        if (_controller.text != textEditingController.text &&
            textEditingController.text.isEmpty) {
          textEditingController.text = _controller.text;
        }

        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecorations.authInputDecorations(
            hintText: 'Buscar...',
            labelText: widget.labelText,
            prefixIcon: widget.prefixIcon,
            context: widget.context ?? context,
          ),
          validator: (value) {
            if (widget.validator != null) {
              return widget.validator!(value);
            }
            if (value == null || value.isEmpty) {
              return 'Seleccione una opción';
            }
            if (widget.getValueFromText != null) {
              final selectedValue = widget.getValueFromText!(value);
              if (selectedValue == null) {
                return 'Seleccione una opción válida';
              }
            }
            return null;
          },
          onChanged: (value) {
            // Si el usuario borra el texto, limpiar la selección
            if (value.isEmpty) {
              widget.onChanged?.call(null);
            } else {
              // Intentar encontrar el valor correspondiente
              if (widget.getValueFromText != null) {
                final selectedValue = widget.getValueFromText!(value);
                if (selectedValue != null) {
                  widget.onChanged?.call(selectedValue);
                }
              }
            }
            _controller.text = value;
          },
          onFieldSubmitted: (String value) {
            onFieldSubmitted();
          },
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<T> onSelected,
        Iterable<T> options,
      ) {
        if (options.isEmpty) {
          return const SizedBox.shrink();
        }
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        widget.getDisplayText(option),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

