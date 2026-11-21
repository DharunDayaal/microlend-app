import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/l10n/l10n_labels.dart';
import 'package:micro_lending_app/shared/design_system/styles/spacing_style.dart';
import 'package:micro_lending_app/shared/widgets/app_button.dart';
import 'package:micro_lending_app/shared/widgets/app_chip_select.dart';
import 'package:micro_lending_app/shared/widgets/app_name_card.dart';
import 'package:micro_lending_app/shared/widgets/app_skeleton.dart';
import 'package:micro_lending_app/shared/widgets/app_text_field.dart';
import 'package:micro_lending_app/shared/widgets/call_icon_button.dart';
import 'package:micro_lending_app/shared/widgets/progress_ring.dart';
import 'package:micro_lending_app/shared/widgets/state_views.dart';
import 'package:micro_lending_app/features/customers/domain/entities/customer.dart';
import 'package:micro_lending_app/features/customers/presentation/controllers/customers_list_controller.dart';
import 'package:micro_lending_app/features/customers/presentation/controllers/dashboard_summary_controller.dart';
import 'package:micro_lending_app/shared/pagination/paged_state.dart';
import 'package:micro_lending_app/app/router/app_routes.dart';
import 'package:micro_lending_app/shared/design_system/constants/alphas.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';
import 'package:micro_lending_app/core/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/phone_formatter.dart';
import 'package:micro_lending_app/core/utils/debouncer.dart';
import 'package:micro_lending_app/shared/helpers/snackbar_helper.dart';

class CustomerScreen extends ConsumerStatefulWidget {
  const CustomerScreen({super.key});

  @override
  ConsumerState<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends ConsumerState<CustomerScreen> {
  static const _loadMoreTrigger = 300.0;

  final _scroll = ScrollController();

  String _weekday = DateFormatter.weekdayFull(DateTime.now());
  bool _showFloatingActionButton = false;

  // ---------- state lives in the controllers ----------

  CustomersListController get _list => ref.read(customersListProvider.notifier);
  PagedState<Customer> get _p => ref.read(customersListProvider);
  DashboardSummaryState get _d => ref.read(dashboardSummaryProvider);

  List<Customer> get _customers => _p.items;
  bool get _listLoading => _p.isLoading;
  bool get _loadingMore => _p.isLoadingMore;
  bool get _hasNext => _p.hasNext;
  String? get _listError => _p.error;
  String? get _loadMoreError => _p.loadMoreError;
  DashboardSummary? get _summary => _d.summary;
  bool get _summaryLoading => _d.isLoading;

  final List<Map<String, String>> _weekdayOptions = [
    {"value": "MONDAY", "label": "MON"},
    {"value": "TUESDAY", "label": "TUE"},
    {"value": "WEDNESDAY", "label": "WED"},
    {"value": "THURSDAY", "label": "THR"},
    {"value": "FRIDAY", "label": "FRI"},
    {"value": "SATURDAY", "label": "SAT"},
    {"value": "SUNDAY", "label": "SUN"},
  ];

  final _searchController = TextEditingController();
  final _searchDebouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    // After the first frame, so build() has subscribed to the providers.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSummary();
      _loadFirstPage();
    });
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _searchController.dispose();
    _scroll.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    final direction = position.userScrollDirection;

    if (direction == ScrollDirection.reverse) {
      if (!_showFloatingActionButton) {
        setState(() => _showFloatingActionButton = true);
      }
    } else if (direction == ScrollDirection.forward || position.pixels <= 0) {
      if (_showFloatingActionButton) {
        setState(() => _showFloatingActionButton = false);
      }
    }

    if (position.pixels >= position.maxScrollExtent - _loadMoreTrigger) {
      _loadNextPage();
    }
  }

  Future<void> _loadSummary({bool showSkeleton = true}) => ref
      .read(dashboardSummaryProvider.notifier)
      .load(
        showSkeleton: showSkeleton,
        onError: (message) {
          if (mounted) AppSnackbar.error(context, message);
        },
      );

  Future<void> _loadFirstPage({bool showSkeleton = true}) => _list.load(
    weekday: _weekday,
    search: _searchController.text.trim(),
    showSkeleton: showSkeleton,
  );

  void _loadNextPage() => _list.loadMore();

  void _retryLoadMore() => _list.retryLoadMore();

  Future<void> _refresh() {
    return Future.wait([
      _loadSummary(showSkeleton: false),
      _loadFirstPage(showSkeleton: false),
    ]);
  }

  void _onSearchChanged(String value) {
    _searchDebouncer.run(() => _loadFirstPage());
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(customersListProvider);
    ref.watch(dashboardSummaryProvider);
    // a short first page may not fill the screen: check for more right away
    ref.listen(customersListProvider.select((s) => s.generation), (_, _) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
    });
    final textTheme = Theme.of(context).textTheme;
    final pad = AppSpacing.screen(context);

    return Scaffold(
      floatingActionButton: _showFloatingActionButton
          ? AppButton(
              label: context.l10n.custAddBorrower,
              onPressed: () => context.push(AppRoutes.addCustomer),
              prefixIcon: Icons.person_outline_rounded,
              width: 180,
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(pad.left, pad.top, pad.right, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSizes.md,
                children: [
                  _summaryCard(textTheme),
                  AppTextField(
                    label: "",
                    showHeader: false,
                    prefixIcon: Icons.search,
                    hint: context.l10n.custSearchHint,
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.done,
                  ),
                  AppChipSelect(
                    selected: _weekday,
                    onSelected: (value) {
                      setState(() => _weekday = value);
                      _loadFirstPage();
                    },
                    padding: EdgeInsets.all(0),
                    options: [
                      for (final option in _weekdayOptions)
                        ChipOption(
                          value: option["value"]!,
                          label: weekdayLabel(
                            context,
                            option["value"]!,
                            short: true,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    context.l10n.custDayBatch(weekdayLabel(context, _weekday)),
                    style: textTheme.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppGap.h4,
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: _customerList(pad),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customerList(EdgeInsets pad) {
    final padding = EdgeInsets.fromLTRB(
      pad.left,
      AppSizes.md,
      pad.right,
      AppSizes.bottomClearance,
    );
    const physics = AlwaysScrollableScrollPhysics();

    if (_listLoading) {
      return ListView(
        physics: physics,
        padding: padding,
        children: const [_CustomerListSkeleton()],
      );
    }

    if (_listError != null) {
      return ListView(
        physics: physics,
        padding: padding,
        children: [ErrorView(message: _listError!, onRetry: _loadFirstPage)],
      );
    }

    if (_customers.isEmpty) {
      return ListView(
        physics: physics,
        padding: padding,
        children: [
          EmptyView(
            icon: Icons.people_outline,
            message: context.l10n.custNoneScheduled,
          ),
        ],
      );
    }

    return ListView.separated(
      controller: _scroll,
      physics: physics,
      padding: padding,
      itemCount: _customers.length + 1,
      separatorBuilder: (context, index) => AppGap.h12,
      itemBuilder: (_, i) => i == _customers.length
          ? _listFooter()
          : _CustomerTile(customer: _customers[i]),
    );
  }

  Widget _listFooter() {
    if (_loadingMore) return const _CustomerListSkeleton(count: 2);

    if (_loadMoreError != null) {
      return Column(
        children: [
          Text(_loadMoreError!, textAlign: TextAlign.center),
          TextButton(
            onPressed: _retryLoadMore,
            child: Text(context.l10n.commonTapToRetry),
          ),
        ],
      );
    }

    if (!_hasNext) {
      return Center(
        child: Text(
          context.l10n.custNoMore,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _summaryCard(TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withAlpha(AppAlphas.badgeFill),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.custTodaysTarget,
                      style: textTheme.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppGap.h4,
                    _summaryLoading
                        ? const AppShimmer(
                            child: SkeletonBox(width: 160, height: 36),
                          )
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text.rich(
                              TextSpan(
                                text: CurrencyFormatter.format(
                                  _summary?.totalTarget,
                                ),
                                style: textTheme.displaySmall?.copyWith(
                                  color: AppColors.stepCurrentLabel,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: context.l10n.custDueSuffix,
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              AppGap.w12,
              _summaryLoading
                  ? const AppShimmer(
                      child: SkeletonBox(
                        width: 76,
                        height: 76,
                        radius: AppSizes.radiusFull,
                      ),
                    )
                  : ProgressRing(
                      value: (_summary?.totalTarget ?? 0) > 0
                          ? (_summary!.totalCollected) / _summary!.totalTarget
                          : 0,
                    ),
            ],
          ),
          AppGap.h16,
          Row(
            children: [
              Expanded(
                child: _statTile(
                  icon: Icons.check_circle_outline_outlined,
                  color: AppColors.success,
                  title: context.l10n.custCollected,
                  value: CurrencyFormatter.format(_summary?.totalCollected),
                  textTheme: textTheme,
                ),
              ),
              AppGap.w12,
              Expanded(
                child: _statTile(
                  icon: Icons.pending_actions_outlined,
                  color: AppColors.progressWarning,
                  title: context.l10n.custPending,
                  value: context.l10n.custBorrowersCount(
                    _summary?.borrowersPending ?? 0,
                  ),
                  textTheme: textTheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required TextTheme textTheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.darkBorder.withAlpha(AppAlphas.badgeFill),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppSizes.lg, color: color),
              AppGap.w8,
              Text(title),
            ],
          ),
          AppGap.h12,
          _summaryLoading
              ? const AppShimmer(child: SkeletonBox(width: 90, height: 24))
              : Text(
                  value,
                  style: textTheme.headlineSmall?.copyWith(color: color),
                ),
        ],
      ),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  final Customer customer;
  const _CustomerTile({required this.customer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.customerDetail(customer.id)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.md,
          ),
          child: Row(
            children: [
              AppNameCard(name: customer.customerName),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      PhoneFormatter.display(customer.phoneNumber),
                      style: theme.textTheme.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${customer.streetName ?? context.l10n.commonNA} • ${customer.district}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              CallIconButton(phone: customer.phoneNumber),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerListSkeleton extends StatelessWidget {
  final int count;
  const _CustomerListSkeleton({this.count = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppSizes.sm,
      children: List.generate(
        count,
        (_) => Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: AppShimmer(
              child: Row(
                children: [
                  const SkeletonBox(height: 40, circle: true),
                  AppGap.w12,
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 140, height: 16),
                        SizedBox(height: AppSizes.sm),
                        SkeletonBox(width: 100, height: 12),
                      ],
                    ),
                  ),
                  const SkeletonBox(height: 32, circle: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
