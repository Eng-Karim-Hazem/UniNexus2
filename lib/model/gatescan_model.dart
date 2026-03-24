class GateScan {
  final String id;        // Firestore Document ID
  final String date;      // e.g., "2026-03-18"
  final String studentId;
  final String faculty;// e.g., "ST20221328"
  final String name;      // e.g., "Abd El-Rahman Mohamed"
  final String year;
  final String note;      // e.g., "Tuition is due"
  final String status;    // e.g., "denied"
  final String time;      // e.g., "23:04:11"
  final String type;      // e.g., "student"

  GateScan({
    required this.id,
    required this.date,
    required this.studentId,
    required this.faculty,
    required this.year,
    required this.name,
    required this.note,
    required this.status,
    required this.time,
    required this.type,
  });

  factory GateScan.fromFirestore(String docId, Map<String, dynamic> data) {
    return GateScan(
      id: docId,
      date: data['date']?.toString() ?? '',
      studentId: data['id']?.toString() ?? '',
      faculty: data['faculty']?.toString() ?? '',
      year: data['year']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      note: data['note']?.toString() ?? '',
      status: data['status']?.toString() ?? 'unknown',
      time: data['time']?.toString() ?? '',
      type: data['type']?.toString() ?? '',
    );
  }
}