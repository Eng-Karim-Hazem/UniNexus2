import 'package:cloud_firestore/cloud_firestore.dart';

class QnAModel {
  final String title; // Added title
  final String? answer;
  final String question;
  final String rName;
  final String sEmail;
  final String sName;
  final String subject;
  final String ID;

  QnAModel({
    required this.title,
    this.answer = "",
    required this.question,
    this.rName = "",
    required this.sEmail,
    required this.sName,
    required this.subject,
    required this.ID,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'ID': ID,
      'answer': answer,
      'question': question,
      'rName': rName,
      'sEmail': sEmail,
      'sName': sName,
      'subject': subject,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}