import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/episode.dart';
import '../models/headache_type.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

class LogHeadacheScreen extends StatefulWidget {
  const LogHeadacheScreen({super.key});

  @override
  State<LogHeadacheScreen> createState() => _LogHeadacheScreenState();
}

class _LogHeadacheScreenState extends State<LogHeadacheScreen> {
  DateTime _start = DateTime.now();
  double _severity = 5;
  double _duration = 45;
  HeadacheType? _type;
  final Set<String> _triggers = {};
  bool _medication = false;
  final _notes = TextEditingController();

  static const _allTriggers = [
    'Poor sleep', 'Stress', 'Screen time', 'Skipped meal', 'Caffeine',
    'Heat', 'Dehydration', 'Noise', 'Bright light', 'Long sitting',
  ];

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Color get _severityColor => AppColors.risk(_severity / 10);

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_start));
    if (t != null && mounted) {
      setState(() => _start = DateTime(_start.year, _start.month, _start.day, t.hour, t.minute));
    }
  }

  void _save() {
    if (_type == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please choose a headache type')));
      return;
    }
    context.read<AppState>().addEpisode(Episode(
          start: _start,
          type: _type!,
          severity: _severity.round(),
          durationMin: _duration.round(),
          triggers: _triggers.toList(),
          tookMedication: _medication,
          notes: _notes.text.trim(),
        ));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Headache logged. Thanks for tracking!')));
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Log headache'),
          leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.s, AppSpace.screen, AppSpace.xl),
          children: [
            // When
            SoftCard(
              onTap: _pickTime,
              child: Row(
                children: [
                  const IconTile(icon: Icons.schedule_rounded, color: AppColors.teal),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Started at', style: AppText.muted),
                        Text('${formatDay(_start)}, ${formatTime(_start)}',
                            style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit_rounded, color: AppColors.textMuted, size: 18),
                ],
              ),
            ),

            // Severity
            const SectionHeader('How bad is it?'),
            SoftCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Severity', style: AppText.label),
                      const Spacer(),
                      Text('${_severity.round()}/10',
                          style: AppText.section.copyWith(color: _severityColor)),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(activeTrackColor: _severityColor, thumbColor: _severityColor),
                    child: Slider(
                      value: _severity, min: 1, max: 10, divisions: 9,
                      onChanged: (v) => setState(() => _severity = v),
                    ),
                  ),
                  Row(
                    children: [
                      Text('Mild', style: AppText.muted),
                      const Spacer(),
                      Text('Severe', style: AppText.muted),
                    ],
                  ),
                  const Divider(height: 28, color: AppColors.mint),
                  Row(
                    children: [
                      Text('Duration', style: AppText.label),
                      const Spacer(),
                      Text(formatDuration(_duration.round()), style: AppText.section),
                    ],
                  ),
                  Slider(
                    value: _duration, min: 10, max: 240, divisions: 23,
                    onChanged: (v) => setState(() => _duration = v),
                  ),
                ],
              ),
            ),

            // Type
            const SectionHeader('What type does it feel like?'),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.0,
              children: [
                for (final t in HeadacheType.loggable)
                  _TypeOption(type: t, selected: _type == t, onTap: () => setState(() => _type = t)),
              ],
            ),

            // Triggers
            const SectionHeader('Possible triggers'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tr in _allTriggers)
                  PillChip(
                    label: tr,
                    selected: _triggers.contains(tr),
                    onTap: () => setState(() => _triggers.contains(tr) ? _triggers.remove(tr) : _triggers.add(tr)),
                  ),
              ],
            ),

            // Medication + notes
            const SizedBox(height: AppSpace.l),
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const IconTile(icon: Icons.medication_rounded, color: AppColors.peach, size: 36),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Took medication', style: AppText.body)),
                  Switch(value: _medication, onChanged: (v) => setState(() => _medication = v)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _notes,
                maxLines: 3,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Notes (optional)',
                  hintStyle: AppText.muted.copyWith(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: AppSpace.l),
            PrimaryButton(label: 'Save episode', icon: Icons.check_rounded, onPressed: _save),
          ],
        ),
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({required this.type, required this.selected, required this.onTap});
  final HeadacheType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? type.color.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? type.color : Colors.transparent, width: 2),
          boxShadow: [BoxShadow(color: AppColors.tealDark.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(type.icon, color: type.color, size: 28),
            const SizedBox(height: 6),
            Text(type.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: AppText.muted.copyWith(color: AppColors.text, fontWeight: FontWeight.w500, fontSize: 11.5)),
          ],
        ),
      ),
    );
  }
}
