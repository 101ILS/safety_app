import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/models/employee.dart';
import '../data/models/risk_level.dart';
import '../data/models/safety_check.dart';

class AppState extends ChangeNotifier {
  Employee? currentEmployee;

  SafetyCheck? lastCheck;

  final List<SafetyCheck> checkHistory = [];

  String aiExplanation = '';
  String aiDecision = '';

  String get employeeName =>
      currentEmployee?.fullName ?? 'Иванов Иван';

  String get employeeId =>
      currentEmployee?.id ?? '1001';

  String get position =>
      currentEmployee?.position ??
      'Инженер-проектировщик';

  String get department =>
      currentEmployee?.department ??
      'Отдел инженерного проектирования';

  bool shiftStarted = false;

  RiskLevel? riskLevel;

  int safetyTestScore = 0;

  bool admitted = false;

  void setEmployee(Employee employee) {
    currentEmployee = employee;
    notifyListeners();
  }

  void saveShiftCheck({
    required RiskLevel risk,
    required int score,
  }) {
    riskLevel = risk;

    safetyTestScore = score;

    shiftStarted = true;

    admitted =
        risk != RiskLevel.high &&
        score >= 70;

    aiExplanation =
        buildAiExplanation(
      risk: risk,
      score: score,
    );

    aiDecision =
        buildDecision(
      risk: risk,
      score: score,
    );

    lastCheck = SafetyCheck(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),

      employeeId: employeeId,

      dateTime: DateTime.now(),

      riskLevel: risk,

      cognitiveScore: score,

      safetyScore: score,

      admitted: admitted,

      recommendation:
          aiExplanation,
    );

    checkHistory.add(lastCheck!);

    FirebaseFirestore.instance
        .collection(
          'shiftChecks',
        )
        .add({
      'employeeId':
          employeeId,

      'employeeName':
          employeeName,

      'position':
          position,

      'department':
          department,

      'riskLevel':
          risk.name,

      'cognitiveScore':
          score,

      'safetyScore':
          score,

      'admitted':
          admitted,

      'recommendation':
          aiExplanation,

      'decision':
          aiDecision,

      'createdAt':
          FieldValue
              .serverTimestamp(),
    });

    notifyListeners();
  }

  String buildAiExplanation({
    required RiskLevel risk,
    required int score,
  }) {
    final reasons = <String>[];

    if (risk ==
        RiskLevel.high) {
      reasons.add(
        'выявлены признаки усталости',
      );

      reasons.add(
        'сниженное внимание',
      );
    }

    if (risk ==
        RiskLevel.medium) {
      reasons.add(
        'обнаружено умеренное снижение внимания',
      );
    }

    if (score < 70) {
      reasons.add(
        'низкий результат тестирования',
      );
    }

    if (reasons.isEmpty) {
      reasons.add(
        'нарушений не обнаружено',
      );
    }

    return reasons.join(
      ', ',
    );
  }

  String buildDecision({
    required RiskLevel risk,
    required int score,
  }) {
    if (risk ==
        RiskLevel.high) {
      return '''
Допуск запрещён

Причины:
• признаки усталости
• сниженное внимание

Решение:
направить сотрудника
на медицинский осмотр
''';
    }

    if (score < 70) {
      return '''
Допуск временно запрещён

Причины:
• тест не пройден

Решение:
повторная проверка
''';
    }

    return '''
Допуск разрешён

Нарушений не выявлено

Сотрудник может
приступить к работе
''';
  }

  void resetShift() {
    shiftStarted = false;

    riskLevel = null;

    safetyTestScore = 0;

    admitted = false;

    aiExplanation = '';

    aiDecision = '';

    lastCheck = null;

    notifyListeners();
  }
}