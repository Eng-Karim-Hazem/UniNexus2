import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/student_model.dart';

class IDLookupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Existing search method
  Future<Student?> searchStudentById(String id) async {
    try {
      final querySnapshot = await _db
          .collection('students')
          .where('ID', isEqualTo: id.toUpperCase())//touppercase
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

  // NEW: Method to get all students for the automatic list
  Future<List<Student>> getDeniedStudents() async {
    try {
      final querySnapshot = await _db
          .collection('students')
          .where('entry', isEqualTo: false)
          .get();

      return querySnapshot.docs
          .map((doc) => Student.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching denied students: $e");
      return [];
    }
  }
}