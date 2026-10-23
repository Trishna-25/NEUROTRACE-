import 'headache_type.dart';

/// One packet from the wearable (or the simulator).
///
/// BLE wire format (JSON, one object per notification):
/// {"hr":78,"spo2":97,"bt":36.6,"gsr":4.2,"mot":0.12,
///  "at":33.5,"hum":68,"pres":1008.2,"lux":420,"db":52,
///  "risk":0.31,"type":0}
///
/// `risk` (0..1) and `type` (0..6) come from the TFLite Micro model on the
/// ESP32. They are optional: if missing, the app falls back to its own
/// rule-based estimate (see RiskEngine).
class SensorReading {
  final DateTime time;
  final double heartRate; // bpm
  final double spo2; // %
  final double bodyTemp; // °C
  final double gsr; // skin conductance, µS
  final double motion; // activity magnitude, g
  final double ambientTemp; // °C
  final double humidity; // %
  final double pressure; // hPa
  final double light; // lux
  final double sound; // dB
  final double? deviceRisk; // 0..1 from on-device model
  final HeadacheType? deviceType; // from on-device model

  const SensorReading({
    required this.time,
    required this.heartRate,
    required this.spo2,
    required this.bodyTemp,
    required this.gsr,
    required this.motion,
    required this.ambientTemp,
    required this.humidity,
    required this.pressure,
    required this.light,
    required this.sound,
    this.deviceRisk,
    this.deviceType,
  });

  factory SensorReading.fromJson(Map<String, dynamic> j) {
    double d(String k, [double def = 0]) => (j[k] as num?)?.toDouble() ?? def;
    return SensorReading(
      time: DateTime.now(),
      heartRate: d('hr'),
      spo2: d('spo2'),
      bodyTemp: d('bt'),
      gsr: d('gsr'),
      motion: d('mot'),
      ambientTemp: d('at'),
      humidity: d('hum'),
      pressure: d('pres', 1013),
      light: d('lux'),
      sound: d('db'),
      deviceRisk: (j['risk'] as num?)?.toDouble(),
      deviceType:
          j['type'] == null ? null : HeadacheType.fromLabel((j['type'] as num).toInt()),
    );
  }
}
