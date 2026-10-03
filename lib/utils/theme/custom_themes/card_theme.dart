import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';

class AppCardTheme {
  AppCardTheme._();

  static final CardThemeData light = CardThemeData(
    color: AppColors.lightSurface,
    elevation: 1,
    shadowColor: const Color(0x0D0F172A),
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.lightBorder),
    ),
  );

  static final CardThemeData dark = CardThemeData(
    color: AppColors.darkSurface,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: AppColors.darkBorder),
    ),
  );
}
