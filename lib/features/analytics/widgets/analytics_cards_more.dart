import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/call_icon_button.dart';
import 'package:micro_lending_app/data/models/analytics_model.dart';
import 'package:micro_lending_app/data/services/analytics_service.dart';
import 'package:micro_lending_app/features/analytics/analytics_filter.dart';
import 'package:micro_lending_app/features/analytics/widgets/analytics_common.dart';
import 'package:micro_lending_app/routes/app_routes.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';

Duration _anim(BuildContext c) => MediaQuery.disableAnimationsOf(c)
    ? Duration.zero
    : const Duration(milliseconds: 500);

FlGridData get _grid => FlGridData(
  show: true,
  drawVerticalLine: false,
  getDrawingHorizontalLine: (_) =>
      const FlLine(color: AppColors.darkBorder, strokeWidth: 1),
);

String periodLabel(String raw) {
  final d = DateTime.tryParse(raw);
  return d == null ? raw : DateFormat('d MMM').format(d);
}

void _openLoan(BuildContext c, String loanId) =>
    c.push('${AppRoutes.loansList}/$loanId');

// =============== chart helpers ===============

class LineSeries {
  final String name;
  final Color color;
  final List<double> values;
  final bool dashed;
  const LineSeries(this.name, this.color, this.values, {this.dashed = false});
}

class MultiLine extends StatelessWidget {
  final List<String> labels;
  final List<LineSeries> series;
  final double height;
  const MultiLine({
    super.key,
    required this.labels,
    required this.series,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final maxY = series.expand((s) => s.values).fold<double>(0, math.max);
    if (labels.isEmpty || maxY == 0) {
      return const EmptyNote('No data in this period. Try a longer range.');
    }
    final step = math.max(1, (labels.length / 4).ceil());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.only(right: 18),
            child: LineChart(
              duration: _anim(context),
              LineChartData(
                minY: 0,
                maxY: maxY * 1.15,
                gridData: _grid,
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: step.toDouble(),
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            periodLabel(labels[i]),
                            style: text.labelSmall?.copyWith(
                              color: AppColors.darkOnSurfaceMuted,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.darkBorder,
                    getTooltipItems: (spots) => [
                      for (final s in spots)
                        LineTooltipItem(
                          '${series[s.barIndex].name}: ${Money.compact(s.y)}',
                          TextStyle(
                            fontSize: 12,
                            color: series[s.barIndex].color,
                          ),
                        ),
                    ],
                  ),
                ),
                lineBarsData: [
                  for (final s in series)
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < s.values.length; i++)
                          FlSpot(i.toDouble(), s.values[i]),
                      ],
                      isCurved: true,
                      color: s.color,
                      barWidth: 2.5,
                      dashArray: s.dashed ? [6, 4] : null,
                      dotData: const FlDotData(show: false),
                    ),
                ],
              ),
            ),
          ),
        ),
        AppGap.h8,
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            for (final s in series)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, color: s.color),
                  const SizedBox(width: 6),
                  Text(s.name, style: text.labelMedium),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

/// Stacked (or single-segment) bars. [stacks] holds one list of segment values per bar.
class StackedBars extends StatelessWidget {
  final List<String> labels;
  final List<List<double>> stacks;
  final List<Color> colors;
  final List<String> names;
  final bool money;
  final double height;
  final int? highlight;

  const StackedBars({
    super.key,
    required this.labels,
    required this.stacks,
    required this.colors,
    required this.names,
    this.money = true,
    this.height = 180,
    this.highlight,
  });

  String _f(double v) => money ? Money.compact(v) : v.round().toString();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final totals = [for (final s in stacks) s.fold<double>(0, (a, b) => a + b)];
    final maxY = totals.fold<double>(0, math.max);
    if (labels.isEmpty || maxY == 0) {
      return const EmptyNote('No data in this period. Try a longer range.');
    }
    final step = math.max(1, (labels.length / 5).ceil());

    return SizedBox(
      height: height,
      child: BarChart(
        duration: _anim(context),
        BarChartData(
          maxY: maxY * 1.15,
          gridData: _grid,
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= labels.length || i % step != 0) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[i],
                      style: text.labelSmall?.copyWith(
                        color: AppColors.darkOnSurfaceMuted,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.darkBorder,
              getTooltipItem: (g, gi, rod, ri) => BarTooltipItem(
                '${labels[gi]}\n${[for (var k = 0; k < names.length; k++) '${names[k]} ${_f(stacks[gi][k])}'].join('\n')}',
                const TextStyle(fontSize: 12),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < stacks.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: totals[i],
                    width: 14,
                    borderRadius: BorderRadius.circular(3),
                    rodStackItems: () {
                      var from = 0.0;
                      final items = <BarChartRodStackItem>[];
                      for (var k = 0; k < stacks[i].length; k++) {
                        items.add(
                          BarChartRodStackItem(
                            from,
                            from + stacks[i][k],
                            i == highlight ? AppColors.success : colors[k],
                          ),
                        );
                        from += stacks[i][k];
                      }
                      return items;
                    }(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class AgingBody extends StatelessWidget {
  final List<AgingBucket> buckets;
  const AgingBody({super.key, required this.buckets});

  static const _colors = [
    AppColors.success,
    Color(0xFF4FC3F7),
    AppColors.warning,
    AppColors.progressWarning,
    AppColors.progressDanger,
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final total = buckets.fold<double>(0, (s, b) => s + b.outstanding);
    if (total == 0) return const EmptyNote('Nothing outstanding right now.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 14,
            child: Row(
              children: [
                for (var i = 0; i < buckets.length; i++)
                  if (buckets[i].outstanding > 0)
                    Expanded(
                      flex: math.max(
                        1,
                        (buckets[i].outstanding / total * 1000).round(),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(right: 2),
                        color: _colors[i % _colors.length],
                      ),
                    ),
              ],
            ),
          ),
        ),
        AppGap.h12,
        for (var i = 0; i < buckets.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _colors[i % _colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                AppGap.w8,
                Expanded(child: Text(buckets[i].label, style: text.bodyMedium)),
                Text(
                  '${buckets[i].loans} loans • ${Money.compact(buckets[i].outstanding)}',
                  style: text.labelMedium?.copyWith(
                    color: AppColors.darkOnSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Top four series by total, everything else as "Others".
(List<String>, List<LineSeries>) splitSeries(
  List<(String period, String? id, double value)> rows,
  Map<String, String> names,
) {
  final labels = {for (final r in rows) r.$1}.toList()..sort();
  final totals = <String, double>{};
  for (final r in rows) {
    if (r.$2 != null) totals[r.$2!] = (totals[r.$2!] ?? 0) + r.$3;
  }
  final ids = totals.keys.toList()
    ..sort((a, b) => totals[b]!.compareTo(totals[a]!));
  final top = ids.take(4).toList();
  final rest = ids.skip(4).toSet();

  List<double> values(bool Function(String) pick) => [
    for (final l in labels)
      rows
          .where((r) => r.$1 == l && r.$2 != null && pick(r.$2!))
          .fold<double>(0, (s, r) => s + r.$3),
  ];

  return (
    labels,
    [
      for (var i = 0; i < top.length; i++)
        LineSeries(
          names[top[i]] ?? 'Admin ${i + 1}',
          kSeries[i],
          values((x) => x == top[i]),
        ),
      if (rest.isNotEmpty)
        LineSeries(
          'Others',
          AppColors.darkOnSurfaceMuted,
          values(rest.contains),
        ),
    ],
  );
}

// =============== pulse ===============

class _KpiTile extends StatelessWidget {
  final KpiMetric m;
  final bool showDelta;
  final String caption;
  final VoidCallback onTap;
  const _KpiTile({
    required this.m,
    required this.onTap,
    this.showDelta = true,
    this.caption = '',
  });

  String _fmt(double v) => switch (m.unit) {
    'INR' => Money.compact(v),
    '%' => '${v.toStringAsFixed(1)}%',
    _ => v.round().toString(),
  };

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: '${m.label}, ${_fmt(m.current)}',
      child: AnalyticsFrame(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              m.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.labelMedium?.copyWith(
                color: AppColors.darkOnSurfaceMuted,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: CountUp(
                value: m.current,
                format: _fmt,
                style: text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 6),
            showDelta
                ? DeltaChip(m: m)
                : Text(
                    caption,
                    style: text.labelMedium?.copyWith(
                      color: AppColors.darkOnSurfaceMuted,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

/// Six KPIs. Overdue comes from the overview, the rest from kpis/compare.
class PulseKpiGrid extends StatelessWidget {
  final AnalyticsFilters f;
  final void Function(String metricKey) onTap;
  const PulseKpiGrid({super.key, required this.f, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AsyncCard<(KpiCompare, Overview)>(
      cacheKey: 'pkpi|${f.key}',
      skeletonHeight: 200,
      load: () async {
        final r = await Future.wait([
          AnalyticsService.kpisCompare(
            from: f.fromStr,
            to: f.toStr,
            scope: f.scope('admin'),
          ),
          AnalyticsService.overview(scope: f.scope('admin')),
        ]);
        return (r[0] as KpiCompare, r[1] as Overview);
      },
      builder: (context, d) {
        final (cmp, ov) = d;
        final overdue = KpiMetric(
          key: 'overdue',
          label: 'Overdue',
          unit: 'count',
          current: ov.overdue.toDouble(),
          previous: 0,
          change: 0,
          changePct: null,
          direction: 'flat',
          isGood: null,
        );
        final items = <KpiMetric>[
          ?cmp.by('collected'),
          ?cmp.by('collection_rate'),
          overdue,
          ?cmp.by('disbursed'),
          ?cmp.by('interest_earned'),
          ?cmp.by('new_customers'),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: Text(
                'Compared with the previous ${cmp.days} days',
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: AppColors.darkOnSurfaceMuted),
              ),
            ),
            for (var i = 0; i < items.length; i += 2) ...[
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSizes.sm,
                  children: [
                    for (final m in items.skip(i).take(2))
                      Expanded(
                        child: _KpiTile(
                          m: m,
                          showDelta: m.key != 'overdue',
                          caption: 'loans right now',
                          onTap: () => onTap(m.key),
                        ),
                      ),
                  ],
                ),
              ),
              if (i + 2 < items.length) const SizedBox(height: AppSizes.sm),
            ],
          ],
        );
      },
    );
  }
}

class CollectedNowCard extends StatelessWidget {
  final AnalyticsFilters f;
  const CollectedNowCard({super.key, required this.f});

  @override
  Widget build(BuildContext context) {
    return AsyncCard<Overview>(
      cacheKey: 'ov|${f.scopeKey}',
      title: 'Collected',
      skeletonHeight: 60,
      load: () => AnalyticsService.overview(scope: f.scope('admin')),
      builder: (context, o) => AnalyticsFrame(
        title: 'Collected',
        trailing: Pill(
          'PAR ${o.parPct.toStringAsFixed(1)}%',
          o.parPct > 25 ? AppColors.progressDanger : AppColors.warning,
        ),
        child: Row(
          children: [
            Expanded(
              child: StatCol(
                'TODAY',
                Money.compact(o.today),
                color: AppColors.success,
              ),
            ),
            Expanded(child: StatCol('THIS WEEK', Money.compact(o.week))),
            Expanded(child: StatCol('THIS MONTH', Money.compact(o.month))),
          ],
        ),
      ),
    );
  }
}

// =============== collections ===============

class BehaviourCard extends StatelessWidget {
  final AnalyticsFilters f;
  const BehaviourCard({super.key, required this.f});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AsyncCard<PaymentBehaviour>(
      cacheKey: 'behave|${f.key}',
      title: 'Payment behaviour',
      skeletonHeight: 150,
      load: () => AnalyticsService.behaviour(
        from: f.fromStr,
        to: f.toStr,
        scope: f.scope('admin'),
      ),
      builder: (context, b) {
        if (b.count == 0 && b.dueWeeks == 0) {
          return const AnalyticsFrame(
            title: 'Payment behaviour',
            child: EmptyNote('No payments in this period. Try a longer range.'),
          );
        }
        final total = b.paidPct + b.partialPct + b.unpaidPct;

        Widget seg(double v, Color c) => v <= 0
            ? const SizedBox.shrink()
            : Expanded(
                flex: math.max(1, (v * 10).round()),
                child: Container(color: c),
              );

        return AnalyticsFrame(
          title: 'Payment behaviour',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatCol(
                      'ON TIME',
                      '${b.onTimePct.toStringAsFixed(0)}%',
                      color: AppColors.success,
                    ),
                  ),
                  Expanded(
                    child: StatCol(
                      'LATE',
                      '${b.latePct.toStringAsFixed(0)}%',
                      color: AppColors.warning,
                    ),
                  ),
                  Expanded(
                    child: StatCol(
                      'AVG DAYS LATE',
                      b.avgDaysLate.toStringAsFixed(1),
                    ),
                  ),
                  Expanded(child: StatCol('WORST', '${b.maxDaysLate}d')),
                ],
              ),
              AppGap.h16,
              Text(
                'Weekly instalments (${b.dueWeeks} due)',
                style: text.labelMedium?.copyWith(
                  color: AppColors.darkOnSurfaceMuted,
                ),
              ),
              AppGap.h8,
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 14,
                  child: total <= 0
                      ? Container(color: AppColors.darkBorder)
                      : Row(
                          children: [
                            seg(b.paidPct, AppColors.success),
                            seg(b.partialPct, AppColors.warning),
                            seg(b.unpaidPct, AppColors.progressDanger),
                          ],
                        ),
                ),
              ),
              AppGap.h8,
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  Pill(
                    'Paid ${b.paidPct.toStringAsFixed(0)}%',
                    AppColors.success,
                  ),
                  Pill(
                    'Partial ${b.partialPct.toStringAsFixed(0)}%',
                    AppColors.warning,
                  ),
                  Pill(
                    'Unpaid ${b.unpaidPct.toStringAsFixed(0)}%',
                    AppColors.progressDanger,
                  ),
                  Pill(
                    'Overpaid ${b.overpaidPct.toStringAsFixed(0)}%',
                    const Color(0xFF4FC3F7),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// =============== portfolio ===============

class DisbursementsCard extends StatelessWidget {
  final AnalyticsFilters f;
  const DisbursementsCard({super.key, required this.f});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AsyncCard<DisbursementData>(
      cacheKey: 'disb|${f.key}',
      title: 'Disbursements',
      skeletonHeight: 180,
      load: () => AnalyticsService.disbursements(
        from: f.fromStr,
        to: f.toStr,
        scope: f.scope('admin'),
      ),
      builder: (context, d) => AnalyticsFrame(
        title: 'Disbursements',
        trailing: Text(
          '${d.loans} loans',
          style: text.labelMedium?.copyWith(
            color: AppColors.darkOnSurfaceMuted,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Money.compact(d.disbursed),
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            AppGap.h12,
            StackedBars(
              labels: [for (final p in d.series) periodLabel('${p['period']}')],
              stacks: [
                for (final p in d.series)
                  [(num.tryParse('${p['disbursed']}') ?? 0).toDouble()],
              ],
              colors: const [AppColors.stepCurrentLabel],
              names: const ['Disbursed'],
            ),
          ],
        ),
      ),
    );
  }
}

class EarningsCard extends StatelessWidget {
  final AnalyticsFilters f;
  const EarningsCard({super.key, required this.f});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AsyncCard<EarningsData>(
      cacheKey: 'earn|${f.fromStr}|${f.toStr}|${f.adminId}|${f.tick}',
      title: 'Earnings',
      skeletonHeight: 180,
      load: () => AnalyticsService.earnings(
        from: f.fromStr,
        to: f.toStr,
        adminOnly: f.adminOnly,
      ),
      builder: (context, e) => _earningsBody(context, e, text, 'Earnings'),
    );
  }
}

Widget _earningsBody(
  BuildContext context,
  EarningsData e,
  TextTheme text,
  String title,
) {
  double v(Map<String, dynamic> p, String k) =>
      (num.tryParse('${p[k]}') ?? 0).toDouble();

  return AnalyticsFrame(
    title: title,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: StatCol(
                'TOTAL',
                Money.compact(e.total),
                color: AppColors.success,
              ),
            ),
            Expanded(child: StatCol('FEES', Money.compact(e.fees))),
            Expanded(child: StatCol('INTEREST', Money.compact(e.interest))),
            Expanded(child: StatCol('EXPECTED', Money.compact(e.expected))),
          ],
        ),
        AppGap.h12,
        StackedBars(
          labels: [for (final p in e.series) periodLabel('${p['period']}')],
          stacks: [
            for (final p in e.series) [v(p, 'fees'), v(p, 'interest_earned')],
          ],
          colors: const [AppColors.warning, AppColors.success],
          names: const ['Fees', 'Interest'],
        ),
        AppGap.h8,
        Row(
          children: [
            Container(width: 10, height: 10, color: AppColors.warning),
            AppGap.w8,
            Text('Fees', style: text.labelMedium),
            AppGap.w12,
            Container(width: 10, height: 10, color: AppColors.success),
            AppGap.w8,
            Text('Interest earned', style: text.labelMedium),
          ],
        ),
      ],
    ),
  );
}

/// Used by the Platform Money chip.
Widget earningsBody(BuildContext context, EarningsData e) =>
    _earningsBody(context, e, Theme.of(context).textTheme, 'Platform earnings');

class MaturingCard extends StatelessWidget {
  final AnalyticsFilters f;
  final int days;
  const MaturingCard({super.key, required this.f, this.days = 14});

  @override
  Widget build(BuildContext context) {
    return PagedCard<MaturingRow>(
      cacheKey: 'mat|$days|${f.scopeKey}',
      title: 'Maturing in $days days',
      empty: 'No loans mature in the next $days days.',
      load: (p) => AnalyticsService.maturing(
        days: days,
        page: p,
        scope: f.scope('admin'),
      ),
      rowBuilder: (context, r, _) => RankedRow(
        name: r.name,
        primary: Money.compact(r.outstanding),
        secondary: 'Weekly ${Money.compact(r.weekly)}',
        pill: Pill(
          '${r.daysLeft}d left',
          r.daysLeft < 3
              ? AppColors.progressDanger
              : (r.daysLeft < 7 ? AppColors.warning : AppColors.success),
        ),
        onTap: () => _openLoan(context, r.loanId),
      ),
    );
  }
}

// =============== customers ===============

class RiskCard extends StatelessWidget {
  final AnalyticsFilters f;
  const RiskCard({super.key, required this.f});

  @override
  Widget build(BuildContext context) {
    return PagedCard<RiskRow>(
      cacheKey: 'risk|${f.scopeKey}',
      title: 'Customers at risk',
      empty: 'No customers at risk right now.',
      load: (p) => AnalyticsService.risk(page: p, scope: f.scope('admin')),
      rowBuilder: (context, r, _) {
        final color = r.score >= 60
            ? AppColors.progressDanger
            : (r.score >= 30 ? AppColors.warning : AppColors.success);
        return Column(
          children: [
            RankedRow(
              name: r.name,
              primary: Money.compact(r.outstanding),
              secondary:
                  '${r.daysPastDue} days late • ${r.missedWeeks} missed weeks'
                  '${r.referrerAtRisk ? ' • referrer at risk' : ''}',
              pill: Pill('Risk ${r.score.toStringAsFixed(0)}', color),
              trailing: r.phone.isEmpty ? null : CallIconButton(phone: r.phone),
              onTap: () => _openLoan(context, r.loanId),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: (r.score / 100).clamp(0, 1).toDouble(),
                minHeight: 4,
                color: color,
                backgroundColor: AppColors.darkBorder,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
          ],
        );
      },
    );
  }
}

class RepeatCard extends StatelessWidget {
  final AnalyticsFilters f;
  const RepeatCard({super.key, required this.f});

  @override
  Widget build(BuildContext context) {
    return AsyncCard<RepeatData>(
      cacheKey: 'repeat|${f.scopeKey}',
      title: 'Repeat borrowers',
      skeletonHeight: 160,
      load: () => AnalyticsService.repeat(scope: f.scope('admin')),
      builder: (context, r) => AnalyticsFrame(
        title: 'Repeat borrowers',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCol(
                    'REPEAT RATE',
                    '${r.repeatRate.toStringAsFixed(1)}%',
                    color: AppColors.success,
                  ),
                ),
                Expanded(
                  child: StatCol(
                    'RETENTION',
                    '${r.retentionRate.toStringAsFixed(1)}%',
                  ),
                ),
                Expanded(
                  child: StatCol('AVG LOANS', r.avgLoans.toStringAsFixed(1)),
                ),
              ],
            ),
            AppGap.h12,
            StackedBars(
              height: 130,
              labels: [
                for (final b in r.buckets)
                  '${b['loans']} loan${'${b['loans']}' == '1' ? '' : 's'}',
              ],
              stacks: [
                for (final b in r.buckets)
                  [(num.tryParse('${b['customers']}') ?? 0).toDouble()],
              ],
              colors: const [AppColors.stepCurrentLabel],
              names: const ['Customers'],
              money: false,
            ),
          ],
        ),
      ),
    );
  }
}

class ReferralsCard extends StatelessWidget {
  final AnalyticsFilters f;
  const ReferralsCard({super.key, required this.f});

  @override
  Widget build(BuildContext context) {
    return AsyncCard<List<Referrer>>(
      cacheKey: 'refs|${f.scopeKey}',
      title: 'Top referrers',
      skeletonHeight: 150,
      load: () => AnalyticsService.referrals(scope: f.scope('admin')),
      builder: (context, list) => AnalyticsFrame(
        title: 'Top referrers',
        child: list.isEmpty
            ? const EmptyNote('No referrals yet.')
            : Column(
                children: [
                  for (var i = 0; i < list.length; i++)
                    RankedRow(
                      rank: i + 1,
                      name: list[i].name,
                      primary:
                          '${list[i].conversionPct.toStringAsFixed(0)}% converted',
                      secondary:
                          'Referred ${list[i].referred} • converted ${list[i].converted}'
                          '${list[i].atRisk > 0 ? ' • ${list[i].atRisk} at risk' : ''}',
                    ),
                ],
              ),
      ),
    );
  }
}

class GeographyCard extends StatefulWidget {
  final AnalyticsFilters f;
  final bool platform;
  const GeographyCard({super.key, required this.f, this.platform = false});

  @override
  State<GeographyCard> createState() => _GeographyCardState();
}

class _GeographyCardState extends State<GeographyCard> {
  String _level = 'district';

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final f = widget.f;

    return AsyncCard<List<GeoArea>>(
      cacheKey: 'geo|${widget.platform}|$_level|${f.scopeKey}',
      title: 'Geography',
      skeletonHeight: 200,
      load: () => AnalyticsService.geography(
        level: _level,
        platform: widget.platform,
        scope: f.scope('admin'),
      ),
      builder: (context, areas) {
        final maxV = areas.fold<double>(
          0,
          (m, a) => math.max(m, a.outstanding),
        );

        return AnalyticsFrame(
          title: 'Outstanding by area',
          trailing: SegmentedButton<String>(
            showSelectedIcon: false,
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
            segments: const [
              ButtonSegment(value: 'district', label: Text('District')),
              ButtonSegment(value: 'city', label: Text('City')),
            ],
            selected: {_level},
            onSelectionChanged: (v) => setState(() => _level = v.first),
          ),
          child: areas.isEmpty || maxV == 0
              ? const EmptyNote('No borrowers in this scope yet.')
              : Column(
                  children: [
                    for (final a in areas)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    a.area,
                                    style: text.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  Money.compact(a.outstanding),
                                  style: text.bodyMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (a.outstanding / maxV)
                                    .clamp(0, 1)
                                    .toDouble(),
                                minHeight: 8,
                                color: AppColors.stepCurrentLabel,
                                backgroundColor: AppColors.darkBorder,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${a.borrowers} borrowers • PAR ${a.parPct.toStringAsFixed(1)}%',
                              style: text.labelMedium?.copyWith(
                                color: AppColors.darkOnSurfaceMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}

// =============== team ===============

class EmployeesCard extends StatelessWidget {
  final AnalyticsFilters f;
  final bool platform;
  final void Function(String id, String name) onEmployee;
  const EmployeesCard({
    super.key,
    required this.f,
    required this.onEmployee,
    this.platform = false,
  });

  @override
  Widget build(BuildContext context) {
    return PagedCard<EmployeePerf>(
      cacheKey: 'emp|$platform|${f.fromStr}|${f.toStr}|${f.adminId}|${f.tick}',
      title: platform ? 'Employee leaderboard' : 'Team leaderboard',
      empty: 'No employees to show yet.',
      load: (p) => AnalyticsService.employees(
        from: f.fromStr,
        to: f.toStr,
        page: p,
        platform: platform,
        adminOnly: f.adminOnly,
      ),
      rowBuilder: (context, e, i) => RankedRow(
        rank: i + 1,
        name: e.name,
        primary: Money.compact(e.collected),
        secondary:
            '${platform ? '${e.adminName} • ' : ''}PAR ${e.parPct.toStringAsFixed(0)}% • '
            '${e.overdueLoans} overdue',
        pill: Pill('${e.rate.toStringAsFixed(0)}%', rateColor(e.rate)),
        onTap: () => onEmployee(e.id, e.name),
      ),
    );
  }
}

class EmployeeSheet extends StatelessWidget {
  final String id;
  final String name;
  final AnalyticsFilters f;
  const EmployeeSheet({
    super.key,
    required this.id,
    required this.name,
    required this.f,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        children: [
          if (name.isNotEmpty) Text(name, style: text.headlineSmall),
          Text(
            f.rangeLabel,
            style: text.labelLarge?.copyWith(
              color: AppColors.darkOnSurfaceMuted,
            ),
          ),
          AppGap.h16,
          AsyncCard<EmployeeSummary>(
            cacheKey: 'empsum|$id|${f.key}',
            skeletonHeight: 320,
            load: () => AnalyticsService.employeeSummary(
              id,
              from: f.fromStr,
              to: f.toStr,
            ),
            builder: (context, s) {
              final o = s.overview;
              final pts = s.trend;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (name.isEmpty) ...[
                    Text(
                      s.name.isEmpty ? 'Employee' : s.name,
                      style: text.headlineSmall,
                    ),
                    AppGap.h12,
                  ],
                  AnalyticsFrame(
                    child: Row(
                      children: [
                        Expanded(
                          child: StatCol(
                            'THIS MONTH',
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
                          ),
                        ),
                        Expanded(child: StatCol('OVERDUE', '${o.overdue}')),
                      ],
                    ),
                  ),
                  AppGap.h12,
                  AnalyticsFrame(
                    title: 'Collections',
                    child: MultiLine(
                      labels: [for (final p in pts) p.label],
                      series: [
                        LineSeries('Collected', AppColors.success, [
                          for (final p in pts) p.collected,
                        ]),
                        LineSeries('Target', AppColors.warning, [
                          for (final p in pts) p.target ?? 0,
                        ], dashed: true),
                      ],
                    ),
                  ),
                  AppGap.h12,
                  AnalyticsFrame(
                    title: 'Outstanding by age',
                    child: AgingBody(buckets: s.aging),
                  ),
                  AppGap.h12,
                  AnalyticsFrame(
                    title: 'Customers at risk',
                    child: s.risky.isEmpty
                        ? const EmptyNote('No risky customers.')
                        : Column(
                            children: [
                              for (final r in s.risky)
                                RankedRow(
                                  name: r.name,
                                  primary: 'Risk ${r.score.toStringAsFixed(0)}',
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    _openLoan(context, r.loanId);
                                  },
                                ),
                            ],
                          ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// =============== forecast ===============

class ForecastCard extends StatefulWidget {
  final AnalyticsFilters f;
  final bool platform;
  const ForecastCard({super.key, required this.f, this.platform = false});

  @override
  State<ForecastCard> createState() => _ForecastCardState();
}

class _ForecastCardState extends State<ForecastCard> {
  int _weeks = 8;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final f = widget.f;

    return AsyncCard<Forecast>(
      cacheKey: 'fc|${widget.platform}|$_weeks|${f.scopeKey}',
      title: 'Cash-flow forecast',
      skeletonHeight: 220,
      load: () => AnalyticsService.forecast(
        weeks: _weeks,
        platform: widget.platform,
        scope: f.scope('admin'),
      ),
      builder: (context, fc) {
        final toggle = SegmentedButton<int>(
          showSelectedIcon: false,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
          segments: const [
            ButtonSegment(value: 4, label: Text('4')),
            ButtonSegment(value: 8, label: Text('8')),
            ButtonSegment(value: 12, label: Text('12')),
            ButtonSegment(value: 26, label: Text('26')),
          ],
          selected: {_weeks},
          onSelectionChanged: (v) => setState(() => _weeks = v.first),
        );

        return AnalyticsFrame(
          title: 'Expected next $_weeks weeks',
          trailing: toggle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Money.compact(fc.total),
                style: text.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (fc.arrears > 0)
                Text(
                  'Plus ${Money.compact(fc.arrears)} overdue and due now',
                  style: text.labelMedium?.copyWith(color: AppColors.warning),
                ),
              AppGap.h12,
              StackedBars(
                labels: [
                  for (final w in fc.series) periodLabel('${w['week_start']}'),
                ],
                stacks: [
                  for (final w in fc.series)
                    [(num.tryParse('${w['expected']}') ?? 0).toDouble()],
                ],
                colors: const [AppColors.stepCurrentLabel],
                names: const ['Due'],
                highlight: 0,
              ),
              AppGap.h8,
              Text(
                '${fc.assumption} The current week is highlighted.',
                style: text.labelSmall?.copyWith(
                  color: AppColors.darkOnSurfaceMuted,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
