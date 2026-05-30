import 'risk_level.dart';

class ShiftCheck {
  final DateTime dateTime;
  final RiskLevel riskLevel;
  final int cognitiveScore;
  final int safetyScore;
  final bool allowed;
  final String recommendation;

  ShiftCheck({
    required this.dateTime,
    required this.riskLevel,
    required this.cognitiveScore,
    required this.safetyScore,
    required this.allowed,
    required this.recommendation,
  });
}
