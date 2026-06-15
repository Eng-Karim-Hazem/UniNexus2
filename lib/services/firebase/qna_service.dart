import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/qna_model.dart';

class QnAService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetches QnA posts that match both the year and the faculty code prefix of the subject id
  Stream<List<Map<String, dynamic>>> streamQnAByYear(int year, String faculty) {
    return _db
        .collection('subjects')
        .where('year', isEqualTo: year)
        .snapshots()
        .asyncMap((subjectSnapshot) async {

      // Filter locally to ensure the subject ID matches the student's faculty prefix
      List<String> validSubjects = subjectSnapshot.docs
          .where((doc) {
        String subId = doc['subID']?.toString() ?? "";
        return subId.toUpperCase().startsWith(faculty.toUpperCase());
      })
          .map((doc) => doc['subName'].toString())
          .toList();

      if (validSubjects.isEmpty) return [];

      QuerySnapshot qnaSnapshot = await _db
          .collection('QnA')
          .where('subject', whereIn: validSubjects)
          .get();

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

  Future<void> deleteQuestion(String docId) async {
    await _db.collection('QnA').doc(docId).delete();
  }

  Future<void> updateQuestion(String docId, String newCourse, String newSubject, String newQuestion) async {
    try {
      await FirebaseFirestore.instance.collection('QnA').doc(docId).update({
        'subject': newCourse,
        'title': newSubject,
        'question': newQuestion,
      });
    } catch (e) {
      throw Exception("Failed to update question: $e");
    }
  }

  // Streams available dropdown choices matching both the year and the faculty prefix code
  Stream<List<String>> streamSubjectsByYear(int year, String faculty) {
    return _db
        .collection('subjects')
        .where('year', isEqualTo: year)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .where((doc) {
      String subId = doc['subID']?.toString() ?? "";
      return subId.toUpperCase().startsWith(faculty.toUpperCase());
    })
        .map((doc) => doc['subName'].toString())
        .toList());
  }

  Future<void> submitQuestion(QnAModel qna) async {
    await _db.collection('QnA').add(qna.toFirestore());
  }

  Stream<List<Map<String, dynamic>>> streamAllQnAForSubjects(List<String> subjects) {
    if (subjects.isEmpty) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('QnA')
        .where('subject', whereIn: subjects)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      data['docId'] = doc.id;
      return data;
    }).toList());
  }
}