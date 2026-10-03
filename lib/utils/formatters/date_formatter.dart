import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _dMMMy = DateFormat('dd MMM yyyy'); // 03 Oct 2026
  static final DateFormat _dMy = DateFormat('dd/MM/yyyy'); // 03/10/2026
  static final DateFormat _dMMM = DateFormat('dd MMM'); // 03 Oct
  static final DateFormat _weekdayDate = DateFormat('EEE, dd MMM'); // Sat, 03 Oct
  static final DateFormat _monthYear = DateFormat('MMMM yyyy'); // October 2026
  static final DateFormat _time = DateFormat('hh:mm a'); // 11:56 AM
  static final DateFormat _apiDate = DateFormat('yyyy-MM-dd'); // 2026-10-03

  /// Accepts DateTime, ISO String or null. Always returns local time.
  static DateTime? parse(dynamic value) {
    if (value is DateTime) return value.toLocal();
    if (value is String) return DateTime.tryParse(value)?.toLocal();
    return null;
  }

  static String date(dynamic value, {String fallback = '-'}) {
    final d = parse(value);
    return d == null ? fallback : _dMMMy.format(d);
  }

  static String dateSlash(dynamic value, {String fallback = '-'}) {
    final d = parse(value);
    return d == null ? fallback : _dMy.format(d);
  }

  static String dayMonth(dynamic value, {String fallback = '-'}) {
    final d = parse(value);
    return d == null ? fallback : _dMMM.format(d);
  }

  static String weekdayDate(dynamic value, {String fallback = '-'}) {
    final d = parse(value);
    return d == null ? fallback : _weekdayDate.format(d);
  }

  static String monthYear(dynamic value, {String fallback = '-'}) {
    final d = parse(value);
    return d == null ? fallback : _monthYear.format(d);
  }

  static String time(dynamic value, {String fallback = '-'}) {
    final d = parse(value);
    return d == null ? fallback : _time.format(d);
  }

  /// 03 Oct 2026, 11:56 AM
  static String dateTime(dynamic value, {String fallback = '-'}) {
    final d = parse(value);
    return d == null ? fallback : '${_dMMMy.format(d)}, ${_time.format(d)}';
  }

  /// MON, TUE ... (weekday filter pills)
  static String weekdayShort(dynamic value, {String fallback = '-'}) {
    final d = parse(value);
    return d == null ? fallback : DateFormat('EEE').format(d).toUpperCase();
  }

  /// "Today", "Yesterday", "Tomorrow", "in 3 days", "3 days ago",
  /// or the full date when more than 30 days away.
  static String relative(dynamic value, {String fallback = '-'}) {
    final d = parse(value);
    if (d == null) return fallback;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    if (diff > 1 && diff <= 30) return 'in $diff days';
    if (diff < -1 && diff >= -30) return '${-diff} days ago';
    return _dMMMy.format(d);
  }

  /// For sending to the backend: 2026-10-03
  static String toApiDate(DateTime d) => _apiDate.format(d);

  /// For sending to the backend: 2026-10-03T06:26:00.000Z
  static String toApiTimestamp(DateTime d) => d.toUtc().toIso8601String();
}