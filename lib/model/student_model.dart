// student_model.dart

class Student {
  final String id;
  final String fName;
  final String lName;
  final String year;
  final String faculty;
  final String section;  // CORRECTED to int (was String)
  final String pNum;
  final String photo;
  final String email;
  final String pass;
  final bool app;    // CORRECTED to bool (was String)
  final bool entry;  // CORRECTED to bool (was String)
  final String note;

  Student({
    required this.id,
    required this.fName,
    required this.lName,
    required this.year,
    required this.faculty,
    required this.section,
    required this.pNum,
    required this.photo,
    required this.email,
    required this.pass,
    required this.app,
    required this.entry,
    required this.note,
  });

  // From JSON
  factory Student.fromJson(Map<String, dynamic> json) {

    return Student(
      id: json['ID'] ?? '',
      fName: json['fName'] ?? '',
      lName: json['lName'] ?? '',
      year: (json['year']),
      faculty: json['faculty'] ?? '',
      section: (json['section']),
      pNum: json['pNum'] ?? '',
      photo: json['photo'] ?? '',
      email: json['email'] ?? '',
      pass: json['pass'] ?? '',
      // Safely parse booleans, defaulting to false if null/missing
      app: json['app'] == true,
      entry: json['entry'] == true,
      note: json['note'] ?? '',
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'fName': fName,
      'lName': lName,
      'year': year,
      'faculty': faculty,
      'section': section,
      'pNum': pNum,
      'photo': photo,
      'email': email,
      'pass': pass,
      'app': app,
      'entry': entry,
      'note': note,
    };
  }
}