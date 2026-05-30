import 'dart:math';
import '../data/models/risk_level.dart';

class AiAnalysisResult {
  final RiskLevel riskLevel;
  final double fatigueScore;
  final double attentionScore;
  final String description;

  AiAnalysisResult({
    required this.riskLevel,
    required this.fatigueScore,
    required this.attentionScore,
    required this.description,
  });
}

class AiAnalysisService {
  final _random = Random();

  Future<AiAnalysisResult> analyzeFaceMock() async {
    await Future.delayed(const Duration(seconds: 2));
    final fatigue = _random.nextDouble();
    final attention = _random.nextDouble();

    final risk = fatigue > 0.72 || attention < 0.25
        ? RiskLevel.high
        : fatigue > 0.45 || attention < 0.5
            ? RiskLevel.medium
            : RiskLevel.low;

    return AiAnalysisResult(
      riskLevel: risk,
      fatigueScore: fatigue,
      attentionScore: attention,
      description: 'Демо-анализ: признаки усталости ${(fatigue * 100).round()}%, внимание ${(attention * 100).round()}%.',
    );
  }
}
