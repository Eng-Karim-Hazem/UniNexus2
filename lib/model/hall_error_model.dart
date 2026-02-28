import 'dart:convert';

class HallErrorModel {
  final String hallName;
  final String errorType;
  final String description;
  final String? attachment; // Attachment stored as base64 string
  final DateTime timestamp;

  HallErrorModel({
    required this.hallName,
    required this.errorType,
    required this.description,
    this.attachment,
    required this.timestamp,
  });

  // Converts the model into a Map to send to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'hallName': hallName,         // From "Hall name" input
      'errorType': errorType,       // From "Error Type" dropdown
      'description': description,   // From "Description" field
      'attachment': attachment, // From "Attachment" as Base64
      'timestamp': timestamp,       // To track when the error was reported
    };
  }

  // Helper factory if you ever need to read an error report back from Firestore
  factory HallErrorModel.fromFirestore(Map<String, dynamic> data) {
    return HallErrorModel(
      hallName: data['hallName'] ?? '',
      errorType: data['errorType'] ?? '',
      description: data['description'] ?? '',
      attachment: data['attachment'],
      timestamp: (data['timestamp'] as dynamic).toDate(),
    );
  }
}