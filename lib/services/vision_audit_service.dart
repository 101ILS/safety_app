import 'dart:convert';
import 'dart:typed_data';

import 'openai_service.dart';

class VisionAuditResult {
  final String objectName;
  final String riskLevel;
  final List<String> findings;
  final List<String> recommendations;

  VisionAuditResult({
    required this.objectName,
    required this.riskLevel,
    required this.findings,
    required this.recommendations,
  });
}

class VisionAuditService {
  static Future<VisionAuditResult> analyze(Uint8List imageBytes) async {
    final response = await OpenAiService.analyzeEquipmentImage(imageBytes);

    if (response == null) {
      return fallback();
    }

    try {
      final cleaned = response
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final data = jsonDecode(cleaned);

      return VisionAuditResult(
        objectName: data['objectName']?.toString() ?? 'Неизвестный объект',
        riskLevel: data['riskLevel']?.toString() ?? 'medium',
        findings: (data['findings'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        recommendations: (data['recommendations'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
    } catch (e) {
      return fallback();
    }
  }

  static VisionAuditResult fallback() {
    return VisionAuditResult(
      objectName: 'Не удалось распознать объект',
      riskLevel: 'medium',
      findings: [
        'AI-анализ изображения не был выполнен корректно',
        'Требуется ручная проверка специалистом',
      ],
      recommendations: [
        'Повторить фото при хорошем освещении',
        'Проверить оборудование ответственным лицом',
      ],
    );
  }
}