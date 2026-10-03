import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';

class AppColorTheme {
  AppColorTheme._();

  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.lightPrimary,
    onPrimary: Colors.white,
    secondary: AppColors.successContainer,
    onSecondary: Colors.white,
    tertiary: AppColors.warningContainer,
    onTertiary: Colors.white,
    error: AppColors.dangerContainer,
    onError: Colors.white,
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightOnSurface,
    onSurfaceVariant: AppColors.lightOnSurfaceMuted,
    outline: AppColors.lightBorderStrong,
    outlineVariant: AppColors.lightBorder,
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.darkPrimary,
    onPrimary: Colors.white,
    secondary: AppColors.success,
    onSecondary: Colors.white,
    tertiary: AppColors.warning,
    onTertiary: Colors.black,
    error: AppColors.danger,
    onError: Colors.white,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkOnSurface,
    onSurfaceVariant: AppColors.darkOnSurfaceMuted,
    outline: AppColors.darkRim,
    outlineVariant: AppColors.darkBorder,
  );
}
