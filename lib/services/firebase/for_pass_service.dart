import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ForpassService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _requestCollection = "ForgotPass_request";

  // The three main collections to check
  final List<String> _userCollections = ['students', 'faculty', 'staff'];

  /// Checks if ID exists, matches National ID, ensures password is new, then sends request
  Future<String> sendRenewalRequest({
    required String universityId,
    required String nationalId,
    required String newPassword,
  }) async {
    try {
      DocumentSnapshot? foundUserDoc;
      String? foundCollection;

      final String targetId = universityId.trim().toUpperCase();
      final String targetNationalId = nationalId.trim();

      // Phase 1: Search through all collections by University ID
      for (String col in _userCollections) {
        QuerySnapshot userCheck = await _db
            .collection(col)
            .where('ID', isEqualTo: targetId)
            .limit(1)
            .get();

        if (userCheck.docs.isNotEmpty) {
          foundUserDoc = userCheck.docs.first;
          foundCollection = col;
          break;
        }
      }

      // If the University ID doesn't exist anywhere
      if (foundUserDoc == null) return 'user_not_found';

      final data = foundUserDoc.data() as Map<String, dynamic>;
      final storedNationalId = (data['nID'] ?? '').toString().trim();

      // Assumes your database field for the password is 'pass'
      final storedPassword = (data['pass'] ?? '').toString();

      // Phase 2: Verify if the National ID matches
      if (storedNationalId != targetNationalId) {
        return 'national_id_mismatch';
      }

      // Phase 3: Check if the requested new password is the exact same as the current one
      if (newPassword == storedPassword) {
        return 'same_as_old_password';
      }

      // Everything matches and password is new! Proceed to save the request
      // Mapping fields directly to match the screenshot schema template values
      await _db.collection(_requestCollection).add({
        'emailOrId': targetId, // Map to emailOrId as required by the database structure
        'nationalId': targetNationalId,
        'newPassword': newPassword,
        'requestDate': FieldValue.serverTimestamp(),
        'status': 'pending',
        'isProcessed': false,
        'userDocRef': foundUserDoc.id,
        'userRole': foundCollection,
      });

      return 'success';
    } catch (e) {
      debugPrint("Forgot Password Service Error: $e");
      return 'error';
    }
  }

  /// Returns existing renewal requests for a specific ID
  Future<List<Map<String, dynamic>>> getActiveRenewalRequests(String universityId) async {
    try {
      QuerySnapshot query = await _db
          .collection(_requestCollection)
          .where('emailOrId', isEqualTo: universityId.toUpperCase()) // Aligned query field
          .where('isProcessed', isEqualTo: false)
          .get();

      return query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint("Error retrieving renewal data: $e");
      return [];
    }
  }
}