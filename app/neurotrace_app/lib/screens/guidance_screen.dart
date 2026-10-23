import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sensor_reading.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'breathing_sheet.dart';

class GuidanceScreen extends StatelessWidget {
  const GuidanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final type = s.type;
    final factors = s.current == null ? <(String, double, IconData)>[] : _factors(s.current!);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Risk & guidance')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.s, AppSpace.screen, AppSpace.xl),
          children: [
            // Type hero
            SoftCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: type.color.withOpacity(0.12),
                      border: Border.all(color: type.color.withOpacity(0.3), width: 6),
                    ),
                    child: Icon(type.icon, color: type.color, size: 40),
                  ),
                  const SizedBox(height: 14),
                  Text(type.title, style: AppText.title),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.risk(s.risk).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${AppColors.riskLabel(s.risk)} risk  •  ${(s.risk * 100).round()}%',
                        style: AppText.label.copyWith(color: AppColors.risk(s.risk), fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 12),
                  Text(type.explanation, textAlign: TextAlign.center, style: AppText.body.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),

            // Why
            const SectionHeader('Why this prediction?'),
            SoftCard(
              child: Column(
                children: [
                  for (final f in factors.take(4))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          IconTile(icon: f.$3, color: AppColors.teal, size: 34),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(f.$1, style: AppText.label.copyWith(color: AppColors.text)),
                                    const Spacer(),
                                    Text('${(f.$2 * 100).round()}%', style: AppText.muted),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: f.$2,
                                    minHeight: 7,
                                    backgroundColor: AppColors.mint,
                                    color: AppColors.risk(f.$2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Steps
            const SectionHeader('What you can do now'),
            for (final tip in type.guidance)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SoftCard(
                  onTap: () => context.read<AppState>().toggleTip(tip),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: s.doneTips.contains(tip) ? AppColors.teal : Colors.transparent,
                          border: Border.all(color: AppColors.teal, width: 2),
                        ),
                        child: s.doneTips.contains(tip)
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tip,
                          style: AppText.body.copyWith(
                            decoration: s.doneTips.contains(tip) ? TextDecoration.lineThrough : null,
                            color: s.doneTips.contains(tip) ? AppColors.textMuted : AppColors.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSpace.m),
            PrimaryButton(
              label: 'Start breathing exercise',
              icon: Icons.air_rounded,
              onPressed: () => showBreathingSheet(context),
            ),
            const SizedBox(height: AppSpace.m),
            Text(
              'NeuroTrace gives wellness suggestions, not a medical diagnosis. '
              'See a doctor for severe, sudden or unusual headaches.',
              textAlign: TextAlign.center,
              style: AppText.muted,
            ),
          ],
        ),
      ),
    );
  }

  /// Simple contribution scores (0..1) from current readings vs calm baseline.
  List<(String, double, IconData)> _factors(SensorReading r) {
    double c(double v) => v.clamp(0.0, 1.0);
    final list = [
      ('Raised heart rate', c((r.heartRate - 70) / 30), Icons.favorite_rounded),
      ('Skin conductance (stress)', c((r.gsr - 2.5) / 7), Icons.bolt_rounded),
      ('Noise level', c((r.sound - 40) / 35), Icons.graphic_eq_rounded),
      ('Bright light', c((r.light - 250) / 700), Icons.light_mode_rounded),
      ('Heat', c((r.ambientTemp - 26) / 12), Icons.wb_sunny_rounded),
      ('Low movement', c((0.15 - r.motion) / 0.15), Icons.directions_walk_rounded),
    ];
    list.sort((a, b) => b.$2.compareTo(a.$2));
    return list;
  }
}
