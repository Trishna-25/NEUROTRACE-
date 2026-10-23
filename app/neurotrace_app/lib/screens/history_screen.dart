import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../models/episode.dart';
import '../models/headache_type.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
   import 'package:firebase_auth/firebase_auth.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HeadacheType? _filter;

  // Firestore queries are created once (not every second on rebuild)
  late final Future<QuerySnapshot> _readingsFuture;
  late final Stream<QuerySnapshot> _logsStream;

  @override
  void initState() {
     super.initState();
     final userDoc = FirebaseFirestore.instance
         .collection('users')
         .doc(FirebaseAuth.instance.currentUser!.uid);

     _readingsFuture = userDoc
         .collection('readings')
         .where('time',
             isGreaterThan: Timestamp.fromDate(
                 DateTime.now().subtract(const Duration(hours: 24))))
         .orderBy('time')
         .get();
     _logsStream = userDoc
         .collection('headache_logs')
         .orderBy('time', descending: true)
         .limit(20)
         .snapshots();
   }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = _filter == null ? s.episodes : s.episodes.where((e) => e.type == _filter).toList();
    final common = s.mostCommonType;
    final avgSeverity = s.episodes.isEmpty
        ? 0.0
        : s.episodes.map((e) => e.severity).reduce((a, b) => a + b) / s.episodes.length;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.screen, AppSpace.m, AppSpace.screen, 120),
        children: [
          Text('Episode history', style: AppText.title),
          Text('${s.episodes.length} episodes logged', style: AppText.muted),
          const SizedBox(height: AppSpace.m),

          // Pattern summary
          SoftCard(
            color: AppColors.mint,
            child: Row(
              children: [
                const IconTile(icon: Icons.auto_graph_rounded, color: AppColors.tealDark, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your pattern', style: AppText.label.copyWith(color: AppColors.tealDark)),
                      const SizedBox(height: 2),
                      Text(
                        common == null
                            ? 'Log a few episodes to see patterns'
                            : 'Mostly ${common.title.toLowerCase()} headaches, average severity ${avgSeverity.toStringAsFixed(1)}/10',
                        style: AppText.body.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.m),

          // 24-hour heart rate chart (from Firestore)
          Text('Heart rate – last 24 hours', style: AppText.section),
          const SizedBox(height: 8),
          SoftCard(child: _cloudChart()),
          const SizedBox(height: AppSpace.m),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                PillChip(label: 'All', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                for (final t in HeadacheType.loggable)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: PillChip(
                      label: t.title,
                      icon: t.icon,
                      color: t.color,
                      selected: _filter == t,
                      onTap: () => setState(() => _filter = t),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.m),

          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                children: [
                  const IconTile(icon: Icons.inbox_rounded, color: AppColors.textMuted, size: 64),
                  const SizedBox(height: 12),
                  Text('No episodes here yet', style: AppText.section),
                  Text('Tap + to log a headache', style: AppText.muted),
                ],
              ),
            ),
          for (final e in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _EpisodeCard(e, onTap: () => _showDetail(context, e)),
            ),

          // Live cloud logs (from Firestore)
          const SizedBox(height: AppSpace.m),
          Text('Cloud logs (live)', style: AppText.section),
          const SizedBox(height: 8),
          _cloudLogs(),
        ],
      ),
    );
  }

  Widget _cloudChart() {
    return FutureBuilder<QuerySnapshot>(
      future: _readingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Text('Could not load readings: ${snapshot.error}', style: AppText.muted);
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Text('Waiting for 24h readings to populate...', style: AppText.muted);
        }
        final spots = <FlSpot>[];
        for (int i = 0; i < docs.length; i++) {
          final d = docs[i].data() as Map<String, dynamic>;
          final hr = (d['hr'] as num?)?.toDouble() ?? 70.0;
          spots.add(FlSpot(i.toDouble(), hr));
        }
        return SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.tealDark,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _cloudLogs() {
    return StreamBuilder<QuerySnapshot>(
      stream: _logsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Could not load logs: ${snapshot.error}', style: AppText.muted);
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Text('No cloud logs yet. Tap + to add one!', style: AppText.muted);
        }
        return Column(
          children: [
            for (final doc in docs)
              Builder(builder: (context) {
                final data = doc.data() as Map<String, dynamic>;
                final ts = data['time'] as Timestamp?;
                final dateStr = ts != null
                    ? DateFormat('dd MMM, hh:mm a').format(ts.toDate())
                    : 'Just now';
                final intensity = data['intensity'] ?? 0;
                final type = data['type'] ?? 'Headache';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SoftCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const IconTile(icon: Icons.cloud_done_rounded, color: AppColors.tealDark, size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$type', style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
                              Text(dateStr, style: AppText.muted),
                            ],
                          ),
                        ),
                        Text('$intensity/10', style: AppText.label),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  void _showDetail(BuildContext context, Episode e) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(4))),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                IconTile(icon: e.type.icon, color: e.type.color, size: 52),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.type.title, style: AppText.title.copyWith(fontSize: 20)),
                    Text('${formatDate(e.start)}, ${formatTime(e.start)}', style: AppText.muted),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _row('Severity', '${e.severity}/10'),
            _row('Duration', formatDuration(e.durationMin)),
            _row('Medication', e.tookMedication ? 'Yes' : 'No'),
            _row('Triggers', e.triggers.isEmpty ? '—' : e.triggers.join(', ')),
            if (e.notes.isNotEmpty) _row('Notes', e.notes),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 100, child: Text(k, style: AppText.label)),
            Expanded(child: Text(v, style: AppText.body.copyWith(fontWeight: FontWeight.w500))),
          ],
        ),
      );
}

class _EpisodeCard extends StatelessWidget {
  const _EpisodeCard(this.e, {required this.onTap});
  final Episode e;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sevColor = AppColors.risk(e.severity / 10);
    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          IconTile(icon: e.type.icon, color: e.type.color, size: 46),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.type.title, style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${formatDay(e.start)} • ${formatTime(e.start)} • ${formatDuration(e.durationMin)}',
                    style: AppText.muted),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: sevColor.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: Text('${e.severity}/10',
                style: AppText.muted.copyWith(color: sevColor, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}