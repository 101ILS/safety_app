import 'package:cloud_firestore/cloud_firestore.dart';

class SeedService {
  static Future<void> seedEmployees() async {
    final db = FirebaseFirestore.instance;

    final employees = [
      {
        'id': '1002',
        'fullName': 'Петров Сергей',
        'position': 'Инженер-электрик',
        'department': 'Электротехнический отдел',
        'pin': '2222',
        'active': true,
      },
      {
        'id': '1003',
        'fullName': 'Сидорова Анна',
        'position': 'Инженер по охране труда',
        'department': 'Отдел промышленной безопасности',
        'pin': '3333',
        'active': true,
      },
      {
        'id': '1004',
        'fullName': 'Ахметов Ерлан',
        'position': 'Главный инженер проекта',
        'department': 'Проектный отдел',
        'pin': '4444',
        'active': true,
      },
      {
        'id': '1005',
        'fullName': 'Ким Ольга',
        'position': 'Инженер-конструктор',
        'department': 'Конструкторский отдел',
        'pin': '5555',
        'active': true,
      },
      {
        'id': '1006',
        'fullName': 'Николаев Максим',
        'position': 'Техник',
        'department': 'Производственно-технический отдел',
        'pin': '6666',
        'active': false,
      },
    ];

    final batch = db.batch();

    for (final employee in employees) {
      final id = employee['id'] as String;
      final ref = db.collection('employees').doc(id);

      batch.set(ref, {
        'fullName': employee['fullName'],
        'position': employee['position'],
        'department': employee['department'],
        'pin': employee['pin'],
        'active': employee['active'],
      });
    }

    await batch.commit();
  }
}