import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';

/// Base pill used everywhere (status chips, filter chips, tags).
/// Every visual part has a default from the theme and can be overridden.
class AppChip extends StatelessWidget {
  final String label;

  // Colors (null = theme default)
  final Color? backgroundColor;
  final Color? foregroundColor; // text and default icon color
  final Color? borderColor;

  // Shape and spacing
  final double radius;
  final double borderWidth; // 0 = no border
  final EdgeInsetsGeometry padding;
  final double gap; // space between leading/trailing and the text

  // Text
  final TextStyle? textStyle;
  final bool uppercase;
  final int? maxLines;

  // Extras
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Duration animationDuration;

  const AppChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.radius = AppSizes.radiusFull,
    this.borderWidth = 1,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSizes.md - 2,
      vertical: AppSizes.xs,
    ),
    this.gap = AppSizes.sm - 2,
    this.textStyle,
    this.uppercase = false,
    this.maxLines = 1,
    this.leading,
    this.trailing,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final base = textStyle ?? theme.textTheme.labelSmall!;
    final fg = foregroundColor ?? base.color ?? scheme.onSurfaceVariant;
    final bg = backgroundColor ?? scheme.surface;
    final border =
        borderColor ??
        (backgroundColor != null ? backgroundColor! : scheme.outlineVariant);

    final chip = AnimatedContainer(
      duration: animationDuration,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: borderWidth > 0
            ? Border.all(color: border, width: borderWidth)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, SizedBox(width: gap)],
          Flexible(
            child: Text(
              uppercase ? label.toUpperCase() : label,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: base.copyWith(color: fg),
            ),
          ),
          if (trailing != null) ...[SizedBox(width: gap), trailing!],
        ],
      ),
    );

    if (onTap == null) return chip;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: chip,
    );
  }
}
