import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/vision_audit_service.dart';

class ArAuditScreen extends StatefulWidget {
  static const routeName = '/ar-audit';

  const ArAuditScreen({super.key});

  @override
  State<ArAuditScreen> createState() => _ArAuditScreenState();
}

class _ArAuditScreenState extends State<ArAuditScreen> {
  final ImagePicker picker = ImagePicker();

  XFile? photo;
  bool analyzing = false;
  bool analyzed = false;

  String objectName = '';
  String riskLevel = '';
  List<String> findings = [];
  List<String> recommendations = [];

  Future<void> takePhoto() async {
    final image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    setState(() {
      photo = image;
      analyzed = false;
      findings = [];
      recommendations = [];
    });
  }

  Future<void> analyzeEquipment() async {
  if (photo == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Сначала сделайте фото оборудования')),
    );
    return;
  }

  setState(() {
    analyzing = true;
  });

  final bytes = await photo!.readAsBytes();
  final result = await VisionAuditService.analyze(bytes);

  setState(() {
    objectName = result.objectName;
    riskLevel = result.riskLevel == 'low'
        ? 'Низкий'
        : result.riskLevel == 'high'
            ? 'Высокий'
            : 'Средний';

    findings = result.findings;
    recommendations = result.recommendations;
    analyzing = false;
    analyzed = true;
  });
}

  Color riskColor() {
    switch (riskLevel) {
      case 'Низкий':
        return Colors.green;
      case 'Средний':
        return Colors.orange;
      case 'Высокий':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = riskColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AR-аудит оборудования'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const Icon(Icons.view_in_ar, size: 64),
                  const SizedBox(height: 12),
                  const Text(
                    'Сделайте фото оборудования. Система выполнит AI-аудит и покажет зоны риска поверх изображения.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),

                  if (photo != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        children: [
                          kIsWeb
                              ? Image.network(
                                  photo!.path,
                                  height: 260,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(photo!.path),
                                  height: 260,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),

                          if (analyzed) ...[
                            Positioned(
                              top: 24,
                              left: 24,
                              child: _RiskMarker(
                                label: 'Зона риска',
                                color: color,
                              ),
                            ),
                            Positioned(
                              bottom: 28,
                              right: 24,
                              child: _RiskMarker(
                                label: 'Проверить',
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  else
                    Container(
                      height: 260,
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
                          Text('Фото оборудования не выбрано'),
                        ],
                      ),
                    ),

                  const SizedBox(height: 18),

                  ElevatedButton.icon(
                    onPressed: takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Сделать фото оборудования'),
                  ),

                  const SizedBox(height: 10),

                  if (analyzing)
                    const Column(
                      children: [
                        SizedBox(height: 12),
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('AI анализирует оборудование...'),
                      ],
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: analyzeEquipment,
                      icon: const Icon(Icons.analytics),
                      label: const Text('Запустить AI-аудит'),
                    ),
                ],
              ),
            ),
          ),

          if (analyzed) ...[
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Результат аудита',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      title: 'Объект',
                      value: objectName,
                    ),
                    _InfoRow(
                      title: 'Уровень риска',
                      value: riskLevel,
                      color: color,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            _ListCard(
              title: 'AI замечания',
              icon: Icons.warning_amber,
              items: findings,
              color: Colors.orange,
            ),

            const SizedBox(height: 12),

            _ListCard(
              title: 'Рекомендации',
              icon: Icons.check_circle,
              items: recommendations,
              color: Colors.green,
            ),
          ],
        ],
      ),
    );
  }
}

class _RiskMarker extends StatelessWidget {
  final String label;
  final Color color;

  const _RiskMarker({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;
  final Color? color;

  const _InfoRow({
    required this.title,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;
  final Color color;

  const _ListCard({
    required this.title,
    required this.icon,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('• $item'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}