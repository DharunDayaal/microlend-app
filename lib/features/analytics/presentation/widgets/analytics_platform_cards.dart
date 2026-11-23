import 'package:flutter/material.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/shared/design_system/styles/spacing_style.dart';
import 'package:micro_lending_app/features/analytics/domain/entities/analytics.dart';
import 'package:micro_lending_app/features/analytics/presentation/analytics_filter.dart';
import 'package:micro_lending_app/features/analytics/presentation/widgets/analytics_cards_more.dart';
import 'package:micro_lending_app/features/analytics/presentation/widgets/analytics_common.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';

class PlatformOverviewCard extends StatelessWidget {
  final AnalyticsFilters f;
  const PlatformOverviewCard({super.key, required this.f});

  @override
  Widget build(BuildContext context) {
    return AsyncCard<Overview>(
      cacheKey: 'sp-ov|${f.tick}',
      title: context.l10n.anSegPlatform,
      skeletonHeight: 130,
      load: (ref) => ref.analytics.spOverview(),
      builder: (context, o) => AnalyticsFrame(
        title: context.l10n.anPlatformAtGlance,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCol(
                    context.l10n.anCollectedMonth,
                    Money.compact(o.month),
                    color: AppColors.success,
                  ),
                ),
                Expanded(
                  child: StatCol(
                    context.l10n.loanOutstanding,
                    Money.compact(o.totalOutstanding),
                  ),
                ),
                Expanded(
                  child: StatCol(
                    context.l10n.anPAR,
                    '${o.parPct.toStringAsFixed(1)}%',
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            AppGap.h12,
            Row(
              children: [
                Expanded(
                  child: StatCol(
                    context.l10n.anAdminsUpper,
                    '${o.admins ?? 0}',
                  ),
                ),
                Expanded(
                  child: StatCol(
                    context.l10n.anEmployeesUpper,
                    '${o.employees ?? 0}',
                  ),
                ),
                Expanded(
                  child: StatCol(
                    context.l10n.anEarned,
                    Money.compact(o.totalEarned ?? 0),
                  ),
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
      title: context.l10n.anTabAdmins,
      skeletonHeight: 180,
      load: (ref) => ref.analytics.spAdmins(from: f.fromStr, to: f.toStr),
      builder: (context, list) {
        final sorted = [...list]
          ..sort((a, b) => b.collected.compareTo(a.collected));
        return AnalyticsFrame(
          title: context.l10n.anTabAdmins,
          child: sorted.isEmpty
              ? EmptyNote(context.l10n.anNoAdmins)
              : Column(
                  children: [
                    for (var i = 0; i < sorted.length; i++)
                      RankedRow(
                        rank: i + 1,
                        name: sorted[i].name,
                        primary: Money.compact(sorted[i].collected),
                        secondary: context.l10n.anAdminRowLine(
                          sorted[i].employees,
                          sorted[i].parPct.toStringAsFixed(0),
                          sorted[i].overdueLoans,
                        ),
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
      title: context.l10n.anDisbursedByAdmin,
      skeletonHeight: 200,
      load: (ref) => ref.analytics.spGrowth(from: f.fromStr, to: f.toStr),
      builder: (context, pts) {
        final names = {for (final p in pts) p.adminId: p.adminName};
        final (labels, series) = splitSeries(
          [for (final p in pts) (p.period, p.adminId, p.disbursed)],
          names,
          adminLabel: context.l10n.anAdminN,
          othersLabel: context.l10n.anOthers,
        );
        return AnalyticsFrame(
          title: context.l10n.anDisbursedByAdminMonthly,
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
      title: context.l10n.anTabCollections,
      skeletonHeight: 220,
      load: (ref) async {
        final r = await Future.wait([
          ref.analytics.spTrend(from: f.fromStr, to: f.toStr, split: _split),
          if (_split) ref.analytics.spAdmins(from: f.fromStr, to: f.toStr),
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
          label: Text(context.l10n.anSplitByAdmin),
          selected: _split,
          onSelected: (v) => setState(() => _split = v),
        );

        late final List<String> labels;
        late final List<LineSeries> series;
        if (_split) {
          (labels, series) = splitSeries(
            [for (final p in pts) (p.label, p.adminId, p.collected)],
            names,
            adminLabel: context.l10n.anAdminN,
            othersLabel: context.l10n.anOthers,
          );
        } else {
          labels = [for (final p in pts) p.label];
          series = [
            LineSeries(context.l10n.anCollected, AppColors.success, [
              for (final p in pts) p.collected,
            ]),
            LineSeries(context.l10n.anTarget, AppColors.warning, [
              for (final p in pts) p.target ?? 0,
            ], dashed: true),
          ];
        }

        return AnalyticsFrame(
          title: context.l10n.anPlatformCollections,
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
      title: context.l10n.anEarnings,
      skeletonHeight: 200,
      load: (ref) =>
          ref.analytics.earnings(from: f.fromStr, to: f.toStr, platform: true),
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
      title: context.l10n.anAccounts,
      skeletonHeight: 160,
      load: (ref) => ref.analytics.spAccounts(),
      builder: (context, d) {
        final roles = (d['by_role'] as List? ?? []).whereType<Map>().toList();
        final per = (d['employees_per_admin'] as List? ?? [])
            .whereType<Map>()
            .toList();

        return AnalyticsFrame(
          title: context.l10n.anAccounts,
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
                      AppGap.w8,
                      Text(
                        context.l10n.anActiveInactive(
                          '${r['active']}',
                          '${r['inactive']}',
                        ),
                        style: text.labelMedium?.copyWith(
                          color: AppColors.darkOnSurfaceMuted,
                        ),
                      ),
                      if ((num.tryParse('${r['pending_verification']}') ?? 0) >
                          0) ...[
                        AppGap.w8,
                        Pill(
                          context.l10n.anPendingCount(
                            '${r['pending_verification']}',
                          ),
                          AppColors.warning,
                        ),
                      ],
                    ],
                  ),
                ),
              if (per.isNotEmpty) ...[
                AppGap.h12,
                Text(
                  context.l10n.anEmployeesPerAdmin,
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
      title: context.l10n.anOutstandingByAge,
      skeletonHeight: 150,
      load: (ref) => ref.analytics.spAging(),
      builder: (context, b) => AnalyticsFrame(
        title: context.l10n.anPlatformOutstandingByAge,
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

    return AsyncCard<Concentration>(
      cacheKey: 'sp-conc|${f.tick}',
      title: context.l10n.anRiskConcentration,
      skeletonHeight: 240,
      load: (ref) => ref.analytics.spConcentration(),
      builder: (context, c) {
        final d = c.data;
        final admins = (d['by_admin'] as List? ?? []).whereType<Map>().toList();
        final top = c.topExposures.items;

        return Column(
          children: [
            AnalyticsFrame(
              title: context.l10n.anOutstandingByAdmin,
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
                                context.l10n.anShareOfBook(
                                  n(a['share_pct']).toStringAsFixed(0),
                                ),
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
                            '${Money.compact(n(a['outstanding']))} • ${context.l10n.anPar(n(a['par_pct']).toStringAsFixed(0))}',
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
              title: context.l10n.anLargestExposures,
              child: top.isEmpty
                  ? EmptyNote(context.l10n.anNoExposures)
                  : Column(
                      children: [
                        for (var i = 0; i < top.length; i++)
                          RankedRow(
                            rank: i + 1,
                            name: '${top[i]['customer_name']}',
                            primary: Money.compact(n(top[i]['outstanding'])),
                            secondary: context.l10n.anExposureLine(
                              '${top[i]['days_past_due']}',
                              n(top[i]['share_pct']).toStringAsFixed(1),
                            ),
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
