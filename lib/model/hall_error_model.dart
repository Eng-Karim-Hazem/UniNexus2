class HallErrorModel {
  final String hallName;
  final String department; // --- NEW FIELD ---
  final String errorType;
  final String description;
  final String? attachment; // Attachment stored as base64 string
  final DateTime timestamp;

  HallErrorModel({
    required this.hallName,
    required this.department, // --- REQUIRED IN CONSTRUCTOR ---
    required this.errorType,
    required this.description,
    this.attachment,
    required this.timestamp,
  });

  // Converts the model into a Map to send to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'hallName': hallName,
      'department': department, // --- ADDED TO MAP ---
      'errorType': errorType,
      'description': description,
      'attachment': attachment,
      'timestamp': timestamp,
    };
  }

  // Helper factory if you ever need to read an error report back from Firestore
  factory HallErrorModel.fromFirestore(Map<String, dynamic> data) {
    return HallErrorModel(
      hallName: data['hallName'] ?? '',
      department: data['department'] ?? '', // --- ADDED TO FACTORY ---
      errorType: data['errorType'] ?? '',
      description: data['description'] ?? '',
      attachment: data['attachment'],
      timestamp: (data['timestamp'] as dynamic).toDate(),
    );
  }
}