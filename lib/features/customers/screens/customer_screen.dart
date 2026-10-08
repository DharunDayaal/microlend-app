import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_button.dart';
import 'package:micro_lending_app/common/widgets/app_chip_select.dart';
import 'package:micro_lending_app/common/widgets/app_name_card.dart';
import 'package:micro_lending_app/common/widgets/app_skeleton.dart';
import 'package:micro_lending_app/common/widgets/app_text_field.dart';
import 'package:micro_lending_app/common/widgets/call_icon_button.dart';
import 'package:micro_lending_app/common/widgets/state_views.dart';
import 'package:micro_lending_app/data/models/customer_model.dart';
import 'package:micro_lending_app/data/services/customer_service.dart';
import 'package:micro_lending_app/routes/app_routes.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/utils/formatters/phone_formatter.dart';
import 'package:micro_lending_app/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/utils/helpers/debouncer.dart';
import 'package:micro_lending_app/utils/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  static const _pageSize = 20;
  static const _loadMoreTrigger = 300.0;

  final _scroll = ScrollController();

  DashboardSummary? _summary;
  final List<Customer> _customers = [];

  String _weekday = DateFormatter.weekdayFull(DateTime.now());
  bool _summaryLoading = true;
  bool _listLoading = true;
  bool _loadingMore = false;
  bool _hasNext = false;
  bool _showFloatingActionButton = false;
  int _page = 1;
  String? _listError;
  String? _loadMoreError;
  String _activeSearch = '';

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

  /// Bumped on every first-page load. A response from an older request
  /// (before a refresh) is ignored.
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _loadSummary();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFirstPage());
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

  Future<void> _loadSummary({bool showSkeleton = true}) async {
    if (showSkeleton && !_summaryLoading) {
      setState(() => _summaryLoading = true);
    }
    try {
      final data = await CustomerService.getDashboardSummary();
      if (!mounted) return;
      setState(() => _summary = data);
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _summaryLoading = false);
    }
  }

  Future<void> _loadFirstPage({bool showSkeleton = true}) async {
    final id = ++_requestId;
    setState(() {
      if (showSkeleton) _listLoading = true;
      _listError = null;
      _loadMoreError = null;
      _loadingMore = false;
    });

    _activeSearch = _searchController.text.trim();

    try {
      final result = await CustomerService.getCustomersByWeekday(
        weekday: _weekday,
        page: 1,
        limit: _pageSize,
        search: _activeSearch,
      );
      if (!mounted || id != _requestId) return;

      setState(() {
        _customers
          ..clear()
          ..addAll(result.items);
        _page = 1;
        _hasNext = result.hasNextPage;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
    } on ApiException catch (e) {
      if (mounted && id == _requestId) setState(() => _listError = e.message);
    } finally {
      if (mounted && id == _requestId) setState(() => _listLoading = false);
    }
  }

  Future<void> _loadNextPage() async {
    if (_listLoading || _loadingMore || !_hasNext || _loadMoreError != null) {
      return;
    }

    final id = _requestId;
    setState(() => _loadingMore = true);
    try {
      final result = await CustomerService.getCustomersByWeekday(
        weekday: _weekday,
        page: _page + 1,
        limit: _pageSize,
        search: _activeSearch,
      );
      if (!mounted || id != _requestId) return;

      setState(() {
        _customers.addAll(result.items);
        _page += 1;
        _hasNext = result.hasNextPage;
      });
    } on ApiException catch (e) {
      if (mounted && id == _requestId) {
        setState(() => _loadMoreError = e.message);
      }
    } finally {
      if (mounted && id == _requestId) setState(() => _loadingMore = false);
    }
  }

  void _retryLoadMore() {
    setState(() => _loadMoreError = null);
    _loadNextPage();
  }

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
    final textTheme = Theme.of(context).textTheme;
    final pad = AppSpacing.screen(context);

    return Scaffold(
      floatingActionButton: _showFloatingActionButton
          ? AppButton(
              label: "Add Borrower",
              onPressed: () {},
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
                    hint: "Search borrower, street, city, district...",
                    controller: _searchController,
                    onChanged: _onSearchChanged,
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
                          label: option["label"]!,
                        ),
                    ],
                  ),
                  Text(
                    "${TextFormatter.titleCase(_weekday)} Batch",
                    style: textTheme.headlineSmall,
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
        children: const [
          EmptyView(
            icon: Icons.people_outline,
            message: 'No customers scheduled',
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
            child: const Text('Tap to retry'),
          ),
        ],
      );
    }

    if (!_hasNext) {
      return Center(
        child: Text(
          'No more customers',
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
          Text("TODAY's TARGET ROUTE", style: textTheme.labelLarge),
          AppGap.h4,
          _summaryLoading
              ? const AppShimmer(child: SkeletonBox(width: 160, height: 36))
              : Text.rich(
                  TextSpan(
                    text: CurrencyFormatter.format(_summary?.totalTarget),
                    style: textTheme.displaySmall?.copyWith(
                      color: AppColors.stepCurrentLabel,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: " due",
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
          AppGap.h16,
          Row(
            children: [
              Expanded(
                child: _statTile(
                  icon: Icons.check_circle_outline_outlined,
                  color: AppColors.success,
                  title: "Collected",
                  value: CurrencyFormatter.format(_summary?.totalCollected),
                  textTheme: textTheme,
                ),
              ),
              AppGap.w12,
              Expanded(
                child: _statTile(
                  icon: Icons.pending_actions_outlined,
                  color: AppColors.progressWarning,
                  title: "Pending",
                  value: "${_summary?.borrowersPending ?? 0} Borrowers",
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
                      '${customer.streetName ?? 'N/A'} • ${customer.district}',
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
