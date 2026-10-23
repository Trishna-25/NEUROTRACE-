import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'common.dart';

/// Tile with icon, label, value, unit and a mini sparkline.
class VitalTile extends StatelessWidget {
  const VitalTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    this.spark = const [],
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;
  final List<double> spark;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(icon: icon, color: color, size: 34),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label, style: AppText.muted, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: AppText.bigNumber().copyWith(fontSize: 24)),
              const SizedBox(width: 4),
              Text(unit, style: AppText.muted),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(height: 26, width: double.infinity, child: Sparkline(values: spark, color: color)),
        ],
      ),
    );
  }
}

/// Small environment tile for the horizontal row.
class MiniTile extends StatelessWidget {
  const MiniTile({super.key, required this.icon, required this.label, required this.value, required this.color});
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      child: SoftCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconTile(icon: icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(value, style: AppText.body.copyWith(fontWeight: FontWeight.w700)),
            Text(label, style: AppText.muted, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class Sparkline extends StatelessWidget {
  const Sparkline({super.key, required this.values, required this.color});
  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _SparkPainter(values, color));
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.values, this.color);
  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final lo = values.reduce(min);
    final hi = values.reduce(max);
    final span = (hi - lo).abs() < 1e-6 ? 1.0 : hi - lo;
    final dx = size.width / (values.length - 1);

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i * dx;
      final y = size.height - ((values[i] - lo) / span) * size.height;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.25), color.withOpacity(0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SparkPainter old) => true;
}
