import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'common.dart';

/// Card with a smooth line chart of recent values.
class LineChartCard extends StatelessWidget {
  const LineChartCard({
    super.key,
    required this.title,
    required this.values,
    required this.color,
    required this.unit,
    this.icon,
    this.decimals = 0,
  });

  final String title;
  final List<double> values;
  final Color color;
  final String unit;
  final IconData? icon;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    final hasData = values.length >= 2;
    final lo = hasData ? values.reduce(min) : 0.0;
    final hi = hasData ? values.reduce(max) : 1.0;
    final pad = max((hi - lo) * 0.2, 0.5);

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[IconTile(icon: icon!, color: color, size: 32), const SizedBox(width: 10)],
              Expanded(child: Text(title, style: AppText.section.copyWith(fontSize: 15))),
              if (hasData)
                Text('${values.last.toStringAsFixed(decimals)} $unit',
                    style: AppText.body.copyWith(fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 130,
            child: !hasData
                ? Center(child: Text('Waiting for data…', style: AppText.muted))
                : LineChart(
                    LineChartData(
                      minY: lo - pad,
                      maxY: hi + pad,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(color: AppColors.mint, strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(show: false),
                      lineTouchData: LineTouchData(enabled: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])],
                          isCurved: true,
                          curveSmoothness: 0.25,
                          barWidth: 2.5,
                          color: color,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [color.withOpacity(0.22), color.withOpacity(0)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          Text('Last ${values.length} seconds', style: AppText.muted),
        ],
      ),
    );
  }
}

/// Weekly bar chart (Mon..Sun labels end on today).
class WeeklyBarCard extends StatelessWidget {
  const WeeklyBarCard({super.key, required this.title, required this.counts, this.subtitle});
  final String title;
  final String? subtitle;
  final List<int> counts;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final labels = List.generate(7, (i) => weekdayShort[today.subtract(Duration(days: 6 - i)).weekday - 1]);
    final maxCount = max(counts.fold<int>(0, max), 1);
    final top = maxCount + 1.0;

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.section.copyWith(fontSize: 15)),
          if (subtitle != null) Text(subtitle!, style: AppText.muted),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                maxY: top,
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(labels[value.toInt()], style: AppText.muted),
                      ),
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < 7; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: counts[i].toDouble(),
                          width: 14,
                          color: i == 6 ? AppColors.peach : AppColors.teal,
                          borderRadius: BorderRadius.circular(7),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: top,
                            color: AppColors.mint.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
