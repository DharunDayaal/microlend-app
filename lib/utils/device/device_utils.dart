import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeviceUtils {
  DeviceUtils._();

  // ---------- KEYBOARD ----------
  static bool isKeyboardOpen(BuildContext c) =>
      MediaQuery.viewInsetsOf(c).bottom > 0;

  static void hideKeyboard(BuildContext c) =>
      FocusManager.instance.primaryFocus?.unfocus();

  // ---------- HAPTICS ----------
  static Future<void> tap() => HapticFeedback.selectionClick();
  static Future<void> success() => HapticFeedback.mediumImpact(); // after saving an entry
  static Future<void> error() => HapticFeedback.vibrate(); // validation failure

  // ---------- CLIPBOARD ----------
  static Future<void> copy(String text) =>
      Clipboard.setData(ClipboardData(text: text));

  // ---------- ORIENTATION ----------
  static Future<void> lockPortrait() =>
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // ---------- STATUS BAR ----------
  static void setSystemBars({required bool isDark}) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
  }
}