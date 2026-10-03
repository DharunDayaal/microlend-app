import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/theme/custom_themes/text_theme.dart';

class AppOutlinedButtonTheme {
  AppOutlinedButtonTheme._();

  static final OutlinedButtonThemeData light = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.lightOnSurface,
      minimumSize: const Size.fromHeight(48),
      side: const BorderSide(color: AppColors.lightBorderStrong, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: AppTextTheme.base.labelLarge,
    ),
  );

  static final OutlinedButtonThemeData dark = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.darkOnSurface,
      minimumSize: const Size.fromHeight(52),
      side: const BorderSide(color: AppColors.darkRim, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      textStyle: AppTextTheme.base.labelLarge,
    ),
  );
}
