import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';

class AppSpacing {
  AppSpacing._();

  /// Screen margin from the design: 12 in dark, 16 in light.
  static EdgeInsets screen(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return EdgeInsets.all(
      dark ? AppSizes.screenPaddingDark : AppSizes.screenPaddingLight,
    );
  }

  /// For scrollable lists: adds the mandatory bottom clearance.
  static EdgeInsets list(BuildContext context) =>
      screen(context).copyWith(bottom: AppSizes.bottomClearance);
}

class AppGap {
  AppGap._();

  static const h4 = SizedBox(height: AppSizes.xs);
  static const h8 = SizedBox(height: AppSizes.sm);
  static const h12 = SizedBox(height: AppSizes.md);
  static const h16 = SizedBox(height: AppSizes.lg);
  static const h24 = SizedBox(height: AppSizes.xl);

  static const w8 = SizedBox(width: AppSizes.sm);
  static const w12 = SizedBox(width: AppSizes.md);
  static const w16 = SizedBox(width: AppSizes.lg);
}
