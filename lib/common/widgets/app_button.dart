import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final onTap = isLoading ? null : onPressed;

    final child = isLoading
        ? SizedBox(
            height: AppSizes.iconSm + 4,
            width: AppSizes.iconSm + 4,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: outlined ? null : Colors.white,
            ),
          )
        : Text(label);

    if (icon != null && !isLoading) {
      return outlined
          ? OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon),
              label: child,
            )
          : ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon),
              label: child,
            );
    }

    return outlined
        ? OutlinedButton(onPressed: onTap, child: child)
        : ElevatedButton(onPressed: onTap, child: child);
  }
}
