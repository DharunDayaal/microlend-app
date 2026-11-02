import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_icon_button.dart';
import 'package:micro_lending_app/common/widgets/app_name_card.dart';
import 'package:micro_lending_app/common/widgets/app_progress_bar.dart';
import 'package:micro_lending_app/common/widgets/app_skeleton.dart';
import 'package:micro_lending_app/common/widgets/app_status_chip.dart';
import 'package:micro_lending_app/common/widgets/payment_tile.dart';
import 'package:micro_lending_app/common/widgets/state_views.dart';
import 'package:micro_lending_app/data/models/customer_model.dart';
import 'package:micro_lending_app/data/models/loan_model.dart';
import 'package:micro_lending_app/data/services/customer_service.dart';
import 'package:micro_lending_app/data/services/loan_service.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/utils/formatters/number_formatter.dart';
import 'package:micro_lending_app/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';

class LoanPaymentsScreen extends StatefulWidget {
  final String loanId;
  const LoanPaymentsScreen({super.key, required this.loanId});

  @override
  State<LoanPaymentsScreen> createState() => _LoanPaymentsScreenState();
}

class _LoanPaymentsScreenState extends State<LoanPaymentsScreen> {
  static const _pageSize = 20;
  static const _loadMoreTrigger = 200.0;

  LoanModel? _loanDetail;
  CustomerDetails? _customerDetail;
  final List<PaymentModel> _items = [];
  final _scrollController = ScrollController();
  final _headerKey = GlobalKey();

  String? _listError;
  String? _loadMoreError;
  String? _loanError;

  bool _isPaymentLoading = true;
  bool _isLoanDetailLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  bool _headerVisible = true;

  int _page = 1;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadDatas();
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
      _loadNextPage();
    }
  }

  Future<void> _loadDatas() =>
      Future.wait([_getPaymentList(), _getLoanDetails()]);

  Future<void> _refresh() => Future.wait([
    _getPaymentList(showSkeleton: false),
    _getLoanDetails(showSkeleton: false),
  ]);

  Future<void> _getPaymentList({bool showSkeleton = true}) async {
    final id = ++_requestId;
    setState(() {
      if (showSkeleton) _isPaymentLoading = true;
      _listError = null;
      _loadMoreError = null;
      _isLoadingMore = false;
    });

    try {
      final response = await LoanService.getPaymentList(
        loanId: widget.loanId,
        page: 1,
        limit: _pageSize,
      );
      if (!mounted || id != _requestId) return;

      setState(() {
        _items
          ..clear()
          ..addAll(response.items);
        _hasMore = response.hasNextPage;
        _page = 1;
        _headerVisible = true;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
    } on ApiException catch (e) {
      if (mounted && id == _requestId) setState(() => _listError = e.message);
    } finally {
      if (mounted && id == _requestId) {
        setState(() => _isPaymentLoading = false);
      }
    }
  }

  Future<void> _loadNextPage() async {
    if (_isPaymentLoading ||
        _isLoadingMore ||
        !_hasMore ||
        _loadMoreError != null) {
      return;
    }

    final id = _requestId;
    setState(() => _isLoadingMore = true);

    try {
      final response = await LoanService.getPaymentList(
        loanId: widget.loanId,
        page: _page + 1,
        limit: _pageSize,
      );
      if (!mounted || id != _requestId) return;

      setState(() {
        final existing = _items.map((p) => p.id).toSet();
        _items.addAll(response.items.where((p) => !existing.contains(p.id)));
        _page += 1;
        _hasMore = response.hasNextPage;
      });
    } on ApiException catch (e) {
      if (mounted && id == _requestId) {
        setState(() => _loadMoreError = e.message);
      }
    } finally {
      if (mounted && id == _requestId) setState(() => _isLoadingMore = false);
    }
  }

  void _retryLoadMore() {
    setState(() => _loadMoreError = null);
    _loadNextPage();
  }

  Future<void> _getLoanDetails({bool showSkeleton = true}) async {
    setState(() {
      if (showSkeleton) _isLoanDetailLoading = true;
      _loanError = null;
    });

    try {
      final response = await LoanService.getLoanDetails(loanid: widget.loanId);
      if (!mounted) return;
      final borrower = await CustomerService.getCustomerDetails(
        customerId: response.customerId,
      );
      if (!mounted) return;

      setState(() {
        _loanDetail = response;
        _customerDetail = borrower;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _loanError = e.message);
    } finally {
      if (mounted) setState(() => _isLoanDetailLoading = false);
    }
  }

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
    final textTheme = Theme.of(context).textTheme;
    final pad = AppSpacing.screen(context);

    return Scaffold(
      appBar: AppBar(
        leading: AppIconButton(
          icon: Icons.arrow_back_ios,
          onPressed: () => context.pop(),
        ),
        title: const Text("Payments"),
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
    if (_isLoanDetailLoading) return const _UserSectionSkeleton();

    final loan = _loanDetail;
    if (loan == null) {
      return _WidgetContainer(
        child: ErrorView(
          message: _loanError ?? 'Could not load the loan details.',
          onRetry: _getLoanDetails,
        ),
      );
    }

    final customer = _customerDetail;
    final collected = loan.totalCollected;
    final payable = loan.totalPayableAmount;
    final progress = NumberFormatter.progress(collected, payable);
    final percent = (payable > 0 && collected >= payable)
        ? 100
        : (progress * 100).floor();

    final status = loan.status.toUpperCase();
    final overdue = loan.isOverdue || status == 'OVERDUE';
    final (statusLabel, statusColor) = overdue
        ? ('OVERDUE', AppColors.progressDanger)
        : status == 'ACTIVE'
        ? ('ACTIVE', AppColors.success)
        : status == 'PAID_OFF'
        ? ('PAID OFF', AppColors.success)
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
                            "TOTAL COLLECTED",
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
                            "OUTSTANDING",
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
                    Text(
                      "Target: ${CurrencyFormatter.format(payable)}",
                      style: textTheme.labelLarge,
                    ),
                    const Spacer(),
                    Text(
                      "$percent% Cleared",
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.success,
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
    final DateTime? lastPaid = _items.isNotEmpty ? _items.first.paidAt : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: AppSizes.md,
      children: [
        Expanded(
          child: _StatCard(
            title: "TOTAL PAID",
            content: CurrencyFormatter.format(loan.totalCollected),
          ),
        ),
        Expanded(
          child: _StatCard(
            title: "COVERAGE",
            content: "${loan.totalWeeks} Weeks",
          ),
        ),
        Expanded(
          child: _StatCard(
            title: "LAST LOG",
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
    final loan = _loanDetail;

    if (_isPaymentLoading || _isLoanDetailLoading) {
      return ListView(
        physics: physics,
        padding: padding,
        children: const [_PaymentListSkeleton(count: 3)],
      );
    }

    if (_listError != null) {
      return ListView(
        physics: physics,
        padding: padding,
        children: [
          ErrorView(message: _listError!, onRetry: () => _getPaymentList()),
        ],
      );
    }

    if (loan == null) {
      return ListView(physics: physics, children: const []);
    }

    if (_items.isEmpty) {
      return ListView(
        physics: physics,
        padding: padding,
        children: const [
          EmptyView(
            icon: Icons.receipt_long_outlined,
            message: 'No payments found',
          ),
        ],
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: physics,
      padding: padding,
      itemCount: _items.length + 1,
      separatorBuilder: (_, _) => AppGap.h12,
      itemBuilder: (_, i) => i == _items.length
          ? _listFooter()
          : PaymentTile.fromLoan(payment: _items[i], loan: loan),
    );
  }

  Widget _listFooter() {
    final text = Theme.of(context).textTheme;

    if (_isLoadingMore) {
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
            Text("Loading older payments...", style: text.bodyMedium),
          ],
        ),
      );
    }

    if (_loadMoreError != null) {
      return Column(
        children: [
          Text(_loadMoreError!, textAlign: TextAlign.center),
          TextButton(
            onPressed: _retryLoadMore,
            child: const Text('Tap to retry'),
          ),
        ],
      );
    }

    if (!_hasMore) {
      return Center(child: Text('No more payments', style: text.bodySmall));
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
