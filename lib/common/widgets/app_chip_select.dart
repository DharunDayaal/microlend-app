import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/widgets/app_status_chip.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/device/device_utils.dart';

class ChipOption<T> {
  final T value;
  final String label;

  const ChipOption({required this.value, required this.label});

  String get text => label;
}

/// Horizontally scrollable pill selector built from AppChip.
class AppChipSelect<T> extends StatefulWidget {
  final List<ChipOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  // Layout
  final EdgeInsetsGeometry padding;
  final double spacing;
  final double height;

  // Chip styling (null = theme default)
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final Color? selectedBorderColor;
  final Color? unselectedBorderColor;
  final TextStyle? textStyle;
  final double radius;
  final EdgeInsetsGeometry chipPadding;
  final bool showSelectedDot;

  const AppChipSelect({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSizes.md),
    this.spacing = AppSizes.sm,
    this.height = AppSizes.minTouchTarget,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.selectedBorderColor,
    this.unselectedBorderColor,
    this.textStyle,
    this.radius = AppSizes.radiusFull,
    this.chipPadding = const EdgeInsets.symmetric(
      horizontal: AppSizes.lg,
      vertical: AppSizes.sm + 2,
    ),
    this.showSelectedDot = true,
  });

  @override
  State<AppChipSelect<T>> createState() => _AppChipSelectState<T>();
}

class _AppChipSelectState<T> extends State<AppChipSelect<T>> {
  late List<GlobalKey> _keys = _makeKeys();

  List<GlobalKey> _makeKeys() =>
      List.generate(widget.options.length, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(covariant AppChipSelect<T> old) {
    super.didUpdateWidget(old);
    if (old.options.length != widget.options.length) _keys = _makeKeys();
    if (old.selected != widget.selected) _scrollToSelected();
  }

  void _scrollToSelected() {
    final i = widget.options.indexWhere((o) => o.value == widget.selected);
    if (i < 0 || i >= _keys.length) return;
    final ctx = _keys[i].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final selBg = widget.selectedColor ?? scheme.primary;
    final selFg = widget.selectedTextColor ?? scheme.onPrimary;
    final selBorder = widget.selectedBorderColor ?? selBg;

    final unselBg = widget.unselectedColor ?? scheme.surface;
    final unselFg = widget.unselectedTextColor ?? scheme.onSurfaceVariant;
    final unselBorder = widget.unselectedBorderColor ?? scheme.outlineVariant;

    final style = widget.textStyle ?? theme.textTheme.labelMedium!;

    return SizedBox(
      height: widget.height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: widget.padding,
        itemCount: widget.options.length,
        separatorBuilder: (_, _) => SizedBox(width: widget.spacing),
        itemBuilder: (_, i) {
          final option = widget.options[i];
          final isSelected = option.value == widget.selected;

          return Center(
            key: _keys[i],
            child: AppChip(
              label: option.text,
              textStyle: style,
              radius: widget.radius,
              padding: widget.chipPadding,
              backgroundColor: isSelected ? selBg : unselBg,
              foregroundColor: isSelected ? selFg : unselFg,
              borderColor: isSelected ? selBorder : unselBorder,
              leading: (isSelected && widget.showSelectedDot)
                  ? Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: selFg,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
              onTap: () {
                if (isSelected) return;
                DeviceUtils.tap();
                widget.onSelected(option.value);
              },
            ),
          );
        },
      ),
    );
  }
}
