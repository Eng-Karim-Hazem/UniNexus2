import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ForpassService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = "ForgotPass_request";

  /// Sends password renewal data to the 'password_renewals' collection
  Future<bool> sendRenewalRequest({
    required String emailOrId,
    required String nationalId,
  }) async {
    try {
      // Using add() to create a unique entry for every request
      await _db.collection(_collection).add({
        'emailOrId': emailOrId,
        'nationalId': nationalId,
        'requestDate': FieldValue.serverTimestamp(),
        'isProcessed': false,
      });
      return true;
    } catch (e) {
      debugPrint("Forgot Password Service Error: $e");
      return false;
    }
  }

  /// Returns existing renewal requests for a specific National ID
  Future<List<Map<String, dynamic>>> getActiveRenewalRequests(String nationalId) async {
    try {
      QuerySnapshot query = await _db
          .collection(_collection)
          .where('nationalId', isEqualTo: nationalId)
          .where('isProcessed', isEqualTo: false)
          .get();

      return query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint("Error retrieving renewal data: $e");
      return [];
    }
  }
}