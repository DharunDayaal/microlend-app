import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/data/models/analytics_model.dart';
import 'package:micro_lending_app/data/services/analytics_service.dart';
import 'package:micro_lending_app/features/analytics/analytics_filter.dart';
import 'package:micro_lending_app/features/analytics/widgets/analytics_cards_more.dart';
import 'package:micro_lending_app/features/analytics/widgets/analytics_common.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';

class PlatformOverviewCard extends StatelessWidget {
  final AnalyticsFilters f;
  const PlatformOverviewCard({super.key, required this.f});

  @override
  Widget build(BuildContext context) {
    return AsyncCard<Overview>(
      cacheKey: 'sp-ov|${f.tick}',
      title: 'Platform',
      skeletonHeight: 130,
      load: AnalyticsService.spOverview,
      builder: (context, o) => AnalyticsFrame(
        title: 'Platform at a glance',
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCol(
                    'COLLECTED (MONTH)',
                    Money.compact(o.month),
                    color: AppColors.success,
                  ),
                ),
                Expanded(
                  child: StatCol(
                    'OUTSTANDING',
                    Money.compact(o.totalOutstanding),
                  ),
                ),
                Expanded(
                  child: StatCol(
                    'PAR',
                    '${o.parPct.toStringAsFixed(1)}%',
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            AppGap.h12,
            Row(
              children: [
                Expanded(child: StatCol('ADMINS', '${o.admins ?? 0}')),
                Expanded(child: StatCol('EMPLOYEES', '${o.employees ?? 0}')),
                Expanded(
                  child: StatCol('EARNED', Money.compact(o.totalEarned ?? 0)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AdminsPerfCard extends StatelessWidget {
  final AnalyticsFilters f;
  final void Function(String id, String name) onAdmin;
  const AdminsPerfCard({super.key, required this.f, required this.onAdmin});

  @override
  Widget build(BuildContext context) {
    return AsyncCard<List<AdminPerf>>(
      cacheKey: 'sp-admins|${f.key}',
      title: 'Admins',
      skeletonHeight: 180,
      load: () => AnalyticsService.spAdmins(from: f.fromStr, to: f.toStr),
      builder: (context, list) {
        final sorted = [...list]
          ..sort((a, b) => b.collected.compareTo(a.collected));
        return AnalyticsFrame(
          title: 'Admins',
          child: sorted.isEmpty
              ? const EmptyNote('No admins yet.')
              : Column(
                  children: [
                    for (var i = 0; i < sorted.length; i++)
                      RankedRow(
                        rank: i + 1,
                        name: sorted[i].name,
                        primary: Money.compact(sorted[i].collected),
                        secondary:
                            '${sorted[i].employees} employees • '
                            'PAR ${sorted[i].parPct.toStringAsFixed(0)}% • '
                            '${sorted[i].overdueLoans} overdue',
                        pill: Pill(
                          '${sorted[i].rate.toStringAsFixed(0)}%',
                          rateColor(sorted[i].rate),
                        ),
                        onTap: () => onAdmin(sorted[i].id, sorted[i].name),
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class AdminsGrowthCard extends StatelessWidget {
  final AnalyticsFilters f;
  const AdminsGrowthCard({super.key, required this.f});

  @override
  Widget build(BuildContext context) {
    return AsyncCard<List<GrowthPoint>>(
      cacheKey: 'sp-growth|${f.key}',
      title: 'Disbursed by admin',
      skeletonHeight: 200,
      load: () => AnalyticsService.spGrowth(from: f.fromStr, to: f.toStr),
      builder: (context, pts) {
        final names = {for (final p in pts) p.adminId: p.adminName};
        final (labels, series) = splitSeries([
          for (final p in pts) (p.period, p.adminId, p.disbursed),
        ], names);
        return AnalyticsFrame(
          title: 'Disbursed by admin (monthly)',
          child: MultiLine(labels: labels, series: series),
        );
      },
    );
  }
}

class PlatformTrendCard extends StatefulWidget {
  final AnalyticsFilters f;
  const PlatformTrendCard({super.key, required this.f});

  @override
  State<PlatformTrendCard> createState() => _PlatformTrendCardState();
}

class _PlatformTrendCardState extends State<PlatformTrendCard> {
  bool _split = false;

  @override
  Widget build(BuildContext context) {
    final f = widget.f;

    return AsyncCard<(List<TrendPoint>, Map<String, String>)>(
      cacheKey: 'sp-trend|$_split|${f.key}',
      title: 'Collections',
      skeletonHeight: 220,
      load: () async {
        final r = await Future.wait([
          AnalyticsService.spTrend(from: f.fromStr, to: f.toStr, split: _split),
          if (_split) AnalyticsService.spAdmins(from: f.fromStr, to: f.toStr),
        ]);
        final admins = _split ? r[1] as List<AdminPerf> : <AdminPerf>[];
        return (
          r[0] as List<TrendPoint>,
          {for (final a in admins) a.id: a.name},
        );
      },
      builder: (context, d) {
        final (pts, names) = d;
        final toggle = FilterChip(
          label: const Text('Split by admin'),
          selected: _split,
          onSelected: (v) => setState(() => _split = v),
        );

        late final List<String> labels;
        late final List<LineSeries> series;
        if (_split) {
          (labels, series) = splitSeries([
            for (final p in pts) (p.label, p.adminId, p.collected),
          ], names);
        } else {
          labels = [for (final p in pts) p.label];
          series = [
            LineSeries('Collected', AppColors.success, [
              for (final p in pts) p.collected,
            ]),
            LineSeries('Target', AppColors.warning, [
              for (final p in pts) p.target ?? 0,
            ], dashed: true),
          ];
        }

        return AnalyticsFrame(
          title: 'Platform collections',
          trailing: toggle,
          child: MultiLine(labels: labels, series: series),
        );
      },
    );
  }
}

class PlatformEarningsCard extends StatelessWidget {
  final AnalyticsFilters f;
  const PlatformEarningsCard({super.key, required this.f});

  @override
  Widget build(BuildContext context) {
    return AsyncCard<EarningsData>(
      cacheKey: 'sp-earn|${f.key}',
      title: 'Earnings',
      skeletonHeight: 200,
      load: () => AnalyticsService.earnings(
        from: f.fromStr,
        to: f.toStr,
        platform: true,
      ),
      builder: (context, e) => earningsBody(context, e),
    );
  }
}

class AccountsCard extends StatelessWidget {
  final AnalyticsFilters f;
  const AccountsCard({super.key, required this.f});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AsyncCard<Map<String, dynamic>>(
      cacheKey: 'sp-acc|${f.tick}',
      title: 'Accounts',
      skeletonHeight: 160,
      load: AnalyticsService.spAccounts,
      builder: (context, d) {
        final roles = (d['by_role'] as List? ?? []).whereType<Map>().toList();
        final per = (d['employees_per_admin'] as List? ?? [])
            .whereType<Map>()
            .toList();

        return AnalyticsFrame(
          title: 'Accounts',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final r in roles)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${r['role']}'.replaceAll('_', ' '),
                          style: text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${r['active']} active • ${r['inactive']} inactive',
                        style: text.labelMedium?.copyWith(
                          color: AppColors.darkOnSurfaceMuted,
                        ),
                      ),
                      if ((num.tryParse('${r['pending_verification']}') ?? 0) >
                          0) ...[
                        AppGap.w8,
                        Pill(
                          '${r['pending_verification']} pending',
                          AppColors.warning,
                        ),
                      ],
                    ],
                  ),
                ),
              if (per.isNotEmpty) ...[
                AppGap.h12,
                Text(
                  'EMPLOYEES PER ADMIN',
                  style: text.labelMedium?.copyWith(
                    color: AppColors.darkOnSurfaceMuted,
                    letterSpacing: 0.6,
                  ),
                ),
                AppGap.h8,
                for (final p in per)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${p['admin_name']}',
                            style: text.bodyMedium,
                          ),
                        ),
                        Text('${p['employees']}', style: text.bodyMedium),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class PlatformAgingCard extends StatelessWidget {
  final AnalyticsFilters f;
  const PlatformAgingCard({super.key, required this.f});

  @override
  Widget build(BuildContext context) {
    return AsyncCard<List<AgingBucket>>(
      cacheKey: 'sp-aging|${f.tick}',
      title: 'Outstanding by age',
      skeletonHeight: 150,
      load: AnalyticsService.spAging,
      builder: (context, b) => AnalyticsFrame(
        title: 'Platform outstanding by age',
        child: AgingBody(buckets: b),
      ),
    );
  }
}

class ConcentrationCard extends StatelessWidget {
  final AnalyticsFilters f;
  const ConcentrationCard({super.key, required this.f});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    double n(dynamic v) => (num.tryParse('$v') ?? 0).toDouble();

    return AsyncCard<Map<String, dynamic>>(
      cacheKey: 'sp-conc|${f.tick}',
      title: 'Risk concentration',
      skeletonHeight: 240,
      load: AnalyticsService.spConcentration,
      builder: (context, d) {
        final admins = (d['by_admin'] as List? ?? []).whereType<Map>().toList();
        final top = (d['top_exposures'] as List? ?? [])
            .whereType<Map>()
            .toList();

        return Column(
          children: [
            AnalyticsFrame(
              title: 'Outstanding by admin',
              trailing: Text(
                Money.compact(n(d['total_outstanding'])),
                style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              child: Column(
                children: [
                  for (final a in admins)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${a['admin_name']}',
                                  style: text.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '${n(a['share_pct']).toStringAsFixed(0)}% of book',
                                style: text.labelMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (n(a['share_pct']) / 100)
                                  .clamp(0, 1)
                                  .toDouble(),
                              minHeight: 8,
                              color: AppColors.stepCurrentLabel,
                              backgroundColor: AppColors.darkBorder,
                            ),
                          ),
                          Text(
                            '${Money.compact(n(a['outstanding']))} • PAR ${n(a['par_pct']).toStringAsFixed(0)}%',
                            style: text.labelMedium?.copyWith(
                              color: AppColors.darkOnSurfaceMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            AppGap.h12,
            AnalyticsFrame(
              title: 'Largest exposures',
              child: top.isEmpty
                  ? const EmptyNote('No exposures to show.')
                  : Column(
                      children: [
                        for (var i = 0; i < top.length; i++)
                          RankedRow(
                            rank: i + 1,
                            name: '${top[i]['customer_name']}',
                            primary: Money.compact(n(top[i]['outstanding'])),
                            secondary:
                                '${top[i]['days_past_due']} days late • ${n(top[i]['share_pct']).toStringAsFixed(1)}% of book',
                          ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}
