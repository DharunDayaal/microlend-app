import 'package:intl/intl.dart';

DateTime toIst(DateTime t) =>
    t.toUtc().add(const Duration(hours: 5, minutes: 30));

/// A date-only value (UTC midnight) for the IST day of [t].
DateTime istDayOf(DateTime t) {
  final i = toIst(t);
  return DateTime.utc(i.year, i.month, i.day);
}

DateTime istToday() => istDayOf(DateTime.now());

String istTime(DateTime t) => DateFormat('h:mm a').format(toIst(t));
String istShort(DateTime t) =>
    DateFormat('d MMM yyyy, h:mm a').format(toIst(t));
String istFull(DateTime t) =>
    '${DateFormat('EEE d MMM yyyy, h:mm a').format(toIst(t))} IST';
String ymd(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

String dayHeader(DateTime day) {
  final diff = istToday().difference(day).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  final sameYear = day.year == istToday().year;
  return DateFormat(sameYear ? 'EEE d MMM' : 'EEE d MMM yyyy').format(day);
}
