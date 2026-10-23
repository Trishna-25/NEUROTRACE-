import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  int _tab = 0;
  static const _tabs = ['Overview', 'Heart', 'Stress', 'Environment'];

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final hr = s.series((r) => r.heartRate);
    final avgHr = hr.isEmpty ? 0 : hr.reduce((a, b) => a + b) / hr.length;
    final weekCount = s.weeklyEpisodeCounts.fold<int>(0, (a, b) => a + b);

    final List<Widget> charts = switch (_tab) {
      1 => [
          LineChartCard(title: 'Heart rate', values: hr, color: AppColors.heart, unit: 'bpm', icon: Icons.favorite_rounded),
          LineChartCard(title: 'SpO₂', values: s.series((r) => r.spo2), color: const Color(0xFF3B7DD8), unit: '%', icon: Icons.water_drop_rounded),
          LineChartCard(title: 'Body temperature', values: s.series((r) => r.bodyTemp), color: AppColors.peach, unit: '°C', icon: Icons.thermostat_rounded, decimals: 1),
        ],
      2 => [
          LineChartCard(title: 'Skin conductance', values: s.series((r) => r.gsr), color: const Color(0xFFE08A1E), unit: 'µS', icon: Icons.bolt_rounded, decimals: 1),
          LineChartCard(title: 'Activity', values: s.series((r) => r.motion), color: AppColors.teal, unit: 'g', icon: Icons.directions_walk_rounded, decimals: 2),
        ],
      3 => [
          LineChartCard(title: 'Ambient temperature', values: s.series((r) => r.ambientTemp), color: AppColors.peach, unit: '°C', icon: Icons.wb_sunny_rounded, decimals: 1),
          LineChartCard(title: 'Humidity', values: s.series((r) => r.humidity), color: const Color(0xFF3B7DD8), unit: '%', icon: Icons.opacity_rounded),
          LineChartCard(title: 'Sound', values: s.series((r) => r.sound), color: AppColors.teal, unit: 'dB', icon: Icons.graphic_eq_rounded),
          LineChartCard(title: 'Light', values: s.series((r) => r.light), color: AppColors.medium, unit: 'lx', icon: Icons.light_mode_rounded),
        ],
      _ => [
          WeeklyBarCard(title: 'Headache episodes', subtitle: 'Last 7 days', counts: s.weeklyEpisodeCounts),
          LineChartCard(
              title: 'Headache risk',
              values: s.series((r) => (r.deviceRisk ?? 0) * 100),
              color: AppColors.risk(s.risk),
              unit: '%',
              icon: Icons.shield_moon_rounded),
        ],
    };

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.m, AppSpace.screen, 120),
        children: [
          Text('Health trends', style: AppText.title),
          Text('Live data from your wearable', style: AppText.muted),
          const SizedBox(height: AppSpace.m),
          PillTabs(tabs: _tabs, selected: _tab, onChanged: (i) => setState(() => _tab = i)),
          const SizedBox(height: AppSpace.m),
          if (_tab == 0) ...[
            Row(
              children: [
                _Stat(icon: Icons.favorite_rounded, color: AppColors.heart, value: '${avgHr.round()}', label: 'Avg bpm'),
                const SizedBox(width: 10),
                _Stat(icon: Icons.warning_amber_rounded, color: AppColors.high, value: '${(s.highRiskShare * 100).round()}%', label: 'High risk'),
                const SizedBox(width: 10),
                _Stat(icon: Icons.event_note_rounded, color: AppColors.teal, value: '$weekCount', label: 'This week'),
              ],
            ),
            const SizedBox(height: 12),
          ],
          for (final c in charts) Padding(padding: const EdgeInsets.only(bottom: 12), child: c),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.color, required this.value, required this.label});
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SoftCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconTile(icon: icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(value, style: AppText.section.copyWith(fontSize: 18)),
            Text(label, style: AppText.muted),
          ],
        ),
      ),
    );
  }
}
