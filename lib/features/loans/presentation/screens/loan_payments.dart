import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
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

class LoanPaymentsScreen extends ConsumerStatefulWidget {
  final String loanId;
  const LoanPaymentsScreen({super.key, required this.loanId});

  @override
  ConsumerState<LoanPaymentsScreen> createState() => _LoanPaymentsScreenState();
}

class _LoanPaymentsScreenState extends ConsumerState<LoanPaymentsScreen> {
  static const _loadMoreTrigger = 200.0;

  final _scrollController = ScrollController();
  final _headerKey = GlobalKey();
  bool _headerVisible = true;

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

  bool _onListScroll(UserScrollNotification n) {
    // only the payment list: ignore horizontal and nested scrollables
    if (n.metrics.axis != Axis.vertical || n.depth != 0) return false;

    switch (n.direction) {
      case ScrollDirection.reverse: // scrolling down
        // Collapse only if the list can still scroll once the header is gone.
        // Otherwise it would hide, the list would stop scrolling, and the
        // header would flick back on.
        final headerHeight = _headerKey.currentContext?.size?.height ?? 0;
        final canCollapse =
            n.metrics.maxScrollExtent > headerHeight + 48 &&
            n.metrics.pixels > 8;
        if (canCollapse && _headerVisible) {
          setState(() => _headerVisible = false);
        }
      case ScrollDirection.forward: // scrolling up
        if (!_headerVisible) setState(() => _headerVisible = true);
      case ScrollDirection.idle:
        break;
    }
    return false; // let the notification keep bubbling
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loanPaymentsProvider(widget.loanId));
    ref.watch(loanWithBorrowerProvider(widget.loanId));
    // after every fresh first page: show the header, and fill a short page
    ref.listen(
      loanPaymentsProvider(widget.loanId).select((s) => s.generation),
      (_, _) {
        setState(() => _headerVisible = true);
        WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
      },
    );
    final textTheme = Theme.of(context).textTheme;
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
        child: Column(
          children: [
            ClipRect(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                heightFactor: _headerVisible ? 1 : 0,
                child: Padding(
                  key: _headerKey,
                  padding: EdgeInsets.fromLTRB(pad.left, pad.top, pad.right, 0),
                  child: _userSection(textTheme),
                ),
              ),
            ),
            Expanded(
              child: NotificationListener<UserScrollNotification>(
                onNotification: _onListScroll,
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: _paymentList(pad),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userSection(TextTheme textTheme) {
    if (_h.isLoading) return const _UserSectionSkeleton();

    final loan = _h.loan;
    if (loan == null) {
      return _WidgetContainer(
        child: ErrorView(
          message: _h.error ?? context.l10n.loanLoadDetailsFailed,
          onRetry: _retryHeader,
        ),
      );
    }

    final customer = _h.borrower;
    final collected = loan.totalCollected;
    final payable = loan.totalPayableAmount;
    final progress = NumberFormatter.progress(collected, payable);
    final percent = (payable > 0 && collected >= payable)
        ? 100
        : (progress * 100).floor();

    final status = loan.status.toUpperCase();
    final overdue = loan.isOverdue || status == 'OVERDUE';
    final (statusLabel, statusColor) = overdue
        ? (context.l10n.statusOverdue, AppColors.progressDanger)
        : status == 'ACTIVE'
        ? (context.l10n.loanStageActive, AppColors.success)
        : status == 'PAID_OFF'
        ? (context.l10n.loanStagePaidOff, AppColors.success)
        : (status.replaceAll('_', ' '), AppColors.darkOnSurfaceMuted);

    return _WidgetContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppNameCard(
                name: customer?.customerName ?? "",
                backgroundColor: AppColors.darkPrimary,
              ),
              AppGap.w8,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer?.customerName ?? "",
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppChip(
                      label: TextFormatter.dummyId(customer?.id ?? "", "#USR"),
                      radius: AppSizes.sm,
                      textStyle: textTheme.labelSmall?.copyWith(
                        color: AppColors.darkOnSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
              AppGap.w8,
              AppChip(
                label: statusLabel,
                radius: AppSizes.xs,
                backgroundColor: statusColor.withAlpha(AppAlphas.badgeFill),
                leading: Icon(
                  overdue ? Icons.error_outline : Icons.check_circle_outline,
                  size: AppSizes.lg,
                  color: statusColor,
                ),
                textStyle: textTheme.labelSmall?.copyWith(color: statusColor),
              ),
            ],
          ),
          AppGap.h12,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.darkBackground,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.loanTotalCollected,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelMedium?.copyWith(
                              color: AppColors.darkOnSurfaceMuted,
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              CurrencyFormatter.format(collected),
                              style: textTheme.displayLarge?.copyWith(
                                color: AppColors.progressSuccess,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppGap.w8,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            context.l10n.loanOutstanding,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelMedium?.copyWith(
                              color: AppColors.darkOnSurfaceMuted,
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              CurrencyFormatter.format(loan.outstandingAmount),
                              style: textTheme.headlineMedium?.copyWith(
                                color: AppColors.progressWarning,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppGap.h8,
                AppProgressBar(value: progress),
                AppGap.h8,
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.loanTarget(
                          CurrencyFormatter.format(payable),
                        ),
                        style: textTheme.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppGap.w8,
                    Flexible(
                      child: Text(
                        context.l10n.loanPercentCleared(percent),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppGap.h12,
          _statSection(loan),
        ],
      ),
    );
  }

  Widget _statSection(LoanModel loan) {
    final items = _p.items;
    final DateTime? lastPaid = items.isNotEmpty ? items.first.paidAt : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: AppSizes.md,
      children: [
        Expanded(
          child: _StatCard(
            title: context.l10n.loanTotalPaid,
            content: CurrencyFormatter.format(loan.totalCollected),
          ),
        ),
        Expanded(
          child: _StatCard(
            title: context.l10n.loanCoverage,
            content: context.l10n.loanWeeksCount(loan.totalWeeks),
          ),
        ),
        Expanded(
          child: _StatCard(
            title: context.l10n.loanLastLog,
            content: DateFormatter.dayMonth(lastPaid, fallback: "--"),
          ),
        ),
      ],
    );
  }

  Widget _paymentList(EdgeInsets pad) {
    final padding = EdgeInsets.fromLTRB(
      pad.left,
      AppSizes.md,
      pad.right,
      AppSizes.bottomClearance,
    );
    const physics = AlwaysScrollableScrollPhysics();
    final loan = _h.loan;

    if (_p.isLoading || _h.isLoading) {
      return ListView(
        physics: physics,
        padding: padding,
        children: const [_PaymentListSkeleton(count: 3)],
      );
    }

    if (_p.error != null) {
      return ListView(
        physics: physics,
        padding: padding,
        children: [
          ErrorView(message: _p.error!, onRetry: () => _list.refresh()),
        ],
      );
    }

    if (loan == null) {
      return ListView(physics: physics, children: const []);
    }

    if (_p.items.isEmpty) {
      return ListView(
        physics: physics,
        padding: padding,
        children: [
          EmptyView(
            icon: Icons.receipt_long_outlined,
            message: context.l10n.loanNoPayments,
          ),
        ],
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: physics,
      padding: padding,
      itemCount: _p.items.length + 1,
      separatorBuilder: (_, _) => AppGap.h12,
      itemBuilder: (_, i) => i == _p.items.length
          ? _listFooter()
          : PaymentTile.fromLoan(payment: _p.items[i], loan: loan),
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
      return Column(
        children: [
          Text(_p.loadMoreError!, textAlign: TextAlign.center),
          TextButton(
            onPressed: _list.retryLoadMore,
            child: Text(context.l10n.commonTapToRetry),
          ),
        ],
      );
    }

    if (!_p.hasNext) {
      return Center(
        child: Text(context.l10n.loanNoMorePayments, style: text.bodySmall),
      );
    }

    return const SizedBox.shrink();
  }
}

class _WidgetContainer extends StatelessWidget {
  final Widget child;
  const _WidgetContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
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
  final String content;
  const _StatCard({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withAlpha(AppAlphas.badgeFill),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.darkOnSurfaceMuted,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              content,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _bar(
  double width,
  double lineHeight, {
  double barHeight = 12,
  Alignment align = Alignment.centerLeft,
}) {
  return SizedBox(
    height: lineHeight,
    child: Align(
      alignment: align,
      child: SkeletonBox(width: width, height: barHeight, radius: 4),
    ),
  );
}

class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withAlpha(AppAlphas.badgeFill),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: AppShimmer(
        child: Column(
          children: [
            _bar(56, 16, barHeight: 10, align: Alignment.center),
            const SizedBox(height: 4),
            _bar(64, 24, barHeight: 16, align: Alignment.center),
          ],
        ),
      ),
    );
  }
}

class _UserSectionSkeleton extends StatelessWidget {
  const _UserSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return _WidgetContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppShimmer(
            child: Row(
              children: [
                const SkeletonBox(
                  width: 48,
                  height: 48,
                  radius: AppSizes.radiusLg,
                ),
                AppGap.w8,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bar(120, 24, barHeight: 14),
                      const SizedBox(height: 2),
                      const SkeletonBox(
                        width: 70,
                        height: 18,
                        radius: AppSizes.sm,
                      ),
                    ],
                  ),
                ),
                AppGap.w8,
                const SkeletonBox(width: 76, height: 24, radius: AppSizes.xs),
              ],
            ),
          ),
          AppGap.h12,
          // totals box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.darkBackground,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: AppShimmer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _bar(100, 16, barHeight: 10),
                            _bar(150, 40, barHeight: 28),
                          ],
                        ),
                      ),
                      AppGap.w8,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _bar(
                              80,
                              16,
                              barHeight: 10,
                              align: Alignment.centerRight,
                            ),
                            _bar(
                              100,
                              40,
                              barHeight: 22,
                              align: Alignment.centerRight,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppGap.h8,
                  const SkeletonBox(
                    width: double.infinity,
                    height: 8,
                    radius: 4,
                  ),
                  AppGap.h8,
                  Row(
                    children: [
                      _bar(90, 20, barHeight: 12),
                      const Spacer(),
                      _bar(80, 20, barHeight: 12, align: Alignment.centerRight),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AppGap.h12,
          const Row(
            spacing: AppSizes.md,
            children: [
              Expanded(child: _StatCardSkeleton()),
              Expanded(child: _StatCardSkeleton()),
              Expanded(child: _StatCardSkeleton()),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentListSkeleton extends StatelessWidget {
  final int count;
  const _PaymentListSkeleton({this.count = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppSizes.md,
      children: List.generate(count, (_) => const _PaymentTileSkeleton()),
    );
  }
}

class _PaymentTileSkeleton extends StatelessWidget {
  const _PaymentTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        color: AppColors.darkSurface.withAlpha(AppAlphas.badgeFill),
        child: Row(
          children: [
            const SizedBox(width: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: AppShimmer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24,
                        child: Row(
                          children: [
                            const SkeletonBox(
                              width: 68,
                              height: 22,
                              radius: AppSizes.radiusSm,
                            ),
                            const Spacer(),
                            _bar(
                              150,
                              24,
                              barHeight: 12,
                              align: Alignment.centerRight,
                            ),
                          ],
                        ),
                      ),
                      AppGap.h12,
                      SizedBox(
                        height: 46,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: const [
                                  SkeletonBox(width: 80, height: 10, radius: 4),
                                  SizedBox(height: 8),
                                  SkeletonBox(
                                    width: 110,
                                    height: 24,
                                    radius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SkeletonBox(
                              width: 104,
                              height: 22,
                              radius: AppSizes.radiusSm,
                            ),
                          ],
                        ),
                      ),
                      AppGap.h12,
                      // progress bar + caption
                      const SkeletonBox(
                        width: double.infinity,
                        height: 6,
                        radius: 3,
                      ),
                      const SizedBox(height: AppSizes.xs + 2),
                      _bar(220, 16, barHeight: 10),
                      AppGap.h12,
                      // payment id box
                      const SkeletonBox(
                        width: double.infinity,
                        height: 32,
                        radius: AppSizes.radiusSm,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
