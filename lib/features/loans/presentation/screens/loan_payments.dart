import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/l10n/l10n_labels.dart';
import 'package:micro_lending_app/shared/design_system/styles/spacing_style.dart';
import 'package:micro_lending_app/shared/widgets/app_icon_button.dart';
import 'package:micro_lending_app/shared/widgets/app_name_card.dart';
import 'package:micro_lending_app/shared/widgets/app_progress_bar.dart';
import 'package:micro_lending_app/shared/widgets/app_skeleton.dart';
import 'package:micro_lending_app/shared/widgets/app_status_chip.dart';
import 'package:micro_lending_app/features/loans/presentation/widgets/payment_tile.dart';
import 'package:micro_lending_app/shared/widgets/state_views.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';
import 'package:micro_lending_app/features/loans/presentation/controllers/loan_payments_controller.dart';
import 'package:micro_lending_app/features/loans/presentation/controllers/loan_with_borrower_controller.dart';
import 'package:micro_lending_app/shared/pagination/paged_state.dart';
import 'package:micro_lending_app/shared/design_system/constants/alphas.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';
import 'package:micro_lending_app/core/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/number_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/text_formatter.dart';

/// A loan's payment history: a summary card, then every payment as a
/// timeline grouped by day (sticky date headers). Tap a payment for details.
class LoanPaymentsScreen extends ConsumerStatefulWidget {
  final String loanId;
  const LoanPaymentsScreen({super.key, required this.loanId});

  @override
  ConsumerState<LoanPaymentsScreen> createState() => _LoanPaymentsScreenState();
}

class _LoanPaymentsScreenState extends ConsumerState<LoanPaymentsScreen> {
  static const _loadMoreTrigger = 200.0;

  final _scrollController = ScrollController();

  LoanPaymentsController get _list =>
      ref.read(loanPaymentsProvider(widget.loanId).notifier);
  PagedState<PaymentModel> get _p =>
      ref.read(loanPaymentsProvider(widget.loanId));
  LoanWithBorrowerState get _h =>
      ref.read(loanWithBorrowerProvider(widget.loanId));

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreTrigger) {
      _list.loadMore();
    }
  }

  Future<void> _refresh() => Future.wait([
    _list.refresh(showSkeleton: false),
    ref
        .read(loanWithBorrowerProvider(widget.loanId).notifier)
        .load(showSkeleton: false),
  ]);

  void _retryHeader() =>
      ref.read(loanWithBorrowerProvider(widget.loanId).notifier).load();

  @override
  Widget build(BuildContext context) {
    ref.watch(loanPaymentsProvider(widget.loanId));
    ref.watch(loanWithBorrowerProvider(widget.loanId));
    // after every fresh first page: fill a short screen with the next page
    ref.listen(
      loanPaymentsProvider(widget.loanId).select((s) => s.generation),
      (_, _) =>
          WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll()),
    );
    final pad = AppSpacing.screen(context);

    return Scaffold(
      appBar: AppBar(
        leading: AppIconButton(
          icon: Icons.arrow_back_ios,
          onPressed: () => context.pop(),
        ),
        title: Text(context.l10n.loanPayments),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(pad.left, pad.top, pad.right, 0),
                sliver: SliverToBoxAdapter(child: _summary()),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  pad.left,
                  AppSizes.lg,
                  pad.right,
                  AppSizes.bottomClearance,
                ),
                sliver: SliverMainAxisGroup(slivers: _history()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- summary ----------

  Widget _summary() {
    if (_h.isLoading) return const _SummarySkeleton();

    final loan = _h.loan;
    if (loan == null) {
      return _Card(
        child: ErrorView(
          message: _h.error ?? context.l10n.loanLoadDetailsFailed,
          onRetry: _retryHeader,
        ),
      );
    }
    return _SummaryCard(
      loan: loan,
      customerName: _h.borrower?.customerName ?? '',
      customerId: _h.borrower?.id ?? '',
      lastPaid: _p.items.firstOrNull?.paidAt, // newest first
    );
  }

  // ---------- history ----------

  List<Widget> _history() {
    final loan = _h.loan;

    if (_p.isLoading || _h.isLoading) {
      return const [SliverToBoxAdapter(child: _HistorySkeleton())];
    }
    if (_p.error != null) {
      return [
        SliverToBoxAdapter(
          child: ErrorView(message: _p.error!, onRetry: () => _list.refresh()),
        ),
      ];
    }
    if (loan == null) return const [];
    if (_p.items.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: EmptyView(
            icon: Icons.receipt_long_outlined,
            message: context.l10n.loanNoPayments,
          ),
        ),
      ];
    }

    final days = _groupByDay(_p.items);
    return [
      SliverToBoxAdapter(child: _historyTitle()),
      for (final day in days)
        SliverMainAxisGroup(
          slivers: [
            PinnedHeaderSliver(
              child: _DayHeader(day: day.day, total: day.total),
            ),
            SliverToBoxAdapter(
              child: _Card(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < day.payments.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          indent: 64,
                          color: AppColors.darkBorder.withAlpha(
                            AppAlphas.borderTint,
                          ),
                        ),
                      PaymentRow(
                        entry: PaymentEntry.fromLoan(day.payments[i], loan),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      SliverToBoxAdapter(child: _listFooter()),
    ];
  }

  Widget _historyTitle() {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.payHistory,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          // the count is only true once every page is in
          if (!_p.hasNext) ...[
            AppGap.w8,
            Flexible(
              child: AppChip(
                label: context.l10n.payCount(_p.items.length),
                radius: AppSizes.radiusSm,
                backgroundColor: AppColors.darkBorder.withAlpha(
                  AppAlphas.badgeFill,
                ),
                textStyle: text.labelSmall?.copyWith(
                  color: AppColors.darkOnSurfaceMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _listFooter() {
    final text = Theme.of(context).textTheme;

    if (_p.isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.stepCurrentLabel,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Flexible(
              child: Text(
                context.l10n.loanLoadingOlder,
                style: text.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    if (_p.loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSizes.md),
        child: Column(
          children: [
            Text(_p.loadMoreError!, textAlign: TextAlign.center),
            TextButton(
              onPressed: _list.retryLoadMore,
              child: Text(context.l10n.commonTapToRetry),
            ),
          ],
        ),
      );
    }

    if (!_p.hasNext) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSizes.lg),
        child: Center(
          child: Text(
            context.l10n.loanNoMorePayments,
            style: text.bodySmall?.copyWith(
              color: AppColors.darkOnSurfaceMuted,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

// ---------- grouping ----------

class _Day {
  final DateTime day;
  final List<PaymentModel> payments;
  _Day(this.day) : payments = [];

  double get total => payments.fold(0, (s, p) => s + p.amountPaid);
}

/// Consecutive payments on the same local day, in list order (newest first).
/// Payments with no date share one "--" group keyed by the epoch.
List<_Day> _groupByDay(List<PaymentModel> items) {
  final out = <_Day>[];
  for (final p in items) {
    final t = DateFormatter.parse(p.paidAt);
    final day = t == null ? DateTime(1970) : DateTime(t.year, t.month, t.day);
    if (out.isEmpty || out.last.day != day) out.add(_Day(day));
    out.last.payments.add(p);
  }
  return out;
}

// ---------- pieces ----------

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.md),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.darkBorder.withAlpha(AppAlphas.badgeFill),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: child,
    );
  }
}

/// "TODAY", "YESTERDAY" or "THU, 05 NOV", with the day's total. Opaque, as
/// it stays pinned over the rows scrolling under it.
class _DayHeader extends StatelessWidget {
  final DateTime day;
  final double total;
  const _DayHeader({required this.day, required this.total});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;
    final label = day.year == 1970
        ? '--'
        : diff == 0
        ? context.l10n.rangeToday
        : diff == 1
        ? context.l10n.audYesterday
        : DateFormatter.weekdayDate(day);
    final style = text.labelMedium?.copyWith(
      color: AppColors.darkOnSurfaceMuted,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
    );

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.only(top: AppSizes.md, bottom: AppSizes.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
          AppGap.w8,
          Text(CurrencyFormatter.format(total), style: style),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final LoanModel loan;
  final String customerName;
  final String customerId;
  final DateTime? lastPaid;

  const _SummaryCard({
    required this.loan,
    required this.customerName,
    required this.customerId,
    required this.lastPaid,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l = context.l10n;
    const muted = AppColors.darkOnSurfaceMuted;

    final collected = loan.totalCollected;
    final payable = loan.totalPayableAmount;
    final progress = NumberFormatter.progress(collected, payable);
    final percent = (payable > 0 && collected >= payable)
        ? 100
        : (progress * 100).floor();
    final weeksPaid = loan.tracks
        .where((t) => t.status.toUpperCase() == 'PAID')
        .length;

    final status = loan.status.toUpperCase();
    final overdue = loan.isOverdueNow;
    final (statusLabel, statusColor) = overdue
        ? (l.statusOverdue, AppColors.progressDanger)
        : status == 'ACTIVE'
        ? (l.loanStageActive, AppColors.success)
        : status == 'PAID_OFF'
        ? (l.loanStagePaidOff, AppColors.success)
        : (status.replaceAll('_', ' '), muted);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // who
          Row(
            children: [
              AppNameCard(
                name: customerName,
                backgroundColor: AppColors.darkPrimary,
              ),
              AppGap.w8,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      TextFormatter.dummyId(customerId, '#USR'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.labelSmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              AppGap.w8,
              Flexible(
                child: AppChip(
                  label: statusLabel,
                  radius: AppSizes.xs,
                  backgroundColor: statusColor.withAlpha(AppAlphas.badgeFill),
                  leading: Icon(
                    overdue ? Icons.error_outline : Icons.check_circle_outline,
                    size: AppSizes.lg,
                    color: statusColor,
                  ),
                  textStyle: text.labelSmall?.copyWith(color: statusColor),
                ),
              ),
            ],
          ),
          AppGap.h16,

          // how much is in
          Text(
            l.loanTotalCollected,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.labelMedium?.copyWith(color: muted),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    CurrencyFormatter.format(collected),
                    style: text.displaySmall?.copyWith(
                      color: AppColors.progressSuccess,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              AppGap.w8,
              Flexible(
                child: Text(
                  l.payOfTotal(CurrencyFormatter.format(payable)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: text.bodyMedium?.copyWith(color: muted),
                ),
              ),
            ],
          ),
          AppGap.h8,
          AppProgressBar(value: progress, height: 10),
          AppGap.h4,
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              l.loanPercentCleared(percent),
              style: text.labelMedium?.copyWith(color: AppColors.success),
            ),
          ),
          AppGap.h12,

          // the three numbers people ask about
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.sm + 2),
            decoration: BoxDecoration(
              color: AppColors.darkBackground.withAlpha(AppAlphas.scrim),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  _Metric(
                    label: l.loanOutstanding,
                    value: CurrencyFormatter.format(loan.outstandingAmount),
                    color: AppColors.progressWarning,
                  ),
                  const _MetricDivider(),
                  _Metric(
                    label: l.payWeeksPaid,
                    value: l.payWeeksPaidValue(weeksPaid, loan.totalWeeks),
                  ),
                  const _MetricDivider(),
                  _Metric(
                    label: l.payLastPaid,
                    value: lastPaid == null
                        ? '--'
                        : agoText(context, lastPaid!),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _Metric({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: Column(
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: text.labelSmall?.copyWith(
                color: AppColors.darkOnSurfaceMuted,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: text.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) => VerticalDivider(
    width: 1,
    color: AppColors.darkBorder.withAlpha(AppAlphas.borderTint),
  );
}

// ---------- skeletons ----------

class _SummarySkeleton extends StatelessWidget {
  const _SummarySkeleton();

  @override
  Widget build(BuildContext context) {
    return const _Card(
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonBox(width: 48, height: 48, radius: AppSizes.radiusLg),
                SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 120, height: 14, radius: 4),
                      SizedBox(height: 6),
                      SkeletonBox(width: 70, height: 10, radius: 4),
                    ],
                  ),
                ),
                SizedBox(width: AppSizes.sm),
                Flexible(
                  child: SkeletonBox(
                    width: 76,
                    height: 24,
                    radius: AppSizes.xs,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.lg),
            SkeletonBox(width: 100, height: 10, radius: 4),
            SizedBox(height: 8),
            SkeletonBox(width: 160, height: 30, radius: 6),
            SizedBox(height: 12),
            SkeletonBox(width: double.infinity, height: 10, radius: 5),
            SizedBox(height: AppSizes.lg),
            SkeletonBox(
              width: double.infinity,
              height: 52,
              radius: AppSizes.radiusMd,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistorySkeleton extends StatelessWidget {
  const _HistorySkeleton();

  @override
  Widget build(BuildContext context) {
    Widget row() => const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm + 4,
      ),
      child: Row(
        children: [
          SkeletonBox(width: 40, height: 40, radius: 20),
          SizedBox(width: AppSizes.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 80, height: 14, radius: 4),
                SizedBox(height: 6),
                SkeletonBox(width: 150, height: 10, radius: 4),
              ],
            ),
          ),
          SizedBox(width: AppSizes.sm),
          SkeletonBox(width: 64, height: 16, radius: 4),
        ],
      ),
    );

    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 140, height: 16, radius: 4),
          const SizedBox(height: AppSizes.lg),
          const SkeletonBox(width: 90, height: 10, radius: 4),
          const SizedBox(height: AppSizes.sm),
          _Card(
            padding: EdgeInsets.zero,
            child: Column(children: [row(), row(), row()]),
          ),
        ],
      ),
    );
  }
}
