import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/shared/design_system/styles/spacing_style.dart';
import 'package:micro_lending_app/shared/widgets/app_button.dart';
import 'package:micro_lending_app/shared/widgets/app_icon_button.dart';
import 'package:micro_lending_app/shared/widgets/app_name_card.dart';
import 'package:micro_lending_app/features/loans/presentation/widgets/payment_sheet.dart';
import 'package:micro_lending_app/shared/widgets/app_skeleton.dart';
import 'package:micro_lending_app/shared/widgets/app_status_chip.dart';
import 'package:micro_lending_app/shared/widgets/recovery_progress_card.dart';
import 'package:micro_lending_app/features/loans/presentation/widgets/repayment_track_list.dart';
import 'package:micro_lending_app/shared/widgets/state_views.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';
import 'package:micro_lending_app/features/loans/domain/entities/payment_result.dart';
import 'package:micro_lending_app/features/loans/presentation/controllers/loan_with_borrower_controller.dart';
import 'package:micro_lending_app/shared/design_system/constants/alphas.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';
import 'package:micro_lending_app/core/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/features/loans/domain/loan_helper.dart';
import 'package:micro_lending_app/shared/helpers/snackbar_helper.dart';

class LoanTrackerScreen extends ConsumerStatefulWidget {
  final String loanId;
  const new({super.key, required this.loanId});

  @override
  ConsumerState<LoanTrackerScreen> createState() => _LoanTrackerScreenState();
}

class _LoanTrackerScreenState extends ConsumerState<LoanTrackerScreen> {
  final _headerKey = GlobalKey();
  bool _chromeVisible = true;

  /// A payment was recorded here, so the previous screen must reload.
  bool _changed = false;

  void _close() => context.pop(_changed);

  LoanWithBorrowerState get _h =>
      ref.read(loanWithBorrowerProvider(widget.loanId));
  LoanWithBorrowerController get _ctrl =>
      ref.read(loanWithBorrowerProvider(widget.loanId).notifier);

  Future<void> _retry() async {
    final ok = await _ctrl.load();
    if (ok && mounted) setState(() => _chromeVisible = true);
  }

  bool _onListScroll(UserScrollNotification n) {
    // only the track list: ignore horizontal and nested scrollables
    if (n.metrics.axis != Axis.vertical || n.depth != 0) return false;

    switch (n.direction) {
      case ScrollDirection.reverse: // scrolling down
        // Hide only if the list will still be scrollable once the header is
        // gone. Otherwise it would hide, the list would stop scrolling, and
        // the header would flick back on.
        final headerHeight = _headerKey.currentContext?.size?.height ?? 0;
        final canCollapse =
            n.metrics.maxScrollExtent > headerHeight + 48 &&
            n.metrics.pixels > 8;
        if (canCollapse && _chromeVisible) {
          setState(() => _chromeVisible = false);
        }
      case ScrollDirection.forward: // scrolling up
        if (!_chromeVisible) setState(() => _chromeVisible = true);
      case ScrollDirection.idle:
        break;
    }
    return false;
  }

  Future<void> _applyPayment(PaymentResultModel result) async {
    if (_h.loan == null) return;
    _changed = true;
    if (mounted) {
      AppSnackbar.success(context, context.l10n.trackerPaymentSuccess);
    }
    await _ctrl.applyPayment(result);
  }

  Future<void> _recordNewPayment() async {
    final loan = _h.loan;
    if (loan == null) return;

    final status = loan.status.toUpperCase();
    if (status != 'ACTIVE' && status != 'OVERDUE') {
      AppSnackbar.info(context, context.l10n.trackerOnlyOpenLoans);
      return;
    }

    if (loan.outstandingAmount <= 0) {
      AppSnackbar.info(context, context.l10n.trackerNothingLeft);
      return;
    }

    // Always a new week after the latest payment; missed weeks are not
    // back-filled from here (use Collect on that week instead).
    final result = await PaymentSheet.showForWeek(
      context,
      customerId: _h.borrower?.id ?? '',
      customerName: _h.borrower?.customerName ?? '',
      loan: loan,
      weekNumber: RepaymentRows.nextNewWeek(loan.tracks),
    );

    if (result != null) await _applyPayment(result);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loanWithBorrowerProvider(widget.loanId));
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final loan = _h.loan;

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: AppIconButton(icon: Icons.arrow_back_ios, onPressed: _close),
          title: Text(context.l10n.commonBack, style: textTheme.bodyLarge),
          titleSpacing: 2,
        ),
        body: SafeArea(
          bottom: false, // the bottom bar handles the bottom inset
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_h.isLoading) ...[
                  const _UserDetailSectionLoading(),
                  AppGap.h16,
                  const _LoanStatsSectionLoading(),
                  AppGap.h16,
                  const RecoveryProgressCardSkeleton(),
                  AppGap.h16,
                  const Expanded(child: _RepaymentTracksSkeleton(count: 7)),
                ] else if (loan == null) ...[
                  Expanded(
                    child: ErrorView(
                      message: _h.error ?? context.l10n.loanLoadFailed,
                      onRetry: _retry,
                    ),
                  ),
                ] else ...[
                  // header: collapses while the list scrolls down
                  ClipRect(
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      heightFactor: _chromeVisible ? 1 : 0,
                      child: Column(
                        key: _headerKey,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _userDetailSection(textTheme),
                          AppGap.h16,
                          _loanStatsSection(),
                          AppGap.h16,
                          RecoveryProgressCard(
                            progress: LoanHelper.recoveryProgress(loan, (week) {
                              final i = loan.issuedAt.toLocal();
                              return DateTime(
                                i.year,
                                i.month,
                                i.day + 7 * week,
                              );
                            }),
                          ),
                          AppGap.h16,
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: NotificationListener<UserScrollNotification>(
                      onNotification: _onListScroll,
                      child: _RepaymentTracks(
                        loan: loan,
                        onCollect: (row) async {
                          final paymentResult = await PaymentSheet.showForWeek(
                            context,
                            customerId: _h.borrower?.id ?? '',
                            customerName: _h.borrower?.customerName ?? '',
                            loan: loan,
                            weekNumber: row.week,
                          );

                          if (paymentResult != null) {
                            await _applyPayment(paymentResult);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        bottomNavigationBar: ClipRect(
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            heightFactor: 1,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: AppButton(
                    label: context.l10n.trackerRecordWeekly,
                    onPressed: loan == null ? null : _recordNewPayment,
                    prefixIcon: Icons.credit_card_outlined,
                    radius: AppSizes.md,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _userDetailSection(TextTheme textTheme) {
    return _WidgetContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppNameCard(name: _h.borrower?.customerName ?? ''),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _h.borrower?.customerName ?? '',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppGap.h4,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: AppSizes.sm,
                      children: [
                        AppChip(
                          label: context.l10n.trackerCycle(
                            _h.borrower?.creditHistory.totalLoans ?? 0,
                          ),
                          radius: AppSizes.sm,
                          backgroundColor: AppColors.darkHint.withAlpha(
                            AppAlphas.badgeFill,
                          ),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.l10n.trackerActiveLoan,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.labelSmall?.copyWith(
                                  color: AppColors.darkOnSurfaceMuted,
                                ),
                              ),
                              Text(
                                TextFormatter.dummyId(_h.loan?.id ?? '', "#LN"),
                                style: textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppGap.w12,
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.trackerWeeklyTarget,
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.darkOnSurfaceMuted,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(_h.loan?.weeklyPayableAmount ?? 0),
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          AppGap.h16,
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.darkBackground,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.trackerPrincipal,
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.darkOnSurfaceMuted,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(_h.loan?.disbursedAmount),
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.lightBorderStrong,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.trackerTotalDue,
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.darkOnSurfaceMuted,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(_h.loan?.totalPayableAmount),
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.lightBorderStrong,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      context.l10n.trackerTenure,
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.darkOnSurfaceMuted,
                      ),
                    ),
                    Text(
                      context.l10n.loanWeeksCount(_h.loan?.totalWeeks ?? 0),
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.lightBorderStrong,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _loanStatsSection() {
    final loan = _h.loan;
    final totalWeeks = loan?.totalWeeks ?? 0;
    final allTracks = loan?.tracks ?? const [];
    final isOverdue = loan?.isOverdue ?? false;

    final highestTrackedWeek = allTracks.fold<int>(
      totalWeeks,
      (max, t) => t.weekNumber > max ? t.weekNumber : max,
    );

    final weeksCollected = allTracks
        .where((t) => t.status == 'PAID' || t.status == 'PARTIAL')
        .length;

    final weeksLeft = (highestTrackedWeek - weeksCollected).clamp(
      0,
      highestTrackedWeek,
    );
    final due = _nextDue(loan);

    String collectedFooter;
    Color? collectedFooterColor;
    if (isOverdue && loan != null) {
      final issued = loan.issuedAt.toLocal();
      final issuedDay = DateTime(issued.year, issued.month, issued.day);
      final today = DateTime.now();
      final todayDay = DateTime(today.year, today.month, today.day);
      final weeksElapsed = todayDay.difference(issuedDay).inDays ~/ 7;

      collectedFooter = context.l10n.payWeekOfTotal(weeksElapsed, totalWeeks);
      collectedFooterColor = AppColors.danger;
    } else {
      collectedFooter = context.l10n.payWeekOfTotal(
        weeksCollected,
        highestTrackedWeek,
      );
      collectedFooterColor = null;
    }

    return Row(
      spacing: AppSizes.md,
      children: [
        Expanded(
          child: _StatCard(
            title: context.l10n.trackerCollected,
            content: loan?.totalCollected ?? 0,
            contentColor: AppColors.synced,
            footerText: collectedFooter,
            footerColor: collectedFooterColor,
            icon: Icons.check_circle_outline,
            iconColor: AppColors.success,
          ),
        ),
        Expanded(
          child: _StatCard(
            title: context.l10n.loanOutstanding,
            content: loan?.outstandingAmount ?? 0,
            contentColor: AppColors.progressWarning,
            footerText: context.l10n.trackerWeeksLeft(weeksLeft),
            icon: Icons.hourglass_top_rounded,
            iconColor: AppColors.progressWarning,
          ),
        ),
        Expanded(
          child: _StatCard(
            title: due.title,
            titleColor: due.color,
            content: due.amount,
            footerText: due.footer,
            footerColor: due.color,
            icon: due.icon,
            iconColor: due.color ?? AppColors.darkOnSurfaceMuted,
          ),
        ),
      ],
    );
  }

  _DueInfo _nextDue(LoanModel? loan) {
    if (loan == null) {
      return _DueInfo(
        title: context.l10n.trackerNextDue,
        footer: "--",
        icon: Icons.event_outlined,
      );
    }

    final highestTrackedWeek = loan.tracks.fold<int>(
      loan.totalWeeks,
      (max, t) => t.weekNumber > max ? t.weekNumber : max,
    );

    int? nextWeek;
    num? remaining;
    for (var w = 1; w <= highestTrackedWeek; w++) {
      final track = loan.tracks.where((t) => t.weekNumber == w).firstOrNull;
      if (track == null || track.status != 'PAID') {
        nextWeek = w;
        remaining = track?.remainingBalance;
        break;
      }
    }

    if (nextWeek == null) {
      if (loan.outstandingAmount <= 0) {
        return _DueInfo(
          title: context.l10n.trackerAllPaid,
          footer: context.l10n.trackerLoanCompleted,
          icon: Icons.verified_outlined,
          color: AppColors.success,
        );
      }
      // Real balance remains but no track exists yet for the next week —
      // point at the first untouched week past what's been recorded.
      nextWeek = highestTrackedWeek + 1;
      remaining = null;
    }

    final amount = (remaining != null && remaining > 0)
        ? remaining
        : loan.weeklyPayableAmount;

    final issued = loan.issuedAt.toLocal();
    final dueDate = DateTime(
      issued.year,
      issued.month,
      issued.day + 7 * nextWeek,
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = dueDate.difference(today).inDays;
    final label = context.l10n.trackerWeekShortDate(
      nextWeek,
      DateFormat('d MMM').format(dueDate),
    );

    if (loan.isOverdue || diff < 0) {
      return _DueInfo(
        title: context.l10n.statusOverdue,
        footer: diff < 0
            ? context.l10n.trackerDaysLate(nextWeek, -diff)
            : label,
        icon: Icons.error_outline_rounded,
        color: AppColors.danger,
        amount: amount,
      );
    }
    if (diff == 0) {
      return _DueInfo(
        title: context.l10n.trackerDueToday,
        footer: label,
        icon: Icons.ring_volume_rounded,
        color: AppColors.danger,
        amount: amount,
      );
    }
    if (diff == 1) {
      return _DueInfo(
        title: context.l10n.trackerDueTomorrow,
        footer: label,
        icon: Icons.notifications_active_outlined,
        color: AppColors.progressWarning,
        amount: amount,
      );
    }
    return _DueInfo(
      title: context.l10n.trackerNextDue,
      footer: label,
      icon: Icons.event_outlined,
      amount: amount,
    );
  }
}

class _WidgetContainer extends StatelessWidget {
  final Widget child;
  const _WidgetContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.darkBorder.withAlpha(AppAlphas.badgeFill),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: child,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final num content;
  final String footerText;
  final Color? titleColor;
  final Color? contentColor;
  final Color? footerColor;
  final IconData icon;
  final Color iconColor;
  const _StatCard({
    required this.title,
    required this.content,
    required this.footerText,
    this.titleColor,
    this.contentColor,
    this.footerColor,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return _WidgetContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: AppSizes.xs,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: textTheme.labelMedium?.copyWith(
                    color: titleColor ?? AppColors.darkOnSurfaceMuted,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: AppSizes.lg, color: iconColor),
            ],
          ),
          Text(
            CurrencyFormatter.format(content),
            style: textTheme.headlineSmall?.copyWith(color: contentColor),
          ),
          Text(
            footerText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: footerColor ?? AppColors.darkOnSurfaceMuted,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DueInfo {
  final String title;
  final String footer;
  final Color? color;
  final IconData icon;
  final num amount;
  const _DueInfo({
    required this.title,
    required this.footer,
    required this.icon,
    this.color,
    this.amount = 0,
  });
}

class _RepaymentTracks extends StatelessWidget {
  final LoanModel loan;
  final void Function(RepaymentRow row) onCollect;
  const _RepaymentTracks({required this.loan, required this.onCollect});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final rows = RepaymentRows.fromLoan(loan);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.trackerWeeklyTracks,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    context.l10n.trackerInstallmentsPlanned(loan.totalWeeks),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.stepCurrentLabel,
                    ),
                  ),
                ],
              ),
            ),
            AppGap.w8,
            AppChip(
              label: context.l10n.trackerLedger,
              backgroundColor: AppColors.darkBorder.withAlpha(
                AppAlphas.badgeFill,
              ),
              textStyle: textTheme.labelMedium?.copyWith(
                color: AppColors.stepCurrentLabel,
              ),
              leading: Icon(
                Icons.receipt_long_outlined,
                color: AppColors.stepCurrentLabel,
                size: AppSizes.xl,
              ),
            ),
          ],
        ),
        AppGap.h16,
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: AppSizes.md),
            itemCount: rows.length,
            separatorBuilder: (_, _) => AppGap.h8,
            itemBuilder: (context, index) => RepaymentTrackCard(
              row: rows[index],
              totalWeeks: loan.totalWeeks,
              onCollect: () => onCollect(rows[index]),
            ),
          ),
        ),
      ],
    );
  }
}

class _UserDetailSectionLoading extends StatelessWidget {
  const _UserDetailSectionLoading();

  @override
  Widget build(BuildContext context) {
    return _WidgetContainer(
      child: AppShimmer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SkeletonBox(
                  width: 48,
                  height: 48,
                  radius: AppSizes.radiusLg,
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SkeletonBox(width: 120, height: 16),
                      AppGap.h8,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: AppSizes.sm,
                        children: [
                          const SkeletonBox(
                            width: 65,
                            height: 24,
                            radius: AppSizes.radiusSm,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SkeletonBox(width: 50, height: 10),
                              SizedBox(height: 4),
                              SkeletonBox(width: 65, height: 12),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppGap.w12,
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SkeletonBox(width: 75, height: 12),
                    SizedBox(height: 6),
                    SkeletonBox(width: 60, height: 20),
                  ],
                ),
              ],
            ),
            AppGap.h16,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonBox(width: 50, height: 12),
                      SizedBox(height: 6),
                      SkeletonBox(width: 70, height: 18),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonBox(width: 55, height: 12),
                      SizedBox(height: 6),
                      SkeletonBox(width: 70, height: 18),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      SkeletonBox(width: 45, height: 12),
                      SizedBox(height: 6),
                      SkeletonBox(width: 60, height: 18),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoanStatsSectionLoading extends StatelessWidget {
  const _LoanStatsSectionLoading();

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppSizes.md,
      children: const [
        Expanded(child: _StatCardLoading()),
        Expanded(child: _StatCardLoading()),
        Expanded(child: _StatCardLoading()),
      ],
    );
  }
}

class _StatCardLoading extends StatelessWidget {
  const _StatCardLoading();

  @override
  Widget build(BuildContext context) {
    return _WidgetContainer(
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: AppSizes.xs,
          children: const [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: SkeletonBox(width: 60, height: 12)),
                SizedBox(width: AppSizes.sm),
                SkeletonBox(
                  width: AppSizes.lg,
                  height: AppSizes.lg,
                  radius: AppSizes.radiusSm,
                ),
              ],
            ),
            SkeletonBox(width: 80, height: 22),
            SkeletonBox(width: 70, height: 12),
          ],
        ),
      ),
    );
  }
}

class _RepaymentTracksSkeleton extends StatelessWidget {
  final int count;
  const _RepaymentTracksSkeleton({this.count = 6});

  static const _widths = [96.0, 120.0, 84.0, 110.0, 100.0, 90.0];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          child: AppShimmer(
            child: Row(
              children: const [
                SkeletonBox(width: 130, height: 14, radius: 4),
                SizedBox(width: AppSizes.sm),
                SkeletonBox(width: 44, height: 20, radius: AppSizes.radiusSm),
              ],
            ),
          ),
        ),
        AppGap.h12,
        Expanded(
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: AppSizes.md),
            itemCount: count,
            separatorBuilder: (_, _) => AppGap.h8,
            itemBuilder: (_, i) =>
                _TrackCardSkeleton(subWidth: _widths[i % _widths.length]),
          ),
        ),
      ],
    );
  }
}

class _TrackCardSkeleton extends StatelessWidget {
  final double subWidth;
  const _TrackCardSkeleton({required this.subWidth});

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
      child: AppShimmer(
        // only layout widgets and SkeletonBox inside
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // row 1: week chip, amount + date, status chip
            SizedBox(
              height: 24,
              child: Row(
                children: [
                  const SkeletonBox(
                    width: 44,
                    height: 22,
                    radius: AppSizes.radiusSm,
                  ),
                  AppGap.w8,
                  const Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SkeletonBox(width: 150, height: 16, radius: 4),
                    ),
                  ),
                  AppGap.w8,
                  const SkeletonBox(
                    width: 64,
                    height: 20,
                    radius: AppSizes.radiusSm,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            // row 2: reference text on the left, status text on the right
            SizedBox(
              height: 16,
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SkeletonBox(
                        width: subWidth,
                        height: 10,
                        radius: 4,
                      ),
                    ),
                  ),
                  AppGap.w8,
                  const SkeletonBox(width: 72, height: 10, radius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
