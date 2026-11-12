import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_icon_button.dart';
import 'package:micro_lending_app/common/widgets/app_name_card.dart';
import 'package:micro_lending_app/common/widgets/app_progress_bar.dart';
import 'package:micro_lending_app/common/widgets/app_skeleton.dart';
import 'package:micro_lending_app/common/widgets/call_icon_button.dart';
import 'package:micro_lending_app/common/widgets/state_views.dart';
import 'package:micro_lending_app/data/models/loan_model.dart';
import 'package:micro_lending_app/data/services/loan_service.dart';
import 'package:micro_lending_app/features/analytics/widgets/analytics_common.dart';
import 'package:micro_lending_app/routes/app_routes.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/utils/formatters/phone_formatter.dart';
import 'package:micro_lending_app/utils/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/utils/loggers/app_logger.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';

class DueListScreen extends StatefulWidget {
  final DateTime date;
  final double? target; // from the heatmap day
  final double? collected;
  final String? adminId;

  const DueListScreen({
    super.key,
    required this.date,
    this.target,
    this.collected,
    this.adminId,
  });

  @override
  State<DueListScreen> createState() => _DueListScreenState();
}

class _DueListScreenState extends State<DueListScreen> {
  static const _pageSize = 20;
  static const _trigger = 300.0;

  final _items = <LoanModel>[];
  final _scroll = ScrollController();
  final _search = TextEditingController();
  Timer? _debounce;
  Summary? _summary;
  String _query = '';
  bool _loading = true;
  bool _more = false;
  bool _hasNext = false;
  String? _error;
  int _page = 1;
  int _req = 0;

  late final String _weekday = DateFormatter.weekdayFull(widget.date);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final p = _scroll.position;
    if (p.pixels >= p.maxScrollExtent - _trigger) _next();
  }

  Future<void> _load({bool skeleton = true}) async {
    final id = ++_req;
    setState(() {
      if (skeleton) _loading = true;
      _error = null;
      _more = false;
    });

    try {
      final r = await LoanService.getCollectionsDue(
        weekday: _weekday,
        page: 1,
        limit: _pageSize,
        search: _query,
        issuedAdmin: widget.adminId ?? '',
      );
      if (!mounted || id != _req) return;
      setState(() {
        _items
          ..clear()
          ..addAll(r.result.items as Iterable<LoanModel>);
        _page = 1;
        _hasNext = r.result.hasNextPage;
        _summary = r.summary;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
    } on ApiException catch (e) {
      if (mounted && id == _req) setState(() => _error = e.message);
    } catch (e, st) {
      AppLogger.error('Due list failed', tag: 'Analytics', error: e, stack: st);
      if (mounted && id == _req) {
        setState(() => _error = 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted && id == _req) setState(() => _loading = false);
    }
  }

  Future<void> _next() async {
    if (_loading || _more || !_hasNext) return;
    final id = _req;
    setState(() => _more = true);
    try {
      final r = await LoanService.getCollectionsDue(
        weekday: _weekday,
        page: _page + 1,
        limit: _pageSize,
        search: _query,
        issuedAdmin: widget.adminId ?? '',
      );
      if (!mounted || id != _req) return;
      setState(() {
        final have = _items.map((l) => l.id).toSet();
        _items.addAll(
          r.result.items.where((l) => !have.contains(l.id))
              as Iterable<LoanModel>,
        );
        _page += 1;
        _hasNext = r.result.hasNextPage;
      });
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _more = false);
    }
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _query = v.trim();
      if (mounted) _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: AppIconButton(
          icon: Icons.arrow_back_ios,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Due list'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.lg,
                AppSizes.sm,
                AppSizes.lg,
                AppSizes.sm,
              ),
              child: _Header(
                date: widget.date,
                weekday: _weekday,
                target: widget.target,
                collected: widget.collected,
                summary: _summary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              child: TextField(
                controller: _search,
                onChanged: _onSearch,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Search by name or phone',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _load(skeleton: false),
                child: _list(text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(TextTheme text) {
    final pad = EdgeInsets.fromLTRB(
      AppSizes.lg,
      AppSizes.md,
      AppSizes.lg,
      AppSizes.bottomClearance,
    );
    const physics = AlwaysScrollableScrollPhysics();

    if (_loading) {
      return ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: pad,
        children: const [
          _TileSkeleton(),
          AppGap.h12,
          _TileSkeleton(),
          AppGap.h12,
          _TileSkeleton(),
        ],
      );
    }
    if (_error != null) {
      return ListView(
        physics: physics,
        padding: pad,
        children: [ErrorView(message: _error!, onRetry: () => _load())],
      );
    }
    if (_items.isEmpty) {
      return ListView(
        physics: physics,
        padding: pad,
        children: [
          EmptyView(
            icon: Icons.event_available_outlined,
            message: _query.isEmpty
                ? 'No loans are scheduled for $_weekday.'
                : 'No loans match "$_query".',
          ),
        ],
      );
    }

    return ListView.separated(
      controller: _scroll,
      physics: physics,
      padding: pad,
      itemCount: _items.length + 1,
      separatorBuilder: (_, _) => AppGap.h12,
      itemBuilder: (context, i) {
        if (i < _items.length) {
          final loan = _items[i];
          return _DueTile(
            loan: loan,
            onTap: () => context.push('${AppRoutes.loansList}/${loan.id}'),
          );
        }
        if (_more) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.md),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
          );
        }
        if (!_hasNext) {
          return Center(child: Text('No more loans', style: text.bodySmall));
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _Header extends StatelessWidget {
  final DateTime date;
  final String weekday;
  final double? target;
  final double? collected;
  final Summary? summary;

  const _Header({
    required this.date,
    required this.weekday,
    required this.target,
    required this.collected,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = text.labelMedium?.copyWith(
      color: AppColors.darkOnSurfaceMuted,
    );
    final t = target;
    final c = collected;
    final rate = (t != null && t > 0 && c != null)
        ? (c / t * 100).clamp(0, 999).toDouble()
        : null;

    return AnalyticsFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormatter.weekdayDate(date),
                  style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (rate != null)
                Pill('${rate.toStringAsFixed(0)}%', rateColor(rate)),
            ],
          ),
          if (t != null && c != null) ...[
            AppGap.h8,
            AppProgressBar(
              value: t <= 0 ? 0 : (c / t).clamp(0, 1).toDouble(),
              height: 8,
              semanticsLabel: 'Collected against target for the day',
            ),
            AppGap.h8,
            Text(
              '${Money.compact(c)} collected of ${Money.compact(t)} target',
              style: text.bodyMedium,
            ),
          ],
          AppGap.h8,
          Text(
            summary == null
                ? 'Loans scheduled for $weekday'
                : '${summary!.totalCustomers} customers • ${summary!.totalActiveLoans} active • '
                      '${summary!.totalOverdueLoans} overdue',
            style: muted,
          ),
          const SizedBox(height: 2),
          Text(
            'The list shows loans scheduled for $weekday as they stand now, '
            'not who paid on this date.',
            style: text.labelSmall?.copyWith(
              color: AppColors.darkOnSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _DueTile extends StatelessWidget {
  final LoanModel loan;
  final VoidCallback onTap;
  const _DueTile({required this.loan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final name = loan.customerName ?? '';
    final phone = loan.phoneNumber ?? '';
    final overdue = loan.status.toUpperCase() == 'OVERDUE' || loan.isOverdue;
    final due = loan.outstandingAmount <= 0
        ? 0.0
        : math.min(loan.weeklyPayableAmount, loan.outstandingAmount);

    return AnalyticsFrame(
      onTap: onTap,
      child: Row(
        children: [
          AppNameCard(name: name.isEmpty ? '?' : name, width: 44, height: 44),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Unknown' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (phone.isNotEmpty)
                  Text(PhoneFormatter.display(phone), style: text.labelMedium),
                const SizedBox(height: 4),
                Text(
                  'Outstanding ${Money.compact(loan.outstandingAmount)}',
                  style: text.labelMedium?.copyWith(
                    color: AppColors.darkOnSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
          AppGap.w8,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Money.compact(due),
                style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                'due',
                style: text.labelSmall?.copyWith(
                  color: AppColors.darkOnSurfaceMuted,
                ),
              ),
              const SizedBox(height: 4),
              Pill(
                overdue ? 'OVERDUE' : 'ON SCHEDULE',
                overdue ? AppColors.progressDanger : AppColors.success,
              ),
            ],
          ),
          if (phone.isNotEmpty) CallIconButton(phone: phone),
        ],
      ),
    );
  }
}

class _TileSkeleton extends StatelessWidget {
  const _TileSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AnalyticsFrame(
      child: AppShimmer(
        child: Row(
          children: [
            SkeletonBox(width: 44, height: 44, radius: AppSizes.radiusLg),
            SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 130, height: 14, radius: 4),
                  SizedBox(height: 8),
                  SkeletonBox(width: 90, height: 10, radius: 4),
                  SizedBox(height: 8),
                  SkeletonBox(width: 110, height: 10, radius: 4),
                ],
              ),
            ),
            SizedBox(width: AppSizes.md),
            SkeletonBox(width: 60, height: 32, radius: 6),
          ],
        ),
      ),
    );
  }
}
