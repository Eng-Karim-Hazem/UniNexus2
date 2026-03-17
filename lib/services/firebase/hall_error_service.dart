import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/hall_error_model.dart';

class HallErrorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> submitError(HallErrorModel report) async {
    try {
      // Access the HallErrors collection and add the report
      // report.toFirestore() now includes the 'department' and the combined 'hallName'
      await _db.collection('HallErrors').add(report.toFirestore());
    } catch (e) {
      throw Exception("Failed to submit report: $e");
    }
  }
}