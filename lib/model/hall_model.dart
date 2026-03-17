  class HallModel {
  final String building;
  final String hallCode;
  final String day;
  final Map<String, dynamic> schedule;

  HallModel({
    required this.building,
    required this.hallCode,
    required this.day,
    required this.schedule,
  });

  factory HallModel.fromFirestore(Map<String, dynamic> data) {
    // Standardizes keys to fix missing 'A'
    return HallModel(
      building: (data['building'] ?? data['building '] ?? "").toString().trim(),
      hallCode: (data['hallCode'] ?? data['hallCode '] ?? "").toString().trim(),
      day: (data['day'] ?? data['day '] ?? "").toString().trim(),
      schedule: data,
    );
  }

  // Combines building and code, e.g., "A 309"
  String get displayName => "$building $hallCode".trim();

  bool isBusy(String timeSlot) {
    if (timeSlot == "OFF_HOURS") return false;
    return schedule[timeSlot] == true; //
  }
}