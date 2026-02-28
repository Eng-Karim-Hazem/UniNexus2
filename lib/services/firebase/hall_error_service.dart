import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/hall_error_model.dart';

class HallErrorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> submitError(HallErrorModel report) async {
    try {
      // Access the HallErrors collection
      await _db.collection('HallErrors').add(report.toFirestore());
    } catch (e) {
      throw Exception("Failed to submit report: $e");
    }
  }
}