import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'connect_device_screen.dart';
import 'sos_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.m, AppSpace.screen, 120),
        children: [
          Text('Profile', style: AppText.title),
          const SizedBox(height: AppSpace.m),
          SoftCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.mint,
                  child: Text(s.userName[0], style: AppText.title.copyWith(color: AppColors.teal)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.userName, style: AppText.section),
                      Text('${s.episodes.length} episodes tracked', style: AppText.muted),
                    ],
                  ),
                ),
                const IconTile(icon: Icons.edit_rounded, color: AppColors.teal, size: 36),
              ],
            ),
          ),

          const SectionHeader('My device'),
          SoftCard(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConnectDeviceScreen())),
            child: Column(
              children: [
                Row(
                  children: [
                    const IconTile(icon: Icons.watch_rounded, color: AppColors.teal, size: 46),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.deviceName, style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          StatusChip(connected: s.connected, simulated: s.simulated),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Icon(Icons.battery_5_bar_rounded,
                            color: s.battery > 20 ? AppColors.low : AppColors.high),
                        Text('${s.battery}%', style: AppText.muted),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24, color: AppColors.mint),
                Row(
                  children: [
                    Expanded(child: Text('Use simulated data', style: AppText.body)),
                    Switch(value: s.simulated, onChanged: s.setSimulated),
                  ],
                ),
              ],
            ),
          ),

          const SectionHeader('Settings'),
          SoftCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                _item(context, Icons.sos_rounded, 'Emergency SOS', AppColors.high,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SosScreen()))),
                _item(context, Icons.notifications_rounded, 'Alerts & reminders', AppColors.medium, null),
                _item(context, Icons.straighten_rounded, 'Units (°C)', const Color(0xFF3B7DD8), null),
                _item(context, Icons.lock_rounded, 'Privacy & data', AppColors.teal, null),
                _item(context, Icons.download_rounded, 'Export data (CSV)', const Color(0xFF6B5BD2), null),
                _item(context, Icons.info_rounded, 'About NeuroTrace', AppColors.textMuted, () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'NeuroTrace',
                    applicationVersion: '0.1.0',
                    children: const [Text('Team Novatriz • Smart India Hackathon 2026')],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String label, Color color, VoidCallback? onTap) {
    return ListTile(
      onTap: onTap ??
          () => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('$label — coming soon'))),
      leading: IconTile(icon: icon, color: color, size: 36),
      title: Text(label, style: AppText.body),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
    );
  }
}
