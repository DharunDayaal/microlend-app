import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/shared/design_system/styles/spacing_style.dart';
import 'package:micro_lending_app/shared/widgets/app_chip_select.dart';
import 'package:micro_lending_app/shared/widgets/app_name_card.dart';
import 'package:micro_lending_app/shared/widgets/app_skeleton.dart';
import 'package:micro_lending_app/shared/widgets/app_status_chip.dart';
import 'package:micro_lending_app/shared/widgets/app_text_field.dart';
import 'package:micro_lending_app/shared/widgets/state_views.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';
import 'package:micro_lending_app/features/loans/presentation/controllers/loans_list_controller.dart';
import 'package:micro_lending_app/shared/pagination/paged_state.dart';
import 'package:micro_lending_app/app/router/app_routes.dart';
import 'package:micro_lending_app/shared/design_system/constants/alphas.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';
import 'package:micro_lending_app/core/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/phone_formatter.dart';
import 'package:micro_lending_app/core/utils/debouncer.dart';

/// Status filter chips: (API value, translated label).
List<(String, String)> _loanStatuses(BuildContext context) {
  final l = context.l10n;
  return [
    ('', l.loansFilterAll),
    ('ACTIVE', l.loansFilterActive),
    ('OVERDUE', l.loansFilterOverdue),
    ('PAID_OFF', l.loansFilterPaidOff),
    ('DEFAULTED', l.loansFilterDefaulted),
    ('CLOSED', l.loansFilterClosed),
  ];
}

class LoansScreen extends ConsumerStatefulWidget {
  const LoansScreen({super.key});

  @override
  ConsumerState<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends ConsumerState<LoansScreen> {
  static const _loadMoreTrigger = 300.0;

  /// The selected status chip ('' = all).
  String _status = '';

  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _debouncer = Debouncer();

  LoansListController get _list => ref.read(loansListProvider.notifier);
  PagedState<LoanModel> get _s => ref.read(loansListProvider);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
      _list.loadMore();
    }
  }

  Future<void> _listLoans({bool showSkeleton = true}) => _list.load(
    search: _searchController.text.trim(),
    status: _status,
    showSkeleton: showSkeleton,
  );

  /// Opens a loan. If it changed there (payment, status), the list reloads
  /// in place so the row shows the new balance and status.
  Future<void> _openLoan(LoanModel loan) async {
    final changed = await context.push<bool>(AppRoutes.loanDetail(loan.id));
    if (changed == true && mounted) await _listLoans(showSkeleton: false);
  }

  void _onSearchChanged(String value) {
    _debouncer.run(() => _listLoans());
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loansListProvider);
    // a short first page may not fill the screen: check for more right away
    ref.listen(loansListProvider.select((s) => s.generation), (_, _) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
    });
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
                    hint: context.l10n.loansSearchHint,
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
                      for (final (value, label) in _loanStatuses(context))
                        ChipOption(value: value, label: label),
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

    if (_s.isLoading) {
      return ListView(
        physics: physics,
        padding: padding,
        children: const [_LoanListSkeleton()],
      );
    }

    if (_s.error != null) {
      return ListView(
        physics: physics,
        padding: padding,
        children: [ErrorView(message: _s.error!, onRetry: () => _listLoans())],
      );
    }

    if (_s.items.isEmpty) {
      return ListView(
        physics: physics,
        padding: padding,
        children: [
          EmptyView(
            icon: Icons.receipt_long_outlined,
            message: context.l10n.loansNoneFound,
          ),
        ],
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: physics,
      padding: padding,
      itemCount: _s.items.length + 1,
      separatorBuilder: (_, _) => AppGap.h12,
      itemBuilder: (_, i) => i == _s.items.length
          ? _listFooter()
          : _LoanTile(loan: _s.items[i], onTap: () => _openLoan(_s.items[i])),
    );
  }

  Widget _listFooter() {
    if (_s.isLoadingMore) return const _LoanListSkeleton(count: 1);

    if (_s.loadMoreError != null) {
      return Column(
        children: [
          Text(_s.loadMoreError!, textAlign: TextAlign.center),
          TextButton(
            onPressed: _list.retryLoadMore,
            child: Text(context.l10n.commonTapToRetry),
          ),
        ],
      );
    }

    if (!_s.hasNext) {
      return Center(
        child: Text(
          context.l10n.loansNoMore,
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

  static _LoanStatusStyle of(BuildContext context, LoanModel loan) {
    final l = context.l10n;
    var status = loan.status.toUpperCase();
    // the API can flag a still-ACTIVE loan as overdue
    if (status == 'ACTIVE' && loan.isOverdueNow) status = 'OVERDUE';

    return switch (status) {
      'ACTIVE' => _LoanStatusStyle(
        label: l.loanStageActive,
        bg: AppColors.darkBorder,
        fg: AppColors.darkOnSurface,
        border: AppColors.darkRim,
        remaining: AppColors.warning,
      ),
      'OVERDUE' => _LoanStatusStyle(
        label: l.statusOverdue,
        bg: AppColors.dangerContainer.withAlpha(AppAlphas.borderTint),
        fg: AppColors.progressDanger,
        border: AppColors.dangerContainer,
        remaining: AppColors.progressDanger,
      ),
      'PAID_OFF' => _LoanStatusStyle(
        label: l.loanStagePaidOff,
        bg: AppColors.successContainer.withAlpha(AppAlphas.borderTint),
        fg: AppColors.progressSuccess,
        border: AppColors.successContainer,
        remaining: AppColors.success,
      ),
      'DEFAULTED' => _LoanStatusStyle(
        label: l.loanStageDefaulted,
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
  final VoidCallback onTap;
  const _LoanTile({required this.loan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = text.labelMedium?.copyWith(
      color: AppColors.darkOnSurfaceMuted,
    );
    final s = _LoanStatusStyle.of(context, loan);

    final settled = loan.outstandingAmount <= 0;
    final remainingColor = settled ? AppColors.success : s.remaining;
    final collectedColor = loan.totalCollected > 0
        ? AppColors.success
        : AppColors.darkOnSurface;

    return _LoanCardShell(
      onTap: onTap,
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
                      context.l10n.loansCallPhone(
                        PhoneFormatter.display(loan.phoneNumber ?? ''),
                      ),
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
                        ? context.l10n.loansSettled
                        : context.l10n.loansPerWeek(
                            CurrencyFormatter.format(loan.weeklyPayableAmount),
                          ),
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
                    label: context.l10n.loansTotalPayable,
                    value: CurrencyFormatter.format(loan.totalPayableAmount),
                    valueStyle: text.headlineSmall,
                    labelStyle: muted,
                  ),
                ),
                Expanded(
                  child: _Stat(
                    label: context.l10n.loansCollected,
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
                    label: context.l10n.loansRemaining,
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
              Expanded(
                child: Text(
                  context.l10n.loansDisbursed(
                    CurrencyFormatter.format(loan.disbursedAmount),
                  ),
                  style: muted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppGap.w8,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.loansViewLedger,
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
          fit: BoxFit.scaleDown,
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
