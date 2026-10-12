import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';

/// A grey placeholder shape. Put these inside an [AppShimmer] to animate them.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final bool circle;

  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.radius = AppSizes.radiusSm,
    this.circle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: circle ? height : width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white, // replaced by the shimmer gradient
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}

/// Sweeps a highlight across its child. Wrap ONLY SkeletonBox widgets in it,
/// because everything inside gets repainted with the shimmer colors.
class AppShimmer extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;

  const AppShimmer({
    super.key,
    required this.child,
    this.enabled = true,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1400),
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.period);

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant AppShimmer old) {
    super.didUpdateWidget(old);
    if (widget.enabled && !_controller.isAnimating) _controller.repeat();
    if (!widget.enabled && _controller.isAnimating) _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final scheme = Theme.of(context).colorScheme;
    final base = widget.baseColor ?? scheme.outlineVariant;
    final highlight = widget.highlightColor ?? scheme.outline;

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            colors: [base, highlight, base],
            stops: const [0.35, 0.5, 0.65],
            transform: _SlideTransform(-1 + 2 * _controller.value),
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }
}

class _SlideTransform extends GradientTransform {
  final double slide; // -1 (left of the box) to 1 (right of the box)
  const _SlideTransform(this.slide);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * slide, 0, 0);
}