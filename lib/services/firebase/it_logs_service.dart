import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ITLogService {
  static Future<void> logAction(String message) async {
    try {
      await FirebaseFirestore.instance.collection('IT_Logs').add({
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error saving log: $e");
    }
  }
}