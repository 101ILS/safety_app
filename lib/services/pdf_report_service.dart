import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/models/risk_level.dart';

class PdfReportService {
  static Future<void> generateShiftCheckReport({
    required String employeeName,
    required String employeeId,
    required String position,
    required String department,
    required RiskLevel riskLevel,
    required int safetyScore,
    required bool admitted,
    required String aiExplanation,
    required String aiDecision,
  }) async {
    final pdf = pw.Document();

    // Unicode шрифт
    final fontData = await rootBundle.load(
      'assets/fonts/NotoSans-Regular.ttf',
    );

    final boldData = await rootBundle.load(
      'assets/fonts/NotoSans-Bold.ttf',
    );

    final regularFont = pw.Font.ttf(fontData);
    final boldFont = pw.Font.ttf(boldData);

    final now = DateTime.now();

    pdf.addPage(
      pw.Page(
        build: (_) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),

            child: pw.Column(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start,

              children: [
                pw.Text(
                  'Отчёт проверки допуска к смене',

                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 22,
                  ),
                ),

                pw.SizedBox(height: 20),

                pw.Text(
                  'Дата: ${now.day}.${now.month}.${now.year}',
                  style: pw.TextStyle(
                    font: regularFont,
                  ),
                ),

                pw.Text(
                  'Время: ${now.hour}:${now.minute}',
                  style: pw.TextStyle(
                    font: regularFont,
                  ),
                ),

                pw.SizedBox(height: 20),

                pw.Text(
                  'Данные сотрудника',

                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 18,
                  ),
                ),

                pw.SizedBox(height: 8),

                pw.Text(
                  'ФИО: $employeeName',
                  style: pw.TextStyle(
                    font: regularFont,
                  ),
                ),

                pw.Text(
                  'ID: $employeeId',
                  style: pw.TextStyle(
                    font: regularFont,
                  ),
                ),

                pw.Text(
                  'Должность: $position',
                  style: pw.TextStyle(
                    font: regularFont,
                  ),
                ),

                pw.Text(
                  'Отдел: $department',
                  style: pw.TextStyle(
                    font: regularFont,
                  ),
                ),

                pw.SizedBox(height: 20),

                pw.Text(
                  'Результаты проверки',

                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 18,
                  ),
                ),

                pw.SizedBox(height: 10),

                pw.Text(
                  'Уровень риска: ${getRiskLabel(riskLevel)}',
                  style: pw.TextStyle(
                    font: regularFont,
                  ),
                ),

                pw.Text(
                  'Тест: $safetyScore%',
                  style: pw.TextStyle(
                    font: regularFont,
                  ),
                ),

                pw.Text(
                  admitted
                      ? 'Допущен к работе'
                      : 'Не допущен',

                  style: pw.TextStyle(
                    font: boldFont,
                  ),
                ),

                pw.SizedBox(height: 20),

                pw.Text(
                  'AI объяснение',

                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 18,
                  ),
                ),

                pw.SizedBox(height: 8),

                pw.Text(
                  aiExplanation,

                  style: pw.TextStyle(
                    font: regularFont,
                  ),
                ),

                pw.SizedBox(height: 20),

                pw.Text(
                  'Решение системы',

                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 18,
                  ),
                ),

                pw.SizedBox(height: 8),

                pw.Text(
                  aiDecision,

                  style: pw.TextStyle(
                    font: regularFont,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async =>
          pdf.save(),
    );
  }
}