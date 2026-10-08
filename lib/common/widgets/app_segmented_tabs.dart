import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/device/device_utils.dart';

class SegmentTab<T> {
  final T value;
  final String label;
  final IconData? icon;
  final bool enabled;

  /// Runs every time this tab is tapped, including when it is already
  /// selected. Use it for tab-specific actions (analytics, scroll to top).
  final VoidCallback? onTap;

  final String? tooltip;

  const SegmentTab({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
    this.onTap,
    this.tooltip,
  });
}

/// Fixed (non-scrollable) segmented selector. Tabs share the width equally.
/// Needs at least 2 tabs.
class AppSegmentedTabs<T> extends StatelessWidget {
  final List<SegmentTab<T>> tabs;
  final T selected;

  /// Called only when the selection actually changes.
  final ValueChanged<T> onChanged;

  // Layout
  final double height;
  final double gap; // space between tabs
  final EdgeInsetsGeometry padding; // inside the outer container
  final EdgeInsetsGeometry margin;

  // Colors (null = theme default)
  final Color? backgroundColor; // outer container
  final Color? borderColor; // outer container
  final Color? selectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;

  // Shape and text
  final double containerRadius;
  final double tabRadius;
  final TextStyle? textStyle;
  final bool haptic;

  const AppSegmentedTabs({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onChanged,
    this.height = AppSizes.minTouchTarget,
    this.gap = AppSizes.xs,
    this.padding = const EdgeInsets.all(AppSizes.xs),
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
    this.borderColor,
    this.selectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.containerRadius = AppSizes.radiusLg,
    this.tabRadius = AppSizes.radiusMd,
    this.textStyle,
    this.haptic = true,
  }) : assert(tabs.length >= 2, 'AppSegmentedTabs needs at least 2 tabs');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final selBg = selectedColor ?? scheme.primary;
    final selFg = selectedTextColor ?? scheme.onPrimary;
    final unselFg = unselectedTextColor ?? scheme.onSurfaceVariant;
    final style = textStyle ?? theme.textTheme.labelLarge!;

    return Container(
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? scheme.surface,
        borderRadius: BorderRadius.circular(containerRadius),
        border: Border.all(color: borderColor ?? scheme.outlineVariant),
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            if (i > 0) SizedBox(width: gap),
            Expanded(
              child: _TabItem<T>(
                tab: tabs[i],
                isSelected: tabs[i].value == selected,
                selectedBg: selBg,
                selectedFg: selFg,
                unselectedFg: unselFg,
                radius: tabRadius,
                style: style,
                onPressed: () {
                  final tab = tabs[i];
                  if (!tab.enabled) return;
                  if (haptic) DeviceUtils.tap();
                  tab.onTap?.call();
                  if (tab.value != selected) onChanged(tab.value);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TabItem<T> extends StatelessWidget {
  final SegmentTab<T> tab;
  final bool isSelected;
  final Color selectedBg;
  final Color selectedFg;
  final Color unselectedFg;
  final double radius;
  final TextStyle style;
  final VoidCallback onPressed;

  const _TabItem({
    required this.tab,
    required this.isSelected,
    required this.selectedBg,
    required this.selectedFg,
    required this.unselectedFg,
    required this.radius,
    required this.style,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final fg = isSelected ? selectedFg : unselectedFg;

    Widget item = Semantics(
      button: true,
      selected: isSelected,
      enabled: tab.enabled,
      label: tab.label,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Opacity(
            opacity: tab.enabled ? 1 : 0.4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (tab.icon != null) ...[
                  Icon(tab.icon, size: AppSizes.iconSm, color: fg),
                  const SizedBox(width: AppSizes.xs),
                ],
                Flexible(
                  child: Text(
                    tab.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style.copyWith(color: fg),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (tab.tooltip != null) {
      item = Tooltip(message: tab.tooltip!, child: item);
    }
    return item;
  }
}
