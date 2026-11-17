import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_skeleton.dart';
import 'package:micro_lending_app/data/models/report_model.dart';
import 'package:micro_lending_app/data/services/report_service.dart';
import 'package:micro_lending_app/features/analytics/widgets/analytics_common.dart';
import 'package:micro_lending_app/features/reports/report_links.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';

TextStyle? _hero(BuildContext c) => Theme.of(c).textTheme.headlineMedium
    ?.copyWith(
      fontWeight: FontWeight.w600,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

Widget _asOf(BuildContext c) => Text(
  'As of today',
  style: Theme.of(c).textTheme.labelSmall
      ?.copyWith(color: AppColors.darkOnSurfaceMuted),
);

class _Stat extends StatelessWidget {
  final String label;
  final double value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.labelMedium?.copyWith(
              color: AppColors.darkOnSurfaceMuted,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Money.compact(value),
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= cash outstanding =================

class CashOutstandingCard extends StatelessWidget {
  final int tick; // bumped by pull-to-refresh
  const CashOutstandingCard({super.key, required this.tick});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AsyncCard<CashOutstanding>(
      cacheKey: 'rep-cash|$tick',
      title: 'Cash outstanding',
      skeletonHeight: 200,
      load: ReportsService.cashOutstanding,
      builder: (context, d) {
        if (d.activeLoans == 0 && d.payable == 0) {
          return const AnalyticsFrame(
            title: 'Cash outstanding',
            child: EmptyNote('No loans in the book yet.'),
          );
        }
        final pct = (d.collectedShare * 100).round();

        return AnalyticsFrame(
          title: 'Cash outstanding',
          trailing: _asOf(context),
          child: Semantics(
            label:
                'Outstanding receivable ${CurrencyFormatter.format(d.outstanding)}, '
                '$pct percent of the payable amount collected',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Outstanding receivable',
                  style: text.labelMedium?.copyWith(
                    color: AppColors.darkOnSurfaceMuted,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: CountUp(
                    value: d.outstanding,
                    format: CurrencyFormatter.format,
                    style: _hero(context),
                  ),
                ),
                AppGap.h12,
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: d.collectedShare,
                    minHeight: 10,
                    color: AppColors.success,
                    backgroundColor: AppColors.darkBorder,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$pct% of payable collected',
                  style: text.labelMedium?.copyWith(
                    color: AppColors.darkOnSurfaceMuted,
                  ),
                ),
                AppGap.h12,
                Row(
                  children: [
                    _Stat('Disbursed', d.disbursed),
                    _Stat('Payable', d.payable),
                    _Stat('Collected', d.collected),
                  ],
                ),
                AppGap.h12,
                Text(
                  '${d.activeLoans} loans in the book',
                  style: text.labelMedium?.copyWith(
                    color: AppColors.darkOnSurfaceMuted,
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

// ================= earnings =================

class ReportEarningsCard extends StatelessWidget {
  final int tick;
  const ReportEarningsCard({super.key, required this.tick});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AsyncCard<EarningsReport>(
      cacheKey: 'rep-earn|$tick',
      title: 'Earnings',
      skeletonHeight: 150,
      load: ReportsService.earnings,
      builder: (context, d) {
        if (d.total == 0 && d.expected == 0) {
          return const AnalyticsFrame(
            title: 'Earnings',
            child: EmptyNote('Earnings appear once loans are issued.'),
          );
        }
        return AnalyticsFrame(
          title: 'Earnings',
          trailing: _asOf(context),
          child: Semantics(
            label: 'Total earned ${CurrencyFormatter.format(d.total)}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total earned',
                  style: text.labelMedium?.copyWith(
                    color: AppColors.darkOnSurfaceMuted,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: CountUp(
                    value: d.total,
                    format: CurrencyFormatter.format,
                    style: _hero(context),
                  ),
                ),
                AppGap.h12,
                Row(
                  children: [
                    _Stat('Fees', d.fees),
                    _Stat('Interest', d.interest),
                    _Stat('Expected interest', d.expected),
                  ],
                ),
                AppGap.h8,
                Text(
                  'Interest counts only what was collected above the principal, '
                  'so it trails the expected figure until loans are repaid.',
                  style: text.labelSmall?.copyWith(
                    color: AppColors.darkOnSurfaceMuted,
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

// ================= overdue =================

class _OverdueTile extends StatelessWidget {
  final OverdueRow r;
  final VoidCallback onTap;
  const _OverdueTile({required this.r, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final color = r.daysPastDue > 30
        ? AppColors.progressDanger
        : AppColors.warning;

    return Semantics(
      button: true,
      label:
          '${r.customerName}, ${CurrencyFormatter.format(r.outstanding)} outstanding, '
          '${r.daysPastDue} days late',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${CurrencyFormatter.format(r.outstanding)} outstanding',
                          style: text.labelMedium?.copyWith(
                            color: AppColors.darkOnSurfaceMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: color.withAlpha(28),
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: Text(
                      '${r.daysPastDue} days late',
                      style: text.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.darkOnSurfaceMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OverdueCard extends StatelessWidget {
  final int tick;
  const OverdueCard({super.key, required this.tick});

  @override
  Widget build(BuildContext context) {
    return AsyncCard<OverduePage>(
      cacheKey: 'rep-overdue|$tick',
      title: 'Overdue loans',
      skeletonHeight: 240,
      load: () => ReportsService.overdue(page: 1, limit: 20),
      builder: (context, p) {
        if (p.rows.isEmpty) {
          return const AnalyticsFrame(
            title: 'Overdue loans',
            child: EmptyNote('No overdue loans. Everything is on schedule.'),
          );
        }
        final shown = p.rows.take(5).toList();
        final more = p.hasNext || p.rows.length > shown.length;

        return AnalyticsFrame(
          title: 'Overdue loans',
          trailing: more
              ? TextButton(
                  onPressed: () => showOverdueSheet(context),
                  child: const Text('See all'),
                )
              : _asOf(context),
          child: Column(
            children: [
              for (final r in shown)
                _OverdueTile(
                  r: r,
                  onTap: () => ReportLinks.loan(context, r.loanId),
                ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> showOverdueSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _OverdueSheet(),
    );

class _OverdueSheet extends StatefulWidget {
  const _OverdueSheet();

  @override
  State<_OverdueSheet> createState() => _OverdueSheetState();
}

class _OverdueSheetState extends State<_OverdueSheet> {
  final _scroll = ScrollController();
  final _rows = <OverdueRow>[];
  final _seen = <String>{};
  int _page = 1;
  bool _loading = false;
  bool _hasNext = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 300) _load();
    });
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_loading || !_hasNext) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await ReportsService.overdue(page: _page, limit: 20);
      if (!mounted) return;
      setState(() {
        for (final r in p.rows) {
          if (_seen.add(r.loanId)) _rows.add(r); // pages can shift
        }
        _hasNext = p.hasNext;
        _page++;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final first = _rows.isEmpty;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSizes.sm),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.darkBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text('Overdue loans', style: text.headlineSmall),
                ),
                _asOf(context),
              ],
            ),
          ),
          Expanded(
            child: first && _loading
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.lg),
                    child: AppShimmer(
                      child: Column(
                        children: [
                          SkeletonBox(height: 56, radius: AppSizes.radiusMd),
                          SizedBox(height: AppSizes.sm),
                          SkeletonBox(height: 56, radius: AppSizes.radiusMd),
                          SizedBox(height: AppSizes.sm),
                          SkeletonBox(height: 56, radius: AppSizes.radiusMd),
                          SizedBox(height: AppSizes.sm),
                          SkeletonBox(height: 56, radius: AppSizes.radiusMd),
                          SizedBox(height: AppSizes.sm),
                          SkeletonBox(height: 56, radius: AppSizes.radiusMd),
                        ],
                      ),
                    ),
                  )
                : first && _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!),
                        TextButton(
                          onPressed: _load,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : first
                ? const Center(child: Text('No overdue loans.'))
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.lg,
                      0,
                      AppSizes.lg,
                      AppSizes.lg,
                    ),
                    itemCount: _rows.length + 1,
                    itemBuilder: (context, i) {
                      if (i < _rows.length) {
                        final r = _rows[i];
                        return _OverdueTile(
                          r: r,
                          onTap: () => ReportLinks.loan(context, r.loanId),
                        );
                      }
                      if (_error != null) {
                        return Row(
                          children: [
                            Expanded(child: Text(_error!)),
                            TextButton(
                              onPressed: _load,
                              child: const Text('Retry'),
                            ),
                          ],
                        );
                      }
                      return _loading
                          ? const Padding(
                              padding: EdgeInsets.all(AppSizes.md),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink();
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
