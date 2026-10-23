import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/app_state.dart';

/// Global navigator key so we can show dialogs from anywhere.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class RiskAlertWatcher extends StatefulWidget {
  const RiskAlertWatcher({super.key, required this.child});
  final Widget child;

  @override
  State<RiskAlertWatcher> createState() => _RiskAlertWatcherState();
}

class _RiskAlertWatcherState extends State<RiskAlertWatcher> {
  late final AppState _state;
  bool _showing = false;

  @override
  void initState() {
    super.initState();
    _state = context.read<AppState>();
    _state.addListener(_check);
  }

  @override
  void dispose() {
    _state.removeListener(_check);
    super.dispose();
  }

  void _check() {
    final msg = _state.pendingAlert;
    if (msg == null || _showing) return;
    _state.clearAlert();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showAlert(msg));
  }

  void _showAlert(String msg) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    _showing = true;
    showDialog(
      context: ctx,
      builder: (dctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
        title: const Text('Health Alert'),
        content: Text(
          '$msg\n\nSuggested: drink water, rest in a cool, quiet place, and take a break from screens.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx),
            child: const Text('Dismiss'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            icon: const Icon(Icons.sos_rounded),
            label: const Text('Send SOS'),
            onPressed: () {
              Navigator.pop(dctx);
              _sendSos(msg);
            },
          ),
        ],
      ),
    ).then((_) => _showing = false);
  }

  Future<void> _sendSos(String reason) async {
    final numbers = _state.emergencyContacts
        .map((c) => c.split('•').last.replaceAll(' ', ''))
        .join(',');
    final body = 'NeuroTrace SOS: ${_state.userName} may need help. $reason';
    final uri = Uri.parse('sms:$numbers?body=${Uri.encodeComponent(body)}');
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}