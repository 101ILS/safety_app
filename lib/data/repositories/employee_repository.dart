import '../models/employee.dart';

class EmployeeRepository {
  final List<Employee> _employees = const [
    Employee(
      id: '1001',
      fullName: 'Иванов Алексей Сергеевич',
      position: 'Инженер-проектировщик',
      department: 'Отдел инженерных систем',
      isActive: true,
      pin: '1111',
    ),
    Employee(
      id: '1002',
      fullName: 'Смагулова Айдана Ерлановна',
      position: 'Специалист по охране труда',
      department: 'Служба безопасности труда',
      isActive: true,
      pin: '2222',
    ),
    Employee(
      id: '1003',
      fullName: 'Петров Дмитрий Олегович',
      position: 'Техник',
      department: 'Производственно-технический отдел',
      isActive: false,
      pin: '3333',
    ),
  ];

  Future<Employee?> login({required String employeeId, required String pin}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    try {
      final employee = _employees.firstWhere((e) => e.id == employeeId && e.pin == pin);
      return employee.isActive ? employee : null;
    } catch (_) {
      return null;
    }
  }

  List<Employee> get demoEmployees => List.unmodifiable(_employees.where((e) => e.isActive));
}
