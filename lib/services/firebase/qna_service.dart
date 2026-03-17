import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/qna_model.dart';

class QnAService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetches QnA posts that match the subjects of a specific year
  Stream<List<Map<String, dynamic>>> streamQnAByYear(int year) {
    // 1. Listen to the subjects collection filtered by year
    return _db
        .collection('subjects')
        .where('year', isEqualTo: year)
        .snapshots()
        .asyncMap((subjectSnapshot) async {

      // 2. Map the documents to a list of subject names (e.g., ["IOT", "Math"])
      List<String> validSubjects = subjectSnapshot.docs
          .map((doc) => doc['subName'].toString())
          .toList();

      if (validSubjects.isEmpty) return [];

      // 3. Query QnA collection where 'subject' is in our validSubjects list
      QuerySnapshot qnaSnapshot = await _db
          .collection('QnA')
          .where('subject', whereIn: validSubjects)
          .get();

      return qnaSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> streamUnansweredQnA(List<String> subjects) {
    if (subjects.isEmpty) return Stream.value([]);

    return _db
        .collection('QnA')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {...doc.data(), 'docId': doc.id})
          .where((data) {
        // 1. Check if the subject matches the user's assigned subjects
        String? docSubject = data['subject']?.toString();
        bool subjectMatch = subjects.contains(docSubject);

        // 2. Check if the answer is empty or null
        var answer = data['answer'];
        bool isUnanswered = (answer == null || answer.toString().trim().isEmpty);

        return subjectMatch && isUnanswered;
      })
          .toList();
    });
  }

  // Updates the document with the answer and the responder's name
  Future<void> submitAnswer(String docId, String answer, String rName) async {
    await _db.collection('QnA').doc(docId).update({
      'answer': answer,
      'rName': rName,
    });
  }

  // Used for the Dropdown in the request screen
  Stream<List<String>> streamSubjectsByYear(int year) {
    return _db
        .collection('subjects')
        .where('year', isEqualTo: year)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => doc['subName'].toString())
        .toList());
  }

  Future<void> submitQuestion(QnAModel qna) async {
    await _db.collection('QnA').add(qna.toFirestore());
  }
}