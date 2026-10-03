class PhoneFormatter {
  PhoneFormatter._();

  static const String countryCode = '+91';

  static String digitsOnly(String input) =>
      input.replaceAll(RegExp(r'\D'), '');

  /// Returns the 10-digit national number.
  /// "+919434587234" -> "9434587234"
  /// "919434587234"  -> "9434587234"
  /// "09434587234"   -> "9434587234"
  /// "9434587234"    -> "9434587234"
  /// Anything else is returned as plain digits, so isValid() fails on it.
  static String normalize(String input) {
    final d = digitsOnly(input);
    if (d.length == 12 && d.startsWith('91')) return d.substring(2);
    if (d.length == 11 && d.startsWith('0')) return d.substring(1);
    return d;
  }

  /// Indian mobile: 10 digits starting with 6-9
  static bool isValid(String input) =>
      RegExp(r'^[6-9]\d{9}$').hasMatch(normalize(input));

  /// "+919434587234" -> "94345 87234"
  static String grouped(String input) {
    final n = normalize(input);
    if (n.length != 10) return input;
    return '${n.substring(0, 5)} ${n.substring(5)}';
  }

  /// "+919434587234" -> "+91 94345 87234"
  static String display(String input) {
    final n = normalize(input);
    return n.length == 10 ? '$countryCode ${grouped(n)}' : input;
  }

  /// "+919434587234" -> "+91 94XXXXX234"
  static String masked(String input) {
    final n = normalize(input);
    if (n.length != 10) return input;
    return '$countryCode ${n.substring(0, 2)}XXXXX${n.substring(7)}';
  }

  /// For the API / OTP: always "+919434587234"
  static String toE164(String input) => '$countryCode${normalize(input)}';
}