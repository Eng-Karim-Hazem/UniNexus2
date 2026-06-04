import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
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
  Future<void> submitError(HallErrorModel report, String targetBuilding, String targetCode) async {
    try {
      // 1. Save the report to the HallErrors collection
      await _db.collection('HallErrors').add({
        'attachment': report.attachment,
        'department': report.department,
        'description': report.description,
        'errorType': report.errorType,
        'hallName': report.hallName,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      debugPrint("✅ Saved to HallErrors. Now searching halls for: Building '$targetBuilding', Code '$targetCode'");

      // 2. Find the exact hall in the 'halls' database
      QuerySnapshot hallQuery = await _db
          .collection('halls')
          .where('building', isEqualTo: targetBuilding)
          .where('hallCode', isEqualTo: targetCode)
          .limit(1)
          .get();

      if (hallQuery.docs.isNotEmpty) {
        // 3. Flip the hasError flag to true!
        await hallQuery.docs.first.reference.update({
          'hasError': true,
        });
        debugPrint("✅ Hall found and hasError updated to true!");
      } else {
        // If you see this in your console, your Firestore fields don't match the query!
        debugPrint("❌ ERROR: Could not find this hall in the 'halls' collection. The light will stay green.");
      }

    } catch (e) {
      throw Exception("Failed to submit error: $e");
    }
  }
}