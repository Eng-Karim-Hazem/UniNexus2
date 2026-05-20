import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = "registration_requests";

  // The three main collections to check
  final List<String> _userCollections = ['students', 'faculty', 'staff'];

  Future<bool> registerUser({
    required String nationalId,
    required String universityId,
    required String email,
  }) async {
    try {
      bool userExists = false;
      String? firstName;
      String? lastName;
      String? userRole;

      // Search through all collections for this ID
      for (String col in _userCollections) {
        QuerySnapshot userCheck = await _db
            .collection(col)
            .where('ID', isEqualTo: universityId.toUpperCase())
            .limit(1)
            .get();

        if (userCheck.docs.isNotEmpty) {
          userExists = true;
          userRole = col; // Save the collection they were found in

          // Extract the user data
          final data = userCheck.docs.first.data() as Map<String, dynamic>;
          firstName = data['fName']?.toString() ?? '';
          lastName = data['lName']?.toString() ?? '';

          break; // Stop searching once we find them!
        }
      }

      // If the ID isn't in ANY table, reject the registration
      if (!userExists) {
        return false;
      }

      // If found, create the pending request with the extracted info
      await _db.collection(_collection).doc(nationalId).set({
        'nationalId': nationalId,
        'ID': universityId.toUpperCase(),
        'email': email,
        'fName': firstName,
        'lName': lastName,
        'fullName': '$firstName $lastName'.trim(),
        'userRole': userRole,
        'status': 'pending',
        'isProcessed': false,
        'requestDate': FieldValue.serverTimestamp(),
      });
      return true;

    } catch (e) {
      debugPrint("Signup Error: $e");
      return false;
    }
  }
}