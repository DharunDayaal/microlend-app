import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/shared/design_system/styles/spacing_style.dart';
import 'package:micro_lending_app/shared/widgets/app_button.dart';
import 'package:micro_lending_app/shared/widgets/app_status_chip.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';
import 'package:micro_lending_app/shared/design_system/constants/alphas.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';
import 'package:micro_lending_app/core/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/number_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/features/loans/domain/loan_helper.dart';

enum RepaymentRowState { paid, partial, missed, scheduled, upcoming }

/// One row of the list: a real track, or a placeholder for a week
/// that has no track yet.
class RepaymentRow {
  final int week;
  final LoanTrackModel? track;
  final double target;
  final double collected;
  final DateTime due;
  final RepaymentRowState state;
  final bool isExtension; // week number is past the loan's term

  const RepaymentRow({
    required this.week,
    required this.track,
    required this.target,
    required this.collected,
    required this.due,
    required this.state,
    required this.isExtension,
  });

  double get remaining => math.max(0, target - collected);
}

class RepaymentRows {
  RepaymentRows._();

  /// The week "Record weekly payment" opens: the next scheduled week, the
  /// first one due today or later, and never one at or before the latest
  /// week that has money against it. Missed weeks are not back-filled from
  /// here; they stay unpaid until collected with their own Collect button.
  /// Past the term this keeps counting (13, 14, ...) as overdue weeks.
  static int nextNewWeek(
    List<LoanTrackModel> tracks, {
    required DateTime issuedAt,
    DateTime? now,
  }) {
    final afterLatestPayment =
        tracks
            .where(
              (t) =>
                  t.totalCollected > 0 ||
                  const {'PAID', 'PARTIAL'}.contains(t.status.toUpperCase()),
            )
            .fold<int>(0, (last, t) => math.max(last, t.weekNumber)) +
        1;

    final n = now ?? DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    var scheduled = 1;
    while (LoanHelper.dueDateForWeek(issuedAt, scheduled).isBefore(today)) {
      scheduled++;
    }
    return math.max(afterLatestPayment, scheduled);
  }

  static List<RepaymentRow> fromLoan(LoanModel loan) => build(
    tracks: loan.tracks,
    totalWeeks: loan.totalWeeks,
    issuedAt: loan.issuedAt,
    isOverdueLoan: loan.isOverdueNow,
    weeklyAmount: loan.weeklyPayableAmount,
  );

  static List<RepaymentRow> build({
    required List<LoanTrackModel> tracks,
    required int totalWeeks,
    required DateTime issuedAt,
    required bool isOverdueLoan,
    double? weeklyAmount,
  }) {
    final byWeek = {for (final t in tracks) t.weekNumber: t};
    final lastWeek = byWeek.keys.fold<int>(0, (a, b) => math.max(a, b));
    final lastTrack = byWeek[lastWeek];

    // placeholder and extension weeks copy the amount from the last track
    final fallbackTarget = lastTrack?.targetAmount ?? weeklyAmount ?? 0.0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final issued = DateTime(issuedAt.year, issuedAt.month, issuedAt.day);

    // For an overdue loan, every due date past the term becomes an overdue row.
    final elapsedWeeks = today.difference(issued).inDays ~/ 7;
    final extensionEnd = isOverdueLoan ? elapsedWeeks : 0;
    final endWeek = math.max(math.max(totalWeeks, lastWeek), extensionEnd);

    var scheduledTaken = false;
    final rows = <RepaymentRow>[];

    for (var week = 1; week <= endWeek; week++) {
      final track = byWeek[week];
      final due = LoanHelper.dueDateForWeek(issuedAt, week);
      final status = (track?.status ?? 'UNPAID').toUpperCase();
      final isExtension = week > totalWeeks;

      RepaymentRowState state;
      if (status == 'PAID') {
        state = RepaymentRowState.paid;
      } else if (status == 'PARTIAL') {
        state = RepaymentRowState.partial;
      } else if (isExtension || due.isBefore(today)) {
        state = RepaymentRowState.missed;
      } else if (!scheduledTaken) {
        scheduledTaken = true;
        state = RepaymentRowState.scheduled;
      } else {
        state = RepaymentRowState.upcoming;
      }

      rows.add(
        RepaymentRow(
          week: week,
          track: track,
          target: track?.targetAmount ?? fallbackTarget,
          collected: track?.totalCollected ?? 0,
          due: due,
          state: state,
          isExtension: isExtension,
        ),
      );
    }
    return rows;
  }
}

class RepaymentTrackCard extends StatelessWidget {
  final RepaymentRow row;
  final int totalWeeks;

  /// Set it to show a "Collect" button. It only ever appears on partial rows.
  final VoidCallback? onCollect;

  const RepaymentTrackCard({
    super.key,
    required this.row,
    required this.totalWeeks,
    this.onCollect,
  });

  String _join(List<String?> parts) =>
      parts.where((p) => p != null && p.isNotEmpty).join(' • ');

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l = context.l10n;
    const muted = AppColors.darkOnSurfaceMuted;

    final track = row.track;
    final ref = track == null ? null : TextFormatter.dummyId(track.id, 'TRK');
    final remaining = CurrencyFormatter.format(row.remaining);

    final unpaid =
        row.state == RepaymentRowState.missed ||
        row.state == RepaymentRowState.scheduled ||
        row.state == RepaymentRowState.upcoming;

    String chipLabel;
    Color chipBg;
    Color chipFg;
    IconData? chipIcon;
    String? sub;
    String? right;
    Color rightColor = muted;
    Color? tint;
    Color? border;
    double opacity = 1;

    switch (row.state) {
      case RepaymentRowState.paid:
        chipLabel = l.statusPaid;
        chipBg = AppColors.successContainer;
        chipFg = Colors.white;
        sub = _join([ref, l.trackDueOn(DateFormatter.dayMonth(row.due))]);
        right = l.trackPaidInFull;
        rightColor = AppColors.success;
        tint = AppColors.darkRim.withAlpha(AppAlphas.badgeFill);
      case RepaymentRowState.partial:
        chipLabel = l.statusPartial;
        chipBg = AppColors.approvalGlowWarm;
        chipFg = AppColors.progressWarning;
        chipIcon = Icons.schedule;
        sub = ref;
        right = l.trackDueToClear(remaining);
        rightColor = AppColors.warning;
        tint = AppColors.warning.withAlpha(AppAlphas.watermark);
        border = AppColors.warning.withAlpha(AppAlphas.borderTint);
      case RepaymentRowState.missed:
        chipLabel = l.statusUnpaid;
        chipBg = AppColors.dangerContainer.withAlpha(AppAlphas.borderTint);
        chipFg = AppColors.progressDanger;
        sub = _join([ref, l.trackNotCollected]);
        right = l.trackPending(remaining);
        rightColor = AppColors.progressDanger;
        tint = AppColors.darkRim.withAlpha(AppAlphas.badgeFill);
      case RepaymentRowState.scheduled:
        chipLabel = l.statusScheduled;
        chipBg = AppColors.darkBorder;
        chipFg = AppColors.darkOnSurface;
        sub = l.trackDueOn(DateFormatter.weekdayDate(row.due));
        right = l.trackUpcoming;
        rightColor = AppColors.stepCurrentLabel;
        tint = AppColors.darkRim.withAlpha(AppAlphas.badgeFill);
      case RepaymentRowState.upcoming:
        chipLabel = l.statusUpcoming;
        chipBg = AppColors.darkBorder.withAlpha(AppAlphas.badgeFill);
        chipFg = muted;
        opacity = 0.6;
    }

    // weeks past the loan's term are overdue, paid or not
    if (row.isExtension) {
      if (!unpaid) sub = _join([sub, l.trackPastTerm(totalWeeks)]);
      border = AppColors.dangerContainer;
      tint = AppColors.dangerContainer.withAlpha(AppAlphas.watermark);
      opacity = 1;
      if (unpaid) {
        chipLabel = l.statusOverdue;
        chipBg = AppColors.dangerContainer;
        chipFg = Colors.white;
        chipIcon = null;
        sub = _join([ref, l.trackPastTerm(totalWeeks)]);
        right = l.trackOverdueAmount(remaining);
        rightColor = AppColors.progressDanger;
      }
    }

    final isPartial = row.state == RepaymentRowState.partial;
    final canCollect =
        row.state == RepaymentRowState.partial ||
        row.state == RepaymentRowState.missed;

    final weekBg = row.isExtension
        ? AppColors.dangerContainer
        : isPartial
        ? AppColors.approvalGlowWarm
        : AppColors.darkBorder;
    final weekFg = row.isExtension
        ? Colors.white
        : isPartial
        ? AppColors.progressWarning
        : AppColors.darkOnSurface;

    final amountStyle = text.headlineSmall?.copyWith(
      fontWeight: FontWeight.w800,
    );
    final dateStyle = text.bodyMedium?.copyWith(color: muted);

    final amountSpans = isPartial
        ? [
            TextSpan(
              text: CurrencyFormatter.format(row.collected),
              style: amountStyle?.copyWith(color: AppColors.warning),
            ),
            TextSpan(
              text: ' / ${CurrencyFormatter.format(row.target)}',
              style: dateStyle,
            ),
          ]
        : [
            TextSpan(
              text: CurrencyFormatter.format(row.target),
              style: amountStyle,
            ),
          ];

    const chipPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 3);

    return Opacity(
      opacity: opacity,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm + 2,
        ),
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: border == null ? null : Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppChip(
                  label: l.trackWeekShort(NumberFormatter.pad2(row.week)),
                  backgroundColor: weekBg,
                  foregroundColor: weekFg,
                  borderColor: Colors.transparent,
                  radius: AppSizes.radiusSm,
                  padding: chipPadding,
                  textStyle: text.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppGap.w8,
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        ...amountSpans,
                        TextSpan(
                          text: ' • ${DateFormatter.date(row.due)}',
                          style: dateStyle,
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AppGap.w8,
                AppChip(
                  label: chipLabel,
                  backgroundColor: chipBg,
                  foregroundColor: chipFg,
                  borderColor: Colors.transparent,
                  radius: AppSizes.radiusSm,
                  padding: chipPadding,
                  textStyle: text.labelSmall,
                  leading: chipIcon == null
                      ? null
                      : Icon(chipIcon, size: 12, color: chipFg),
                ),
              ],
            ),
            if (sub != null || right != null) ...[
              const SizedBox(height: AppSizes.xs),
              Row(
                children: [
                  Expanded(
                    child: sub == null
                        ? const SizedBox.shrink()
                        : Text(
                            sub,
                            style: text.labelMedium?.copyWith(color: muted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                  if (right != null) ...[
                    AppGap.w8,
                    Flexible(
                      child: Text(
                        right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: text.labelMedium?.copyWith(
                          color: rightColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
            // partial and missed weeks can be collected from the list
            if (canCollect && onCollect != null) ...[
              const SizedBox(height: AppSizes.sm),
              AppButton(
                label: l.trackCollectAmount(
                  CurrencyFormatter.format(row.remaining),
                ),
                prefixIcon: Icons.payments_outlined,
                height: 40,
                radius: AppSizes.radiusMd,
                onPressed: onCollect,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
