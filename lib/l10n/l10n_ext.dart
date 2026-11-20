import 'package:flutter/widgets.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';

/// Short access to the app strings: `context.l10n.commonSave`.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
