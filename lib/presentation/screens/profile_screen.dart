import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../services/app_state.dart';
import '../widgets/app_card.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final e = state.currentEmployee;
    final check = state.lastCheck;

    return Scaffold(
      appBar: AppBar(title: const Text('Личный кабинет')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e?.fullName ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('ID: ${e?.id ?? ''}'),
                Text('Должность: ${e?.position ?? ''}'),
                Text('Отдел: ${e?.department ?? ''}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Последняя проверка', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Text('Дата: ${check == null ? '-' : DateFormat('dd.MM.yyyy HH:mm').format(check.dateTime)}'),
                Text('Когнитивный тест: ${check?.cognitiveScore ?? '-'}'),
                Text('Тест по ТБ: ${check?.safetyScore ?? '-'}'),
                Text('Рекомендация: ${check?.recommendation ?? '-'}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
