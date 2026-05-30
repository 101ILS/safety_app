import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/risk_level.dart';
import '../../services/app_state.dart';
import 'dashboard_screen.dart';
import 'start_shift_screen.dart';
import '../../services/pdf_report_service.dart';

class CheckResultScreen extends StatelessWidget {
  static const routeName = '/check-result';

  const CheckResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final risk = state.riskLevel ?? RiskLevel.medium;

    final bool highRisk = risk == RiskLevel.high;
    final bool passedTest = state.safetyTestScore >= 70;
    final bool admitted = !highRisk && passedTest;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Результат проверки'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Spacer(),

            CircleAvatar(
              radius: 58,
              backgroundColor: admitted ? AppTheme.success : AppTheme.danger,
              child: Icon(
                admitted ? Icons.check : Icons.medical_services,
                color: Colors.white,
                size: 56,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              admitted ? 'Допуск разрешён' : 'Допуск запрещён',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              highRisk
                  ? 'Обнаружен высокий уровень риска. Сотрудник направляется на медицинский осмотр.'
                  : passedTest
                      ? 'Проверка успешно пройдена. Сотрудник может приступить к работе.'
                      : 'Результат теста ниже нормы. Необходимо пройти повторную проверку.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 28),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _ResultRow(
                      title: 'Уровень риска',
                      value: getRiskLabel(risk),
                    ),
                    const Divider(),
                    _ResultRow(
                      title: 'Результат теста',
                      value: '${state.safetyTestScore}%',
                    ),
                    const Divider(),
                    _ResultRow(
                      title: 'Статус',
                      value: admitted
                          ? 'Допущен к работе'
                          : highRisk
                              ? 'Медицинский осмотр'
                              : 'Повторная проверка',
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            if (admitted)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    DashboardScreen.routeName,
                  );
                },
                icon: const Icon(Icons.dashboard),
                label: const Text('Перейти на главный экран'),
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  context.read<AppState>().resetShift();
                  Navigator.pushReplacementNamed(
                    context,
                    StartShiftScreen.routeName,
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Пройти проверку повторно'),
              ),

            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed: () {
                PdfReportService.generateShiftCheckReport(
                  employeeName: state.employeeName,
                  employeeId: state.employeeId,
                  position: state.position,
                  department: state.department,
                  riskLevel: risk,
                  safetyScore: state.safetyTestScore,
                  admitted: admitted,
                  aiExplanation: state.aiExplanation,
                  aiDecision: state.aiDecision,
                );
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Сформировать PDF отчёт'),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String title;
  final String value;

  const _ResultRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}