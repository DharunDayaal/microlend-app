import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/widgets/repayment_track_list.dart';
import 'package:micro_lending_app/data/models/loan_model.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/helpers/loan_helper.dart';

enum LoanStage { active, overdue, paidOff, closed, defaulted, unknown }

LoanStage loanStageOf(String status) => switch (status.trim().toUpperCase()) {
  'ACTIVE' => LoanStage.active,
  'OVERDUE' => LoanStage.overdue,
  'PAID_OFF' => LoanStage.paidOff,
  'CLOSED' => LoanStage.closed,
  'DEFAULTED' => LoanStage.defaulted,
  _ => LoanStage.unknown,
};

/// How a stage looks. The one place that maps status to label, colour and icon.
class LoanStatusView {
  final String label;
  final Color color;
  final IconData icon;

  /// Open loans (active or overdue) are the ones that take payments.
  final bool isOpen;

  const LoanStatusView({
    required this.label,
    required this.color,
    required this.icon,
    required this.isOpen,
  });

  static LoanStatusView of(LoanStage stage) => switch (stage) {
    LoanStage.active => const LoanStatusView(
      label: 'ACTIVE',
      color: AppColors.success,
      icon: Icons.autorenew_rounded,
      isOpen: true,
    ),
    LoanStage.overdue => const LoanStatusView(
      label: 'OVERDUE',
      color: AppColors.progressDanger,
      icon: Icons.error_outline,
      isOpen: true,
    ),
    LoanStage.paidOff => const LoanStatusView(
      label: 'PAID OFF',
      color: AppColors.success,
      icon: Icons.verified_outlined,
      isOpen: false,
    ),
    LoanStage.closed => const LoanStatusView(
      label: 'CLOSED',
      color: AppColors.darkOnSurfaceMuted,
      icon: Icons.lock_outline,
      isOpen: false,
    ),
    LoanStage.defaulted => const LoanStatusView(
      label: 'DEFAULTED',
      color: AppColors.progressDanger,
      icon: Icons.cancel_outlined,
      isOpen: false,
    ),
    LoanStage.unknown => const LoanStatusView(
      label: 'UNKNOWN',
      color: AppColors.darkOnSurfaceMuted,
      icon: Icons.help_outline,
      isOpen: false,
    ),
  };
}

/// Everything the detail screen shows, derived from one loan.
/// Built fresh on every build, so "today" is never stale.
class LoanSnapshot {
  final LoanModel loan;
  final LoanStage stage;
  final List<RepaymentRow> rows;
  final List<RepaymentRow> owedRows; // open loans only: weeks with money left
  final List<RepaymentRow> pastDueRows; // owed weeks whose date has passed
  final RepaymentRow? nextUpcoming; // first owed week that isn't due yet
  final double overdueAmount; // capped at the outstanding balance
  final int daysLate;
  final int paidWeeks;

  const LoanSnapshot._({
    required this.loan,
    required this.stage,
    required this.rows,
    required this.owedRows,
    required this.pastDueRows,
    required this.nextUpcoming,
    required this.overdueAmount,
    required this.daysLate,
    required this.paidWeeks,
  });

  factory LoanSnapshot.of(LoanModel loan, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    final rows = RepaymentRows.fromLoan(loan);

    var stage = loanStageOf(loan.status);
    if (stage == LoanStage.active && loan.isOverdue) stage = LoanStage.overdue;

    final open = LoanStatusView.of(stage).isOpen;
    bool isPastDue(RepaymentRow r) => r.isExtension || r.due.isBefore(today);

    final owed = open
        ? rows
              .where(
                (r) => r.state != RepaymentRowState.paid && r.remaining > 0,
              )
              .toList()
        : <RepaymentRow>[];
    final pastDue = owed.where(isPastDue).toList();
    final upcoming = owed.where((r) => !isPastDue(r)).firstOrNull;

    final raw = pastDue.fold<double>(0, (sum, r) => sum + r.remaining);
    final overdue = math.min(raw, math.max(0.0, loan.outstandingAmount));

    // The backend only refreshes the status lazily: a past-due week with money
    // left means the loan is overdue, whatever the stored status says.
    if (stage == LoanStage.active && overdue > 0) stage = LoanStage.overdue;

    var daysLate = pastDue.isEmpty
        ? 0
        : today.difference(pastDue.first.due).inDays;
    if (pastDue.isNotEmpty && daysLate < 1) daysLate = 1;

    return LoanSnapshot._(
      loan: loan,
      stage: stage,
      rows: rows,
      owedRows: owed,
      pastDueRows: pastDue,
      nextUpcoming: upcoming,
      overdueAmount: overdue,
      daysLate: daysLate,
      paidWeeks: rows.where((r) => r.state == RepaymentRowState.paid).length,
    );
  }

  LoanStatusView get view => LoanStatusView.of(stage);
  bool get isOpen => view.isOpen;

  /// Oldest week that still has money left. The primary button collects on it.
  RepaymentRow? get firstOwed => owedRows.isEmpty ? null : owedRows.first;

  bool get hasBanner => stage != LoanStage.active && stage != LoanStage.unknown;

  DateTime get maturityDate =>
      LoanHelper.dueDateForWeek(loan.issuedAt, loan.totalWeeks);

  int get hiddenPastDue => math.max(0, pastDueRows.length - 3);

  /// The few rows worth showing on the detail page: what is overdue, what is
  /// next, and the last paid week for context. Closed loans show the last 3.
  List<RepaymentRow> get previewRows {
    if (rows.isEmpty) return const [];
    if (!isOpen) return rows.length <= 3 ? rows : rows.sublist(rows.length - 3);

    final weeks = <int>{};
    for (final r in pastDueRows.take(3)) {
      weeks.add(r.week);
    }
    if (nextUpcoming != null) weeks.add(nextUpcoming!.week);
    if (weeks.length < 3) {
      final lastPaid = rows
          .where((r) => r.state == RepaymentRowState.paid)
          .lastOrNull;
      if (lastPaid != null) weeks.add(lastPaid.week);
    }
    if (weeks.isEmpty) {
      return rows.length <= 3 ? rows : rows.sublist(rows.length - 3);
    }

    return rows.where((r) => weeks.contains(r.week)).toList();
  }
}
