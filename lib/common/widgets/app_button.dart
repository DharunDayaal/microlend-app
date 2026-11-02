import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;

  // Icons
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final IconData? icon; // alias of prefixIcon
  final double iconGap;
  final Color? iconColor;
  final Color? suffixIconColor;

  // Size
  final double? width; // fixed width. null = take the width the parent gives
  final double? height; // minimum height. null = theme (48 / 52)
  final bool fitContent; // hug the label instead of stretching (good in a Row)

  // Look (null = theme)
  final Color? backgroundColor;
  final Color? foregroundColor; // label and default icon color
  final Color? borderColor; // outlined buttons only
  final double? radius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  /// Full control. Applied last, so it wins over every option above.
  final ButtonStyle? style;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.prefixIcon,
    this.suffixIcon,
    this.icon,
    this.iconGap = AppSizes.sm,
    this.iconColor,
    this.suffixIconColor,
    this.width,
    this.height,
    this.fitContent = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.radius,
    this.padding,
    this.textStyle,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onTap = isLoading ? null : onPressed;
    final leading = prefixIcon ?? icon;

    // The theme's minimum height, so fitContent keeps the same button height.
    final themeStyle = outlined
        ? theme.outlinedButtonTheme.style
        : theme.elevatedButtonTheme.style;
    final themeHeight =
        themeStyle?.minimumSize?.resolve(<WidgetState>{})?.height ?? 48;

    Size? minimumSize;
    if (fitContent || height != null) {
      minimumSize = Size(
        fitContent ? 0 : double.infinity,
        height ?? themeHeight,
      );
    }

    final shape = radius == null
        ? null
        : RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius!));
    final side = borderColor == null
        ? null
        : BorderSide(color: borderColor!, width: 1.5);

    // styleFrom leaves anything that is null alone, so the theme fills the gaps.
    ButtonStyle overrides = outlined
        ? OutlinedButton.styleFrom(
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            minimumSize: minimumSize,
            padding: padding,
            shape: shape,
            side: side,
            textStyle: textStyle,
          )
        : ElevatedButton.styleFrom(
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            minimumSize: minimumSize,
            padding: padding,
            shape: shape,
            textStyle: textStyle,
          );

    if (style != null) overrides = overrides.merge(style);

    final Widget child = isLoading
        ? SizedBox(
            height: AppSizes.iconSm + 4,
            width: AppSizes.iconSm + 4,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: foregroundColor ?? (outlined ? null : Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null) ...[
                Icon(leading, size: AppSizes.iconMd - 4, color: iconColor),
                SizedBox(width: iconGap),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (suffixIcon != null) ...[
                SizedBox(width: iconGap),
                Icon(
                  suffixIcon,
                  size: AppSizes.iconMd - 4,
                  color: suffixIconColor,
                ),
              ],
            ],
          );

    final button = outlined
        ? OutlinedButton(onPressed: onTap, style: overrides, child: child)
        : ElevatedButton(onPressed: onTap, style: overrides, child: child);

    return width == null ? button : SizedBox(width: width, child: button);
  }
}
