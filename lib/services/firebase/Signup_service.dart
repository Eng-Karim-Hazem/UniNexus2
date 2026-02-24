import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = "registration_requests";
  final String _userCollection = "students"; // Your main student/user table

  Future<bool> registerUser({
    required String nationalId,
    required String studentId,
    required String email,
  }) async {
    try {
      QuerySnapshot userCheck = await _db
          .collection(_userCollection)
          .where('ID', isEqualTo: studentId) // Assuming field is named 'id' or 'studentId'
          .limit(1)
          .get();

      if (userCheck.docs.isEmpty) {
        return false; // This ID doesn't exist in the users table
      }

      await _db.collection(_collection).doc(nationalId).set({
        'nationalId': nationalId,
        'studentId': studentId,
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