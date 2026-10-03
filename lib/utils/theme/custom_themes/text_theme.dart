import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/app_constants.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';

class AppTextTheme {
  AppTextTheme._();

  static const TextTheme base = TextTheme(
    displayLarge: TextStyle(
      fontSize: AppSizes.fontDisplay,
      height: AppSizes.lineDisplay / AppSizes.fontDisplay,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.02 * AppSizes.fontDisplay,
    ),
    headlineLarge: TextStyle(
      fontSize: AppSizes.fontHeadlineLg,
      height: AppSizes.lineHeadlineLg / AppSizes.fontHeadlineLg,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.01 * AppSizes.fontHeadlineLg,
    ),
    headlineMedium: TextStyle(
      fontSize: AppSizes.fontHeadlineMd,
      height: AppSizes.lineHeadlineMd / AppSizes.fontHeadlineMd,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.01 * AppSizes.fontHeadlineMd,
    ),
    headlineSmall: TextStyle(
      fontSize: AppSizes.fontHeadlineSm,
      height: AppSizes.lineHeadlineSm / AppSizes.fontHeadlineSm,
      fontWeight: FontWeight.w700,
    ),
    titleLarge: TextStyle(
      fontSize: AppSizes.fontTitle,
      height: AppSizes.lineTitle / AppSizes.fontTitle,
      fontWeight: FontWeight.w700,
    ),
    bodyLarge: TextStyle(
      fontSize: AppSizes.fontBodyLg,
      height: AppSizes.lineBodyLg / AppSizes.fontBodyLg,
      fontWeight: FontWeight.w500,
    ),
    bodyMedium: TextStyle(
      fontSize: AppSizes.fontBodyMd,
      height: AppSizes.lineBodyMd / AppSizes.fontBodyMd,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      fontSize: AppSizes.fontBodySm,
      height: AppSizes.lineBodySm / AppSizes.fontBodySm,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: TextStyle(
      fontSize: AppSizes.fontLabelLg,
      height: AppSizes.lineLabelLg / AppSizes.fontLabelLg,
      fontWeight: FontWeight.w600,
    ),
    labelMedium: TextStyle(
      fontSize: AppSizes.fontLabelMd,
      height: AppSizes.lineLabelMd / AppSizes.fontLabelMd,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.04 * AppSizes.fontLabelMd,
    ),
    labelSmall: TextStyle(
      fontSize: AppSizes.fontLabelSm,
      height: AppSizes.lineLabelSm / AppSizes.fontLabelSm,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.05 * AppSizes.fontLabelSm,
    ),
  );

  static final TextTheme lightTextTheme = base.apply(
    bodyColor: AppColors.lightOnSurface,
    displayColor: AppColors.lightOnSurface,
  );

  static final TextTheme darkTextTheme = base.apply(
    bodyColor: AppColors.darkOnSurface,
    displayColor: AppColors.darkOnSurface,
  );
}

class AppCustomTextStyles {
  AppCustomTextStyles._();

  static const String _fontFamily = AppConstants.fontFamily;

  static const TextStyle currencyDisplay = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppSizes.fontCurrency,
    height: AppSizes.lineCurrency / AppSizes.fontCurrency,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.01 * AppSizes.fontCurrency,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle currencyDisplaySm = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppSizes.fontCurrencySm,
    height: AppSizes.lineCurrencySm / AppSizes.fontCurrencySm,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle dataTabular = TextStyle(
    fontFamily: _fontFamily,
    fontSize: AppSizes.fontData,
    height: AppSizes.lineData / AppSizes.fontData,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
