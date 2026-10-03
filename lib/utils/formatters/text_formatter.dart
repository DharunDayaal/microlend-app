class TextFormatter {
  TextFormatter._();

  /// "ravi kumar" -> "Ravi Kumar"
  static String titleCase(String input) {
    return input
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  /// "Ravi Kumar" -> "RK" (avatar fallback)
  static String initials(String name, {int max = 2}) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.take(max).map((w) => w[0].toUpperCase()).join();
  }

  /// For label styles: "due today" -> "DUE TODAY"
  static String label(String input) => input.toUpperCase();

  /// "PARTIAL" / "PAID_OFF" -> "Partial" / "Paid Off"
  static String enumLabel(String value) =>
      titleCase(value.replaceAll('_', ' '));

  /// "Very long name here" -> "Very long na..."
  static String truncate(String input, int maxChars) =>
      input.length <= maxChars ? input : '${input.substring(0, maxChars)}...';
}