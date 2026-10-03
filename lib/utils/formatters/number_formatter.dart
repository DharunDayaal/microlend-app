class NumberFormatter {
  NumberFormatter._();

  /// 5 -> "5%", 2.5 -> "2.5%"
  static String percent(dynamic value) {
    final n = value is num ? value : num.tryParse('$value') ?? 0;
    final s = n == n.truncate() ? n.toInt().toString() : n.toString();
    return '$s%';
  }

  /// "Week 3 of 10"
  static String weekOf(int week, int totalWeeks) =>
      'Week $week of $totalWeeks';

  /// "Week 3"
  static String week(int week) => 'Week $week';

  /// 1 -> "1st", 2 -> "2nd", 3 -> "3rd", 11 -> "11th"
  static String ordinal(int n) {
    final mod100 = n % 100;
    if (mod100 >= 11 && mod100 <= 13) return '${n}th';
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }

  /// 7 -> "07" (installment numbers in ledger rows)
  static String pad2(int n) => n.toString().padLeft(2, '0');

  /// 3, 10 -> 0.3 (for progress bars)
  static double progress(num done, num total) =>
      total <= 0 ? 0 : (done / total).clamp(0, 1).toDouble();

  /// uuid -> "#A1B2C3D4" (short loan / customer reference)
  static String shortId(String uuid) {
    final clean = uuid.replaceAll('-', '');
    final take = clean.length < 8 ? clean.length : 8;
    return '#${clean.substring(0, take).toUpperCase()}';
  }
}