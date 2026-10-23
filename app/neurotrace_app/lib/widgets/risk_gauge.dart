import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Circular ring showing headache risk (0..1). Animates between values.
class RiskGauge extends StatelessWidget {
  const RiskGauge({super.key, required this.value, this.size = 140, this.stroke = 14});
  final double value;
  final double size;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.clamp(0, 1).toDouble()),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        final color = AppColors.risk(v);
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(v, color, stroke),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${(v * 100).round()}%', style: AppText.bigNumber(color).copyWith(fontSize: size * 0.22)),
                  Text('${AppColors.riskLabel(v)} risk',
                      style: AppText.muted.copyWith(fontWeight: FontWeight.w600, color: color)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.color, this.stroke);
  final double value;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    final track = Paint()
      ..color = AppColors.mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawArc(r, 0, 2 * pi, false, track);

    final arc = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * pi,
        colors: [AppColors.teal, color],
        transform: const GradientRotation(-pi / 2),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    canvas.drawArc(r, -pi / 2, 2 * pi * max(value, 0.01), false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value || old.color != color;
}
