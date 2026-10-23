import 'package:micro_lending_app/data/models/loan_model.dart';

class LoanBreakdown {
  final double principal;
  final double upfrontFee;
  final double disbursedAmount;
  final double totalInterest;
  final double totalPayable;
  final double weeklyPayable;

  const LoanBreakdown({
    required this.principal,
    required this.upfrontFee,
    required this.disbursedAmount,
    required this.totalInterest,
    required this.totalPayable,
    required this.weeklyPayable,
  });
}

class LoanHelper {
  LoanHelper._();

  /// Same rule as the backend: total_weeks = round(total_months * 4)
  static int totalWeeksFromMonths(double months) => (months * 4).round();

  /// Live preview while the admin fills the issue-loan form.
  /// ASSUMPTION: fee and interest are both a percentage of principal;
  /// disbursed = principal - fee; payable = principal + interest.
  /// Change this to match your backend's calculation if it differs.
  static LoanBreakdown breakdown({
    required double principal,
    required double feePercent,
    required double interestPercent,
    required int totalWeeks,
  }) {
    final fee = principal * feePercent / 100;
    final interest = principal * interestPercent / 100;
    final payable = principal + interest;
    return LoanBreakdown(
      principal: principal,
      upfrontFee: fee,
      disbursedAmount: principal - fee,
      totalInterest: interest,
      totalPayable: payable,
      weeklyPayable: totalWeeks > 0 ? payable / totalWeeks : 0,
    );
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Week the loan is currently in (1-based, can go past totalWeeks).
  static int currentWeek(DateTime issuedAt, {DateTime? now}) {
    final days = _dateOnly(now ?? DateTime.now())
        .difference(_dateOnly(issuedAt))
        .inDays;
    return days < 0 ? 1 : (days ~/ 7) + 1;
  }

  /// Due date at the end of a given week.
  static DateTime dueDateForWeek(DateTime issuedAt, int week) =>
      _dateOnly(issuedAt).add(Duration(days: week * 7));

  /// Same rule as the backend read-time check: only an ACTIVE loan with
  /// money outstanding, past issued_at + total_weeks.
  static bool isOverdue({
    required DateTime issuedAt,
    required int totalWeeks,
    required bool isActive,
    required double balance,
    DateTime? now,
  }) {
    if (!isActive || balance <= 0) return false;
    final end = dueDateForWeek(issuedAt, totalWeeks);
    return _dateOnly(now ?? DateTime.now()).isAfter(end);
  }

  /// How many weeks past the loan term. 0 if not overdue.
  static int overdueWeeks(DateTime issuedAt, int totalWeeks, {DateTime? now}) {
    final w = currentWeek(issuedAt, now: now);
    return w > totalWeeks ? w - totalWeeks : 0;
  }

  /// Weeks the frontend should render: 1..totalWeeks, plus extra rows
  /// when overdue.
  static int rowsToShow(DateTime issuedAt, int totalWeeks, {DateTime? now}) {
    final w = currentWeek(issuedAt, now: now);
    return w > totalWeeks ? w : totalWeeks;
  }

  /// "MON", "monday", "Monday" -> DateTime.monday (1). Returns null if unknown.
  static int? weekdayFromName(String name) {
    const map = {
      'mon': DateTime.monday,
      'tue': DateTime.tuesday,
      'wed': DateTime.wednesday,
      'thu': DateTime.thursday,
      'fri': DateTime.friday,
      'sat': DateTime.saturday,
      'sun': DateTime.sunday,
    };
    final key = name.trim().toLowerCase();
    if (key.length < 3) return null;
    return map[key.substring(0, 3)];
  }

  /// Next date (today included) that falls on the given weekday.
  static DateTime nextWeekday(int weekday, {DateTime? from}) {
    final start = _dateOnly(from ?? DateTime.now());
    final diff = (weekday - start.weekday) % 7;
    return start.add(Duration(days: diff));
  }

  /// First unpaid week = the next installment due. null when every week is paid.
  static LoanTrackModel? nextDueTrack(LoanModel loan) {
    final unpaid =
        loan.tracks
            .where((t) => t.status != 'PAID' && t.remainingBalance > 0)
            .toList()
          ..sort((a, b) => a.weekNumber.compareTo(b.weekNumber));
    return unpaid.isEmpty ? null : unpaid.first;
  }

  /// Date the next installment is due, or null when nothing is left to pay.
  static DateTime? nextDueDate(LoanModel loan) {
    final track = nextDueTrack(loan);
    return track == null
        ? null
        : dueDateForWeek(loan.issuedAt, track.weekNumber);
  }

  /// Next day the borrower should pay: their next preferred weekday, today
  /// included. null when nothing is left to pay or the loan isn't active.
  static DateTime? nextPaymentDate(
    LoanModel loan,
    String? preferredDay, {
    DateTime? now,
  }) {
    if (!(loan.status == 'ACTIVE') && loan.status.toUpperCase() != 'OVERDUE') {
      return null;
    }
    if (nextDueTrack(loan) == null) return null;

    final weekday = preferredDay == null ? null : weekdayFromName(preferredDay);
    if (weekday == null) {
      return nextDueDate(loan);
    }
    return nextWeekday(weekday, from: now);
  }

  /// Automatically calculates the next consecutive installment week number.
  /// Works infinitely past the loan term if the borrower is overdue and extending payments.
  static int nextCollectableWeek(List<LoanTrackModel> tracks) {
    if (tracks.isEmpty) {
      return 1; // Brand new loan with no recorded activity starts at Week 1
    }

    // Find the highest week number currently registered in the database tracks
    final maxWeek = tracks
        .map((t) => t.weekNumber)
        .fold<int>(0, (max, current) => current > max ? current : max);

    // The next collectable target is ALWAYS the next consecutive linear step
    return maxWeek + 1;
  }
}
