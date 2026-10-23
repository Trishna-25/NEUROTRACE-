import 'package:flutter/material.dart';

import '../models/headache_type.dart';
import '../theme/app_theme.dart';

/// Soft gradient background used behind every screen.
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgTop, Color(0xFFF8FBFA), AppColors.bgBottom],
        ),
      ),
      child: child,
    );
  }
}

/// White rounded card with a very soft shadow.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpace.m),
    this.onTap,
    this.color = Colors.white,
    this.radius = AppSpace.radius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.tealDark.withOpacity(0.07),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: color.withOpacity(color == Colors.white ? 0.92 : 1),
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Rounded tinted square holding an icon.
class IconTile extends StatelessWidget {
  const IconTile({super.key, required this.icon, required this.color, this.size = 40});
  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(icon, color: color, size: size * 0.52),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.l, bottom: AppSpace.s + 4),
      child: Row(
        children: [
          Text(title, style: AppText.section),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!,
                  style: AppText.label.copyWith(color: AppColors.teal, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}

/// Full-width teal pill button.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.onPressed, this.icon, this.color = AppColors.teal});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 18, offset: const Offset(0, 8)),
          ],
        ),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: color,
            shape: const StadiumBorder(),
            textStyle: AppText.body.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label),
              if (icon != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                  child: Icon(icon, size: 18),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Selectable pill chip.
class PillChip extends StatelessWidget {
  const PillChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.color = AppColors.teal,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: selected ? color : AppColors.mint, width: 1.4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: selected ? Colors.white : color),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: AppText.label.copyWith(
                    color: selected ? Colors.white : AppColors.text, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

/// Segmented pill tabs (Overview / Heart / ...).
class PillTabs extends StatelessWidget {
  const PillTabs({super.key, required this.tabs, required this.selected, required this.onChanged});
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: PillChip(label: tabs[i], selected: i == selected, onTap: () => onChanged(i)),
            ),
        ],
      ),
    );
  }
}

/// Small coloured badge showing the headache type.
class TypeBadge extends StatelessWidget {
  const TypeBadge(this.type, {super.key});
  final HeadacheType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: type.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(type.icon, size: 15, color: type.color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(type.title,
                overflow: TextOverflow.ellipsis,
                style: AppText.muted.copyWith(color: type.color, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

/// Connected / disconnected / simulated status chip.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.connected, required this.simulated});
  final bool connected;
  final bool simulated;

  @override
  Widget build(BuildContext context) {
    final color = connected ? AppColors.low : AppColors.textMuted;
    final text = !connected ? 'Disconnected' : (simulated ? 'Simulated' : 'Connected');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(text, style: AppText.muted.copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
