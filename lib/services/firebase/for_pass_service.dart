import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ForpassService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _requestCollection = "ForgotPass_request";

  // The three main collections to check
  final List<String> _userCollections = ['students', 'faculty', 'staff'];

  /// Checks if ID exists across all roles, then sends renewal request
  Future<bool> sendRenewalRequest({
    required String universityId, // Replaced emailOrId
    required String nationalId,
    required String newPassword,
  }) async {
    try {
      String? foundDocId;
      String? foundCollection;
      String? firstName;
      String? lastName;

      final String searchValue = universityId.toUpperCase();

      for (String col in _userCollections) {
        QuerySnapshot userCheck = await _db
            .collection(col)
            .where('ID', isEqualTo: searchValue)
            .limit(1)
            .get();

        if (userCheck.docs.isNotEmpty) {
          foundDocId = userCheck.docs.first.id;
          foundCollection = col;

          // Extract the user data
          final data = userCheck.docs.first.data() as Map<String, dynamic>;
          firstName = data['fName']?.toString() ?? '';
          lastName = data['lName']?.toString() ?? '';

          break;
        }
      }

      if (foundDocId == null) return false;

      await _db.collection(_requestCollection).add({
        'ID': searchValue,
        'nationalId': nationalId,
        'newPassword': newPassword,
        'fName': firstName,
        'lName': lastName,
        'fullName': '$firstName $lastName'.trim(),
        'requestDate': FieldValue.serverTimestamp(),
        'status': 'pending', // Added to match admin dashboard logic
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
  Future<List<Map<String, dynamic>>> getActiveRenewalRequests(String universityId) async {
    try {
      QuerySnapshot query = await _db
          .collection(_requestCollection)
          .where('ID', isEqualTo: universityId.toUpperCase())
          .where('isProcessed', isEqualTo: false)
          .get();

      return query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint("Error retrieving renewal data: $e");
      return [];
    }
  }
}