class Staff {
  final String id;
  final String fName;
  final String lName;
  final String pNum;
  final String email;
  final String nID;
  final String department;
  final String prosition;
  final String pass;
  final String photo;
  final int workDays;
  final String type;

  Staff({
    required this.id,
    required this.fName,
    required this.lName,
    required this.pNum,
    required this.email,
    required this.nID,
    required this.department,
    required this.prosition,
    required this.pass,
    required this.photo,
    required this.workDays,
    required this.type,
  });

  // From JSON
  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['ID'] ?? '',
      fName: json['fName'] ?? '',
      lName: json['lName'] ?? '',
      pNum: json['pNum'] ?? '',
      email: json['email'] ?? '',
      nID: json['nID'] ?? '',
      department: json['department'] ?? '',
      prosition: json['prosition'] ?? '',
      pass: json['pass'] ?? '',
      photo: json['photo'] ?? '',
      workDays: json['workDays'] ?? 0,
      type: json['type'] ?? '',
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'fName': fName,
      'lName': lName,
      'pNum': pNum,
      'email': email,
      'nID': nID,
      'department': department,
      'prosition': prosition,
      'pass': pass,
      'photo': photo,
      'workDays': workDays,
      'type': type,
    };
  }
}