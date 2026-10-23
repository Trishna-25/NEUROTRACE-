import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'home_shell.dart';

/// Scan & connect. Currently simulates a scan; replace with flutter_blue_plus
/// scanning when the ESP32 BLE firmware is ready.
class ConnectDeviceScreen extends StatefulWidget {
  const ConnectDeviceScreen({super.key, this.firstRun = false});
  final bool firstRun;

  @override
  State<ConnectDeviceScreen> createState() => _ConnectDeviceScreenState();
}

class _ConnectDeviceScreenState extends State<ConnectDeviceScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  bool _scanning = false;
  bool _found = false;

  @override
  void initState() {
    super.initState();
    _scan();
  }

  Future<void> _scan() async {
    setState(() {
      _scanning = true;
      _found = false;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _scanning = false;
      _found = true;
    });
  }

  void _connect() {
    context.read<AppState>().connect();
    if (widget.firstRun) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeShell()));
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Connect wearable')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.m, AppSpace.screen, AppSpace.xl),
          children: [
            // Radar
            SizedBox(
              height: 230,
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, __) => Stack(
                    alignment: Alignment.center,
                    children: [
                      for (var i = 0; i < 3; i++)
                        _ring(((_pulse.value + i / 3) % 1.0)),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [BoxShadow(color: AppColors.teal.withOpacity(0.25), blurRadius: 20)],
                        ),
                        child: const Icon(Icons.watch_rounded, color: AppColors.teal, size: 42),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(child: Text(_scanning ? 'Searching for NeuroTrace…' : 'Devices nearby', style: AppText.section)),
            Center(child: Text('Keep the wearable close to your phone', style: AppText.muted)),
            const SizedBox(height: AppSpace.l),

            if (_found)
              SoftCard(
                child: Row(
                  children: [
                    const IconTile(icon: Icons.bluetooth_rounded, color: AppColors.teal, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.deviceName, style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
                          Text('Signal strong • ESP32-C3', style: AppText.muted),
                        ],
                      ),
                    ),
                    s.connected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.low)
                        : FilledButton(
                            onPressed: _connect,
                            style: FilledButton.styleFrom(backgroundColor: AppColors.teal, shape: const StadiumBorder()),
                            child: const Text('Connect'),
                          ),
                  ],
                ),
              ),

            const SizedBox(height: 12),
            SoftCard(
              child: Row(
                children: [
                  const IconTile(icon: Icons.science_rounded, color: AppColors.peach, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Simulated data', style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
                        Text('Use generated readings for testing', style: AppText.muted),
                      ],
                    ),
                  ),
                  Switch(value: s.simulated, onChanged: s.setSimulated),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.l),
            if (!_scanning)
              OutlinedButton.icon(
                onPressed: _scan,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Scan again'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.teal,
                  side: const BorderSide(color: AppColors.teal),
                  shape: const StadiumBorder(),
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            if (s.connected && !widget.firstRun) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.read<AppState>().disconnect(),
                child: Text('Disconnect', style: AppText.label.copyWith(color: AppColors.high)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _ring(double t) {
    final size = 90 + 130 * t;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.teal.withOpacity((1 - t) * 0.5), width: 2),
      ),
    );
  }
}
