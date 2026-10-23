import 'package:flutter/material.dart';

import '../widgets/bottom_nav.dart';
import '../widgets/common.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'log_headache_screen.dart';
import 'profile_screen.dart';
import 'trends_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = [
    DashboardScreen(),
    TrendsScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: IndexedStack(index: _index, children: _pages),
        bottomNavigationBar: NeuroBottomNav(
          index: _index,
          onTap: (i) => setState(() => _index = i),
          onAdd: () => Navigator.push(
            context,
            MaterialPageRoute(fullscreenDialog: true, builder: (_) => const LogHeadacheScreen()),
          ),
        ),
      ),
    );
  }
}
