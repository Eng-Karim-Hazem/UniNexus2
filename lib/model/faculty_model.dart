class Faculty {
  final String id;
  final String fName;
  final String faculty;
  final String lName;
  final String pNum;
  final String nID;
  final String email;
  final String pass;
  final String photo;
  final List<String> subjects;
  final int workDays;
  final String subID; // The target of the fix

  Faculty({
    required this.id,
    required this.fName,
    required this.faculty,
    required this.lName,
    required this.pNum,
    required this.nID,
    required this.email,
    required this.pass,
    required this.photo,
    required this.subjects,
    required this.workDays,
    required this.subID,
  });

  // From JSON
  factory Faculty.fromJson(Map<String, dynamic> json) {
    List<String> subjectsList = [];

    // Helper function to safely convert any number type (int, double, num) to int, defaulting to 0
    int safeParseInt(dynamic value) => (value is num) ? value.toInt() : 0;

    // Helper function to safely convert any type (int, num, String) to String
    String safeParseString(dynamic value) => value?.toString() ?? '';

    // Handle different JSON formats for subjects
    if (json['subjects'] != null) {
      if (json['subjects'] is List) {
        subjectsList = List<String>.from(json['subjects']);
      } else if (json['subjects'] is String) {
        final subjectsStr = json['subjects'] as String;
        if (subjectsStr.isNotEmpty) {
          subjectsList = subjectsStr.split(',').map((s) => s.trim()).toList();
        }
      }
    }

    return Faculty(
      id: json['ID'] ?? '',
      fName: json['fName'] ?? '',
      faculty: json['faculty'] ?? '',
      lName: json['lName'] ?? '',
      pNum: json['pNum'] ?? '',
      nID: json['nID'] ?? '',
      email: json['email'] ?? '',
      pass: json['pass'] ?? '',
      photo: json['photo'] ?? '',
      subjects: subjectsList,
      // Fix 1: Robustly parse workDays as Int
      workDays: safeParseInt(json['workDays']),
      // Fix 2: Robustly parse subID as String
      subID: safeParseString(json['subID']),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'fName': fName,
      'faculty': faculty,
      'lName': lName,
      'pNum': pNum,
      'nID': nID,
      'email': email,
      'pass': pass,
      'photo': photo,
      'subjects': subjects,
      'workDays': workDays,
      'subID': subID,
    };
  }
}