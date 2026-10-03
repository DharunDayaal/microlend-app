import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/theme/custom_themes/text_theme.dart';

class AppAppBarTheme {
  AppAppBarTheme._();

  static final AppBarTheme light = AppBarTheme(
    backgroundColor: AppColors.lightSurface,
    foregroundColor: AppColors.lightOnSurface,
    elevation: 0,
    scrolledUnderElevation: 0,
    titleTextStyle: AppTextTheme.lightTextTheme.headlineSmall,
  );

  static final AppBarTheme dark = AppBarTheme(
    backgroundColor: AppColors.darkAppBar,
    foregroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    titleTextStyle: AppTextTheme.darkTextTheme.headlineSmall,
  );
}