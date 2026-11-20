// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get languageTitle => 'மொழி';

  @override
  String get languageSubtitle => 'செயலியின் மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTamil => 'தமிழ்';

  @override
  String get deviceLanguageNotice =>
      'உங்கள் தொலைபேசியில் தமிழ் விருப்ப மொழியாக உள்ளது, அதனால் செயலி தமிழில் திறக்கப்பட்டுள்ளது. சுயவிவர மெனுவில் உள்ள \'மொழி\' பகுதியில் இதை மாற்றலாம்.';

  @override
  String get commonOk => 'சரி';

  @override
  String get commonCancel => 'ரத்து செய்';

  @override
  String get commonSave => 'சேமி';

  @override
  String get commonClose => 'மூடு';

  @override
  String get commonRetry => 'மீண்டும் முயற்சி';

  @override
  String daysLate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count நாட்கள் தாமதம்',
      one: '1 நாள் தாமதம்',
    );
    return '$_temp0';
  }
}
