import 'dart:math';

import '../models/headache_type.dart';
import '../models/sensor_reading.dart';

/// Generates realistic fake readings, cycling through headache scenarios so
/// the demo shows risk rising, a predicted type, and returning to normal.
///
/// It also fills `deviceRisk` / `deviceType`, standing in for the output of
/// the TFLite Micro model on the ESP32. Swap this class for a BLE source later.
class SensorSimulator {
  final _rnd = Random();
  int _tick = 0;
  int _cycleIndex = 0;
  double _risk = 0.15;

  static const _cycle = [
    HeadacheType.normal,
    HeadacheType.stress,
    HeadacheType.normal,
    HeadacheType.tension,
    HeadacheType.normal,
    HeadacheType.sleepDeprivation,
    HeadacheType.caffeineWithdrawal,
  ];

  // Baseline (calm) values.
  static const _base = {
    'hr': 74.0, 'spo2': 97.5, 'bt': 36.6, 'gsr': 3.0, 'mot': 0.12,
    'at': 31.0, 'hum': 62.0, 'pres': 1009.0, 'lux': 320.0, 'db': 45.0,
  };

  // How each scenario pushes values at full risk.
  static const _scenario = {
    HeadacheType.stress: {'hr': 96.0, 'gsr': 8.0, 'db': 64.0, 'bt': 36.9},
    HeadacheType.tension: {'hr': 82.0, 'gsr': 4.8, 'mot': 0.02, 'lux': 520.0},
    HeadacheType.sleepDeprivation: {'hr': 69.0, 'bt': 36.3, 'lux': 700.0, 'mot': 0.05},
    HeadacheType.caffeineWithdrawal: {'hr': 66.0, 'gsr': 3.8, 'spo2': 97.0},
  };

  HeadacheType get _current => _cycle[_cycleIndex];

  double _noise(double s) => (_rnd.nextDouble() * 2 - 1) * s;

  SensorReading next() {
    _tick++;
    if (_tick % 40 == 0) _cycleIndex = (_cycleIndex + 1) % _cycle.length;

    final target = _current == HeadacheType.normal ? 0.14 : 0.74;
    _risk = (_risk + (target - _risk) * 0.07 + _noise(0.008)).clamp(0.03, 0.97);

    final k = ((_risk - 0.14) / 0.6).clamp(0.0, 1.0);
    final push = _scenario[_current] ?? const {};
    double v(String key, double noise) {
      final b = _base[key]!;
      final s = push[key] ?? b;
      return b + (s - b) * k + _noise(noise);
    }

    final type = _risk >= 0.35 ? _current : HeadacheType.normal;

    return SensorReading(
      time: DateTime.now(),
      heartRate: v('hr', 1.5),
      spo2: v('spo2', 0.3).clamp(90, 100).toDouble(),
      bodyTemp: v('bt', 0.03),
      gsr: v('gsr', 0.15).clamp(0.5, 20).toDouble(),
      motion: v('mot', 0.02).clamp(0, 2).toDouble(),
      ambientTemp: v('at', 0.1),
      humidity: v('hum', 0.6),
      pressure: v('pres', 0.2),
      light: v('lux', 12).clamp(0, 5000).toDouble(),
      sound: v('db', 1.5),
      deviceRisk: _risk,
      deviceType: type,
    );
  }
}
