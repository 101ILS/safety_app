import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../data/models/risk_level.dart';
import '../../services/ai_behavior_service.dart';
import '../../services/app_state.dart';
import 'dashboard_screen.dart';
import '../../services/face_ai_service.dart';
import '../../services/ai_question_service.dart';
import 'check_result_screen.dart';

class StartShiftScreen extends StatefulWidget {
  static const routeName = '/start-shift';

  const StartShiftScreen({super.key});

  @override
  State<StartShiftScreen> createState() => _StartShiftScreenState();
}

class _StartShiftScreenState extends State<StartShiftScreen> {
  final ImagePicker picker = ImagePicker();

  XFile? photo;
  bool analyzing = false;
  bool aiDone = false;
  bool testStarted = false;

  AiBehaviorResult? aiResult;

  int currentQuestion = 0;
  int correctAnswers = 0;

  List<Map<String, dynamic>> questions = [];

  Future<void> takePhoto() async {
    final image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    setState(() {
      photo = image;
      aiDone = false;
      aiResult = null;
    });
  }

  Future<void> runAiCheck() async {
    if (photo == null) return;

    setState(() {
      analyzing = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    try {
      final appState = context.read<AppState>();

      if (kIsWeb) {
        final result = AiBehaviorService.analyze();

        final generated = await AiQuestionService.generateQuestions(
          position: appState.position,
          department: appState.department,
          risk: result.riskLevel.name,
        );

        setState(() {
          aiResult = result;
          analyzing = false;
          aiDone = true;

          questions = generated.isNotEmpty
              ? generated
              : [
                  {
                    'question': 'Что делать при пожаре в офисе?',
                    'options': [
                      'Продолжить работу',
                      'Сообщить ответственному и эвакуироваться',
                      'Открыть все окна',
                    ],
                    'answer': 1,
                  },
                ];

          testStarted = true;
        });
      } else {
        final result = await FaceAIService.analyze(photo!.path);

        final converted = AiBehaviorResult(
          attention: result.lookingForward ? 85 : 60,
          fatigue: result.tired ? 75 : 20,
          eyeOpen: result.eyesOpen ? 90 : 30,
          stability: result.lookingForward ? 80 : 50,
          riskLevel: result.risk,
        );

        final generated = await AiQuestionService.generateQuestions(
          position: appState.position,
          department: appState.department,
          risk: result.risk.name,
        );

        setState(() {
          aiResult = converted;
          analyzing = false;
          aiDone = true;

          questions = generated.isNotEmpty
              ? generated
              : [
                  {
                    'question': 'Что делать при пожаре в офисе?',
                    'options': [
                      'Продолжить работу',
                      'Сообщить ответственному и эвакуироваться',
                      'Открыть все окна',
                    ],
                    'answer': 1,
                  },
                ];

          testStarted = true;
        });
      }
    } catch (e) {
      setState(() {
        analyzing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка AI анализа: $e')),
      );
    }
  }

  void answerQuestion(int selectedIndex) {
    final correctIndex = questions[currentQuestion]['answer'] as int;

    if (selectedIndex == correctIndex) {
      correctAnswers++;
    }

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
      });
    } else {
      finishCheck();
    }
  }

  void finishCheck() {
    final score = ((correctAnswers / questions.length) * 100).round();
    final risk = aiResult?.riskLevel ?? RiskLevel.medium;

    context.read<AppState>().saveShiftCheck(
          risk: risk,
          score: score,
        );

    Navigator.pushReplacementNamed(context, CheckResultScreen.routeName);
  }

  Color riskColor(RiskLevel risk) {
    switch (risk) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = questions.isNotEmpty ? questions[currentQuestion] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Начало смены'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!testStarted) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    const Icon(Icons.health_and_safety, size: 68),
                    const SizedBox(height: 12),
                    const Text(
                      'Перед началом смены необходимо пройти фото-контроль и AI-анализ состояния.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 18),
                    if (photo != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: kIsWeb
                            ? Image.network(
                                photo!.path,
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(photo!.path),
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                      )
                    else
                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.blueGrey.shade100),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 52),
                            SizedBox(height: 8),
                            Text('Фото ещё не сделано'),
                          ],
                        ),
                      ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      onPressed: takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Сделать фото'),
                    ),
                    const SizedBox(height: 10),
                    if (analyzing)
                      const Column(
                        children: [
                          SizedBox(height: 12),
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text('AI анализирует лицо, внимание и усталость...'),
                        ],
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: runAiCheck,
                        icon: const Icon(Icons.psychology),
                        label: const Text('Запустить AI-анализ'),
                      ),
                  ],
                ),
              ),
            ),
          ],
          if (testStarted && aiResult != null && question != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Результат AI-анализа',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _RiskBadge(
                      risk: aiResult!.riskLevel,
                      color: riskColor(aiResult!.riskLevel),
                    ),
                    const SizedBox(height: 16),
                    _MetricBar(
                      title: 'Внимание',
                      value: aiResult!.attention,
                    ),
                    _MetricBar(
                      title: 'Усталость',
                      value: aiResult!.fatigue,
                      reverse: true,
                    ),
                    _MetricBar(
                      title: 'Открытость глаз',
                      value: aiResult!.eyeOpen,
                    ),
                    _MetricBar(
                      title: 'Стабильность поведения',
                      value: aiResult!.stability,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Вопрос ${currentQuestion + 1}/${questions.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      question['question'].toString(),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    ...(question['options'] as List)
                        .map((e) => e.toString())
                        .toList()
                        .asMap()
                        .entries
                        .map(
                      (entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ElevatedButton(
                            onPressed: () => answerQuestion(entry.key),
                            child: Text(entry.value),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  final RiskLevel risk;
  final Color color;

  const _RiskBadge({
    required this.risk,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(Icons.analytics, color: color),
          const SizedBox(width: 10),
          Text(
            'Уровень риска: ${getRiskLabel(risk)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  final String title;
  final int value;
  final bool reverse;

  const _MetricBar({
    required this.title,
    required this.value,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    final percent = value / 100;
    final displayColor = reverse
        ? value > 60
            ? Colors.red
            : value > 35
                ? Colors.orange
                : Colors.green
        : value > 75
            ? Colors.green
            : value > 50
                ? Colors.orange
                : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title)),
              Text('$value%'),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: percent,
            minHeight: 9,
            borderRadius: BorderRadius.circular(20),
            color: displayColor,
            backgroundColor: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }
}