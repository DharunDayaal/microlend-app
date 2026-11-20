import 'package:flutter/material.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/l10n/l10n_labels.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_icon_button.dart';
import 'package:micro_lending_app/data/models/analytics_model.dart';
import 'package:micro_lending_app/data/models/export_model.dart';
import 'package:micro_lending_app/data/models/user_role_model.dart';
import 'package:micro_lending_app/data/services/analytics_service.dart';
import 'package:micro_lending_app/features/analytics/analytics_filter.dart';
import 'package:micro_lending_app/features/analytics/widgets/analytics_cards.dart';
import 'package:micro_lending_app/features/analytics/widgets/analytics_cards_more.dart';
import 'package:micro_lending_app/features/analytics/widgets/analytics_filter_bar.dart';
import 'package:micro_lending_app/features/analytics/widgets/analytics_platform_cards.dart';
import 'package:micro_lending_app/features/exports/widgets/export_sheet.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/session/current_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _Seg { analytics, platform }

enum _Tab { pulse, collections, portfolio, customers, team, forecast }

enum _PTab { admins, money, risk, geography, people }

/// Tab names in [_Tab] order.
List<String> _tabLabels(BuildContext context) {
  final l = context.l10n;
  return [
    l.anTabPulse,
    l.anTabCollections,
    l.anTabPortfolio,
    l.anTabCustomers,
    l.anTabTeam,
    l.anTabForecast,
  ];
}

/// Tab names in [_PTab] order.
List<String> _pTabLabels(BuildContext context) {
  final l = context.l10n;
  return [
    l.anTabAdmins,
    l.anTabMoney,
    l.anTabRisk,
    l.anTabGeography,
    l.anTabPeople,
  ];
}

const _kPreset = 'analytics_preset';
const _kFrom = 'analytics_from';
const _kTo = 'analytics_to';
const _kTab = 'analytics_tab';

String _ago(BuildContext context, DateTime t) => agoText(context, t);

class AdvancedAnalyticsScreen extends StatefulWidget {
  const AdvancedAnalyticsScreen({super.key});

  @override
  State<AdvancedAnalyticsScreen> createState() =>
      _AdvancedAnalyticsScreenState();
}

class _AdvancedAnalyticsScreenState extends State<AdvancedAnalyticsScreen> {
  final _f = AnalyticsFilters(); // Analytics
  final _pf = AnalyticsFilters(); // Platform (date range only)

  _Seg _seg = _Seg.analytics;
  _Tab _tab = _Tab.pulse;
  _PTab _ptab = _PTab.admins;
  int _maturingDays = 14;
  bool _ready = false;

  bool get _isSuper => CurrentUser.instance.isSuperAdmin;
  bool get _platform => _seg == _Seg.platform && _isSuper;
  AnalyticsFilters get _cur => _platform ? _pf : _f;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  @override
  void dispose() {
    _f.removeListener(_saveRange);
    _f.dispose();
    _pf.dispose();
    super.dispose();
  }

  // ---------- saved filters ----------

  Future<void> _restore() async {
    try {
      final p = await SharedPreferences.getInstance();
      final preset = p.getString(_kPreset);
      if (preset == 'custom') {
        final from = DateTime.tryParse(p.getString(_kFrom) ?? '');
        final to = DateTime.tryParse(p.getString(_kTo) ?? '');
        if (from != null && to != null) _f.apply('custom', from, to);
      } else if (preset != null) {
        final r = AnalyticsFilters.rangeFor(
          preset,
        ); // "last 30 days" stays current
        _f.apply(preset, r.$1, r.$2);
      }
      final tab = p.getInt(_kTab);
      if (tab != null && tab >= 0 && tab < _Tab.values.length) {
        _tab = _Tab.values[tab];
      }
    } catch (_) {
      // the defaults are fine
    }
    if (!mounted) return;
    _f.addListener(_saveRange);
    setState(() => _ready = true);

    // warm the calendar once the first chip has had a moment
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && !_platform) {
        AnalyticsService.prefetchCalendar(_f.scope('admin'));
      }
    });
  }

  Future<void> _saveRange() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_kPreset, _f.preset);
      await p.setString(_kFrom, _f.fromStr);
      await p.setString(_kTo, _f.toStr);
    } catch (_) {}
  }

  Future<void> _saveTab(int i) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt(_kTab, i);
    } catch (_) {}
  }

  void _setTab(_Tab t) {
    setState(() => _tab = t);
    _saveTab(t.index);
  }

  // ---------- taps ----------

  void _openEmployee(String id, String name) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) =>
          EmployeeSheet(id: id, name: name, f: _platform ? _pf : _f),
    );
  }

  void _onInsight(Insight i) {
    final a = i.action;
    if (a == null) return;
    switch (a.screen) {
      case 'collection_calendar':
      case 'collections_by_weekday':
        _setTab(_Tab.collections);
      case 'portfolio_aging':
        _setTab(_Tab.portfolio);
      case 'customer_risk':
        _setTab(_Tab.customers);
      case 'maturing_loans':
        final d = num.tryParse('${a.params['days']}')?.round() ?? 14;
        setState(() => _maturingDays = d.clamp(1, 90));
        _setTab(_Tab.forecast);
      case 'employee_detail':
        final id = a.params['employee_id']?.toString();
        if (id != null) _openEmployee(id, '');
    }
  }

  void _onKpi(String key) => _setTab(switch (key) {
    'collected' || 'collection_rate' => _Tab.collections,
    'overdue' || 'new_customers' => _Tab.customers,
    _ => _Tab.portfolio,
  });

  void _onAdmin(String id, String name) {
    _f.setAdmin(id, name);
    setState(() => _seg = _Seg.analytics);
    _setTab(_Tab.pulse);
  }

  // ---------- content ----------

  List<Widget> _content() {
    final f = _f;
    const l = 'admin';

    if (_platform) {
      return switch (_ptab) {
        _PTab.admins => [
          PlatformOverviewCard(f: _pf),
          AdminsPerfCard(f: _pf, onAdmin: _onAdmin),
          AdminsGrowthCard(f: _pf),
        ],
        _PTab.money => [
          PlatformTrendCard(f: _pf),
          PlatformEarningsCard(f: _pf),
          ForecastCard(f: _pf, platform: true),
          AccountsCard(f: _pf),
        ],
        _PTab.risk => [PlatformAgingCard(f: _pf), ConcentrationCard(f: _pf)],
        _PTab.geography => [GeographyCard(f: _pf, platform: true)],
        _PTab.people => [
          EmployeesCard(f: _pf, platform: true, onEmployee: _openEmployee),
        ],
      };
    }

    return switch (_tab) {
      _Tab.pulse => [
        InsightsCard(f: f, level: l, onAction: _onInsight),
        PulseKpiGrid(f: f, onTap: _onKpi),
        CollectedNowCard(f: f),
        TrendCard(f: f, level: l),
        StatusCard(f: f),
        AgingCard(f: f, level: l),
      ],
      _Tab.collections => [
        TrendCard(f: f, level: l),
        CalendarCard(f: f, level: l),
        WeekdayCard(f: f, level: l),
        BehaviourCard(f: f),
      ],
      _Tab.portfolio => [
        AgingCard(f: f, level: l),
        StatusCard(f: f),
        CohortCard(f: f),
        MaturingCard(f: f),
        EarningsCard(f: f),
        DisbursementsCard(f: f),
      ],
      _Tab.customers => [
        RiskCard(f: f),
        RepeatCard(f: f),
        ReferralsCard(f: f),
        GeographyCard(f: f),
      ],
      _Tab.team => [EmployeesCard(f: f, onEmployee: _openEmployee)],
      _Tab.forecast => [
        ForecastCard(f: f),
        MaturingCard(f: f, days: _maturingDays),
      ],
    };
  }

  Widget _chips() {
    final labels = _platform ? _pTabLabels(context) : _tabLabels(context);
    final selected = _platform ? _ptab.index : _tab.index;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSizes.sm),
        itemBuilder: (_, i) => Center(
          child: ChoiceChip(
            label: Text(labels[i]),
            selected: selected == i,
            onSelected: (_) {
              if (_platform) {
                setState(() => _ptab = _PTab.values[i]);
              } else {
                _setTab(_Tab.values[i]);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _offlineBanner() {
    return ValueListenableBuilder<AnalyticsStatus>(
      valueListenable: AnalyticsService.connection,
      builder: (context, s, _) {
        if (!s.offline) return const SizedBox.shrink();
        final text = Theme.of(context).textTheme;
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(
            AppSizes.lg,
            AppSizes.xs,
            AppSizes.lg,
            AppSizes.xs,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.warning.withAlpha(28),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.warning.withAlpha(80)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 18,
                color: AppColors.warning,
              ),
              AppGap.w8,
              Expanded(
                child: Text(
                  s.updatedAt == null
                      ? context.l10n.offlineNoData
                      : context.l10n.offlineShowingFrom(
                          _ago(context, s.updatedAt!),
                        ),
                  style: text.labelMedium?.copyWith(color: AppColors.warning),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    // The menu hides this screen from a USER; a stale deep link ends here.
    if (!CurrentUser.instance.hasRole(UserRole.admin)) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.menuAnalytics)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Text(context.l10n.anNoAccess, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: AppIconButton(
          icon: Icons.arrow_back_ios,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          context.l10n.menuAnalytics,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          ExportMenuButton(
            types: _platform
                ? const [ExportType.teamSummary, ExportType.employeePerformance]
                : const [
                    ExportType.collections,
                    ExportType.employeePerformance,
                    ExportType.newCustomers,
                    ExportType.closedLoans,
                    ExportType.loansRegister,
                  ],
            preset: () => ExportPreset(
              from: _cur.from,
              to: _cur.to,
              adminId: _f.adminId,
              adminName: _f.adminName,
              employeeId: _f.employeeId,
              employeeName: _f.employeeName,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: !_ready
            ? const Center(child: CircularProgressIndicator())
            : ListenableBuilder(
                listenable: Listenable.merge([_f, _pf]),
                builder: (context, _) {
                  final f = _cur;

                  return Column(
                    children: [
                      if (_isSuper)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSizes.lg,
                            AppSizes.sm,
                            AppSizes.lg,
                            AppSizes.sm,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<_Seg>(
                              showSelectedIcon: false,
                              segments: [
                                ButtonSegment(
                                  value: _Seg.analytics,
                                  label: Text(context.l10n.anSegAnalytics),
                                ),
                                ButtonSegment(
                                  value: _Seg.platform,
                                  label: Text(context.l10n.anSegPlatform),
                                ),
                              ],
                              selected: {_seg},
                              onSelectionChanged: (v) =>
                                  setState(() => _seg = v.first),
                            ),
                          ),
                        ),
                      AnalyticsFilterBar(
                        f: f,
                        showAdmin: !_platform && _isSuper,
                        showEmployee:
                            !_platform && (!_isSuper || _f.adminId != null),
                      ),
                      _chips(),
                      _offlineBanner(),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            f.refresh(); // cards refetch; the spinner waits for them
                            await AnalyticsService.settled();
                          },
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(
                              AppSizes.lg,
                              AppSizes.sm,
                              AppSizes.lg,
                              AppSizes.bottomClearance,
                            ),
                            children: [
                              for (final w in _content()) ...[w, AppGap.h16],
                              ValueListenableBuilder<AnalyticsStatus>(
                                valueListenable: AnalyticsService.connection,
                                builder: (_, s, _) => Text(
                                  s.updatedAt == null
                                      ? context.l10n.pullToRefresh
                                      : context.l10n.updatedPullRefresh(
                                          _ago(context, s.updatedAt!),
                                        ),
                                  textAlign: TextAlign.center,
                                  style: text.labelSmall?.copyWith(
                                    color: AppColors.darkOnSurfaceMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
