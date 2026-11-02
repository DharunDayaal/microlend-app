import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_chip_select.dart';
import 'package:micro_lending_app/common/widgets/app_name_card.dart';
import 'package:micro_lending_app/common/widgets/app_skeleton.dart';
import 'package:micro_lending_app/common/widgets/app_status_chip.dart';
import 'package:micro_lending_app/common/widgets/app_text_field.dart';
import 'package:micro_lending_app/common/widgets/state_views.dart';
import 'package:micro_lending_app/data/models/loan_model.dart';
import 'package:micro_lending_app/data/services/loan_service.dart';
import 'package:micro_lending_app/routes/app_routes.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/utils/formatters/phone_formatter.dart';
import 'package:micro_lending_app/utils/helpers/debouncer.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';

final List<Map<String, String>> _loanStatuses = [
  {"value": "", "label": "All"},
  {"value": "ACTIVE", "label": "Active"},
  {"value": "OVERDUE", "label": "Overdue"},
  {"value": "PAID_OFF", "label": "Paid off"},
  {"value": "DEFAULTED", "label": "Defaulted"},
  {"value": "CLOSED", "label": "Closed"},
];

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  static const _pageSize = 20;
  static const _loadMoreTrigger = 300.0;

  final List<LoanModel> _items = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasNext = false;
  int _page = 1;
  String? _listError;
  String? _loadMoreError;
  String _activeSearch = '';
  String _status = '';

  /// Bumped on every first-page load. A response from an older request
  /// (before a new search or filter) is ignored.
  int _requestId = 0;

  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _debouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _listLoans();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreTrigger) {
      _loadNextPage();
    }
  }

  Future<void> _listLoans({bool showSkeleton = true}) async {
    final id = ++_requestId;
    _activeSearch = _searchController.text.trim();

    setState(() {
      if (showSkeleton) _isLoading = true;
      _listError = null;
      _loadMoreError = null;
      _isLoadingMore = false;
    });

    try {
      final response = await LoanService.listLoans(
        page: 1,
        limit: _pageSize,
        search: _activeSearch,
        status: _status,
      );
      if (!mounted || id != _requestId) return;

      setState(() {
        _items
          ..clear()
          ..addAll(response.items);
        _page = 1;
        _hasNext = response.hasNextPage;
      });

      debugPrint('loans page=1 items=${_items.length} hasNext=$_hasNext');
      WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
    } on ApiException catch (e) {
      if (mounted && id == _requestId) setState(() => _listError = e.message);
    } finally {
      if (mounted && id == _requestId) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadNextPage() async {
    if (_isLoading || _isLoadingMore || !_hasNext || _loadMoreError != null) {
      return;
    }

    final id = _requestId;
    setState(() => _isLoadingMore = true);

    try {
      final response = await LoanService.listLoans(
        page: _page + 1,
        limit: _pageSize,
        search: _activeSearch,
        status: _status,
      );
      if (!mounted || id != _requestId) return;

      setState(() {
        final existing = _items.map((l) => l.id).toSet();
        _items.addAll(response.items.where((l) => !existing.contains(l.id)));
        _page += 1;
        _hasNext = response.hasNextPage;
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

  void _onSearchChanged(String value) {
    _debouncer.run(() => _listLoans());
  }

  @override
  Widget build(BuildContext context) {
    final pad = AppSpacing.screen(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(pad.left, pad.top, pad.right, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSizes.md,
                children: [
                  AppTextField(
                    label: "",
                    showHeader: false,
                    prefixIcon: Icons.search,
                    hint: "Search loan by name and phone number...",
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.done,
                  ),
                  AppChipSelect<String>(
                    selected: _status,
                    onSelected: (value) {
                      setState(() => _status = value);
                      _listLoans();
                    },
                    padding: EdgeInsets.zero,
                    options: [
                      for (final option in _loanStatuses)
                        ChipOption(
                          value: option["value"]!,
                          label: option["label"]!,
                        ),
                    ],
                  ),
                  AppGap.h4,
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _listLoans(showSkeleton: false),
                child: _loanList(pad),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loanList(EdgeInsets pad) {
    final padding = EdgeInsets.fromLTRB(
      pad.left,
      AppSizes.md,
      pad.right,
      AppSizes.bottomClearance,
    );
    const physics = AlwaysScrollableScrollPhysics();

    if (_isLoading) {
      return ListView(
        physics: physics,
        padding: padding,
        children: const [_LoanListSkeleton()],
      );
    }

    if (_listError != null) {
      return ListView(
        physics: physics,
        padding: padding,
        children: [
          ErrorView(message: _listError!, onRetry: () => _listLoans()),
        ],
      );
    }

    if (_items.isEmpty) {
      return ListView(
        physics: physics,
        padding: padding,
        children: const [
          EmptyView(
            icon: Icons.receipt_long_outlined,
            message: 'No loans found',
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
      itemBuilder: (_, i) =>
          i == _items.length ? _listFooter() : _LoanTile(loan: _items[i]),
    );
  }

  Widget _listFooter() {
    if (_isLoadingMore) return const _LoanListSkeleton(count: 1);

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

    if (!_hasNext) {
      return Center(
        child: Text(
          'No more loans',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _LoanStatusStyle {
  final String label;
  final Color bg;
  final Color fg;
  final Color border;
  final Color remaining;

  const _LoanStatusStyle({
    required this.label,
    required this.bg,
    required this.fg,
    required this.border,
    required this.remaining,
  });

  static _LoanStatusStyle of(LoanModel loan) {
    var status = loan.status.toUpperCase();
    // the API can flag a still-ACTIVE loan as overdue
    if (status == 'ACTIVE' && loan.isOverdue) status = 'OVERDUE';

    return switch (status) {
      'ACTIVE' => _LoanStatusStyle(
        label: 'ACTIVE',
        bg: AppColors.darkBorder,
        fg: AppColors.darkOnSurface,
        border: AppColors.darkRim,
        remaining: AppColors.warning,
      ),
      'OVERDUE' => _LoanStatusStyle(
        label: 'OVERDUE',
        bg: AppColors.dangerContainer.withAlpha(AppAlphas.borderTint),
        fg: AppColors.progressDanger,
        border: AppColors.dangerContainer,
        remaining: AppColors.progressDanger,
      ),
      'PAID_OFF' => _LoanStatusStyle(
        label: 'PAID OFF',
        bg: AppColors.successContainer.withAlpha(AppAlphas.borderTint),
        fg: AppColors.progressSuccess,
        border: AppColors.successContainer,
        remaining: AppColors.success,
      ),
      'DEFAULTED' => _LoanStatusStyle(
        label: 'DEFAULTED',
        bg: AppColors.darkBorder,
        fg: AppColors.darkOnSurface,
        border: AppColors.darkRim,
        remaining: AppColors.progressDanger,
      ),
      _ => _LoanStatusStyle(
        label: status.replaceAll('_', ' '),
        bg: AppColors.darkBorder,
        fg: AppColors.darkOnSurface,
        border: AppColors.darkRim,
        remaining: AppColors.darkOnSurfaceMuted,
      ),
    };
  }
}

class _LoanCardShell extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _LoanCardShell({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: AppColors.darkSurface.withAlpha(AppAlphas.badgeFill),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: child,
        ),
      ),
    );
  }
}

class _StatsFrame extends StatelessWidget {
  final Widget child;
  const _StatsFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withAlpha(AppAlphas.scrim),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: child,
    );
  }
}

class _LoanTile extends StatelessWidget {
  final LoanModel loan;
  const _LoanTile({required this.loan});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = text.labelMedium?.copyWith(
      color: AppColors.darkOnSurfaceMuted,
    );
    final s = _LoanStatusStyle.of(loan);

    final settled = loan.outstandingAmount <= 0;
    final remainingColor = settled ? AppColors.success : s.remaining;
    final collectedColor = loan.totalCollected > 0
        ? AppColors.success
        : AppColors.darkOnSurface;

    return _LoanCardShell(
      onTap: () => context.push(AppRoutes.loanDetail(loan.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppNameCard(
                name: loan.customerName ?? '',
                width: 44,
                height: 44,
                backgroundColor: s.bg,
                textColor: s.fg,
              ),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan.customerName ?? '',
                      style: text.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'call ${PhoneFormatter.display(loan.phoneNumber ?? '')}',
                      style: text.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AppGap.w8,
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppChip(
                    label: s.label,
                    backgroundColor: s.bg,
                    foregroundColor: s.fg,
                    borderColor: s.border,
                    textStyle: text.labelSmall,
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    loan.status.toUpperCase() == 'PAID_OFF'
                        ? 'Settled'
                        : '${CurrencyFormatter.format(loan.weeklyPayableAmount)}/wk',
                    style: text.bodySmall?.copyWith(
                      color: loan.status.toUpperCase() == 'PAID_OFF'
                          ? AppColors.success
                          : AppColors.darkOnSurfaceMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          AppGap.h12,
          _StatsFrame(
            child: Row(
              children: [
                Expanded(
                  child: _Stat(
                    label: 'Total Payable',
                    value: CurrencyFormatter.format(loan.totalPayableAmount),
                    valueStyle: text.headlineSmall,
                    labelStyle: muted,
                  ),
                ),
                Expanded(
                  child: _Stat(
                    label: 'Collected',
                    value: CurrencyFormatter.format(loan.totalCollected),
                    valueStyle: text.bodyLarge?.copyWith(
                      color: collectedColor,
                      fontWeight: FontWeight.w700,
                    ),
                    labelStyle: muted,
                  ),
                ),
                Expanded(
                  child: _Stat(
                    label: 'Remaining',
                    value: CurrencyFormatter.format(loan.outstandingAmount),
                    valueStyle: text.bodyLarge?.copyWith(
                      color: remainingColor,
                      fontWeight: FontWeight.w700,
                    ),
                    labelStyle: muted,
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ),
          AppGap.h12,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Disbursed: ${CurrencyFormatter.format(loan.disbursedAmount)}',
                style: muted,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View Ledger',
                    style: text.labelLarge?.copyWith(
                      color: AppColors.stepCurrentLabel,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.stepCurrentLabel,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final bool alignEnd;

  const _Stat({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: labelStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSizes.xs),
        FittedBox(
          fit:
              BoxFit.scaleDown,
          child: Text(value, style: valueStyle),
        ),
      ],
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

class _LoanListSkeleton extends StatelessWidget {
  final int count;
  const _LoanListSkeleton({this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppSizes.md,
      children: List.generate(count, (_) => const _LoanTileSkeleton()),
    );
  }
}

class _LoanTileSkeleton extends StatelessWidget {
  const _LoanTileSkeleton();

  Widget _statCol(double labelW, double valueW, {bool end = false}) {
    final align = end ? Alignment.centerRight : Alignment.centerLeft;
    return Expanded(
      child: Column(
        crossAxisAlignment: end
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          _bar(labelW, 16, barHeight: 10, align: align),
          const SizedBox(height: AppSizes.xs),
          _bar(valueW, 24, barHeight: 16, align: align),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _LoanCardShell(
      child: AppShimmer(
        // only layout widgets and SkeletonBox inside
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SkeletonBox(
                  width: 44,
                  height: 44,
                  radius: AppSizes.radiusMd,
                ),
                AppGap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bar(130, 24, barHeight: 14),
                      _bar(110, 16, barHeight: 10),
                    ],
                  ),
                ),
                AppGap.w8,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SkeletonBox(
                      width: 64,
                      height: 24,
                      radius: AppSizes.radiusFull,
                    ),
                    const SizedBox(height: AppSizes.xs),
                    _bar(52, 16, barHeight: 10, align: Alignment.centerRight),
                  ],
                ),
              ],
            ),
            AppGap.h12,
            _StatsFrame(
              child: Row(
                children: [
                  _statCol(70, 70),
                  _statCol(55, 55),
                  _statCol(55, 55, end: true),
                ],
              ),
            ),
            AppGap.h12,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _bar(110, 20, barHeight: 10),
                _bar(80, 20, barHeight: 10, align: Alignment.centerRight),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
