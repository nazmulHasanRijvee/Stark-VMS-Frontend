import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/localization_extension.dart';
import '../theme/theme.dart';

class MultiSelectDropdown extends StatefulWidget {
  const MultiSelectDropdown({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
    this.hint,
  });

  final List<String> items;
  final List<String> selectedItems;
  final ValueChanged<List<String>> onChanged;
  final String? hint;

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  late List<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.of(widget.selectedItems);
  }

  @override
  void didUpdateWidget(covariant MultiSelectDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedItems != oldWidget.selectedItems) {
      _selectedItems = List.of(widget.selectedItems);
    }
  }

  void _onItemTapped(String item) {
    setState(() {
      if (!_selectedItems.remove(item)) {
        _selectedItems.add(item);
      }
    });
    widget.onChanged(List.unmodifiable(_selectedItems));
  }

  @override
  Widget build(BuildContext context) {
    final hint = widget.hint ?? context.loc.select;

    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        key: ValueKey(_selectedItems.length),
        isExpanded: true,
        onChanged: (value) {
          if (value != null) _onItemTapped(value);
        },
        hint: Text(
          hint,
          style: context.textStyle.bodyMedium.copyWith(
            color: context.color.text.secondary,
          ),
        ),
        items: widget.items.map((item) {
          return DropdownItem<String>(
            value: item,
            enabled: false,
            child: StatefulBuilder(
              builder: (context, menuSetState) {
                final isSelected = _selectedItems.contains(item);
                return InkWell(
                  onTap: () {
                    _onItemTapped(item);
                    menuSetState(() {});
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing.md,
                      vertical: context.spacing.sm2,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: isSelected
                              ? context.color.primary
                              : context.color.text.tertiary,
                        ),
                        SizedBox(width: context.spacing.sm),
                        Expanded(
                          child: Text(
                            item,
                            style: context.textStyle.bodyMedium.copyWith(
                              color: context.color.text.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
        selectedItemBuilder: (context) => widget.items.map((_) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _selectedItems.isEmpty ? hint : _selectedItems.join(', '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyle.bodyMedium.copyWith(
                color: context.color.text.primary,
              ),
            ),
          );
        }).toList(),
        buttonStyleData: ButtonStyleData(
          height: context.sizes.lg,
          padding: EdgeInsets.symmetric(horizontal: context.spacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.radius.sm),
            border: Border.all(color: context.color.border),
            color: context.color.textFieldFillColor,
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: context.sizes.dropdownMaxHeight,
          decoration: BoxDecoration(
            color: context.color.surface,
            borderRadius: BorderRadius.circular(context.radius.sm),
          ),
        ),
      ),
    );
  }
}
