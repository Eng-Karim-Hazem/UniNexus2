import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../model/who_sent_model.dart';

class WhoSentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetches a student's profile details based on their unique ID (e.g., ST202...).
  /// It checks both the document name and the 'ID' field for robustness.
  Future<WhoSentModel?> getSenderById(String senderId) async {
    final String trimmedId = senderId.trim();
    if (trimmedId.isEmpty) return null;

    try {
      // METHOD 1: Direct Document Lookup
      // (Used if the senderId passed IS the document name)
      final DocumentSnapshot doc = await _db.collection('students').doc(trimmedId).get();
      if (doc.exists && doc.data() != null) {
        return WhoSentModel.fromMap(doc.data() as Map<String, dynamic>);
      }

      // METHOD 2: Query by 'ID' field
      // (Used if the senderId passed is the 'ST202...' ID string, not the doc name)
      final QuerySnapshot query = await _db
          .collection('students')
          .where('ID', isEqualTo: trimmedId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return WhoSentModel.fromMap(query.docs.first.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      // Using debugPrint for production-safe logging
      debugPrint("WhoSentService Error: $e");
      return null;
    }
  }
}
