import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = "registration_requests";

  // The three main collections to check
  final List<String> _userCollections = ['students', 'faculty', 'staff'];

  Future<bool> registerUser({
    required String nationalId,
    required String universityId, // Renamed from studentId to be more generic
    required String email,
  }) async {
    try {
      bool userExists = false;

      // Search through all collections for this ID
      for (String col in _userCollections) {
        QuerySnapshot userCheck = await _db
            .collection(col)
            .where('ID', isEqualTo: universityId.toUpperCase())
            .limit(1)
            .get();

        if (userCheck.docs.isNotEmpty) {
          userExists = true;
          break; // Stop searching once we find them!
        }
      }

      // If the ID isn't in ANY table, reject the registration
      if (!userExists) {
        return false;
      }

      // If found, create the pending request
      await _db.collection(_collection).doc(nationalId).set({
        'nationalId': nationalId,
        'universityId': universityId.toUpperCase(),
        'email': email,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;

    } catch (e) {
      debugPrint("Signup Error: $e");
      return false;
    }
  }
}