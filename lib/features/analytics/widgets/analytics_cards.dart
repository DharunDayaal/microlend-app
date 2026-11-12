import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/data/models/analytics_model.dart';
import 'package:micro_lending_app/data/services/analytics_service.dart';
import 'package:micro_lending_app/features/analytics/analytics_filter.dart';
import 'package:micro_lending_app/features/analytics/widgets/analytics_common.dart';
import 'package:micro_lending_app/routes/app_routes.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/utils/formatters/date_formatter.dart';

Duration _anim(BuildContext c) => MediaQuery.disableAnimationsOf(c)
    ? Duration.zero
    : const Duration(milliseconds: 500);

FlGridData get _grid => FlGridData(
  show: true,
  drawVerticalLine: false,
  getDrawingHorizontalLine: (_) =>
      const FlLine(color: AppColors.darkBorder, strokeWidth: 1),
);

String _shortDay(String w) =>
    w.length < 3 ? w : '${w[0]}${w.substring(1, 3).toLowerCase()}';

// ================= insights =================

class InsightsCard extends StatefulWidget {
  final AnalyticsFilters f;
  final String level;
  final void Function(Insight) onAction;
  const InsightsCard({
    super.key,
    required this.f,
    required this.level,
    required this.onAction,
  });

  @override
  State<InsightsCard> createState() => _InsightsCardState();
}

class _InsightsCardState extends State<InsightsCard> {
  bool _all = false;

  @override
  Widget build(BuildContext context) {
    final f = widget.f;
    return AsyncCard<List<Insight>>(
      cacheKey: 'insights|${widget.level}|${f.scopeKey}',
      title: 'Insights',
      skeletonHeight: 120,
      load: () => AnalyticsService.insights(scope: f.scope(widget.level)),
      builder: (context, list) {
        if (list.isEmpty) {
          return const AnalyticsFrame(
            title: 'Insights',
            child: EmptyNote('Insights appear once your customers have loans.'),
          );
        }
        final shown = _all ? list : list.take(3).toList();
        return AnalyticsFrame(
          title: 'Insights',
          trailing: list.length > 3
              ? TextButton(
                  onPressed: () => setState(() => _all = !_all),
                  child: Text(_all ? 'Show less' : 'See all ${list.length}'),
                )
              : null,
          child: Column(
            children: [
              for (final i in shown) ...[
                _InsightTile(
                  i: i,
                  onTap: i.action == null ? null : () => widget.onAction(i),
                ),
                if (i != shown.last) AppGap.h8,
              ],
            ],
          ),
        );
      },
    );
  }
}

class _InsightTile extends StatelessWidget {
  final Insight i;
  final VoidCallback? onTap;
  const _InsightTile({required this.i, this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final (color, icon) = switch (i.severity) {
      'critical' => (AppColors.progressDanger, Icons.error_outline),
      'warning' => (AppColors.warning, Icons.warning_amber_rounded),
      'positive' => (AppColors.success, Icons.trending_up_rounded),
      _ => (const Color(0xFF4FC3F7), Icons.info_outline),
    };

    return Semantics(
      button: onTap != null,
      label: '${i.severity}: ${i.title}. ${i.detail}',
      child: Material(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3, color: color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, size: 20, color: color),
                        AppGap.w12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                i.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: text.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                i.detail,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: text.labelMedium?.copyWith(
                                  color: AppColors.darkOnSurfaceMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (onTap != null)
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.darkOnSurfaceMuted,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= collections trend =================

class TrendCard extends StatefulWidget {
  final AnalyticsFilters f;
  final String level;
  const TrendCard({super.key, required this.f, required this.level});

  @override
  State<TrendCard> createState() => _TrendCardState();
}

class _TrendCardState extends State<TrendCard> {
  String _group = 'week';

  String _label(String raw) {
    final d = DateTime.tryParse(raw);
    return d == null ? raw : DateFormat('d MMM').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.f;
    final text = Theme.of(context).textTheme;

    return AsyncCard<List<TrendPoint>>(
      cacheKey: 'trend|${widget.level}|${f.key}|$_group',
      title: 'Collections vs target',
      skeletonHeight: 200,
      load: () => AnalyticsService.trend(
        from: f.fromStr,
        to: f.toStr,
        groupBy: _group,
        scope: f.scope(widget.level),
      ),
      builder: (context, pts) {
        final toggle = SegmentedButton<String>(
          showSelectedIcon: false,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
          segments: const [
            ButtonSegment(value: 'day', label: Text('D')),
            ButtonSegment(value: 'week', label: Text('W')),
            ButtonSegment(value: 'month', label: Text('M')),
          ],
          selected: {_group},
          onSelectionChanged: (v) => setState(() => _group = v.first),
        );
        final total = pts.fold<double>(0, (s, p) => s + p.collected);

        if (pts.isEmpty || total == 0) {
          return AnalyticsFrame(
            title: 'Collections vs target',
            trailing: toggle,
            child: const EmptyNote(
              'No collections in this period. Try a longer range.',
            ),
          );
        }

        final hasTarget = pts.any((p) => p.target != null);
        final maxY = pts.fold<double>(
          0,
          (m, p) => math.max(m, math.max(p.collected, p.target ?? 0)),
        );
        final best = pts.reduce((a, b) => a.collected >= b.collected ? a : b);
        final step = math.max(1, (pts.length / 4).ceil());

        return AnalyticsFrame(
          title: 'Collections vs target',
          trailing: toggle,
          child: Semantics(
            label: 'Collections trend, total ${Money.compact(total)}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Money.compact(total),
                  style: text.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Best ${_group == 'day' ? 'day' : _group}: ${_label(best.label)} '
                  '${Money.compact(best.collected)}',
                  style: text.labelMedium?.copyWith(
                    color: AppColors.darkOnSurfaceMuted,
                  ),
                ),
                AppGap.h12,
                Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: SizedBox(
                    height: 180,
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
                                if (i < 0 || i >= pts.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    _label(pts[i].label),
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
                                s.barIndex == 0
                                    ? LineTooltipItem(
                                        '${_label(pts[s.x.toInt()].label)}\n'
                                        '${Money.compact(pts[s.x.toInt()].collected)}'
                                        '${pts[s.x.toInt()].target != null ? ' of ${Money.compact(pts[s.x.toInt()].target!)}' : ''}',
                                        const TextStyle(fontSize: 12),
                                      )
                                    : null,
                            ],
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              for (var i = 0; i < pts.length; i++)
                                FlSpot(i.toDouble(), pts[i].collected),
                            ],
                            isCurved: true,
                            color: AppColors.success,
                            barWidth: 3,
                            dotData: FlDotData(
                              show: true,
                              checkToShowDot: (s, _) =>
                                  s.x == pts.length - 1, // last point only
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.success.withAlpha(28),
                            ),
                          ),
                          if (hasTarget)
                            LineChartBarData(
                              spots: [
                                for (var i = 0; i < pts.length; i++)
                                  if (pts[i].target != null)
                                    FlSpot(i.toDouble(), pts[i].target!),
                              ],
                              color: AppColors.warning,
                              barWidth: 2,
                              dashArray: [6, 4],
                              dotData: const FlDotData(show: false),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ================= portfolio: aging and status =================

class AgingCard extends StatelessWidget {
  final AnalyticsFilters f;
  final String level;
  final void Function(AgingBucket)? onBucket;
  const AgingCard({
    super.key,
    required this.f,
    required this.level,
    this.onBucket,
  });

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

    return AsyncCard<List<AgingBucket>>(
      cacheKey: 'aging|$level|${f.scopeKey}',
      title: 'Outstanding by age',
      skeletonHeight: 90,
      load: () => AnalyticsService.aging(scope: f.scope(level)),
      builder: (context, buckets) {
        final total = buckets.fold<double>(0, (s, b) => s + b.outstanding);
        if (buckets.isEmpty || total == 0) {
          return const AnalyticsFrame(
            title: 'Outstanding by age',
            child: EmptyNote('Nothing outstanding right now.'),
          );
        }

        return AnalyticsFrame(
          title: 'Outstanding by age',
          trailing: Text(
            Money.compact(total),
            style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          child: Semantics(
            label: 'Aging, total outstanding ${Money.compact(total)}',
            child: Column(
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
                              child: GestureDetector(
                                onTap: onBucket == null
                                    ? null
                                    : () => onBucket!(buckets[i]),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 2),
                                  color: _colors[i % _colors.length],
                                ),
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
                        Expanded(
                          child: Text(buckets[i].label, style: text.bodyMedium),
                        ),
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
            ),
          ),
        );
      },
    );
  }
}

class StatusCard extends StatelessWidget {
  final AnalyticsFilters f;
  const StatusCard({super.key, required this.f});

  Color _color(String s) => switch (s.toUpperCase()) {
    'ACTIVE' => AppColors.success,
    'OVERDUE' => AppColors.warning,
    'DEFAULTED' => AppColors.progressDanger,
    'PAID_OFF' => AppColors.stepCurrentLabel,
    _ => AppColors.darkOnSurfaceMuted,
  };

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AsyncCard<List<StatusSlice>>(
      cacheKey: 'status|${f.scopeKey}',
      title: 'Portfolio health',
      skeletonHeight: 160,
      load: () => AnalyticsService.status(scope: f.scope('admin')),
      builder: (context, slices) {
        final total = slices.fold<int>(0, (s, e) => s + e.count);
        if (total == 0) {
          return const AnalyticsFrame(
            title: 'Portfolio health',
            child: EmptyNote('No loans yet.'),
          );
        }

        return AnalyticsFrame(
          title: 'Portfolio health',
          child: Semantics(
            label: 'Loan status, $total loans',
            child: Row(
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        duration: _anim(context),
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: [
                            for (final s in slices)
                              if (s.count > 0)
                                PieChartSectionData(
                                  value: s.count.toDouble(),
                                  color: _color(s.status),
                                  radius: 16,
                                  showTitle: false,
                                ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$total',
                            style: text.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'loans',
                            style: text.labelSmall?.copyWith(
                              color: AppColors.darkOnSurfaceMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppGap.w12,
                Expanded(
                  child: Column(
                    children: [
                      for (final s in slices)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: _color(s.status),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              AppGap.w8,
                              Expanded(
                                child: Text(
                                  s.status.replaceAll('_', ' ').toLowerCase(),
                                  style: text.bodyMedium,
                                ),
                              ),
                              Text(
                                '${s.count}',
                                style: text.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ================= collections: calendar heatmap =================

class CalendarCard extends StatefulWidget {
  final AnalyticsFilters f;
  final String level;
  const CalendarCard({super.key, required this.f, required this.level});

  @override
  State<CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<CalendarCard> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selected;

  String get _ym => DateFormat('yyyy-MM').format(_month);

  void _shift(int by) => setState(() {
    _month = DateTime(_month.year, _month.month + by);
    _selected = null;
  });

  @override
  Widget build(BuildContext context) {
    final f = widget.f;
    final now = DateTime.now();
    final canNext = _month.isBefore(DateTime(now.year, now.month));

    return AsyncCard<CollectionCalendar>(
      cacheKey: 'cal|${widget.level}|${f.scopeKey}|$_ym',
      title: 'Collection calendar',
      skeletonHeight: 260,
      load: () =>
          AnalyticsService.calendar(month: _ym, scope: f.scope(widget.level)),
      builder: (context, cal) {
        final text = Theme.of(context).textTheme;
        final picked = _selected == null
            ? null
            : cal.days.where((d) => d.date == _selected).firstOrNull;

        return AnalyticsFrame(
          title: DateFormat('MMMM yyyy').format(_month),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Previous month',
                onPressed: () => _shift(-1),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              IconButton(
                tooltip: 'Next month',
                onPressed: canNext ? () => _shift(1) : null,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${Money.compact(cal.collected)} of ${Money.compact(cal.target)}'
                      '${cal.ratePct == null ? '' : ' • ${cal.ratePct!.toStringAsFixed(0)}%'}',
                      style: text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              AppGap.h12,
              CalendarHeatmap(
                cal: cal,
                selected: _selected,
                onSelect: (d) => setState(
                  () => _selected = d.date == _selected ? null : d.date,
                ),
              ),
              AppGap.h12,
              if (picked != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.darkBorder.withAlpha(60),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormatter.weekdayDate(picked.date),
                          style: text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        picked.isFuture
                            ? 'Target ${Money.compact(picked.target)}'
                            : 'Target ${Money.compact(picked.target)} • '
                                  'Paid ${Money.compact(picked.collected)}'
                                  '${picked.ratePct == null ? '' : ' • ${picked.ratePct!.toStringAsFixed(0)}%'}',
                        style: text.labelMedium?.copyWith(
                          color: AppColors.darkOnSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                AppGap.h8,
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(
                      AppRoutes.analyticsDueFor(
                        picked.date,
                        target: picked.target,
                        collected: picked.collected,
                        adminId: f.adminId,
                      ),
                    ),
                    icon: const Icon(Icons.list_alt_outlined),
                    label: const Text('Open due list'),
                  ),
                ),
              ] else
                Text(
                  'Tap a day for its target and collection.',
                  style: text.labelMedium?.copyWith(
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

class CalendarHeatmap extends StatelessWidget {
  final CollectionCalendar cal;
  final DateTime? selected;
  final ValueChanged<CalendarDay> onSelect;
  const CalendarHeatmap({
    super.key,
    required this.cal,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);

    Widget cell(CalendarDay d) {
      final isToday = d.date == todayDay;
      final isSel = d.date == selected;
      final rate = d.ratePct;
      final tinted = !d.isFuture && rate != null && d.target > 0;
      final fill = isSel
          ? AppColors.stepCurrentLabel
          : tinted
          ? AppColors.success.withAlpha(
              40 + (rate.clamp(0, 100) / 100 * 180).round(),
            )
          : Colors.transparent;
      final isBest = d.date == cal.bestDay;
      final isWorst = d.date == cal.worstDay;

      return Semantics(
        button: true,
        label:
            '${DateFormat('d MMMM').format(d.date)}, '
            '${d.isFuture
                ? 'upcoming'
                : rate == null
                ? 'nothing due'
                : '${rate.round()} percent collected'}',
        child: GestureDetector(
          onTap: () => onSelect(d),
          child: Container(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isToday
                    ? AppColors.stepCurrentLabel
                    : (tinted || isSel
                          ? Colors.transparent
                          : AppColors.darkBorder),
                width: isToday ? 2 : 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '${d.date.day}',
                  style: text.labelMedium?.copyWith(
                    color: isSel
                        ? AppColors.darkBackground
                        : AppColors.darkOnSurface,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (isBest)
                  const Positioned(
                    top: 1,
                    right: 2,
                    child: Icon(Icons.star_rounded, size: 10),
                  ),
                if (isWorst)
                  const Positioned(
                    top: 1,
                    right: 2,
                    child: Icon(
                      Icons.flag_rounded,
                      size: 10,
                      color: AppColors.progressDanger,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            for (final l in const ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
              Expanded(
                child: Center(
                  child: Text(
                    l,
                    style: text.labelSmall?.copyWith(
                      color: AppColors.darkOnSurfaceMuted,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          children: [
            // first_weekday pads the first row (1 = Monday)
            for (var i = 0; i < cal.firstWeekday - 1; i++)
              const SizedBox.shrink(),
            for (final d in cal.days) cell(d),
          ],
        ),
      ],
    );
  }
}

// ================= collections: by weekday =================

class WeekdayCard extends StatelessWidget {
  final AnalyticsFilters f;
  final String level;
  const WeekdayCard({super.key, required this.f, required this.level});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AsyncCard<List<WeekdayRow>>(
      cacheKey: 'weekday|$level|${f.key}',
      title: 'By weekday',
      skeletonHeight: 180,
      load: () => AnalyticsService.byWeekday(
        from: f.fromStr,
        to: f.toStr,
        scope: f.scope(level),
      ),
      builder: (context, rows) {
        final maxY = rows.fold<double>(
          0,
          (m, r) => math.max(m, math.max(r.target, r.collected)),
        );
        if (rows.isEmpty || maxY == 0) {
          return const AnalyticsFrame(
            title: 'By weekday',
            child: EmptyNote(
              'No collections in this period. Try a longer range.',
            ),
          );
        }

        return AnalyticsFrame(
          title: 'By weekday',
          child: Semantics(
            label: 'Target against collected for each weekday',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 190,
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
                            reservedSize: 38,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 0 || i >= rows.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  '${_shortDay(rows[i].weekday)}\n${rows[i].customers}',
                                  textAlign: TextAlign.center,
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
                          getTooltipItem: (group, _, rod, rodIndex) =>
                              BarTooltipItem(
                                '${rodIndex == 0 ? 'Target' : 'Collected'} ${Money.compact(rod.toY)}',
                                const TextStyle(fontSize: 12),
                              ),
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < rows.length; i++)
                          BarChartGroupData(
                            x: i,
                            barsSpace: 3,
                            barRods: [
                              BarChartRodData(
                                toY: rows[i].target,
                                width: 10,
                                color: AppColors.darkBorder,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              BarChartRodData(
                                toY: rows[i].collected,
                                width: 10,
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                AppGap.h8,
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      color: AppColors.darkBorder,
                    ),
                    AppGap.w8,
                    Text('Target', style: text.labelMedium),
                    AppGap.w12,
                    Container(width: 10, height: 10, color: AppColors.success),
                    AppGap.w8,
                    Text('Collected', style: text.labelMedium),
                    const Spacer(),
                    Text(
                      'Customers under each day',
                      style: text.labelSmall?.copyWith(
                        color: AppColors.darkOnSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ================= portfolio: cohorts =================

class CohortCard extends StatefulWidget {
  final AnalyticsFilters f;
  const CohortCard({super.key, required this.f});

  @override
  State<CohortCard> createState() => _CohortCardState();
}

class _CohortCardState extends State<CohortCard> {
  bool _onTrack = false; // false = Repaid, true = On track
  String? _picked;

  String _month(String c) {
    final d = DateTime.tryParse('$c-01');
    return d == null ? c : DateFormat('MMM yyyy').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.f;
    final text = Theme.of(context).textTheme;

    return AsyncCard<List<Cohort>>(
      cacheKey: 'cohorts|${f.scopeKey}',
      title: 'Repayment by issue month',
      skeletonHeight: 220,
      load: () => AnalyticsService.cohorts(scope: f.scope('admin')),
      builder: (context, all) {
        final toggle = SegmentedButton<bool>(
          showSelectedIcon: false,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
          segments: const [
            ButtonSegment(value: false, label: Text('Repaid')),
            ButtonSegment(value: true, label: Text('On track')),
          ],
          selected: {_onTrack},
          onSelectionChanged: (v) => setState(() => _onTrack = v.first),
        );

        final cohorts = all.where((c) => c.curve.isNotEmpty).toList();
        if (cohorts.isEmpty) {
          return AnalyticsFrame(
            title: 'Repayment by issue month',
            trailing: toggle,
            child: const EmptyNote(
              'Cohorts appear once loans have been issued for a few weeks.',
            ),
          );
        }

        // newest six are coloured, older ones fade
        final visibleStart = math.max(0, cohorts.length - 6);
        final focus = cohorts.firstWhere(
          (c) => c.cohort == _picked,
          orElse: () => cohorts.last,
        );
        double? v(CohortPoint p) => _onTrack ? p.onTrackPct : p.repaidPct;

        Color colorOf(int i) {
          final base =
              kSeries[(i - visibleStart).clamp(0, kSeries.length - 1) %
                  kSeries.length];
          if (i < visibleStart) {
            return AppColors.darkOnSurfaceMuted.withAlpha(90);
          }
          return (_picked == null || cohorts[i].cohort == _picked)
              ? base
              : base.withAlpha(70);
        }

        final last = focus.curve.lastWhere(
          (p) => p.repaidPct != null,
          orElse: () => focus.curve.last,
        );
        final gap = (last.repaidPct != null && last.onTrackPct != null)
            ? last.repaidPct! - last.onTrackPct!
            : null;

        return AnalyticsFrame(
          title: 'Repayment by issue month',
          trailing: toggle,
          child: Semantics(
            label: 'Repayment curves for each issue month',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 200,
                  child: LineChart(
                    duration: _anim(context),
                    LineChartData(
                      minY: 0,
                      maxY: 105,
                      minX: 1,
                      gridData: _grid,
                      borderData: FlBorderData(show: false),
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: 100,
                            color: AppColors.darkOnSurfaceMuted.withAlpha(80),
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                        ],
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 34,
                            interval: 25,
                            getTitlesWidget: (val, _) => Text(
                              '${val.toInt()}%',
                              style: text.labelSmall?.copyWith(
                                color: AppColors.darkOnSurfaceMuted,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          axisNameWidget: Text(
                            'Weeks since issue',
                            style: text.labelSmall?.copyWith(
                              color: AppColors.darkOnSurfaceMuted,
                            ),
                          ),
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: 2,
                            getTitlesWidget: (val, _) => Text(
                              '${val.toInt()}',
                              style: text.labelSmall?.copyWith(
                                color: AppColors.darkOnSurfaceMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => AppColors.darkBorder,
                          getTooltipItems: (spots) => [
                            for (final s in spots)
                              LineTooltipItem(
                                '${_month(cohorts[s.barIndex].cohort)}\n'
                                'Week ${s.x.toInt()}: ${s.y.toStringAsFixed(1)}%',
                                const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                      lineBarsData: [
                        for (var i = 0; i < cohorts.length; i++)
                          LineChartBarData(
                            spots: [
                              for (final p in cohorts[i].curve)
                                if (v(p) != null)
                                  FlSpot(p.week.toDouble(), v(p)!),
                            ],
                            isCurved: true,
                            color: colorOf(i),
                            barWidth: cohorts[i].cohort == focus.cohort ? 3 : 2,
                            dotData: const FlDotData(show: false),
                          ),
                      ],
                    ),
                  ),
                ),
                AppGap.h12,
                Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: [
                    for (var i = 0; i < cohorts.length; i++)
                      ChoiceChip(
                        showCheckmark: false,
                        selected: cohorts[i].cohort == focus.cohort,
                        onSelected: (_) =>
                            setState(() => _picked = cohorts[i].cohort),
                        avatar: CircleAvatar(
                          radius: 5,
                          backgroundColor: colorOf(i),
                        ),
                        label: Text(_month(cohorts[i].cohort)),
                      ),
                  ],
                ),
                AppGap.h12,
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.darkBorder.withAlpha(60),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_month(focus.cohort)}: ${focus.loans} loans • '
                        '${CurrencyFormatter.format(focus.nominal)}'
                        '${focus.defaultRatePct == null ? '' : ' • ${focus.defaultRatePct!.toStringAsFixed(1)}% defaulted'}',
                        style: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        last.repaidPct == null
                            ? 'Too early to read this cohort.'
                            : 'Loans issued in ${_month(focus.cohort)} have repaid '
                                  '${last.repaidPct!.toStringAsFixed(0)}% of what they owe after '
                                  '${last.week} weeks'
                                  '${gap == null ? '.' : '; the schedule says ${last.onTrackPct!.toStringAsFixed(0)}%, so they are ${gap >= -1 ? 'on track' : 'behind'}.'}',
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
        );
      },
    );
  }
}
