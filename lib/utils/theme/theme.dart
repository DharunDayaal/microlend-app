import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/app_constants.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/theme/custom_themes/appbar_theme.dart';
import 'package:micro_lending_app/utils/theme/custom_themes/card_theme.dart';
import 'package:micro_lending_app/utils/theme/custom_themes/checkbox_theme.dart';
import 'package:micro_lending_app/utils/theme/custom_themes/colors_theme.dart';
import 'package:micro_lending_app/utils/theme/custom_themes/elevated_button_theme.dart';
import 'package:micro_lending_app/utils/theme/custom_themes/input_decoration_theme.dart';
import 'package:micro_lending_app/utils/theme/custom_themes/outlined_button_theme.dart';
import 'package:micro_lending_app/utils/theme/custom_themes/status_colors.dart';
import 'package:micro_lending_app/utils/theme/custom_themes/text_theme.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: AppConstants.fontFamily,
    brightness: Brightness.light,
    colorScheme: AppColorTheme.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    dividerColor: AppColors.lightBorder,
    textTheme: AppTextTheme.lightTextTheme,
    appBarTheme: AppAppBarTheme.light,
    cardTheme: AppCardTheme.light,
    elevatedButtonTheme: AppElevatedButtonTheme.light,
    outlinedButtonTheme: AppOutlinedButtonTheme.light,
    inputDecorationTheme: AppInputDecorationTheme.light,
    checkboxTheme: AppCheckboxTheme.light,
    extensions: const [StatusColors.light],
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    colorScheme: AppColorTheme.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    dividerColor: AppColors.darkBorder,
    textTheme: AppTextTheme.darkTextTheme,
    appBarTheme: AppAppBarTheme.dark,
    cardTheme: AppCardTheme.dark,
    elevatedButtonTheme: AppElevatedButtonTheme.dark,
    outlinedButtonTheme: AppOutlinedButtonTheme.dark,
    inputDecorationTheme: AppInputDecorationTheme.dark,
    checkboxTheme: AppCheckboxTheme.dark,
    extensions: const [StatusColors.dark],
  );
}
