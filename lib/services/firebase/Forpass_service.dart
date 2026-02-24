import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ForpassService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _requestCollection = "ForgotPass_request";
  final String _userCollection = "students"; // Your main student/user table

  /// Checks if ID exists and matches email, then sends renewal request
  Future<bool> sendRenewalRequest({
    required String emailOrId,
    required String nationalId,
  }) async {
    try {
      // 1. Check if the Student ID exists in the system
      QuerySnapshot userCheck = await _db
          .collection(_userCollection)
          .where('ID', isEqualTo: emailOrId) // Assuming field is named 'id' or 'studentId'
          .limit(1)
          .get();

      if (userCheck.docs.isEmpty) {
        return false; // This ID doesn't exist in the users table
      }

      // 3. If everything is valid, add to ForgotPass_request collection
      await _db.collection(_requestCollection).add({
        'emailOrId': emailOrId,
        'nationalId': nationalId,
        'requestDate': FieldValue.serverTimestamp(),
        'isProcessed': false,
        'userDocRef': userCheck.docs.first.id, // Reference to the original user
      });

      return true;
    } catch (e) {
      debugPrint("Forgot Password Service Error: $e");
      return false;
    }
  }

  /// Returns existing renewal requests for a specific ID
  Future<List<Map<String, dynamic>>> getActiveRenewalRequests(String emailOrId) async {
    try {
      QuerySnapshot query = await _db
          .collection(_requestCollection)
          .where('emailOrId', isEqualTo: emailOrId)
          .where('isProcessed', isEqualTo: false)
          .get();

      return query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint("Error retrieving renewal data: $e");
      return [];
    }
  }
}