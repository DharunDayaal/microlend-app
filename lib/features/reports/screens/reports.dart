import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/data/models/analytics_model.dart';
import 'package:micro_lending_app/data/models/user_role_model.dart';
import 'package:micro_lending_app/data/services/analytics_service.dart';
import 'package:micro_lending_app/features/analytics/analytics_filter.dart';
import 'package:micro_lending_app/features/analytics/widgets/analytics_cards.dart';
import 'package:micro_lending_app/features/analytics/widgets/analytics_cards_more.dart';
import 'package:micro_lending_app/features/analytics/widgets/analytics_filter_bar.dart';
import 'package:micro_lending_app/features/analytics/widgets/offline_banner.dart';
import 'package:micro_lending_app/features/reports/widgets/report_cards.dart';
import 'package:micro_lending_app/routes/app_routes.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/session/current_user.dart';

const _jumpIds = ['trend', 'calendar', 'risk', 'aging', 'weekday', 'maturing'];

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // Date range only. No admin or employee: Reports is always the caller's own scope.
  final _f = AnalyticsFilters();
  final _scroll = ScrollController();
  final _keys = {for (final k in _jumpIds) k: GlobalKey()};

  int _tick = 0; // makes the three classic reports refetch on pull-to-refresh
  int _maturingDays = 14;

  bool get _isAdmin => CurrentUser.instance.hasRole(UserRole.admin);

  @override
  void dispose() {
    _f.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ---------- jumps ----------

  Future<void> _jump(String id) async {
    final fast = MediaQuery.disableAnimationsOf(context);
    if (_keys[id]?.currentContext == null && _scroll.hasClients) {
      _scroll.jumpTo(0); // lists build lazily; walk down from the top
    }
    for (var i = 0; i < 10; i++) {
      if (!mounted) return;
      final ctx = _keys[id]?.currentContext;
      if (ctx != null) {
        if (!ctx.mounted) return;
        await Scrollable.ensureVisible(
          ctx,
          alignment: 0.05,
          duration: fast ? Duration.zero : const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
        return;
      }
      if (!_scroll.hasClients) return;
      final p = _scroll.position;
      if (p.pixels >= p.maxScrollExtent) return;
      _scroll.jumpTo((p.pixels + 600).clamp(0, p.maxScrollExtent));
      await WidgetsBinding.instance.endOfFrame;
    }
  }

  void _onInsight(Insight i) {
    final a = i.action;
    if (a == null) return;
    switch (a.screen) {
      case 'collection_calendar':
        _jump('calendar');
      case 'collections_by_weekday':
        _jump('weekday');
      case 'portfolio_aging':
        _jump('aging');
      case 'customer_risk':
        _jump('risk');
      case 'maturing_loans':
        final d = num.tryParse('${a.params['days']}')?.round() ?? 14;
        setState(() => _maturingDays = d.clamp(1, 90));
        _jump('maturing');
      case 'employee_detail':
        if (_isAdmin) context.push(AppRoutes.analytics);
    }
  }

  void _onKpi(String key) => _jump(switch (key) {
    'collected' || 'collection_rate' => 'trend',
    'overdue' || 'new_customers' => 'risk',
    _ => 'aging',
  });

  Future<void> _refresh() async {
    setState(() => _tick++);
    _f.refresh(); // analytics cards refetch
    await AnalyticsService.settled();
  }

  // ---------- content ----------

  List<(String?, Widget)> _sections() {
    final f = _f;
    const l =
        'admin'; // the cards take a level; the service picks the route by role

    return [
      if (_isAdmin) (null, const _AdvancedBanner()),
      (null, InsightsCard(f: f, level: l, onAction: _onInsight)),
      (null, CashOutstandingCard(tick: _tick)),
      (null, ReportEarningsCard(tick: _tick)),
      (null, PulseKpiGrid(f: f, onTap: _onKpi)),
      (null, CollectedNowCard(f: f)),
      ('trend', TrendCard(f: f, level: l)),
      ('calendar', CalendarCard(f: f, level: l)),
      (null, OverdueCard(tick: _tick)),
      ('risk', RiskCard(f: f)),
      ('aging', AgingCard(f: f, level: l)),
      ('weekday', WeekdayCard(f: f, level: l)),
      (null, ForecastCard(f: f)),
      ('maturing', MaturingCard(f: f, days: _maturingDays)),
      (null, ReferralsCard(f: f)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    // The shell draws the app bar; this is only the body.
    return ListenableBuilder(
      listenable: _f,
      builder: (context, _) {
        final items = _sections();

        return Column(
          children: [
            AnalyticsFilterBar(f: _f, showAdmin: false, showEmployee: false),
            const OfflineBanner(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  controller: _scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollCacheExtent: ScrollCacheExtent.pixels(800),
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.lg,
                    AppSizes.sm,
                    AppSizes.lg,
                    AppSizes.bottomClearance,
                  ),
                  itemCount: items.length + 1,
                  itemBuilder: (context, i) {
                    if (i == items.length) {
                      return ValueListenableBuilder<AnalyticsStatus>(
                        valueListenable: AnalyticsService.connection,
                        builder: (_, s, _) => Text(
                          s.updatedAt == null
                              ? 'Pull down to refresh.'
                              : 'Updated ${agoLabel(s.updatedAt!)}. Pull down to refresh.',
                          textAlign: TextAlign.center,
                          style: text.labelSmall?.copyWith(
                            color: AppColors.darkOnSurfaceMuted,
                          ),
                        ),
                      );
                    }
                    final (id, w) = items[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.md),
                      child: id == null
                          ? w
                          : KeyedSubtree(key: _keys[id], child: w),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AdvancedBanner extends StatelessWidget {
  const _AdvancedBanner();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: 'Advanced analytics. Trends, cohorts and team performance.',
      child: Material(
        color: AppColors.stepCurrentLabel.withAlpha(24),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(AppRoutes.analytics),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              children: [
                const Icon(
                  Icons.insights_outlined,
                  color: AppColors.stepCurrentLabel,
                ),
                AppGap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Advanced analytics',
                        style: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Trends, cohorts and team performance',
                        style: text.labelMedium?.copyWith(
                          color: AppColors.darkOnSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
