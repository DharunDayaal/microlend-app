import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';

/// Live Indian grouping while typing: 1250000 -> 12,50,000 (whole rupees only).
/// Read the value back with: CurrencyFormatter.parse(controller.text)
class AmountInputFormatter extends TextInputFormatter {
  final int maxDigits;
  const AmountInputFormatter({this.maxDigits = 9});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');

    if (digits.length > maxDigits) digits = digits.substring(0, maxDigits);
    digits = digits.replaceFirst(
      RegExp(r'^0+(?=\d)'),
      '',
    ); // strip leading zeros

    final text = CurrencyFormatter.groupIndian(digits);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class AppInputFormatters {
  AppInputFormatters._();

  static final List<TextInputFormatter> amount = [const AmountInputFormatter()];

  static final List<TextInputFormatter> phone = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
  ];

  static final List<TextInputFormatter> otp = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(6),
  ];
}

/// Shows "5%", "12.5%" while typing. The cursor stays before the % sign.
/// Digits and one decimal point only, limited to [maxDecimals] places and [max].
class PercentInputFormatter extends TextInputFormatter {
  final int maxDecimals;
  final double max;

  const PercentInputFormatter({this.maxDecimals = 2, this.max = 100});

  /// "12.5%" -> 12.5 (use this when sending the value to the API)
  static double parse(String text) =>
      double.tryParse(text.replaceAll('%', '').trim()) ?? 0;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var raw = newValue.text;

    // Backspace pressed with the cursor after the "%": remove the last digit.
    if (oldValue.text.endsWith('%') &&
        !raw.contains('%') &&
        raw.length < oldValue.text.length) {
      raw = raw.isEmpty ? '' : raw.substring(0, raw.length - 1);
    }

    var cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    if (maxDecimals == 0) cleaned = cleaned.replaceAll('.', '');

    // Keep only the first dot, and limit the decimal places.
    final dot = cleaned.indexOf('.');
    if (dot != -1) {
      cleaned =
          cleaned.substring(0, dot + 1) +
          cleaned.substring(dot + 1).replaceAll('.', '');
      final decimals = cleaned.length - dot - 1;
      if (decimals > maxDecimals) {
        cleaned = cleaned.substring(0, dot + 1 + maxDecimals);
      }
    }

    if (cleaned.startsWith('.')) cleaned = '0$cleaned';
    cleaned = cleaned.replaceFirst(RegExp(r'^0+(?=\d)'), ''); // "05" -> "5"

    if (cleaned.isEmpty) return const TextEditingValue();

    final number = double.tryParse(cleaned);
    if (number == null || number > max) return oldValue; // ignore the keystroke

    return TextEditingValue(
      text: '$cleaned%',
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
  }
}

class ProgressiveDecimalFormatter extends TextInputFormatter {
  final int decimalPlaces;
  final double? max; // optional upper limit, e.g. 60 months

  const ProgressiveDecimalFormatter({this.decimalPlaces = 1, this.max});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Let the field be emptied
    if (newValue.text.isEmpty) return newValue;

    // Digits and dots only (a comma from some keyboards counts as a dot)
    var text = newValue.text
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'[^0-9.]'), '');

    // Keep only the first dot
    final firstDot = text.indexOf('.');
    if (firstDot != -1) {
      text =
          text.substring(0, firstDot + 1) +
          text.substring(firstDot + 1).replaceAll('.', '');
    }

    // No decimals allowed: drop the dot and anything after it
    if (decimalPlaces == 0) {
      text = text.split('.').first;
    } else if (firstDot != -1) {
      final decimals = text.length - firstDot - 1;
      if (decimals > decimalPlaces) {
        final typedAtEnd =
            newValue.text.length > oldValue.text.length &&
            newValue.selection.baseOffset == newValue.text.length;
        text = typedAtEnd
            // "3.0" + "5" -> "3.5": the new digit replaces the last decimal
            ? text.substring(0, firstDot + decimalPlaces) +
                  text.substring(text.length - 1)
            : text.substring(0, firstDot + 1 + decimalPlaces);
      }
    }

    // ".5" -> "0.5"
    if (text.startsWith('.')) text = '0$text';

    // "05" -> "5", but keep "0" and "0.51
    text = text.replaceFirst(RegExp(r'^0+(?=\d)'), '');

    if (text.isEmpty) return const TextEditingValue();

    // Reject a keystroke that goes over the maximum
    final value = double.tryParse(text);
    if (max != null && value != null && value > max!) return oldValue;

    // Keep the cursor where the user was typing
    final removed = newValue.text.length - text.length;
    final offset = (newValue.selection.baseOffset - removed).clamp(
      0,
      text.length,
    );

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
