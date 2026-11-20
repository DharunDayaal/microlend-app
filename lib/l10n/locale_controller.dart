import 'package:flutter/material.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lets us show the one-time notice without a BuildContext.
final rootMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Holds the app language.
/// - Until the user picks a language, the app follows the phone: Tamil if it is
///   the top preferred language, English otherwise (checked on every launch).
/// - Once the user picks one in the Language sheet, that choice wins.
class LocaleController extends ChangeNotifier {
  LocaleController._();
  static final LocaleController instance = LocaleController._();

  static const supported = [Locale('en'), Locale('ta')];

  // new key: the old 'app_language' held auto-detected values, so it is ignored
  static const _kChosen = 'app_language_user';
  static const _kNotice = 'app_language_notice_shown';

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  bool _userChosen = false;
  bool _pendingNotice = false;

  static bool _isSupported(String? code) =>
      supported.any((l) => l.languageCode == code);

  /// Call once in main() before runApp.
  Future<void> init() async {
    try {
      final p = await SharedPreferences.getInstance();
      final chosen = p.getString(_kChosen);
      final device = WidgetsBinding.instance.platformDispatcher.locales;

      if (_isSupported(chosen)) {
        _userChosen = true;
        _locale = Locale(chosen!);
        return;
      }

      // no manual choice yet: follow the phone's top preferred language
      final isTamil = device.isNotEmpty && device.first.languageCode == 'ta';
      _locale = Locale(isTamil ? 'ta' : 'en');
      _pendingNotice = isTamil && !(p.getBool(_kNotice) ?? false);
    } catch (e) {
      debugPrint('LocaleController.init failed: $e');
    }
  }

  /// Called from the Language sheet. This is the user's own choice.
  Future<void> setLocale(Locale l) async {
    if (!_isSupported(l.languageCode)) return;

    final changed = l.languageCode != _locale.languageCode;
    if (!changed && _userChosen) return;

    _locale = l;
    _userChosen = true;
    if (changed) notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_kChosen, l.languageCode);
    } catch (_) {}
  }

  bool get hasPendingNotice => _pendingNotice;

  Future<void> markNoticeShown() async {
    _pendingNotice = false;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kNotice, true);
    } catch (_) {}
  }
}

/// Shows "your phone is set to Tamil" once, ever.
Future<void> showDeviceLanguageNotice([int attempt = 0]) async {
  final c = LocaleController.instance;
  if (!c.hasPendingNotice) return;

  final messenger = rootMessengerKey.currentState;
  if (messenger == null) {
    if (attempt < 5) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return showDeviceLanguageNotice(attempt + 1);
    }
    return; // not marked as shown, so the next launch tries again
  }

  final l = lookupAppLocalizations(const Locale('ta'));
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          l.deviceLanguageNotice,
          style: const TextStyle(color: AppColors.darkOnSurface),
        ),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 8),
        margin: const EdgeInsets.all(AppSizes.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          side: const BorderSide(color: AppColors.stepCurrentLabel),
        ),
        action: SnackBarAction(
          label: l.commonOk,
          textColor: AppColors.stepCurrentLabel,
          onPressed: () {},
        ),
      ),
    );
  await c.markNoticeShown();
}
