import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class ITLogService {
  // PASTE YOUR GOOGLE SCRIPT URL HERE
  static const String _sheetUrl = "https://script.google.com/macros/s/AKfycbxIBX-VE__xN6AFVdOf6QtFLyXNHj-0ams6VqXl3fXk6Yf0fLHXUvdA3G46MbLXcS4XNQ/exec";

  static Future<void> logAction(String message) async {
    // --------------------------------------------------
    // 1. SAVE TO FIREBASE (Your existing logic)
    // --------------------------------------------------
    try {
      await FirebaseFirestore.instance.collection('IT_Logs').add({
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Firebase Log Error: $e");
    }

    // --------------------------------------------------
    // 2. SAVE TO GOOGLE SHEETS (The new magic)
    // --------------------------------------------------
    try {
      final Map<String, dynamic> payload = {
        "message": message,
      };

      final response = await http.post(
        Uri.parse(_sheetUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'Success') {
          print("SUCCESS: Log successfully written to Google Sheets!");
        } else {
          print("GOOGLE SCRIPT ERROR: ${responseData['message']}");
        }
      } else {
        print("HTTP ERROR: Failed to reach Google Sheets. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("FLUTTER HTTP ERROR: $e");
    }
  }
}