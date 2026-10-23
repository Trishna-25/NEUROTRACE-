import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Bottom navigation with a raised centre "+" button.
class NeuroBottomNav extends StatelessWidget {
  const NeuroBottomNav({super.key, required this.index, required this.onTap, required this.onAdd});
  final int index;
  final ValueChanged<int> onTap;
  final VoidCallback onAdd;

  static const _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.insights_rounded, 'Trends'),
    (Icons.history_rounded, 'History'),
    (Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return SizedBox(
      height: 76 + bottom + 22,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 76 + bottom,
            padding: EdgeInsets.only(bottom: bottom),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
              boxShadow: [
                BoxShadow(color: AppColors.tealDark.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, -6)),
              ],
            ),
            child: Row(
              children: [
                _item(0),
                _item(1),
                const SizedBox(width: 72),
                _item(2),
                _item(3),
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2BB8AC), AppColors.tealDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(color: AppColors.teal.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
                  ],
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(int i) {
    final selected = i == index;
    final color = selected ? AppColors.teal : AppColors.textMuted;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_items[i].$1, color: color, size: 24),
            const SizedBox(height: 3),
            Text(_items[i].$2,
                style: AppText.muted.copyWith(
                    color: color, fontSize: 11, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}
