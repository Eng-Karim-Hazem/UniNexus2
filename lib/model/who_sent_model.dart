class WhoSentModel {
  final String id;
  final String fName;
  final String lName;
  final String faculty;
  final String year;
  final String email;
  final String phone;
  final String photoUrl;

  WhoSentModel({
    required this.id,
    required this.fName,
    required this.lName,
    required this.faculty,
    required this.year,
    required this.email,
    required this.phone,
    required this.photoUrl,
  });

  // Factory to create from Firestore data
  factory WhoSentModel.fromMap(Map<String, dynamic> data) {
    return WhoSentModel(
      // Maps 'ID' from Firestore to 'id'
      id: data['ID']?.toString() ?? '',

      // Maps 'fName' and 'lName'
      fName: data['fName']?.toString() ?? '',
      lName: data['lName']?.toString() ?? '',

      // Maps 'faculty'
      faculty: data['faculty']?.toString() ?? '',

      // Maps 'year' (handles if it's stored as Number or String)
      year: data['year']?.toString() ?? '',

      // Maps 'email'
      email: data['email']?.toString() ?? '',

      // Maps 'pNum' to 'phone'
      phone: data['pNum']?.toString() ?? '',

      // Maps 'photo' to 'photoUrl'
      photoUrl: data['photo']?.toString() ?? '',
    );
  }

  String get fullName => "$fName $lName";
}