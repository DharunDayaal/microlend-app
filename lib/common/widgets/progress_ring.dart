import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';

/// A ring that fills to [value] (0 to 1) with the percentage in the centre.
class ProgressRing extends StatelessWidget {
  final double value;
  final double size;
  final double stroke;
  final Color color;

  const ProgressRing({
    super.key,
    required this.value,
    this.size = 76,
    this.stroke = 8,
    this.color = AppColors.success,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    final instant = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      label: '${(v * 100).round()} percent collected',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: v),
        duration: instant ? Duration.zero : const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) => SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(t, stroke, color),
            child: Center(
              child: Text(
                '${(t * 100).round()}%',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double t;
  final double stroke;
  final Color color;
  _RingPainter(this.t, this.stroke, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      arc,
      0,
      6.2831853,
      false,
      base..color = AppColors.darkBorder,
    );
    if (t > 0) {
      canvas.drawArc(
        arc,
        -1.5707963,
        6.2831853 * t,
        false,
        base..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter o) =>
      o.t != t || o.stroke != stroke || o.color != color;
}
