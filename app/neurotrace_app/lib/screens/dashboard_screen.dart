import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sensor_reading.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/risk_gauge.dart';
import '../widgets/vital_tile.dart';
import 'breathing_sheet.dart';
import 'connect_device_screen.dart';
import 'guidance_screen.dart';
import 'log_headache_screen.dart';
import 'sos_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final r = s.current;
    List<double> last(double Function(SensorReading) f) {
      final list = s.history.length > 30 ? s.history.sublist(s.history.length - 30) : s.history;
      return list.map(f).toList();
    }

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.m, AppSpace.screen, 120),
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.mint,
                child: Text(s.userName[0],
                    style: AppText.section.copyWith(color: AppColors.teal)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${greeting()},', style: AppText.muted),
                    Text(s.userName, style: AppText.title.copyWith(fontSize: 20)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const ConnectDeviceScreen())),
                child: StatusChip(connected: s.connected, simulated: s.simulated),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.m),

          if (!s.connected)
            _Banner(
              color: AppColors.textMuted,
              icon: Icons.bluetooth_disabled_rounded,
              text: 'Wearable disconnected. Showing last known readings.',
              action: 'Connect',
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const ConnectDeviceScreen())),
            )
          else if (s.risk >= 0.6)
            _Banner(
              color: AppColors.high,
              icon: Icons.warning_amber_rounded,
              text: 'High ${s.type.title.toLowerCase()} headache risk. Act now to prevent it.',
              action: 'See tips',
              onTap: () => _openGuidance(context),
            ),

          // Hero risk card
          SoftCard(
            onTap: () => _openGuidance(context),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                RiskGauge(value: s.risk, size: 128),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Headache risk', style: AppText.label),
                      const SizedBox(height: 4),
                      Text(AppColors.riskLabel(s.risk),
                          style: AppText.title.copyWith(color: AppColors.risk(s.risk))),
                      const SizedBox(height: 10),
                      Text('Likely type', style: AppText.muted),
                      const SizedBox(height: 4),
                      TypeBadge(s.type),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text('View guidance',
                              style: AppText.label.copyWith(color: AppColors.teal, fontWeight: FontWeight.w600)),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.teal, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Vitals
          const SectionHeader('Vitals'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.02,
            children: [
              VitalTile(
                icon: Icons.favorite_rounded,
                label: 'Heart rate',
                value: r == null ? '--' : r.heartRate.round().toString(),
                unit: 'bpm',
                color: AppColors.heart,
                spark: last((e) => e.heartRate),
              ),
              VitalTile(
                icon: Icons.water_drop_rounded,
                label: 'SpO₂',
                value: r == null ? '--' : r.spo2.round().toString(),
                unit: '%',
                color: const Color(0xFF3B7DD8),
                spark: last((e) => e.spo2),
              ),
              VitalTile(
                icon: Icons.thermostat_rounded,
                label: 'Body temp',
                value: r == null ? '--' : r.bodyTemp.toStringAsFixed(1),
                unit: '°C',
                color: AppColors.peach,
                spark: last((e) => e.bodyTemp),
              ),
              VitalTile(
                icon: Icons.bolt_rounded,
                label: 'Skin conductance',
                value: r == null ? '--' : r.gsr.toStringAsFixed(1),
                unit: 'µS',
                color: const Color(0xFFE08A1E),
                spark: last((e) => e.gsr),
              ),
            ],
          ),

          // Environment
          const SectionHeader('Environment'),
          SizedBox(
            height: 118,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              children: [
                MiniTile(icon: Icons.wb_sunny_rounded, label: 'Ambient', color: AppColors.peach,
                    value: r == null ? '--' : '${r.ambientTemp.toStringAsFixed(1)}°C'),
                const SizedBox(width: 10),
                MiniTile(icon: Icons.opacity_rounded, label: 'Humidity', color: const Color(0xFF3B7DD8),
                    value: r == null ? '--' : '${r.humidity.round()}%'),
                const SizedBox(width: 10),
                MiniTile(icon: Icons.speed_rounded, label: 'Pressure', color: const Color(0xFF6B5BD2),
                    value: r == null ? '--' : '${r.pressure.round()} hPa'),
                const SizedBox(width: 10),
                MiniTile(icon: Icons.light_mode_rounded, label: 'Light', color: AppColors.medium,
                    value: r == null ? '--' : '${r.light.round()} lx'),
                const SizedBox(width: 10),
                MiniTile(icon: Icons.graphic_eq_rounded, label: 'Sound', color: AppColors.teal,
                    value: r == null ? '--' : '${r.sound.round()} dB'),
              ],
            ),
          ),

          // Tip
          const SizedBox(height: AppSpace.l),
          SoftCard(
            color: AppColors.peachLight,
            onTap: () => _openGuidance(context),
            child: Row(
              children: [
                const IconTile(icon: Icons.lightbulb_rounded, color: Color(0xFFE07A55), size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tip for you', style: AppText.label.copyWith(color: const Color(0xFFB85C3C))),
                      const SizedBox(height: 2),
                      Text(s.type.guidance.first, style: AppText.body.copyWith(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Quick actions
          const SectionHeader('Quick actions'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _QuickAction(
                icon: Icons.edit_note_rounded,
                label: 'Log\nheadache',
                color: AppColors.teal,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(fullscreenDialog: true, builder: (_) => const LogHeadacheScreen())),
              ),
              _QuickAction(
                icon: Icons.air_rounded,
                label: 'Breathe',
                color: const Color(0xFF6B5BD2),
                onTap: () => showBreathingSheet(context),
              ),
              _QuickAction(
                icon: Icons.local_drink_rounded,
                label: 'Hydrate',
                color: const Color(0xFF3B7DD8),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hydration reminder set for 1 hour')),
                ),
              ),
              _QuickAction(
                icon: Icons.sos_rounded,
                label: 'SOS',
                color: AppColors.high,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SosScreen())),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openGuidance(BuildContext context) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const GuidanceScreen()));
}

class _Banner extends StatelessWidget {
  const _Banner({required this.color, required this.icon, required this.text, required this.action, required this.onTap});
  final Color color;
  final IconData icon;
  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.m),
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppText.label.copyWith(color: AppColors.text))),
          TextButton(
            onPressed: onTap,
            child: Text(action, style: AppText.label.copyWith(color: color, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: Column(
        children: [
          SoftCard(
            onTap: onTap,
            padding: const EdgeInsets.all(14),
            radius: 20,
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: AppText.muted.copyWith(color: AppColors.text)),
        ],
      ),
    );
  }
}
