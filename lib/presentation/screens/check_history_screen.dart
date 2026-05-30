import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../services/app_state.dart';

class CheckHistoryScreen extends StatelessWidget {
  static const routeName = '/check-history';

  const CheckHistoryScreen({super.key});

  Color statusColor(bool admitted) {
    return admitted ? AppTheme.success : AppTheme.danger;
  }

  String statusText(
    bool admitted,
    String risk,
  ) {
    if (risk == 'high') {
      return 'Медосмотр';
    }

    return admitted ? 'Допущен' : 'Не допущен';
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final employeeId = context.watch<AppState>().employeeId;

    final stream = FirebaseFirestore.instance
        .collection('shiftChecks')
        .where(
          'employeeId',
          isEqualTo: employeeId,
        )
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'История проверок',
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Ошибка загрузки: ${snapshot.error}',
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = [...(snapshot.data?.docs ?? [])];

          docs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;

            final aTime = aData['createdAt'];
            final bTime = bData['createdAt'];

            if (aTime is Timestamp && bTime is Timestamp) {
              return bTime.compareTo(aTime);
            }

            return 0;
          });

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'Проверок пока нет',
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              final admitted = data['admitted'] == true;

              final risk = data['riskLevel'] ?? 'medium';

              final score = data['safetyScore'] ?? 0;

              final recommendation = data['recommendation'] ?? '-';

              final decision = data['decision'] ?? '-';

              final ts = data['createdAt'];

              String date = '-';

              if (ts is Timestamp) {
                final d = ts.toDate();

                date =
                    '${d.day}.${d.month}.${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
              }

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: statusColor(admitted),
                            child: Icon(
                              admitted ? Icons.check : Icons.medical_services,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  statusText(
                                    admitted,
                                    risk,
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(date),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Риск: $risk'),
                      Text('Тест: $score%'),
                      const SizedBox(height: 10),
                      const Text(
                        'AI анализ:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(recommendation),
                      const SizedBox(height: 10),
                      Text(decision),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}