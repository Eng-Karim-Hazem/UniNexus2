import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../model/schedule_model.dart';

class ScheduleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<ScheduleModel>> getStudentSchedule({
    required String year,
    required String section,
    required String day,
  }) async {
    try {
      // Collection name is 'schedule' as per your Firebase console image
      QuerySnapshot querySnapshot = await _db
          .collection('schedule')
          .where('year', isEqualTo: year)
          .where('section', isEqualTo: section)
          .where('day', isEqualTo: day.toLowerCase())
          .get();

      return querySnapshot.docs.map((doc) {
        return ScheduleModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      debugPrint("Firebase Error: $e");
      return [];
    }
  }
}