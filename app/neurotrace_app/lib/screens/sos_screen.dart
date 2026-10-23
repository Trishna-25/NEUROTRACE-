import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Emergency SOS')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.m, AppSpace.screen, AppSpace.xl),
          children: [
            Center(
              child: GestureDetector(
                onLongPress: () => _confirm(context),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(colors: [Color(0xFFF26B62), AppColors.high]),
                    border: Border.all(color: AppColors.high.withOpacity(0.15), width: 18),
                    boxShadow: [BoxShadow(color: AppColors.high.withOpacity(0.35), blurRadius: 30, offset: const Offset(0, 12))],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.sos_rounded, color: Colors.white, size: 54),
                      Text('Hold to send', style: AppText.label.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpace.l),
            SoftCard(
              color: AppColors.mint,
              child: Row(
                children: [
                  const IconTile(icon: Icons.watch_rounded, color: AppColors.tealDark),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'SOS also works directly from the wearable by SMS and call, even without this app or internet.',
                      style: AppText.label.copyWith(color: AppColors.text),
                    ),
                  ),
                ],
              ),
            ),
            const SectionHeader('Emergency contacts', action: 'Edit'),
            for (final c in s.emergencyContacts)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SoftCard(
                  child: Row(
                    children: [
                      const IconTile(icon: Icons.person_rounded, color: AppColors.peach),
                      const SizedBox(width: 12),
                      Expanded(child: Text(c, style: AppText.body)),
                      const IconTile(icon: Icons.call_rounded, color: AppColors.low, size: 36),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Send SOS alert?'),
        content: const Text('Your emergency contacts will get an SMS with your location.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.high),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('SOS alert sent to emergency contacts (demo)')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
