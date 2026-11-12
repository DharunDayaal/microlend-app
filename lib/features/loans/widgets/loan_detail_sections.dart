import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_button.dart';
import 'package:micro_lending_app/common/widgets/app_name_card.dart';
import 'package:micro_lending_app/common/widgets/app_progress_bar.dart';
import 'package:micro_lending_app/common/widgets/app_skeleton.dart';
import 'package:micro_lending_app/common/widgets/app_status_chip.dart';
import 'package:micro_lending_app/common/widgets/call_icon_button.dart';
import 'package:micro_lending_app/data/models/customer_model.dart';
import 'package:micro_lending_app/data/models/loan_model.dart';
import 'package:micro_lending_app/features/loans/screens/loan_snapshot.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/utils/formatters/phone_formatter.dart';
import 'package:micro_lending_app/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/utils/helpers/loan_helper.dart';

// Row heights shared by every card and its skeleton, so nothing jumps on load.
const double _topRowH = 52;
const double _captionH = 20;
const double _tileH = 88;
const double _headerH = 40;

String _plural(int n, String word) => '$n ${n == 1 ? word : '${word}s'}';
String _num(double v) =>
    v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

// ---------- shared frame ----------

class DetailCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;

  const DetailCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.md),
    this.onTap,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.darkBorder.withAlpha(AppAlphas.badgeFill),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: borderColor == null
            ? BorderSide.none
            : BorderSide(color: borderColor!),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class DetailSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const DetailSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SizedBox(
      height: _headerH,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, _headerH),
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(actionLabel!),
                  const Icon(Icons.chevron_right_rounded, size: 18),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ---------- status banner ----------

class LoanStatusBanner extends StatelessWidget {
  final LoanSnapshot s;
  const LoanStatusBanner({super.key, required this.s});

  @override
  Widget build(BuildContext context) {
    if (!s.hasBanner) return const SizedBox.shrink();

    final text = Theme.of(context).textTheme;
    final loan = s.loan;
    final money = CurrencyFormatter.format;

    final (color, icon, title, body) = switch (s.stage) {
      LoanStage.overdue => (
        AppColors.progressDanger,
        Icons.error_outline,
        'Overdue • ${_plural(s.daysLate, 'day')} late',
        '${money(s.overdueAmount)} across ${_plural(s.pastDueRows.length, 'week')} '
            'is past due.'
            '${s.pastDueRows.any((r) => r.isExtension) ? ' The ${loan.totalWeeks}-week term has ended.' : ''}',
      ),
      LoanStage.paidOff => (
        AppColors.success,
        Icons.verified_outlined,
        'Fully repaid',
        'All ${loan.totalWeeks} weekly installments are collected. '
            '${money(loan.totalCollected)} received in total.',
      ),
      LoanStage.closed => (
        AppColors.darkOnSurfaceMuted,
        Icons.lock_outline,
        'Loan closed',
        [
              if (loan.closedAt != null)
                'Closed on ${DateFormatter.date(loan.closedAt)}.',
              if (loan.outstandingAmount > 0)
                '${money(loan.outstandingAmount)} was left unpaid.',
            ].join(' ').trim().isEmpty
            ? 'This loan is closed.'
            : [
                if (loan.closedAt != null)
                  'Closed on ${DateFormatter.date(loan.closedAt)}.',
                if (loan.outstandingAmount > 0)
                  '${money(loan.outstandingAmount)} was left unpaid.',
              ].join(' '),
      ),
      LoanStage.defaulted => (
        AppColors.progressDanger,
        Icons.cancel_outlined,
        'Marked as defaulted',
        '${money(loan.outstandingAmount)} is still outstanding.',
      ),
      _ => (AppColors.darkOnSurfaceMuted, Icons.info_outline, '', ''),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: color.withAlpha(AppAlphas.badgeFill),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: color.withAlpha(AppAlphas.borderTint)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: text.bodyLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(body, style: text.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- borrower ----------

class LoanBorrowerStrip extends StatelessWidget {
  final CustomerDetails customer;
  final int? cycle; // null until the borrower's loans have loaded
  final VoidCallback onTap;

  const LoanBorrowerStrip({
    super.key,
    required this.customer,
    required this.cycle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final route = customer.preferredPaymentDay.isEmpty
        ? null
        : '${TextFormatter.enumLabel(customer.preferredPaymentDay)} route';

    return DetailCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppNameCard(name: customer.customerName, width: 48, height: 48),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.customerName,
                      style: text.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      PhoneFormatter.display(customer.phoneNumber),
                      style: text.bodyMedium,
                    ),
                  ],
                ),
              ),
              CallIconButton(phone: customer.phoneNumber),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.darkOnSurfaceMuted,
              ),
            ],
          ),
          if (cycle != null || route != null) ...[
            AppGap.h8,
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.xs,
              children: [
                AppChip(
                  label: TextFormatter.dummyId(customer.id, '#USR'),
                  radius: AppSizes.radiusSm,
                  textStyle: text.labelSmall?.copyWith(
                    color: AppColors.darkOnSurfaceMuted,
                  ),
                ),
                if (cycle != null)
                  AppChip(
                    label: 'Cycle $cycle',
                    radius: AppSizes.radiusSm,
                    backgroundColor: AppColors.successContainer.withAlpha(
                      AppAlphas.badgeFill,
                    ),
                    textStyle: text.labelSmall?.copyWith(
                      color: AppColors.progressSuccess,
                    ),
                  ),
                if (route != null)
                  AppChip(
                    label: route,
                    radius: AppSizes.radiusSm,
                    textStyle: text.labelSmall?.copyWith(
                      color: AppColors.darkOnSurfaceMuted,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class LoanBorrowerError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const LoanBorrowerError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      child: Row(
        children: [
          const Icon(
            Icons.person_off_outlined,
            color: AppColors.darkOnSurfaceMuted,
          ),
          AppGap.w12,
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class LoanBorrowerStripSkeleton extends StatelessWidget {
  const LoanBorrowerStripSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SkeletonBox(
                  width: 48,
                  height: 48,
                  radius: AppSizes.radiusLg,
                ),
                AppGap.w12,
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 140, height: 16, radius: 4),
                      SizedBox(height: 8),
                      SkeletonBox(width: 110, height: 12, radius: 4),
                    ],
                  ),
                ),
                const SkeletonBox(
                  width: 40,
                  height: 40,
                  radius: AppSizes.radiusMd,
                ),
              ],
            ),
            AppGap.h8,
            const Row(
              children: [
                SkeletonBox(width: 76, height: 24, radius: AppSizes.radiusSm),
                SizedBox(width: AppSizes.sm),
                SkeletonBox(width: 64, height: 24, radius: AppSizes.radiusSm),
                SizedBox(width: AppSizes.sm),
                SkeletonBox(width: 96, height: 24, radius: AppSizes.radiusSm),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- balance ----------

class LoanBalanceCard extends StatelessWidget {
  final LoanSnapshot s;
  const LoanBalanceCard({super.key, required this.s});

  (String, String, String, Color) _third() {
    final loan = s.loan;
    switch (s.stage) {
      case LoanStage.overdue:
        return (
          'OVERDUE',
          CurrencyFormatter.format(s.overdueAmount),
          '${_plural(s.pastDueRows.length, 'week')} past due',
          AppColors.progressDanger,
        );
      case LoanStage.active:
        final n = s.nextUpcoming;
        if (n == null) {
          return (
            'NEXT INSTALLMENT',
            '--',
            'Nothing scheduled',
            AppColors.darkOnSurfaceMuted,
          );
        }
        return (
          'NEXT INSTALLMENT',
          CurrencyFormatter.format(n.remaining),
          'Due ${DateFormatter.weekdayDate(n.due)}',
          AppColors.warning,
        );
      case LoanStage.paidOff:
        return (
          'SETTLED',
          CurrencyFormatter.format(0),
          'No balance left',
          AppColors.success,
        );
      default:
        return loan.outstandingAmount > 0
            ? (
                'UNPAID AT CLOSE',
                CurrencyFormatter.format(loan.outstandingAmount),
                'Not collected',
                AppColors.progressDanger,
              )
            : (
                'SETTLED',
                CurrencyFormatter.format(0),
                'No balance left',
                AppColors.success,
              );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = text.labelMedium?.copyWith(
      color: AppColors.darkOnSurfaceMuted,
    );
    final loan = s.loan;
    final cleared = loan.outstandingAmount <= 0;

    final progress = RecoveryProgress(
      total: loan.totalPayableAmount,
      collected: loan.totalCollected,
      overdue: s.overdueAmount,
    );
    final outColor = cleared
        ? AppColors.success
        : s.stage == LoanStage.overdue
        ? AppColors.progressDanger
        : AppColors.progressWarning;
    final (thirdLabel, thirdValue, thirdCaption, thirdColor) = _third();

    return DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _topRowH),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OUTSTANDING', style: muted),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          CurrencyFormatter.format(loan.outstandingAmount),
                          style: text.headlineMedium?.copyWith(
                            color: outColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppGap.w8,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('TOTAL REPAYABLE', style: muted),
                    Text(
                      CurrencyFormatter.format(loan.totalPayableAmount),
                      style: text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          AppProgressBar.segmented(
            height: 8,
            semanticsLabel: 'Loan repayment progress',
            segments: [
              ProgressSegment(value: progress.collectedFraction),
              if (s.overdueAmount > 0)
                ProgressSegment(
                  value: progress.overdueFraction,
                  color: AppColors.progressWarning,
                ),
            ],
          ),
          const SizedBox(height: AppSizes.xs + 2),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _captionH),
            child: Row(
              children: [
                Text(
                  '${progress.completedPercent}% repaid',
                  style: text.labelMedium?.copyWith(color: AppColors.success),
                ),
                const Spacer(),
                if (s.overdueAmount > 0)
                  Text(
                    '${progress.overduePercent}% overdue • '
                    '${CurrencyFormatter.format(s.overdueAmount)}',
                    style: text.labelMedium?.copyWith(
                      color: AppColors.progressWarning,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            spacing: AppSizes.sm,
            children: [
              Expanded(
                child: _MiniTile(
                  label: 'COLLECTED',
                  value: CurrencyFormatter.format(loan.totalCollected),
                  caption: '${s.paidWeeks} of ${loan.totalWeeks} weeks paid',
                  color: AppColors.success,
                ),
              ),
              Expanded(
                child: _MiniTile(
                  label: thirdLabel,
                  value: thirdValue,
                  caption: thirdCaption,
                  color: thirdColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniTile extends StatelessWidget {
  final String label;
  final String value;
  final String caption;
  final Color color;
  const _MiniTile({
    required this.label,
    required this.value,
    required this.caption,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      constraints: const BoxConstraints(minHeight: _tileH),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withAlpha(AppAlphas.scrim),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: text.labelSmall?.copyWith(
              color: AppColors.darkOnSurfaceMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: text.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            caption,
            style: text.labelMedium?.copyWith(
              color: AppColors.darkOnSurfaceMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class LoanBalanceCardSkeleton extends StatelessWidget {
  const LoanBalanceCardSkeleton({super.key});

  Widget _tile() => Expanded(
    child: Container(
      height: _tileH,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withAlpha(AppAlphas.scrim),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: const AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 70, height: 10, radius: 4),
            SizedBox(height: 10),
            SkeletonBox(width: 90, height: 20, radius: 4),
            SizedBox(height: 8),
            SkeletonBox(width: 80, height: 10, radius: 4),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: _topRowH,
            child: AppShimmer(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 80, height: 10, radius: 4),
                        SizedBox(height: 10),
                        SkeletonBox(width: 150, height: 26, radius: 4),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SkeletonBox(width: 90, height: 10, radius: 4),
                      SizedBox(height: 10),
                      SkeletonBox(width: 80, height: 18, radius: 4),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          const AppShimmer(
            child: SkeletonBox(width: double.infinity, height: 8, radius: 4),
          ),
          const SizedBox(height: AppSizes.xs + 2),
          const SizedBox(
            height: _captionH,
            child: AppShimmer(
              child: Align(
                alignment: Alignment.centerLeft,
                child: SkeletonBox(width: 90, height: 10, radius: 4),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(spacing: AppSizes.sm, children: [_tile(), _tile()]),
        ],
      ),
    );
  }
}

// ---------- schedule skeleton ----------

class LoanScheduleRowSkeleton extends StatelessWidget {
  const LoanScheduleRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkRim.withAlpha(AppAlphas.badgeFill),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: const AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24,
              child: Row(
                children: [
                  SkeletonBox(width: 44, height: 22, radius: AppSizes.radiusSm),
                  SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SkeletonBox(width: 150, height: 16, radius: 4),
                    ),
                  ),
                  SizedBox(width: AppSizes.sm),
                  SkeletonBox(width: 64, height: 20, radius: AppSizes.radiusSm),
                ],
              ),
            ),
            SizedBox(height: AppSizes.xs),
            SizedBox(
              height: 16,
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SkeletonBox(width: 100, height: 10, radius: 4),
                    ),
                  ),
                  SkeletonBox(width: 72, height: 10, radius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailHeaderSkeleton extends StatelessWidget {
  const DetailHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: _headerH,
      child: AppShimmer(
        child: Align(
          alignment: Alignment.centerLeft,
          child: SkeletonBox(width: 140, height: 14, radius: 4),
        ),
      ),
    );
  }
}

// ---------- recent payments ----------

class RecentPaymentsSection extends StatelessWidget {
  final List<PaymentModel> payments;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onViewAll;

  const RecentPaymentsSection({
    super.key,
    required this.payments,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    Widget body;
    if (isLoading) {
      body = const Column(
        spacing: AppSizes.sm,
        children: [
          RecentPaymentRowSkeleton(),
          RecentPaymentRowSkeleton(),
          RecentPaymentRowSkeleton(),
        ],
      );
    } else if (error != null) {
      body = DetailCard(
        child: Row(
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: AppColors.darkOnSurfaceMuted,
            ),
            AppGap.w12,
            Expanded(child: Text(error!, style: text.bodyMedium)),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    } else if (payments.isEmpty) {
      body = DetailCard(
        child: Row(
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.darkOnSurfaceMuted,
            ),
            AppGap.w12,
            Expanded(
              child: Text('No payments recorded yet.', style: text.bodyMedium),
            ),
          ],
        ),
      );
    } else {
      body = Column(
        spacing: AppSizes.sm,
        children: [for (final p in payments) RecentPaymentRow(payment: p)],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DetailSectionHeader(
          title: 'Recent payments',
          actionLabel: 'View all',
          onAction: onViewAll,
        ),
        AppGap.h8,
        body,
      ],
    );
  }
}

class RecentPaymentRow extends StatelessWidget {
  final PaymentModel payment;
  const RecentPaymentRow({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return DetailCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm + 2,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.successContainer.withAlpha(AppAlphas.badgeFill),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.south_west_rounded,
              size: 18,
              color: AppColors.success,
            ),
          ),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CurrencyFormatter.format(payment.amountPaid),
                  style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  'Week ${payment.weekNumber} • '
                  '${DateFormatter.dateTime(payment.paidAt, fallback: '--')}',
                  style: text.labelMedium?.copyWith(
                    color: AppColors.darkOnSurfaceMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecentPaymentRowSkeleton extends StatelessWidget {
  const RecentPaymentRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const DetailCard(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm + 2,
      ),
      child: AppShimmer(
        child: Row(
          children: [
            SkeletonBox(width: 36, height: 36, circle: true),
            SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 80, height: 14, radius: 4),
                  SizedBox(height: 8),
                  SkeletonBox(width: 170, height: 10, radius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- contract details (collapsed by default) ----------

class LoanContractCard extends StatefulWidget {
  final LoanSnapshot s;
  const LoanContractCard({super.key, required this.s});

  @override
  State<LoanContractCard> createState() => _LoanContractCardState();
}

class _LoanContractCardState extends State<LoanContractCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final loan = widget.s.loan;
    final money = CurrencyFormatter.format;

    final feePct = loan.nominalAmount > 0
        ? loan.upfrontFee / loan.nominalAmount * 100
        : 0.0;
    final interest = loan.totalPayableAmount - loan.nominalAmount;

    final rows = <(String, String)>[
      ('Sanctioned principal', money(loan.nominalAmount)),
      (
        'Upfront fee (${_num(double.parse(feePct.toStringAsFixed(1)))}%)',
        '-${money(loan.upfrontFee)}',
      ),
      ('Net disbursed', money(loan.disbursedAmount)),
      ('Flat interest', money(interest)),
      ('Total repayable', money(loan.totalPayableAmount)),
      ('Weekly installment', money(loan.weeklyPayableAmount)),
      ('Term', '${loan.totalWeeks} weeks (${_num(loan.totalMonths)} months)'),
      ('Disbursed on', DateFormatter.date(loan.issuedAt)),
      ('Matures on', DateFormatter.date(widget.s.maturityDate)),
      if (loan.closedAt != null)
        ('Closed on', DateFormatter.date(loan.closedAt)),
    ];

    return DetailCard(
      onTap: () => setState(() => _open = !_open),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined, size: AppSizes.iconMd),
              AppGap.w8,
              Expanded(
                child: Text(
                  'Contract details',
                  style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              AnimatedRotation(
                turns: _open ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.keyboard_arrow_down_rounded),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: _open
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSizes.sm),
                    child: Column(
                      children: [
                        for (var i = 0; i < rows.length; i++) ...[
                          if (i > 0)
                            const Divider(
                              height: 1,
                              color: AppColors.darkBorder,
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    rows[i].$1,
                                    style: text.bodyMedium?.copyWith(
                                      color: AppColors.darkOnSurfaceMuted,
                                    ),
                                  ),
                                ),
                                AppGap.w8,
                                Text(
                                  rows[i].$2,
                                  style: text.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

// ---------- bottom bar ----------

class LoanActionBar extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final bool urgent; // red button for overdue collection

  const LoanActionBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.outlined = false,
    this.urgent = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: AppButton(
            label: label,
            prefixIcon: icon,
            outlined: outlined,
            isLoading: isLoading,
            radius: AppSizes.md,
            backgroundColor: urgent ? AppColors.dangerContainer : null,
            foregroundColor: urgent ? Colors.white : null,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}

// ---------- full-page skeleton ----------

class LoanDetailsSkeleton extends StatelessWidget {
  const LoanDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LoanBorrowerStripSkeleton(),
        AppGap.h16,
        LoanBalanceCardSkeleton(),
        AppGap.h16,
        DetailHeaderSkeleton(),
        AppGap.h8,
        LoanScheduleRowSkeleton(),
        AppGap.h8,
        LoanScheduleRowSkeleton(),
        AppGap.h16,
        DetailHeaderSkeleton(),
        AppGap.h8,
        RecentPaymentRowSkeleton(),
        AppGap.h8,
        RecentPaymentRowSkeleton(),
      ],
    );
  }
}
