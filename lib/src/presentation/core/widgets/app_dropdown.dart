import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

class AppDropdown<T> extends StatefulWidget {
  final List<T> items;
  final T? value;
  final String? hint;
  final String? label;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final String Function(T)? itemAsString;

  const AppDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.hint,
    this.label,
    this.validator,
    this.itemAsString,
  });

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  late final ValueNotifier<T?> _valueNotifier;

  @override
  void initState() {
    super.initState();
    _valueNotifier = ValueNotifier<T?>(widget.value);
  }

  @override
  void didUpdateWidget(covariant AppDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _valueNotifier.value = widget.value;
    }
  }

  @override
  void dispose() {
    _valueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.color;
    final dimensions = context.dimensions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: context.textStyle.labelLarge.copyWith(
              fontWeight: FontWeight.w500,
              color: colors.text.primary,
            ),
          ),
          SizedBox(height: dimensions.spacing.sm),
        ],
        FormField<T>(
          initialValue: widget.value,
          validator: widget.validator,
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton2<T>(
                    isExpanded: true,
                    valueListenable: _valueNotifier,
                    hint: widget.hint != null
                        ? Text(
                            widget.hint!,
                            style: context.textStyle.bodyMedium.copyWith(
                              color: colors.text.secondary,
                            ),
                          )
                        : null,
                    items: widget.items.map((item) {
                      return DropdownItem<T>(
                        value: item,
                        child: Text(
                          widget.itemAsString?.call(item) ?? item.toString(),
                          style: context.textStyle.bodyMedium.copyWith(
                            color: colors.text.primary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      _valueNotifier.value = val;
                      field.didChange(val);
                      widget.onChanged(val);
                    },
                    buttonStyleData: ButtonStyleData(
                      height: context.sizes.lg,
                      padding: EdgeInsets.symmetric(
                        horizontal: dimensions.spacing.sm,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          dimensions.radius.sm,
                        ),
                        border: Border.all(
                          color: field.hasError ? colors.error : colors.border,
                        ),
                        color: colors.textFieldFillColor,
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          dimensions.radius.sm,
                        ),
                        color: colors.onPrimary,
                      ),
                      elevation: 2,
                    ),
                    menuItemStyleData: MenuItemStyleData(
                      padding: EdgeInsets.symmetric(
                        horizontal: dimensions.spacing.lg,
                      ),
                    ),
                  ),
                ),
                if (field.hasError)
                  Padding(
                    padding: EdgeInsets.only(
                      top: dimensions.spacing.sm,
                      left: dimensions.spacing.md,
                    ),
                    child: Text(
                      field.errorText!,
                      style: context.textStyle.bodySmall.copyWith(
                        color: colors.error,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
