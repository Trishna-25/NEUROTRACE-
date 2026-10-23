import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

void showBreathingSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => const _BreathingSheet(),
  );
}

/// Guided breathing: 4 s in, 6 s out.
class _BreathingSheet extends StatefulWidget {
  const _BreathingSheet();

  @override
  State<_BreathingSheet> createState() => _BreathingSheetState();
}

class _BreathingSheetState extends State<_BreathingSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
    reverseDuration: const Duration(seconds: 6),
  );
  bool _inhale = true;

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() => _inhale = false);
        _c.reverse();
      } else if (s == AnimationStatus.dismissed) {
        setState(() => _inhale = true);
        _c.forward();
      }
    });
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 20),
          Text('Breathing exercise', style: AppText.title),
          const SizedBox(height: 4),
          Text('Follow the circle for 2 minutes', style: AppText.muted),
          const SizedBox(height: 28),
          SizedBox(
            height: 220,
            child: Center(
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, __) {
                  final size = 110 + 100 * Curves.easeInOut.transform(_c.value);
                  return Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [AppColors.teal.withOpacity(0.35), AppColors.mint]),
                      border: Border.all(color: AppColors.teal.withOpacity(0.4), width: 2),
                    ),
                    child: Center(
                      child: Text(_inhale ? 'Breathe in' : 'Breathe out',
                          style: AppText.section.copyWith(color: AppColors.tealDark)),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(label: 'Done', onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
