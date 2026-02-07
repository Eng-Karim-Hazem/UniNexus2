import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = "registration_requests";

  Future<bool> registerUser({
    required String nationalId,
    required String studentId,
    required String email,
  }) async {
    try {
      // Using National ID as the document ID for uniqueness
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