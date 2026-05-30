import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/employee.dart';

class FirebaseEmployeeRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Employee?> login({
    required String employeeId,
    required String pin,
  }) async {
    final doc = await _db.collection('employees').doc(employeeId).get();

    if (!doc.exists) return null;

    final data = doc.data()!;

    final bool active = data['active'] == true;
    final String savedPin = data['pin']?.toString() ?? '';

    if (!active) return null;
    if (savedPin != pin) return null;

    return Employee(
      id: employeeId,
      fullName: data['fullName'] ?? '',
      position: data['position'] ?? '',
      department: data['department'] ?? '',
      pin: savedPin,
      active: active,
    );
  }
}