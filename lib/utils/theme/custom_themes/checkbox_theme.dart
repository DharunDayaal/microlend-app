import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';

class AppCheckboxTheme {
  AppCheckboxTheme._();

  static final CheckboxThemeData light = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    side: const BorderSide(color: AppColors.lightBorderStrong, width: 2),
    fillColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AppColors.lightPrimary
          : Colors.transparent,
    ),
    checkColor: const WidgetStatePropertyAll(Colors.white),
  );

  static final CheckboxThemeData dark = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    side: const BorderSide(color: AppColors.darkRim, width: 2),
    fillColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AppColors.success
          : Colors.transparent,
    ),
    checkColor: const WidgetStatePropertyAll(Colors.white),
  );
}
