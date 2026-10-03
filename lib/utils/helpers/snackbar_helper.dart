import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/theme/custom_themes/status_colors.dart';

enum _SnackType { success, error, warning, info }

class AppSnackbar {
  AppSnackbar._();

  static void success(BuildContext c, String message) =>
      _show(c, message, _SnackType.success);

  static void error(BuildContext c, String message) =>
      _show(c, message, _SnackType.error);

  static void warning(BuildContext c, String message) =>
      _show(c, message, _SnackType.warning);

  static void info(BuildContext c, String message) =>
      _show(c, message, _SnackType.info);

  static void _show(BuildContext context, String message, _SnackType type) {
    final theme = Theme.of(context);
    final s = theme.extension<StatusColors>()!;

    final (bg, fg, border, icon) = switch (type) {
      _SnackType.success => (s.paidBg, s.paidFg, s.paidBorder, Icons.check_circle),
      _SnackType.error => (s.overdueBg, s.overdueFg, s.overdueBorder, Icons.error),
      _SnackType.warning => (s.pendingBg, s.pendingFg, s.pendingBorder, Icons.warning_amber_rounded),
      _SnackType.info => (theme.colorScheme.surface, theme.colorScheme.onSurface, theme.colorScheme.outline, Icons.info),
    };

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: bg,
          margin: const EdgeInsets.all(AppSizes.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            side: BorderSide(color: border),
          ),
          content: Row(
            children: [
              Icon(icon, color: fg, size: AppSizes.iconMd),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium!.copyWith(color: fg),
                ),
              ),
            ],
          ),
        ),
      );
  }
}