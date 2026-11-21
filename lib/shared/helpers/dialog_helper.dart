import 'package:flutter/material.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';

class DialogHelper {
  DialogHelper._();

  /// Returns true if the user confirms.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: Theme.of(ctx).textTheme.headlineSmall),
        content: Text(message, style: Theme.of(ctx).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelText ?? ctx.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmText ?? ctx.l10n.commonConfirm),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  /// Call after the request finishes.
  static void hideLoading(BuildContext context) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
