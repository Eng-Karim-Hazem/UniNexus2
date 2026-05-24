import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = "registration_requests";
  final List<String> _userCollections = ['students', 'faculty', 'staff'];

  /// Registers a user and returns a status string indicating the result.
  Future<String> registerUser({
    required String nationalId,
    required String universityId,
    required String email,
  }) async {
    try {
      final targetId = universityId.trim().toUpperCase();
      final targetEmail = email.trim().toLowerCase();
      final targetNationalId = nationalId.trim();

      DocumentSnapshot? foundUserDoc;
      String? foundRole;

      // Phase 1: Search through all collections just by University ID first
      for (String col in _userCollections) {
        QuerySnapshot idCheck = await _db
            .collection(col)
            .where('ID', isEqualTo: targetId)
            .limit(1)
            .get();

        if (idCheck.docs.isNotEmpty) {
          foundUserDoc = idCheck.docs.first;
          foundRole = col;
          break;
        }
      }

      // If the University ID doesn't exist anywhere
      if (foundUserDoc == null) {
        return 'user_not_found';
      }

      final userData = foundUserDoc.data() as Map<String, dynamic>;
      final storedEmail = (userData['email'] ?? '').toString().trim().toLowerCase();
      final storedNationalId = (userData['nID'] ?? '').toString().trim();

      // Phase 2: Verify if the fields match the records found
      if (storedEmail != targetEmail) {
        return 'email_mismatch';
      }
      if (storedNationalId != targetNationalId) {
        return 'national_id_mismatch';
      }

      // Everything matches perfectly! Proceed to save the request
      final firstName = userData['fName']?.toString() ?? '';
      final lastName = userData['lName']?.toString() ?? '';

      await _db.collection(_collection).doc(targetNationalId).set({
        'nationalId': targetNationalId,
        'ID': targetId,
        'email': targetEmail,
        'fName': firstName,
        'lName': lastName,
        'fullName': '$firstName $lastName'.trim(),
        'userRole': foundRole,
        'status': 'pending',
        'isProcessed': false,
        'requestDate': FieldValue.serverTimestamp(),
      });

      return 'success';

    } catch (e) {
      debugPrint("Signup Error: $e");
      return 'error';
    }
  }
}