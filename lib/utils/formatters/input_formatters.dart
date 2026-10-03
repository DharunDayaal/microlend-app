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
    digits = digits.replaceFirst(RegExp(r'^0+(?=\d)'), ''); // strip leading zeros

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