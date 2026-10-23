import 'headache_type.dart';

/// A headache episode the user logged.
class Episode {
  final DateTime start;
  final HeadacheType type;
  final int severity; // 1..10
  final int durationMin;
  final List<String> triggers;
  final bool tookMedication;
  final String notes;

  const Episode({
    required this.start,
    required this.type,
    required this.severity,
    required this.durationMin,
    this.triggers = const [],
    this.tookMedication = false,
    this.notes = '',
  });
}
