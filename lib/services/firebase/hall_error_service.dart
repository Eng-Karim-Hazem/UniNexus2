import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/hall_error_model.dart';

class HallErrorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 1. FIXED HALL EXISTENCE CHECK ---
  Future<bool> doesHallExist(String building, String hallCode) async {
    try {
      // Because your database keys sometimes have trailing spaces (like 'building '),
      // we fetch the halls and filter them in Dart to safely strip the spaces.
      final query = await _db.collection('halls').get();

      return query.docs.any((doc) {
        final data = doc.data();

        // Using the exact same robust extraction from your HallModel
        final String dbBuilding = (data['building'] ?? data['building '] ?? "").toString().trim();
        final String dbHallCode = (data['hallCode'] ?? data['hallCode '] ?? "").toString().trim();

        return dbBuilding.toUpperCase() == building.trim().toUpperCase() &&
            dbHallCode == hallCode.trim();
      });
    } catch (e) {
      print("Database Error checking hall: $e");
      return false;
    }
  }

  // --- 2. FIXED DUPLICATE CHECK (Ignores 'fixed' errors) ---
  Future<bool> isErrorAlreadyReported(String fullHallName, String errorType) async {
    try {
      // Querying only by hallName avoids Firebase Composite Index requirements
      final query = await _db.collection('HallErrors')
          .where('hallName', isEqualTo: fullHallName)
          .get();

      return query.docs.any((doc) {
        final data = doc.data();
        final String dbErrorType = data['errorType']?.toString() ?? "";
        final String dbStatus = data['status']?.toString().toLowerCase() ?? "pending";

        // It's only a duplicate if the error type matches AND it hasn't been fixed yet!
        return dbErrorType == errorType && dbStatus != 'fixed';
      });
    } catch (e) {
      print("Error checking duplicates: $e");
      return false;
    }
  }

  // --- 3. SUBMIT ERROR ---
  Future<void> submitError(HallErrorModel report) async {
    try {
      // Convert to map and automatically attach a "pending" status for the duplicate checker
      Map<String, dynamic> reportData = report.toFirestore();
      reportData['status'] = 'pending';

      await _db.collection('HallErrors').add(reportData);
    } catch (e) {
      throw Exception("Failed to submit report: $e");
    }
  }
}