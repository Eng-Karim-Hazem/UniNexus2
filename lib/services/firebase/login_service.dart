import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/student_model.dart';
import '../../model/faculty_model.dart';
import '../../model/staff_model.dart';

enum LoginResult { success, userNotFound, passwordMismatch, invalidPrefix, signUpRequired, error }
enum UserType { student, faculty, staff }

class LoginService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> login(String code, String password) async {
    try {
      final cleanCode = code.toUpperCase().trim();
      final cleanPassword = password.trim();

      if (cleanCode.length < 2) return {'status': LoginResult.invalidPrefix};
      final prefix = cleanCode.substring(0, 2);

      switch (prefix) {
        case 'ST': return await _loginStudent(cleanCode, cleanPassword);
        case 'FA': return await _loginFaculty(cleanCode, cleanPassword);
        case 'MN':
        case 'SC':
        case 'AD': return await _loginStaff(cleanCode, cleanPassword);
        default: return {'status': LoginResult.invalidPrefix};
      }
    } catch (e) {
      return {'status': LoginResult.error};
    }
  }

  Future<Map<String, dynamic>> _loginStudent(String code, String password) async {
    final query = await _firestore.collection('students').where('ID', isEqualTo: code).limit(1).get();
    if (query.docs.isEmpty) return {'status': LoginResult.userNotFound};

    final docData = query.docs.first.data();
    final student = Student.fromJson(docData);

    if (student.pass != password) return {'status': LoginResult.passwordMismatch};
    if (!student.app) return {'status': LoginResult.signUpRequired};

    return {
      'status': LoginResult.success,
      'userData': docData, // Returning the full map for individual variable storage
      'userType': UserType.student,
    };
  }

  Future<Map<String, dynamic>> _loginFaculty(String code, String password) async {
    final query = await _firestore.collection('faculty').where('ID', isEqualTo: code).limit(1).get();
    if (query.docs.isEmpty) return {'status': LoginResult.userNotFound};

    final docData = query.docs.first.data();
    final faculty = Faculty.fromJson(docData);

    if (faculty.pass != password) return {'status': LoginResult.passwordMismatch};

    return {
      'status': LoginResult.success,
      'userData': docData,
      'userType': UserType.faculty,
    };
  }

  Future<Map<String, dynamic>> _loginStaff(String code, String password) async {
    final query = await _firestore.collection('staff').where('ID', isEqualTo: code).limit(1).get();
    if (query.docs.isEmpty) return {'status': LoginResult.userNotFound};

    final docData = query.docs.first.data();
    final staff = Staff.fromJson(docData);

    if (staff.pass != password) return {'status': LoginResult.passwordMismatch};

    return {
      'status': LoginResult.success,
      'userData': docData,
      'userType': UserType.staff,
    };
  }
}