import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ForpassService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _requestCollection = "ForgotPass_request";

  // The three main collections to check
  final List<String> _userCollections = ['students', 'faculty', 'staff'];

  /// Checks if ID/Email exists across all roles, then sends renewal request
  Future<bool> sendRenewalRequest({
    required String emailOrId,
    required String nationalId,
  }) async {
    try {
      String? foundDocId;
      String? foundCollection;

      // Determine if they typed an email or an ID
      final bool isEmail = emailOrId.contains('@');
      final String queryField = isEmail ? 'email' : 'ID';
      final String searchValue = isEmail ? emailOrId.toLowerCase() : emailOrId.toUpperCase();

      // Search through all collections
      for (String col in _userCollections) {
        QuerySnapshot userCheck = await _db
            .collection(col)
            .where(queryField, isEqualTo: searchValue)
            .limit(1)
            .get();

        if (userCheck.docs.isNotEmpty) {
          foundDocId = userCheck.docs.first.id;
          foundCollection = col; // Keeps track of whether they are staff/faculty/student
          break;
        }
      }

      // If not found in any table, reject the request
      if (foundDocId == null) {
        return false;
      }

      // If valid, add to ForgotPass_request collection
      await _db.collection(_requestCollection).add({
        'emailOrId': emailOrId,
        'nationalId': nationalId,
        'requestDate': FieldValue.serverTimestamp(),
        'isProcessed': false,
        'userDocRef': foundDocId,
        'userRole': foundCollection, // Helpful for admins to know who requested it!
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