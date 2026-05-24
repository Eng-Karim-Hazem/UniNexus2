import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/qna_model.dart';

class QnAService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetches QnA posts that match the subjects of a specific year
  Stream<List<Map<String, dynamic>>> streamQnAByYear(int year) {
    return _db
        .collection('subjects')
        .where('year', isEqualTo: year)
        .snapshots()
        .asyncMap((subjectSnapshot) async {

      List<String> validSubjects = subjectSnapshot.docs
          .map((doc) => doc['subName'].toString())
          .toList();

      if (validSubjects.isEmpty) return [];

      QuerySnapshot qnaSnapshot = await _db
          .collection('QnA')
          .where('subject', whereIn: validSubjects)
          .get();

      // --- UPDATED: Added docId mapping so we can target it for deletion ---
      return qnaSnapshot.docs.map((doc) => {
        ...doc.data() as Map<String, dynamic>,
        'docId': doc.id
      }).toList();
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
        String? docSubject = data['subject']?.toString();
        bool subjectMatch = subjects.contains(docSubject);

        var answer = data['answer'];
        bool isUnanswered = (answer == null || answer.toString().trim().isEmpty);

        return subjectMatch && isUnanswered;
      })
          .toList();
    });
  }

  Future<void> submitAnswer(String docId, String answer, String rName) async {
    await _db.collection('QnA').doc(docId).update({
      'answer': answer,
      'rName': rName,
    });
  }

  // --- NEW: Delete Question Method ---
  Future<void> deleteQuestion(String docId) async {
    await _db.collection('QnA').doc(docId).delete();
  }

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