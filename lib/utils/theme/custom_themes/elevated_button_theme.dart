import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/theme/custom_themes/text_theme.dart';

class AppElevatedButtonTheme {
  AppElevatedButtonTheme._();

  static final ElevatedButtonThemeData light = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.lightPrimary,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(AppSizes.buttonHeightLight),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
      textStyle: AppTextTheme.base.labelLarge,
    ),
  );

  static final ElevatedButtonThemeData dark = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppColors.darkBorder,
      minimumSize: const Size.fromHeight(AppSizes.buttonHeightDark),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSm)),
      textStyle: AppTextTheme.base.labelLarge!.copyWith(letterSpacing: 0.8),
    ),
  );
}
