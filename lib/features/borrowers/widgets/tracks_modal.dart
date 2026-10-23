import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_icon_button.dart';
import 'package:micro_lending_app/common/widgets/app_status_chip.dart';
import 'package:micro_lending_app/data/models/loan_model.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/utils/formatters/number_formatter.dart';
import 'package:micro_lending_app/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/utils/helpers/loan_helper.dart';

enum _TrackState { paid, partial, missed, scheduled, upcoming }

/// One row of the list: a real track, or a placeholder for a week
/// that has no track yet.
class _TrackRow {
  final int week;
  final LoanTrackModel? track;
  final double target;
  final double collected;
  final DateTime due;
  final _TrackState state;
  final bool isExtension;

  const _TrackRow({
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

class TracksModal extends StatefulWidget {
  final String customerId;
  final String customerName;
  final String loanId;
  final int totalWeeks;
  final double remainingBalance;
  final List<LoanTrackModel> loanTracks;
  final DateTime issuedAt;
  final bool isOverdueLoan;
  final double? weeklyAmount;

  const TracksModal({
    super.key,
    required this.customerId,
    required this.customerName,
    required this.loanId,
    required this.totalWeeks,
    required this.remainingBalance,
    required this.loanTracks,
    required this.issuedAt,
    this.isOverdueLoan = false,
    this.weeklyAmount,
  });

  static Future<void> show(
    BuildContext context, {
    required String customerId,
    required String customerName,
    required String loanId,
    required int totalWeeks,
    required double remainingBalance,
    required List<LoanTrackModel> loanTracks,
    required DateTime issuedAt,
    bool isOverdueLoan = false,
    double? weeklyAmount,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      useSafeArea: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: TracksModal(
          customerId: customerId,
          customerName: customerName,
          loanId: loanId,
          totalWeeks: totalWeeks,
          remainingBalance: remainingBalance,
          loanTracks: loanTracks,
          issuedAt: issuedAt,
          isOverdueLoan: isOverdueLoan,
          weeklyAmount: weeklyAmount,
        ),
      ),
    );
  }

  @override
  State<TracksModal> createState() => _TracksModalState();
}

class _TracksModalState extends State<TracksModal> {
  List<_TrackRow> _buildRows() {
    final byWeek = {for (final t in widget.loanTracks) t.weekNumber: t};
    final lastWeek = byWeek.keys.fold<int>(0, (a, b) => math.max(a, b));
    final lastTrack = byWeek[lastWeek];

    // placeholder and extension weeks copy the amount from the last track
    final fallbackTarget =
        lastTrack?.targetAmount ?? widget.weeklyAmount ?? 0.0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final issued = DateTime(
      widget.issuedAt.year,
      widget.issuedAt.month,
      widget.issuedAt.day,
    );

    // Week N is due on issued + 7N days, so this is the number of due dates
    // that have already passed. For an overdue loan, every one of them beyond
    // the term becomes an overdue row.
    final elapsedWeeks = today.difference(issued).inDays ~/ 7;
    final extensionEnd = widget.isOverdueLoan ? elapsedWeeks : 0;

    final endWeek = math.max(
      math.max(widget.totalWeeks, lastWeek),
      extensionEnd,
    );

    var scheduledTaken = false;
    final rows = <_TrackRow>[];

    for (var week = 1; week <= endWeek; week++) {
      final track = byWeek[week];
      final due = LoanHelper.dueDateForWeek(widget.issuedAt, week);
      final status = (track?.status ?? 'UNPAID').toUpperCase();
      final isExtension = widget.isOverdueLoan && week > widget.totalWeeks;

      _TrackState state;
      if (status == 'PAID') {
        state = _TrackState.paid;
      } else if (status == 'PARTIAL') {
        state = _TrackState.partial;
      } else if (isExtension || due.isBefore(today)) {
        state = _TrackState.missed; // past the term, or the date has passed
      } else if (!scheduledTaken) {
        scheduledTaken = true; // the next one to collect
        state = _TrackState.scheduled;
      } else {
        state = _TrackState.upcoming;
      }

      rows.add(
        _TrackRow(
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final rows = _buildRows();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppGap.h12,
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.darkRim,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        _trackHeader(textTheme),
        AppGap.h12,
        const Divider(height: 4),
        AppGap.h8,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: _statContainer(textTheme),
        ),
        AppGap.h12,
        Expanded(
          child: rows.isEmpty
              ? Center(
                  child: Text('No tracks found', style: textTheme.bodyMedium),
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.md,
                    0,
                    AppSizes.md,
                    AppSizes.md + MediaQuery.paddingOf(context).bottom,
                  ),
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => AppGap.h8,
                  itemBuilder: (_, i) =>
                      _TrackCard(row: rows[i], totalWeeks: widget.totalWeeks),
                ),
        ),
      ],
    );
  }

  Widget _trackHeader(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.md,
        AppSizes.sm,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.darkPrimary.withAlpha(AppAlphas.badgeFill),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: const Center(child: Icon(Icons.edit_note)),
          ),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: AppSizes.sm,
                  children: [
                    Flexible(
                      child: Text(
                        'Repayment Tracks',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppChip(
                      label: '${widget.totalWeeks} Wks',
                      backgroundColor: AppColors.darkBorder.withAlpha(
                        AppAlphas.badgeFill,
                      ),
                      textStyle: textTheme.labelSmall?.copyWith(
                        color: AppColors.darkPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${widget.customerName} • Active Facility '
                  '${TextFormatter.dummyId(widget.loanId, "#LN")}',
                  style: textTheme.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          AppGap.w8,
          AppIconButton(
            icon: Icons.close,
            color: AppColors.darkOnSurface,
            backgroundColor: AppColors.approvalBase.withAlpha(
              AppAlphas.badgeFill,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _statContainer(TextTheme textTheme) {
    final int totalCompleted = widget.loanTracks
        .where((track) => track.status == 'PAID')
        .length;
    final int totalPartials = widget.loanTracks
        .where((track) => track.status == 'PARTIAL')
        .length;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Row(
        spacing: AppSizes.sm,
        children: [
          Expanded(
            child: _StatBadgeCard(
              title: 'COMPLETED',
              subtitle: '$totalCompleted Paid',
              textTheme: textTheme,
              titleColor: AppColors.stepCurrentLabel,
              subtitleColor: AppColors.success,
            ),
          ),
          Expanded(
            child: _StatBadgeCard(
              title: 'PARTIAL',
              subtitle: '$totalPartials Track',
              textTheme: textTheme,
              titleColor: AppColors.warning,
              subtitleColor: AppColors.warning,
            ),
          ),
          Expanded(
            child: _StatBadgeCard(
              title: 'FACILITY BAL',
              subtitle: CurrencyFormatter.format(widget.remainingBalance),
              textTheme: textTheme,
              titleColor: AppColors.darkHint,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- one row ----------

class _TrackCard extends StatelessWidget {
  final _TrackRow row;
  final int totalWeeks;

  const _TrackCard({required this.row, required this.totalWeeks});

  String _join(List<String?> parts) =>
      parts.where((p) => p != null && p.isNotEmpty).join(' • ');

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const muted = AppColors.darkOnSurfaceMuted;

    final track = row.track;
    final ref = track == null ? null : TextFormatter.dummyId(track.id, 'TRK');
    final remaining = CurrencyFormatter.format(row.remaining);

    final unpaid =
        row.state == _TrackState.missed ||
        row.state == _TrackState.scheduled ||
        row.state == _TrackState.upcoming;

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
      case _TrackState.paid:
        chipLabel = 'PAID';
        chipBg = AppColors.successContainer;
        chipFg = Colors.white;
        sub = _join([ref, 'Due ${DateFormatter.dayMonth(row.due)}']);
        right = 'Paid in full';
        rightColor = AppColors.success;
        tint = AppColors.darkRim.withAlpha(AppAlphas.badgeFill);
      case _TrackState.partial:
        chipLabel = 'PARTIAL';
        chipBg = AppColors.approvalGlowWarm;
        chipFg = AppColors.progressWarning;
        chipIcon = Icons.schedule;
        sub = ref;
        right = '$remaining Due to clear';
        rightColor = AppColors.warning;
        tint = AppColors.warning.withAlpha(AppAlphas.watermark);
        border = AppColors.warning.withAlpha(AppAlphas.borderTint);
      case _TrackState.missed:
        chipLabel = 'UNPAID';
        chipBg = AppColors.dangerContainer.withAlpha(AppAlphas.borderTint);
        chipFg = AppColors.progressDanger;
        sub = _join([ref, 'Not collected']);
        right = '$remaining pending';
        rightColor = AppColors.progressDanger;
        tint = AppColors.darkRim.withAlpha(AppAlphas.badgeFill);
      case _TrackState.scheduled:
        chipLabel = 'SCHEDULED';
        chipBg = AppColors.darkBorder;
        chipFg = AppColors.darkOnSurface;
        sub = 'Due ${DateFormatter.weekdayDate(row.due)}';
        right = 'Upcoming';
        rightColor = AppColors.stepCurrentLabel;
        tint = AppColors.darkRim.withAlpha(AppAlphas.badgeFill);
      case _TrackState.upcoming:
        chipLabel = 'UPCOMING';
        chipBg = AppColors.darkBorder.withAlpha(AppAlphas.badgeFill);
        chipFg = muted;
        opacity = 0.6; // dim, single line
    }

    // weeks past the loan's term on an overdue loan
    if (row.isExtension) {
      border = AppColors.dangerContainer;
      tint = AppColors.dangerContainer.withAlpha(AppAlphas.watermark);
      opacity = 1;
      if (unpaid) {
        chipLabel = 'OVERDUE';
        chipBg = AppColors.dangerContainer;
        chipFg = Colors.white;
        chipIcon = null;
        sub = _join([ref, 'Past $totalWeeks-week term']);
        right = '$remaining overdue';
        rightColor = AppColors.progressDanger;
      }
    }

    final weekBg = row.isExtension
        ? AppColors.dangerContainer
        : row.state == _TrackState.partial
        ? AppColors.approvalGlowWarm
        : AppColors.darkBorder;
    final weekFg = row.isExtension
        ? Colors.white
        : row.state == _TrackState.partial
        ? AppColors.progressWarning
        : AppColors.darkOnSurface;

    final amountStyle = text.headlineSmall?.copyWith(
      fontWeight: FontWeight.w800,
    );
    final dateStyle = text.bodyMedium?.copyWith(color: muted);

    final amountSpans = row.state == _TrackState.partial
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

    final chipPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3);

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
                  label: 'Wk ${NumberFormatter.pad2(row.week)}',
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
                    Text(
                      right,
                      style: text.labelMedium?.copyWith(
                        color: rightColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatBadgeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color? titleColor;
  final Color? subtitleColor;
  final TextTheme textTheme;

  const _StatBadgeCard({
    required this.title,
    required this.subtitle,
    required this.textTheme,
    this.titleColor,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkBorder.withAlpha(AppAlphas.badgeFill),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: textTheme.labelLarge?.copyWith(
              color: titleColor ?? AppColors.darkOnSurfaceMuted,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: subtitleColor ?? AppColors.darkOnSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
