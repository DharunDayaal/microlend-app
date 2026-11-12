import 'dart:async';

import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_name_card.dart';
import 'package:micro_lending_app/common/widgets/app_skeleton.dart';
import 'package:micro_lending_app/data/models/analytics_model.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/utils/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/utils/loggers/app_logger.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';

/// Chart palette: at most four series, then muted.
const kSeries = [
  AppColors.stepCurrentLabel,
  AppColors.success,
  AppColors.warning,
  Color(0xFFB388FF),
  Color(0xFF4FC3F7),
];

class Money {
  Money._();

  /// Full below 1 lakh, compact above (₹1.2L, ₹4.5Cr).
  static String compact(double v) {
    final a = v.abs();
    final sign = v < 0 ? '-' : '';
    String t(double x) =>
        x.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
    if (a >= 1e7) return '$sign₹${t(a / 1e7)}Cr';
    if (a >= 1e5) return '$sign₹${t(a / 1e5)}L';
    return CurrencyFormatter.format(v);
  }
}

class AnalyticsFrame extends StatelessWidget {
  final String? title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const AnalyticsFrame({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.padding = const EdgeInsets.all(AppSizes.md),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Material(
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title!,
                        style: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ?trailing,
                  ],
                ),
                AppGap.h12,
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// A card that loads on its own: skeleton, then content, or its own error
/// with Retry. It reloads only when [cacheKey] changes.
class AsyncCard<T> extends StatefulWidget {
  final String cacheKey;
  final Future<T> Function() load;
  final Widget Function(BuildContext context, T data) builder;
  final double skeletonHeight;
  final String? title; // shown on the skeleton and the error

  const AsyncCard({
    super.key,
    required this.cacheKey,
    required this.load,
    required this.builder,
    this.skeletonHeight = 140,
    this.title,
  });

  @override
  State<AsyncCard<T>> createState() => _AsyncCardState<T>();
}

class _AsyncCardState<T> extends State<AsyncCard<T>> {
  T? _data;
  String? _error;
  bool _loading = true;
  bool _slow = false;
  int _req = 0;
  Timer? _slowTimer;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(covariant AsyncCard<T> old) {
    super.didUpdateWidget(old);
    if (old.cacheKey != widget.cacheKey) _fetch();
  }

  @override
  void dispose() {
    _slowTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetch() async {
    final id = ++_req;
    setState(() {
      _loading = true;
      _error = null;
      _slow = false;
    });
    _slowTimer?.cancel();
    _slowTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && _loading) setState(() => _slow = true);
    });

    try {
      final v = await widget.load();
      if (!mounted || id != _req) return;
      setState(() => _data = v);
    } on ApiException catch (e) {
      if (mounted && id == _req) setState(() => _error = e.message);
    } catch (e, st) {
      AppLogger.error(
        'Analytics card failed',
        tag: 'Analytics',
        error: e,
        stack: st,
      );
      if (mounted && id == _req) {
        setState(() => _error = 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted && id == _req) {
        _slowTimer?.cancel();
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final data = _data;

    if (data != null && _error == null) {
      return Opacity(
        opacity: _loading ? 0.5 : 1,
        child: widget.builder(context, data),
      );
    }

    if (_loading) {
      return AnalyticsFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppShimmer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(width: 120, height: 14, radius: 4),
                  AppGap.h12,
                  SkeletonBox(
                    width: double.infinity,
                    height: widget.skeletonHeight,
                    radius: AppSizes.radiusMd,
                  ),
                ],
              ),
            ),
            if (_slow) ...[
              AppGap.h8,
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Taking longer than usual.',
                      style: text.labelMedium?.copyWith(
                        color: AppColors.darkOnSurfaceMuted,
                      ),
                    ),
                  ),
                  TextButton(onPressed: _fetch, child: const Text('Retry')),
                ],
              ),
            ],
          ],
        ),
      );
    }

    return AnalyticsFrame(
      title: widget.title,
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: AppColors.darkOnSurfaceMuted,
          ),
          AppGap.w12,
          Expanded(
            child: Text(
              _error ?? 'Could not load this card.',
              style: text.bodyMedium,
            ),
          ),
          TextButton(onPressed: _fetch, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class EmptyNote extends StatelessWidget {
  final String message;
  const EmptyNote(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Row(
        children: [
          const Icon(Icons.inbox_outlined, color: AppColors.darkOnSurfaceMuted),
          AppGap.w12,
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.darkOnSurfaceMuted),
            ),
          ),
        ],
      ),
    );
  }
}

/// Counts up on first load (600 ms), instant when the OS asks for less motion.
class CountUp extends StatelessWidget {
  final double value;
  final String Function(double) format;
  final TextStyle? style;
  const CountUp({
    super.key,
    required this.value,
    required this.format,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Text(format(value), style: style);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (_, v, _) => Text(format(v), style: style),
    );
  }
}

/// Amounts show change_pct; rates show the change in percentage points.
/// Colour comes from is_good, muted when null.
class DeltaChip extends StatelessWidget {
  final KpiMetric m;
  const DeltaChip({super.key, required this.m});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final color = m.isGood == null
        ? AppColors.darkOnSurfaceMuted
        : (m.isGood! ? AppColors.success : AppColors.progressDanger);
    final icon = switch (m.direction) {
      'up' => Icons.arrow_upward_rounded,
      'down' => Icons.arrow_downward_rounded,
      _ => Icons.remove_rounded,
    };
    String amount(double v) =>
        m.unit == 'INR' ? Money.compact(v.abs()) : v.abs().round().toString();
    final sign = m.change > 0
        ? '+'
        : '${m.change > 0 ? '+' : '-'}${amount(m.change)}';

    final label = m.unit == '%'
        ? '$sign${m.change.toStringAsFixed(1)} pts'
        : m.changePct != null
        ? '$sign${m.changePct!.round()}%'
        : m.change == 0
        ? 'No change'
        : '$sign${m.change < 0 ? '-' : ''}${amount(m.change)} (new)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(32),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(label, style: text.labelSmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}

Color rateColor(double? pct) => pct == null
    ? AppColors.darkOnSurfaceMuted
    : pct >= 90
    ? AppColors.success
    : pct >= 60
    ? AppColors.warning
    : AppColors.progressDanger;

class Pill extends StatelessWidget {
  final String label;
  final Color color;
  const Pill(this.label, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withAlpha(32),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
    ),
  );
}

class StatCol extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const StatCol(this.label, this.value, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: text.labelSmall?.copyWith(color: AppColors.darkOnSurfaceMuted),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: text.bodyLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class RankedRow extends StatelessWidget {
  final int? rank;
  final String name;
  final String primary;
  final String? secondary;
  final Widget? pill;
  final Widget? trailing;
  final VoidCallback? onTap;

  const RankedRow({
    super.key,
    required this.name,
    required this.primary,
    this.rank,
    this.secondary,
    this.pill,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          children: [
            if (rank != null)
              SizedBox(
                width: 26,
                child: Text(
                  '$rank',
                  style: text.labelLarge?.copyWith(
                    color: AppColors.darkOnSurfaceMuted,
                  ),
                ),
              ),
            AppNameCard(name: name.isEmpty ? '?' : name, width: 36, height: 36),
            AppGap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (secondary != null)
                    Text(
                      secondary!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                  primary,
                  style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                ?pill,
              ],
            ),
            ?trailing,
            if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.darkOnSurfaceMuted,
              ),
          ],
        ),
      ),
    );
  }
}

/// A paged list card: first page with a skeleton, then "Show more".
class PagedCard<T> extends StatefulWidget {
  final String cacheKey;
  final String title;
  final String empty;
  final Future<PagedRows<T>> Function(int page) load;
  final Widget Function(BuildContext context, T item, int index) rowBuilder;

  const PagedCard({
    super.key,
    required this.cacheKey,
    required this.title,
    required this.empty,
    required this.load,
    required this.rowBuilder,
  });

  @override
  State<PagedCard<T>> createState() => _PagedCardState<T>();
}

class _PagedCardState<T> extends State<PagedCard<T>> {
  final _items = <T>[];
  int _total = 0;
  int _page = 1;
  bool _loading = true;
  bool _more = false;
  String? _error;
  int _req = 0;

  @override
  void initState() {
    super.initState();
    _first();
  }

  @override
  void didUpdateWidget(covariant PagedCard<T> old) {
    super.didUpdateWidget(old);
    if (old.cacheKey != widget.cacheKey) _first();
  }

  Future<void> _first() async {
    final id = ++_req;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await widget.load(1);
      if (!mounted || id != _req) return;
      setState(() {
        _items
          ..clear()
          ..addAll(r.rows);
        _total = r.total;
        _page = 1;
      });
    } on ApiException catch (e) {
      if (mounted && id == _req) setState(() => _error = e.message);
    } catch (e, st) {
      AppLogger.error(
        'Paged card failed',
        tag: 'Analytics',
        error: e,
        stack: st,
      );
      if (mounted && id == _req) {
        setState(() => _error = 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted && id == _req) setState(() => _loading = false);
    }
  }

  Future<void> _next() async {
    if (_more) return;
    final id = _req;
    setState(() => _more = true);
    try {
      final r = await widget.load(_page + 1);
      if (!mounted || id != _req) return;
      setState(() {
        _items.addAll(r.rows);
        _page += 1;
      });
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _more = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    if (_loading) {
      return const AnalyticsFrame(
        child: AppShimmer(
          child: Column(
            children: [
              SkeletonBox(width: double.infinity, height: 40, radius: 8),
              SizedBox(height: 10),
              SkeletonBox(width: double.infinity, height: 40, radius: 8),
              SizedBox(height: 10),
              SkeletonBox(width: double.infinity, height: 40, radius: 8),
            ],
          ),
        ),
      );
    }
    if (_error != null) {
      return AnalyticsFrame(
        title: widget.title,
        child: Row(
          children: [
            Expanded(child: Text(_error!, style: text.bodyMedium)),
            TextButton(onPressed: _first, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return AnalyticsFrame(
        title: widget.title,
        child: EmptyNote(widget.empty),
      );
    }

    final left = _total - _items.length;
    return AnalyticsFrame(
      title: widget.title,
      trailing: Text(
        '$_total',
        style: text.labelMedium?.copyWith(color: AppColors.darkOnSurfaceMuted),
      ),
      child: Column(
        children: [
          for (var i = 0; i < _items.length; i++)
            widget.rowBuilder(context, _items[i], i),
          if (left > 0)
            TextButton(
              onPressed: _more ? null : _next,
              child: Text(_more ? 'Loading...' : 'Show more ($left left)'),
            ),
        ],
      ),
    );
  }
}
