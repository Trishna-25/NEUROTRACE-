import 'package:flutter/material.dart';

/// Label key shared with the ML model / firmware.
/// 0 Normal, 1 Tension, 2 Stress, 3 Sleep-deprivation,
/// 4 Caffeine-withdrawal, 5 Hormonal, 6 Cluster
enum HeadacheType {
  normal(0, 'Normal', Icons.check_circle_outline, Color(0xFF2E9E6B)),
  tension(1, 'Tension', Icons.compress, Color(0xFF3B7DD8)),
  stress(2, 'Stress', Icons.psychology, Color(0xFFE08A1E)),
  sleepDeprivation(3, 'Sleep deprivation', Icons.bedtime, Color(0xFF6B5BD2)),
  caffeineWithdrawal(4, 'Caffeine withdrawal', Icons.coffee, Color(0xFF8A5A3C)),
  hormonal(5, 'Hormonal', Icons.loop, Color(0xFFC2457A)),
  cluster(6, 'Cluster', Icons.flare, Color(0xFFD23F3F));

  const HeadacheType(this.label, this.title, this.icon, this.color);

  final int label;
  final String title;
  final IconData icon;
  final Color color;

  static HeadacheType fromLabel(int label) => HeadacheType.values
      .firstWhere((t) => t.label == label, orElse: () => HeadacheType.normal);

  /// Types a user can log (Normal is not a headache).
  static List<HeadacheType> get loggable =>
      HeadacheType.values.where((t) => t != HeadacheType.normal).toList();

  String get explanation {
    switch (this) {
      case HeadacheType.normal:
        return 'Your readings look steady. Keep up your routine.';
      case HeadacheType.tension:
        return 'Low movement and rising muscle tension signs, often from long sitting or poor posture.';
      case HeadacheType.stress:
        return 'Raised heart rate and skin conductance suggest your body is under stress.';
      case HeadacheType.sleepDeprivation:
        return 'Patterns match short or poor-quality sleep.';
      case HeadacheType.caffeineWithdrawal:
        return 'Signals match a drop from your usual caffeine intake.';
      case HeadacheType.hormonal:
        return 'Signals match patterns linked to hormonal changes.';
      case HeadacheType.cluster:
        return 'Signals match a cluster-type pattern. These can be severe.';
    }
  }

  /// Short, cause-specific preventive guidance.
  List<String> get guidance {
    switch (this) {
      case HeadacheType.normal:
        return [
          'Keep drinking water through the day',
          'Take a short screen break every hour',
          'Keep a regular sleep time tonight',
        ];
      case HeadacheType.tension:
        return [
          'Roll your neck and shoulders slowly for 1 minute',
          'Check your posture and screen height',
          'Apply a warm compress to your neck',
          'Stand up and stretch for 5 minutes',
        ];
      case HeadacheType.stress:
        return [
          'Do 2 minutes of slow breathing (4 s in, 6 s out)',
          'Step away for a short walk',
          'Move to a quieter place if you can',
          'Drink a glass of water',
        ];
      case HeadacheType.sleepDeprivation:
        return [
          'Take a 20-minute nap if possible',
          'Dim screens and lights around you',
          'Avoid screens for an hour before bed tonight',
          'Keep a consistent wake-up time',
        ];
      case HeadacheType.caffeineWithdrawal:
        return [
          'If you usually have caffeine, a small amount may help',
          'Reduce caffeine gradually, not suddenly',
          'Stay hydrated',
        ];
      case HeadacheType.hormonal:
        return [
          'Note this alongside your cycle to spot patterns',
          'Keep regular meals and sleep on higher-risk days',
          'Discuss recurring patterns with a doctor',
        ];
      case HeadacheType.cluster:
        return [
          'Follow any plan your doctor has given you',
          'Avoid alcohol during a cluster period',
          'Seek medical care if this is new or very intense',
        ];
    }
  }
}
