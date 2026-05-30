import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../services/app_state.dart';
import 'profile_screen.dart';
import 'ai_chat_screen.dart';
import 'ar_audit_screen.dart';
import 'start_shift_screen.dart';
import '../../data/models/risk_level.dart';
import 'check_history_screen.dart';

class DashboardScreen extends StatelessWidget {
  static const routeName = '/dashboard';

  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety AI'),
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
          IconButton(
            onPressed: () {
              context.read<AppState>().resetShift();
              Navigator.pushReplacementNamed(context, StartShiftScreen.routeName);
            },
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Начать проверку заново',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor:
                        state.admitted ? AppTheme.success : AppTheme.danger,
                    child: Icon(
                      state.admitted ? Icons.check : Icons.warning,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.admitted ? 'Допущен к работе' : 'Не допущен',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          state.riskLevel == null
                              ? 'Проверка ещё не пройдена'
                              : 'Риск: ${getRiskLabel(state.riskLevel!)
                              } • Тест: ${state.safetyTestScore}%',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.badge, color: AppTheme.primary),
              title: Text(state.employeeName),
              subtitle: Text('${state.position}\n${state.department}'),
              isThreeLine: true,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  title: 'Смена',
                  value: state.shiftStarted ? 'Активна' : 'Не начата',
                  icon: Icons.work_history,
                ),
              ),
              Expanded(
                child: _InfoCard(
                  title: 'Тест',
                  value: '${state.safetyTestScore}%',
                  icon: Icons.quiz,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (state.riskLevel != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.recommend, color: AppTheme.primary),
                title: const Text('Рекомендация'),
                subtitle: Text(getRiskRecommendation(state.riskLevel!)),
              ),
            ),

          const SizedBox(height: 18),

          const Text(
            'Основные разделы',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          _MenuButton(
            icon: Icons.person,
            title: 'Личный кабинет',
            subtitle: 'Данные сотрудника, история проверок',
            onTap: () => Navigator.pushNamed(context, ProfileScreen.routeName),
          ),
          _MenuButton(
            icon: Icons.chat,
            title: 'AI чат-ассистент',
            subtitle: 'Помощник по технике безопасности',
            onTap: () => Navigator.pushNamed(context, AiChatScreen.routeName),
          ),
          _MenuButton(
            icon: Icons.history,
            title: 'История проверок',
            subtitle: 'Просмотр прошлых проверок и результатов',
            onTap: () {
              Navigator.pushNamed(
                context,
                CheckHistoryScreen.routeName,
              );
            },
          ),
          _MenuButton(
            icon: Icons.view_in_ar,
            title: 'AR-аудит оборудования',
            subtitle: 'Проверка объектов через камеру',
            onTap: () => Navigator.pushNamed(context, ArAuditScreen.routeName),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primary),
            const SizedBox(height: 8),
            Text(title),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}