import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'connect_device_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;

  static const _slides = [
    (Icons.monitor_heart_rounded, 'Track', 'Your wearable quietly tracks heart rate, stress, sleep and your surroundings.'),
    (Icons.psychology_rounded, 'Predict', 'On-device AI spots headache risk early and tells you the likely type.'),
    (Icons.spa_rounded, 'Prevent', 'Get simple, personal steps to stop a headache before it starts.'),
  ];

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _slides.length - 1) {
      _page.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const ConnectDeviceScreen(firstRun: true)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.screen),
            child: Column(
              children: [
                Row(
                  children: [
                    const IconTile(icon: Icons.monitor_heart_rounded, color: AppColors.teal, size: 40),
                    const SizedBox(width: 10),
                    Text('NeuroTrace', style: AppText.section),
                  ],
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _page,
                    itemCount: _slides.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) {
                      final sl = _slides[i];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppColors.mint, AppColors.peachLight],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [BoxShadow(color: AppColors.teal.withOpacity(0.15), blurRadius: 40, offset: const Offset(0, 16))],
                            ),
                            child: Icon(sl.$1, size: 96, color: AppColors.teal),
                          ),
                          const SizedBox(height: 40),
                          Text(sl.$2, style: AppText.bigNumber()),
                          const SizedBox(height: 12),
                          Text(sl.$3,
                              textAlign: TextAlign.center,
                              style: AppText.body.copyWith(color: AppColors.textMuted, fontSize: 15)),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _slides.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _index ? AppColors.teal : AppColors.mint,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpace.l),
                PrimaryButton(
                  label: _index == _slides.length - 1 ? 'Get Started' : 'Next',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _next,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
