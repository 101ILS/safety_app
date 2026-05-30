import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/risk_level.dart';

class AdminDashboardScreen extends StatefulWidget {
  static const routeName = '/admin-dashboard';

  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String selectedFilter = 'all';

  RiskLevel parseRisk(String value) {
    switch (value) {
      case 'low':
        return RiskLevel.low;
      case 'medium':
        return RiskLevel.medium;
      case 'high':
        return RiskLevel.high;
      default:
        return RiskLevel.medium;
    }
  }

  String getDecision(Map<String, dynamic> data) {
    final risk = data['riskLevel'] ?? 'medium';
    final admitted = data['admitted'] == true;
    final safetyScore = data['safetyScore'] ?? 0;

    if (risk == 'high') return 'medical';
    if (!admitted && safetyScore < 70) return 'failed_test';
    return 'admitted';
  }

  String getDecisionText(String decision) {
    switch (decision) {
      case 'medical':
        return 'Медосмотр';
      case 'failed_test':
        return 'Тест не пройден';
      case 'admitted':
        return 'Допущен';
      default:
        return 'Неизвестно';
    }
  }

  Color getDecisionColor(String decision) {
    switch (decision) {
      case 'medical':
        return AppTheme.danger;
      case 'failed_test':
        return Colors.orange;
      case 'admitted':
        return AppTheme.success;
      default:
        return Colors.grey;
    }
  }

  List<QueryDocumentSnapshot> applyFilter(List<QueryDocumentSnapshot> docs) {
    if (selectedFilter == 'all') return docs;

    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return getDecision(data) == selectedFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('shiftChecks')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Панель управляющего',
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
            ),

            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Ошибка загрузки данных'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          final filteredDocs = applyFilter(docs);

          final admittedCount = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return getDecision(data) == 'admitted';
          }).length;

          final medicalCount = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return getDecision(data) == 'medical';
          }).length;

          final failedCount = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return getDecision(data) == 'failed_test';
          }).length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Мониторинг смен',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Всего',
                      value: docs.length.toString(),
                      icon: Icons.people,
                      color: AppTheme.primary,
                    ),
                  ),
                  Expanded(
                    child: _StatCard(
                      title: 'Допущены',
                      value: admittedCount.toString(),
                      icon: Icons.check_circle,
                      color: AppTheme.success,
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Медосмотр',
                      value: medicalCount.toString(),
                      icon: Icons.medical_services,
                      color: AppTheme.danger,
                    ),
                  ),
                  Expanded(
                    child: _StatCard(
                      title: 'Не прошли',
                      value: failedCount.toString(),
                      icon: Icons.warning,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              const Text(
                'Фильтр',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChipButton(
                      label: 'Все',
                      value: 'all',
                      selected: selectedFilter == 'all',
                      onTap: () => setState(() => selectedFilter = 'all'),
                    ),
                    _FilterChipButton(
                      label: 'Допущены',
                      value: 'admitted',
                      selected: selectedFilter == 'admitted',
                      onTap: () => setState(() => selectedFilter = 'admitted'),
                    ),
                    _FilterChipButton(
                      label: 'Медосмотр',
                      value: 'medical',
                      selected: selectedFilter == 'medical',
                      onTap: () => setState(() => selectedFilter = 'medical'),
                    ),
                    _FilterChipButton(
                      label: 'Тест не пройден',
                      value: 'failed_test',
                      selected: selectedFilter == 'failed_test',
                      onTap: () =>
                          setState(() => selectedFilter = 'failed_test'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Результаты сотрудников',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              if (filteredDocs.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text('Нет данных по выбранному фильтру.'),
                  ),
                )
              else
                ...filteredDocs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final employeeId = data['employeeId'] ?? '-';
                  final employeeName = data['employeeName'] ?? '-';
                  final position = data['position'] ?? '-';
                  final department = data['department'] ?? '-';
                  final cognitiveScore = data['cognitiveScore'] ?? 0;
                  final safetyScore = data['safetyScore'] ?? 0;
                  final risk = parseRisk(data['riskLevel'] ?? 'medium');
                  final decision = getDecision(data);
                  final decisionColor = getDecisionColor(decision);

                  final timestamp = data['createdAt'];
                  String dateText = '-';

                  if (timestamp is Timestamp) {
                    final date = timestamp.toDate();
                    dateText =
                        '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                  }

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: decisionColor,
                                child: Icon(
                                  decision == 'admitted'
                                      ? Icons.check
                                      : decision == 'medical'
                                          ? Icons.medical_services
                                          : Icons.warning,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$employeeId — $employeeName',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '$position • $department',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: decisionColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: decisionColor),
                                ),
                                child: Text(
                                  getDecisionText(decision),
                                  style: TextStyle(
                                    color: decisionColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          _InfoLine(
                            icon: Icons.analytics,
                            title: 'Риск',
                            value: getRiskLabel(risk),
                          ),
                          _InfoLine(
                            icon: Icons.psychology,
                            title: 'Когнитивный тест',
                            value: '$cognitiveScore%',
                          ),
                          _InfoLine(
                            icon: Icons.quiz,
                            title: 'Тест по ТБ',
                            value: '$safetyScore%',
                          ),
                          _InfoLine(
                            icon: Icons.access_time,
                            title: 'Время проверки',
                            value: dateText,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(title),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoLine({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}