import 'risk_level.dart';

class SafetyCheck {
  final String id;
  final String employeeId;
  final DateTime dateTime;
  final RiskLevel riskLevel;
  final int cognitiveScore;
  final int safetyScore;
  final bool admitted;
  final String recommendation;

  SafetyCheck({
    required this.id,
    required this.employeeId,
    required this.dateTime,
    required this.riskLevel,
    required this.cognitiveScore,
    required this.safetyScore,
    required this.admitted,
    required this.recommendation,
  });

  int get testScore => safetyScore;
}