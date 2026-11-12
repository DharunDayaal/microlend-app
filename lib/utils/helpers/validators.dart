import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/utils/formatters/phone_formatter.dart';

class AppValidators {
  AppValidators._();

  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Name is required';
    if (v.length < 2) return 'Name is too short';
    if (!RegExp(r"^[A-Za-z .'-]+$").hasMatch(v)) {
      return 'Name can only contain letters, spaces, and certain punctuation';
    }
    return null;
  }

  static String? phone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Phone number is required';
    if (!PhoneFormatter.isValid(v)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  static String? otp(String? value, {int length = 6}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'OTP is required';
    if (!RegExp('^\\d{$length}\$').hasMatch(v)) {
      return 'Enter the $length-digit OTP';
    }
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? password(String? value, {int minLength = 8}) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';

    final List<String> missingRequirements = [];

    if (v.length < minLength) missingRequirements.add('$minLength+ chars');
    if (!RegExp(r'[A-Z]').hasMatch(v)) missingRequirements.add('uppercase');
    if (!RegExp(r'[0-9]').hasMatch(v)) missingRequirements.add('number');
    if (!RegExp(r'[!@#\$&*~_+-=]|\p{P}').hasMatch(v)) {
      missingRequirements.add('special char');
    }

    if (missingRequirements.isNotEmpty) {
      return 'Missing: ${missingRequirements.join(", ")}';
    }

    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  /// Works with the formatted text from AmountInputFormatter ("12,50,000").
  static String? amount(String? value, {double? min, double? max}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Amount is required';
    final n = CurrencyFormatter.parse(v);
    if (n <= 0) return 'Enter an amount greater than 0';
    if (min != null && n < min) {
      return 'Minimum is ${CurrencyFormatter.format(min)}';
    }
    if (max != null && n > max) {
      return 'Maximum is ${CurrencyFormatter.format(max)}';
    }
    return null;
  }

  /// For fee % and interest % fields.
  static String? percentage(String? value, {double max = 100}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Percentage is required';
    final n = double.tryParse(v);
    if (n == null) return 'Enter a valid number';
    if (n < 0 || n > max) return 'Enter a value between 0 and ${max.toInt()}';
    return null;
  }

  /// For total months (e.g. 2.5).
  static String? positiveNumber(String? value, [String field = 'Value']) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '$field is required';
    final n = double.tryParse(v);
    if (n == null || n <= 0) return 'Enter a valid number greater than 0';
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
