import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';

class ProgressSegment {
  /// Share of the full bar, 0.0 to 1.0.
  final double value;

  /// null = default green.
  final Color? color;

  const ProgressSegment({required this.value, this.color});
}

/// Rounded progress bar. One color or many colors in a row.
///
/// Single:  AppProgressBar(value: 0.6)
/// Multi:   AppProgressBar.segmented(segments: [
///            ProgressSegment(value: 0.62),
///            ProgressSegment(value: 0.07, color: AppColors.progressWarning),
///          ])
class AppProgressBar extends StatelessWidget {
  final List<ProgressSegment> segments;
  final double height;
  final double? radius; // null = fully rounded
  final Color? trackColor; // null = theme outlineVariant
  final double segmentGap; // space between segments, 0 = flush
  final bool animate;
  final Duration duration;
  final String? semanticsLabel;

  const AppProgressBar.segmented({
    super.key,
    required this.segments,
    this.height = 8,
    this.radius,
    this.trackColor,
    this.segmentGap = 0,
    this.animate = true,
    this.duration = const Duration(milliseconds: 500),
    this.semanticsLabel,
  });

  AppProgressBar({
    super.key,
    required double value,
    Color? color,
    this.height = 8,
    this.radius,
    this.trackColor,
    this.animate = true,
    this.duration = const Duration(milliseconds: 500),
    this.semanticsLabel,
  }) : segments = [ProgressSegment(value: value, color: color)],
       segmentGap = 0;

  /// Clamp each value to 0..1 and scale down if the total goes over 1.
  List<double> _fractions() {
    final raw = segments.map((s) => s.value.clamp(0.0, 1.0)).toList();
    final total = raw.fold<double>(0, (a, b) => a + b);
    if (total <= 1) return raw;
    return raw.map((v) => v / total).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final track = trackColor ?? scheme.outlineVariant;
    final r = BorderRadius.circular(radius ?? height / 2);
    final fractions = _fractions();

    final total = fractions.fold<double>(0, (a, b) => a + b);
    final percent = (total * 100).round();

    return Semantics(
      label: semanticsLabel ?? 'Progress',
      value: '$percent%',
      child: ClipRRect(
        borderRadius: r,
        child: SizedBox(
          height: height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final gaps = segmentGap * (segments.length - 1).clamp(0, 99);
              final usable = (width - gaps).clamp(0.0, width);

              return ColoredBox(
                color: track,
                child: Row(
                  children: [
                    for (var i = 0; i < segments.length; i++) ...[
                      if (i > 0 && segmentGap > 0) SizedBox(width: segmentGap),
                      _Segment(
                        width: usable * fractions[i],
                        color: segments[i].color ?? AppColors.progressSuccess,
                        animate: animate,
                        duration: duration,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final double width;
  final Color color;
  final bool animate;
  final Duration duration;

  const _Segment({
    required this.width,
    required this.color,
    required this.animate,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    if (!animate) {
      return ColoredBox(
        color: color,
        child: SizedBox(width: width),
      );
    }
    // begin: 0 makes the first build grow from empty;
    // later value changes animate from the current width.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: width),
      duration: duration,
      curve: Curves.easeOut,
      builder: (_, w, _) => ColoredBox(
        color: color,
        child: SizedBox(width: w, height: double.infinity),
      ),
    );
  }
}
