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
    required String newPassword, // <--- Add this requirement
  }) async {
    try {
      String? foundDocId;
      String? foundCollection;

      final bool isEmail = emailOrId.contains('@');
      final String queryField = isEmail ? 'email' : 'ID';
      final String searchValue = isEmail ? emailOrId.toLowerCase() : emailOrId.toUpperCase();

      for (String col in _userCollections) {
        QuerySnapshot userCheck = await _db.collection(col).where(queryField, isEqualTo: searchValue).limit(1).get();

        if (userCheck.docs.isNotEmpty) {
          foundDocId = userCheck.docs.first.id;
          foundCollection = col;
          break;
        }
      }

      if (foundDocId == null) return false;

      await _db.collection(_requestCollection).add({
        'emailOrId': emailOrId,
        'nationalId': nationalId,
        'newPassword': newPassword, // <--- Save it to Firestore here!
        'requestDate': FieldValue.serverTimestamp(),
        'isProcessed': false,
        'userDocRef': foundDocId,
        'userRole': foundCollection,
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