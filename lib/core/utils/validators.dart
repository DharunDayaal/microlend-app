import 'package:flutter/widgets.dart';
import 'package:micro_lending_app/core/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/phone_formatter.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';

/// Form validators with translated messages. Screens use
/// `context.validators.email` and so on.
extension ValidatorsContext on BuildContext {
  AppValidators get validators => AppValidators(AppLocalizations.of(this));
}

class AppValidators {
  final AppLocalizations l;
  const AppValidators(this.l);

  String? required(String? value, [String? field]) {
    if (value == null || value.trim().isEmpty) {
      return l.valRequired(field ?? l.valThisField);
    }
    return null;
  }

  String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l.valNameRequired;
    if (v.length < 2) return l.valNameShort;
    if (!RegExp(r"^[A-Za-z .'-]+$").hasMatch(v)) return l.valNameChars;
    return null;
  }

  String? phone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l.valPhoneRequired;
    if (!PhoneFormatter.isValid(v)) return l.valPhoneInvalid;
    return null;
  }

  String? otp(String? value, {int length = 6}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l.valOtpRequired;
    if (!RegExp('^\\d{$length}\$').hasMatch(v)) return l.valOtpLength(length);
    return null;
  }

  String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l.valEmailRequired;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
      return l.valEmailInvalid;
    }
    return null;
  }

  /// Strength rules for a new password (sign up, reset). Signing in only
  /// needs [required]: older accounts may predate these rules.
  String? password(String? value, {int minLength = 8}) {
    final v = value ?? '';
    if (v.isEmpty) return l.valPasswordRequired;

    final missing = <String>[
      if (v.length < minLength) l.valMinChars(minLength),
      if (!RegExp(r'[A-Z]').hasMatch(v)) l.valUppercase,
      if (!RegExp(r'[0-9]').hasMatch(v)) l.valNumber,
      if (!RegExp(r'[!@#\$&*~_+-=]|\p{P}').hasMatch(v)) l.valSpecialChar,
    ];
    return missing.isEmpty ? null : l.valPasswordMissing(missing.join(', '));
  }

  String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return l.valConfirmPassword;
    if (value != original) return l.valPasswordsMismatch;
    return null;
  }

  /// Works with the formatted text from AmountInputFormatter ("12,50,000").
  String? amount(String? value, {double? min, double? max}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l.valAmountRequired;
    final n = CurrencyFormatter.parse(v);
    if (n <= 0) return l.valAmountPositive;
    if (min != null && n < min) {
      return l.valAmountMin(CurrencyFormatter.format(min));
    }
    if (max != null && n > max) {
      return l.valAmountMax(CurrencyFormatter.format(max));
    }
    return null;
  }

  /// For fee % and interest % fields.
  String? percentage(String? value, {double max = 100}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l.valPercentRequired;
    final n = double.tryParse(v);
    if (n == null) return l.valNumberInvalid;
    if (n < 0 || n > max) return l.valPercentRange(max.toInt());
    return null;
  }

  /// For total months (e.g. 2.5).
  String? positiveNumber(String? value, [String? field]) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l.valRequired(field ?? l.valValue);
    final n = double.tryParse(v);
    if (n == null || n <= 0) return l.valPositiveNumber;
    return null;
  }

  /// Combine several validators: validators: [..] run in order, first error wins.
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final v in validators) {
        final error = v(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
