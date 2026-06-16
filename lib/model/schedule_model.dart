class ScheduleModel {
  final Map<String, String> timeSlots; // Dynamic map of {"Time-Range": "Subject Name"}
  final String day;
  final String faculty;
  final String year;
  final String section;

  ScheduleModel({
    required this.timeSlots,
    required this.day,
    required this.faculty,
    required this.year,
    required this.section,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    final Map<String, String> dynamicSlots = {};
    final metadataKeys = {'day', 'faculty', 'year', 'section'};

    json.forEach((key, value) {
      if (!metadataKeys.contains(key) && value != null && value.toString().trim().isNotEmpty) {
        dynamicSlots[key] = value.toString();
      }
    });

    return ScheduleModel(
      timeSlots: dynamicSlots,
      day: json['day'] ?? '',
      faculty: json['faculty'] ?? '',
      year: json['year']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
    );
  }
}