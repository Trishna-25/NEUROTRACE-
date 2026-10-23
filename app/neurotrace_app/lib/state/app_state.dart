import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/firestore_service.dart';
import '../data/sensor_simulator.dart';
import '../models/episode.dart';
import '../models/headache_type.dart';
import '../models/sensor_reading.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _seedEpisodes();
    for (var i = 0; i < 60; i++) {
      history.add(_sim.next());
    }
  }

  final SensorSimulator _sim = SensorSimulator();
  Timer? _timer;
  int _saveTickCount = 0;
    // Alerts
  String? pendingAlert; // message to show; null = no alert
  DateTime? _lastRiskAlert;
  static const double alertThreshold = 0.6;

  void clearAlert() => pendingAlert = null;
  static const int maxHistory = 180;
  final List<SensorReading> history = [];

  // Device
  bool connected = false;
  bool simulated = true;
  String deviceName = 'NeuroTrace-01';
  int battery = 82;

  // User
  String userName = 'Alex';
  final List<String> emergencyContacts = ['Amma  •  +919876500001', 'Friend  •  +919876500002'];

  // Episodes & guidance
  final List<Episode> episodes = [];
  final Set<String> doneTips = {};

  SensorReading? get current => history.isEmpty ? null : history.last;
  double get risk => current?.deviceRisk ?? 0;
  HeadacheType get type => current?.deviceType ?? HeadacheType.normal;

  List<double> series(double Function(SensorReading r) pick) =>
      history.map(pick).toList();

  void start() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!connected) return;
    final reading = _sim.next();
    history.add(reading);
    if (history.length > maxHistory) history.removeAt(0);
        // High-risk alert (at most once every 10 minutes)
    final r = reading.deviceRisk ?? 0;
    if (r >= alertThreshold &&
        (_lastRiskAlert == null ||
            DateTime.now().difference(_lastRiskAlert!).inMinutes >= 10)) {
      _lastRiskAlert = DateTime.now();
      pendingAlert =
          'High headache risk detected (${(r * 100).round()}%). Likely type: ${reading.deviceType?.title ?? 'Unknown'}.';
    }
    if (DateTime.now().second == 0 && battery > 5) battery--;

    // Save to Firestore once every minute (every 60 ticks)
    _saveTickCount++;
    if (_saveTickCount % 60 == 0) {
      saveReading(
        [
          reading.heartRate,
          reading.spo2,
          reading.gsr,
          reading.bodyTemp,
          reading.ambientTemp,
          reading.humidity,
          reading.pressure,
          reading.motion,
        ],
        reading.deviceType?.title ?? 'Normal',
        0.85,
        reading.deviceRisk ?? 0.0,
      );
    }

    notifyListeners();
  }

  void connect() {
    connected = true;
    notifyListeners();
  }

  void disconnect() {
    connected = false;
    notifyListeners();
  }

  void setSimulated(bool value) {
    simulated = value;
    notifyListeners();
  }

  void toggleTip(String tip) {
    doneTips.contains(tip) ? doneTips.remove(tip) : doneTips.add(tip);
    notifyListeners();
  }

  void addEpisode(Episode e) {
    episodes.insert(0, e);
    if (e.severity >= 8) {
      pendingAlert =
          'Severe headache logged (${e.severity}/10). Consider alerting your emergency contact.';
    }
    // Also save to Firestore
    saveHeadacheLog(
      e.severity,
      7.0,
      6,
      e.triggers.contains('Stress') ? 8 : 4,
      type: e.type.title,
      notes: e.notes,
    );
    notifyListeners();
  }

  /// Episode counts for the last 7 days, oldest first.
  List<int> get weeklyEpisodeCounts {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final day = DateTime(today.year, today.month, today.day).subtract(Duration(days: 6 - i));
      return episodes
          .where((e) =>
              e.start.year == day.year && e.start.month == day.month && e.start.day == day.day)
          .length;
    });
  }

  /// Fraction of recorded readings at high risk.
  double get highRiskShare {
    if (history.isEmpty) return 0;
    return history.where((r) => (r.deviceRisk ?? 0) >= 0.6).length / history.length;
  }

  HeadacheType? get mostCommonType {
    if (episodes.isEmpty) return null;
    final counts = <HeadacheType, int>{};
    for (final e in episodes) {
      counts[e.type] = (counts[e.type] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  void _seedEpisodes() {
    final now = DateTime.now();
    DateTime at(int daysAgo, int hour) =>
        DateTime(now.year, now.month, now.day, hour).subtract(Duration(days: daysAgo));
    episodes.addAll([
      Episode(start: at(0, 11), type: HeadacheType.stress, severity: 5, durationMin: 45,
          triggers: ['Stress', 'Screen time']),
      Episode(start: at(1, 16), type: HeadacheType.tension, severity: 4, durationMin: 60,
          triggers: ['Long sitting']),
      Episode(start: at(3, 9), type: HeadacheType.sleepDeprivation, severity: 6, durationMin: 90,
          triggers: ['Poor sleep'], tookMedication: true),
      Episode(start: at(3, 18), type: HeadacheType.stress, severity: 3, durationMin: 30,
          triggers: ['Stress']),
      Episode(start: at(5, 14), type: HeadacheType.caffeineWithdrawal, severity: 4, durationMin: 50,
          triggers: ['Skipped coffee']),
      Episode(start: at(8, 15), type: HeadacheType.stress, severity: 7, durationMin: 120,
          triggers: ['Stress', 'Heat'], tookMedication: true),
    ]);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}