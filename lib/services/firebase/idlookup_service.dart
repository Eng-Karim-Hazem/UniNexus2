import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/student_model.dart';

class IDLookupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Student?> searchStudentById(String id) async {
    try {
      final querySnapshot = await _db
          .collection('students')
          .where('ID', isEqualTo: id) //
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Student.fromJson(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}