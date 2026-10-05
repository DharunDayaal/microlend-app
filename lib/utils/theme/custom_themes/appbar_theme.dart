import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/theme/custom_themes/text_theme.dart';

class AppAppBarTheme {
  AppAppBarTheme._();

  static final AppBarTheme light = AppBarTheme(
    backgroundColor: AppColors.lightSurface,
    foregroundColor: AppColors.lightOnSurface,
    surfaceTintColor: Colors.transparent,
    shadowColor: const Color(0x290F172A),
    elevation: 2,
    scrolledUnderElevation: 2,
    titleTextStyle: AppTextTheme.lightTextTheme.headlineSmall,
  );

  static final AppBarTheme dark = AppBarTheme(
    backgroundColor: AppColors.darkAppBar,
    foregroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.black,
    elevation: 2,
    scrolledUnderElevation: 2,
    titleTextStyle: AppTextTheme.darkTextTheme.headlineSmall,
  );
}
