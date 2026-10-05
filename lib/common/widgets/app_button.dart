import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final IconData? icon;
  final double iconGap;
  final Color? iconColor;
  final Color? suffixIconColor;

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

    /// The same color variable for prefix icon and icon.
    this.iconColor,
    this.suffixIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final onTap = isLoading ? null : onPressed;
    final leading = prefixIcon ?? icon;

    final Widget child = isLoading
        ? SizedBox(
            height: AppSizes.iconSm + 4,
            width: AppSizes.iconSm + 4,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: outlined ? null : Colors.white,
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

    return outlined
        ? OutlinedButton(onPressed: onTap, child: child)
        : ElevatedButton(onPressed: onTap, child: child);
  }
}
