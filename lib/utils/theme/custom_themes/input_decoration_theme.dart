import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/theme/custom_themes/text_theme.dart';

class AppInputDecorationTheme {
  AppInputDecorationTheme._();

  static OutlineInputBorder _border(
    double radius,
    Color color, [
    double width = 1,
  ]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(radius),
    borderSide: BorderSide(color: color, width: width),
  );

  static final InputDecorationTheme light = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.lightSurface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: _border(12, AppColors.lightBorderStrong),
    enabledBorder: _border(12, AppColors.lightBorderStrong),
    focusedBorder: _border(12, AppColors.lightPrimary, 2),
    errorBorder: _border(12, AppColors.dangerContainer),
    focusedErrorBorder: _border(12, AppColors.dangerContainer, 2),
    hintStyle: AppTextTheme.base.bodyMedium!.copyWith(
      color: AppColors.lightHint,
    ),
  );

  static final InputDecorationTheme dark = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkInputFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: _border(12, Colors.transparent),
    enabledBorder: _border(12, Colors.transparent),
    disabledBorder: _border(12, Colors.transparent),
    focusedBorder: _border(12, AppColors.darkPrimary, 1.5),
    errorBorder: _border(12, AppColors.danger),
    focusedErrorBorder: _border(12, AppColors.danger, 1.5),
    hintStyle: AppTextTheme.base.bodyLarge!.copyWith(
      color: AppColors.darkHint,
      fontWeight: FontWeight.w400,
    ),
    prefixIconColor: WidgetStateColor.resolveWith(
      (states) => states.contains(WidgetState.focused)
          ? AppColors.darkOnSurface
          : AppColors.darkHint,
    ),
    suffixIconColor: WidgetStateColor.resolveWith(
      (states) => states.contains(WidgetState.focused)
          ? AppColors.darkOnSurface
          : AppColors.darkHint,
    ),
  );
}
