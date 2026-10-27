import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_icon_button.dart';
import 'package:micro_lending_app/common/widgets/app_status_chip.dart';
import 'package:micro_lending_app/data/models/loan_model.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/common/widgets/repayment_track_list.dart';

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
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final rows = RepaymentRows.build(
      tracks: widget.loanTracks,
      totalWeeks: widget.totalWeeks,
      issuedAt: widget.issuedAt,
      isOverdueLoan: widget.isOverdueLoan,
      weeklyAmount: widget.weeklyAmount,
    );

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
                  itemBuilder: (_, i) => RepaymentTrackCard(
                    row: rows[i],
                    totalWeeks: widget.totalWeeks,
                  ),
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
