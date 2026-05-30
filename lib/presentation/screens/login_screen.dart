import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/firebase_employee_repository.dart';
import '../../services/app_state.dart';
import 'start_shift_screen.dart';
import 'admin_dashboard_screen.dart';


import '../../services/seed_service.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController(text: '1001');
  final _pinController = TextEditingController(text: '1111');

  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final id = _idController.text.trim();
    final pin = _pinController.text.trim();

    if (id == 'admin' && pin == '0000') {
      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.pushReplacementNamed(context, AdminDashboardScreen.routeName);
      return;
    }

    final repo = context.read<FirebaseEmployeeRepository>();
    final appState = context.read<AppState>();

    final employee = await repo.login(
      employeeId: id,
      pin: pin,
    );

    if (!mounted) return;

    setState(() => _loading = false);

    if (employee == null) {
      setState(() {
        _error = 'Сотрудник не найден, неактивен или PIN неверный';
      });
      return;
    }

    appState.setEmployee(employee);
    Navigator.pushReplacementNamed(context, StartShiftScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              const Text(
                'Safety AI',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Корпоративный контроль безопасности труда',
                style: TextStyle(color: Colors.grey.shade700),
              ),

              const SizedBox(height: 28),

              TextField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'Табельный номер / ID',
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'PIN-код',
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: Text(_loading ? 'Проверка...' : 'Войти'),
              ),

              const Spacer(),

              Center(
                child: Text(
                  'Админ: admin / 0000',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
