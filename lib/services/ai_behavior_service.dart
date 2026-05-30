import 'dart:math';
import '../data/models/risk_level.dart';

class AiBehaviorResult {
  final int attention;
  final int fatigue;
  final int eyeOpen;
  final int stability;
  final RiskLevel riskLevel;

  AiBehaviorResult({
    required this.attention,
    required this.fatigue,
    required this.eyeOpen,
    required this.stability,
    required this.riskLevel,
  });
}

class AiBehaviorService {
  static AiBehaviorResult analyze() {
    final random = Random();

    final attention = 60 + random.nextInt(41);
    final fatigue = random.nextInt(55);
    final eyeOpen = 65 + random.nextInt(36);
    final stability = 55 + random.nextInt(46);

    final average = ((attention + eyeOpen + stability + (100 - fatigue)) / 4).round();

    RiskLevel risk;

    if (average >= 75) {
      risk = RiskLevel.low;
    } else if (average >= 55) {
      risk = RiskLevel.medium;
    } else {
      risk = RiskLevel.high;
    }

    return AiBehaviorResult(
      attention: attention,
      fatigue: fatigue,
      eyeOpen: eyeOpen,
      stability: stability,
      riskLevel: risk,
    );
  }
}