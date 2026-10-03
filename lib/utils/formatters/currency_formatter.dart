import 'package:intl/intl.dart';
import 'package:micro_lending_app/utils/constants/app_constants.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _whole = NumberFormat.currency(
    locale: AppConstants.currencyLocale,
    symbol: AppConstants.currencySymbol,
    decimalDigits: 0,
  );

  static final NumberFormat _decimal = NumberFormat.currency(
    locale: AppConstants.currencyLocale,
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
  );

  static final NumberFormat _plain = NumberFormat.decimalPattern(
    AppConstants.currencyLocale,
  );

  static String _trim(double v) {
    final s = v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  /// Postgres NUMERIC often arrives from the API as a String ("11000.00").
  /// This accepts num, String or null safely.
  static num toNum(dynamic value) {
    if (value is num) {
      return value;
    }
    if (value is String) {
      return num.tryParse(value) ?? 0;
    }
    return 0;
  }

  /// ₹11,000
  static String format(dynamic amount) => _whole.format((toNum(amount)));

  /// ₹11,000.50
  static String formatWithDecimals(dynamic amount) =>
      _decimal.format(toNum(amount));

  /// ₹11,000 if whole, ₹11,000.50 if it has paise.
  static String formatSmart(dynamic amount) {
    final num = toNum(amount);
    return num == num.truncate() ? format(num) : formatWithDecimals(num);
  }

  /// 11,000 (no symbol)
  static String plain(dynamic amount) => _plain.format(toNum(amount));

  /// ₹1.2K, ₹3.5L, ₹1.2Cr (for dashboard tiles)
  static String compact(dynamic amount) {
    final n = toNum(amount).toDouble();
    final abs = n.abs();
    final sign = n < 0 ? '-' : '';
    final s = AppConstants.currencySymbol;

    if (abs >= 1e7) return '$sign$s${_trim(abs / 1e7)}Cr';
    if (abs >= 1e5) return '$sign$s${_trim(abs / 1e5)}L';
    if (abs >= 1e3) return '$sign$s${_trim(abs / 1e3)}K';
    return format(n);
  }

  /// "₹1,250" or "1,250" -> 1250.0
  static double parse(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  /// Indian grouping on a digits-only string: "1234567" -> "12,34,567"
  static String groupIndian(String digits) {
    if (digits.length <= 3) return digits;
    final last3 = digits.substring(digits.length - 3);
    var rest = digits.substring(0, digits.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return '${parts.join(',')},$last3';
  }
}
