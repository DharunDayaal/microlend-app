import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/widgets/app_icon_button.dart';
import 'package:micro_lending_app/common/widgets/app_name_card.dart';
import 'package:micro_lending_app/common/widgets/app_skeleton.dart';
import 'package:micro_lending_app/common/widgets/app_text_field.dart';
import 'package:micro_lending_app/common/widgets/state_views.dart';
import 'package:micro_lending_app/data/models/customer_model.dart';
import 'package:micro_lending_app/data/models/paged_modal.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/phone_formatter.dart';
import 'package:micro_lending_app/utils/helpers/debouncer.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';

typedef ReferrerLoader = Future<PagedResult<Customer>> Function(
  int page,
  String search,
);

class ReferralSelectionSheet extends StatefulWidget {
  final ReferrerLoader loader;
  final String? selectedId;

  const ReferralSelectionSheet({
    super.key,
    required this.loader,
    required this.selectedId,
  });

  static Future<Customer?> show(
    BuildContext context, {
    required ReferrerLoader loader,
    String? selectedId,
  }) {
    return showModalBottomSheet<Customer>(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (context) => Padding(
        // lifts the sheet above the keyboard
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: FractionallySizedBox(
          heightFactor: 0.85, // fixed height, so Expanded works inside
          child: ReferralSelectionSheet(loader: loader, selectedId: selectedId),
        ),
      ),
    );
  }

  @override
  State<ReferralSelectionSheet> createState() => _ReferralSelectionSheetState();
}

class _ReferralSelectionSheetState extends State<ReferralSelectionSheet> {
  final _scroll = ScrollController();
  final _debouncer = Debouncer();
  final _search = TextEditingController();

  final List<Customer> _items = [];
  int _page = 1;
  bool _hasNext = false;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _loadFirst();
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _debouncer.dispose();
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.hasClients &&
        _scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadFirst() async {
    final id = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await widget.loader(1, _search.text.trim());
      if (!mounted || id != _requestId) return;
      setState(() {
        _items
          ..clear()
          ..addAll(response.items);
        _page = 1;
        _hasNext = response.hasNextPage;
      });
    } on ApiException catch (e) {
      if (mounted && id == _requestId) setState(() => _error = e.message);
    } finally {
      if (mounted && id == _requestId) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasNext) return;
    final id = _requestId;
    setState(() => _loadingMore = true);

    try {
      final response = await widget.loader(_page + 1, _search.text.trim());
      if (!mounted || id != _requestId) return; // was `==`
      setState(() {
        _items.addAll(response.items);
        _page += 1;
        _hasNext = response.hasNextPage;
      });
    } on ApiException {
      // the next scroll tries again
    } finally {
      if (mounted && id == _requestId) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSizes.md),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.lg,
              AppSizes.md,
              AppSizes.sm,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Referring Borrower',
                    style: textTheme.headlineSmall,
                  ),
                ),
                AppIconButton(
                  icon: Icons.close,
                  color: AppColors.darkOnSurface,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.lg,
              AppSizes.sm,
              AppSizes.lg,
              AppSizes.md,
            ),
            child: AppTextField(
              label: '',
              showHeader: false,
              prefixIcon: Icons.search,
              hint: 'Search by name or phone',
              controller: _search,
              onChanged: (_) => _debouncer.run(_loadFirst),
            ),
          ),
          Expanded(child: _body(textTheme)),
        ],
      ),
    );
  }

  Widget _body(TextTheme textTheme) {
    if (_loading) {
      return ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
        children: List.generate(
          5,
          (_) => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
            child: AppShimmer(
              child: SkeletonBox(height: 56, radius: AppSizes.radiusMd),
            ),
          ),
        ),
      );
    }

    if (_error != null) return ErrorView(message: _error!, onRetry: _loadFirst);

    if (_items.isEmpty) {
      return const EmptyView(
        icon: Icons.people_outline,
        message: 'No referrers found',
      );
    }

    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
      itemCount: _items.length + (_loadingMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == _items.length) {
          return const Padding(
            padding: EdgeInsets.all(AppSizes.lg),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final c = _items[i];
        final selected = c.id == widget.selectedId;

        return ListTile(
          style: ListTileStyle.drawer,
          leading: AppNameCard(
            name: c.customerName,
            textColor: AppColors.stepCurrentLabel,
            backgroundColor: AppColors.darkRim.withAlpha(AppAlphas.badgeFill),
          ),
          title: Text(c.customerName, style: textTheme.bodyLarge),
          subtitle: Text(
            "${PhoneFormatter.display(c.phoneNumber)} • ${c.city}",
          ),
          trailing: selected
              ? const Icon(Icons.check_circle, color: AppColors.success)
              : const Icon(Icons.chevron_right_rounded, size: AppSizes.xl + 4),
          onTap: () => Navigator.of(context).pop(c),
        );
      },
    );
  }
}
