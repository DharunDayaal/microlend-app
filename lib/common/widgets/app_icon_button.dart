import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? color; // icon color, defaults to primary
  final Color? backgroundColor; // set it for a filled button
  final double iconSize;
  final bool isLoading;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.backgroundColor,
    this.iconSize = AppSizes.iconMd,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconColor = color ?? scheme.primary;

    return IconButton(
      tooltip: tooltip,
      onPressed: isLoading ? null : onPressed,
      iconSize: iconSize,
      constraints: const BoxConstraints(
        minWidth: AppSizes.minTouchTarget,
        minHeight: AppSizes.minTouchTarget,
      ),
      style: backgroundColor == null
          ? null
          : IconButton.styleFrom(
              backgroundColor: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
      icon: isLoading
          ? SizedBox(
              width: iconSize - 4,
              height: iconSize - 4,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: iconColor,
              ),
            )
          : Icon(icon, color: iconColor),
    );
  }
}
