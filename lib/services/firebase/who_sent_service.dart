import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/who_sent_model.dart';

class WhoSentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<WhoSentModel?> getSenderById(String senderId) async {
    print("WhoSentService: Searching for Student ID: '$senderId'");

    if (senderId.isEmpty) return null;

    try {
      // METHOD 1: Direct Document Lookup
      // (Used if the senderId passed IS the document name)
      DocumentSnapshot doc = await _db.collection('students').doc(senderId).get();
      if (doc.exists && doc.data() != null) {
        print("WhoSentService: Found student by Document ID");
        return WhoSentModel.fromMap(doc.data() as Map<String, dynamic>);
      }

      // METHOD 2: Query by 'ID' field
      // (Used if the senderId passed is the 'ST202...' ID string, not the doc name)
      QuerySnapshot query = await _db
          .collection('students')
          .where('ID', isEqualTo: senderId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        print("WhoSentService: Found student by Field 'ID'");
        return WhoSentModel.fromMap(query.docs.first.data() as Map<String, dynamic>);
      }

      print("WhoSentService: Student not found in DB.");
      return null;
    } catch (e) {
      print("WhoSentService Error: $e");
      return null;
    }
  }
}