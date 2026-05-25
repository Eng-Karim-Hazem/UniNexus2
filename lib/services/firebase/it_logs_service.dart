import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class ITLogService {
  // PASTE YOUR NEW GOOGLE SCRIPT URL HERE
  static const String _sheetUrl = "https://script.google.com/macros/s/AKfycbxYcaAugk8QHUYzG0LM4iX9sFKyNX_uo4fmTivEj4wrhO-j8ic8yPEQlBuQPy-wqyxHoQ/exec";

  static Future<void> logAction(String message) async {
    // 1. SAVE TO FIREBASE
    try {
      await FirebaseFirestore.instance.collection('IT_Logs').add({
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Firebase Log Error: $e");
    }

    // 2. SAVE TO GOOGLE SHEETS
    try {
      final Map<String, dynamic> payload = {
        "message": message,
      };

      // --- THE FLUTTER 500 FIX ---
      // We build a manual request so we can disable redirects
      final request = http.Request('POST', Uri.parse(_sheetUrl))
        ..followRedirects = false // This stops Flutter from crashing Google's servers
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(payload);

      final http.Client client = http.Client();
      final http.StreamedResponse streamedResponse = await client.send(request);
      final http.Response response = await http.Response.fromStream(streamedResponse);

      client.close(); // Always close the client to prevent memory leaks

      // If we disabled redirects, Google will hand us the 302 directly, which means success!
      if (response.statusCode == 302 || response.statusCode == 200) {
        print("SUCCESS: Log successfully written to Google Sheets!");
      } else {
        print("HTTP ERROR: Failed to reach Google Sheets. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("FLUTTER HTTP ERROR: $e");
    }
  }
}