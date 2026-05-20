class HallModel {
  final String building;
  final String hallCode;
  final bool isAvailable;

  HallModel({
    required this.building,
    required this.hallCode,
    required this.isAvailable,
  });

  factory HallModel.fromFirestore(Map<String, dynamic> data) {
    return HallModel(
      building: (data['building'] ?? data['building '] ?? "").toString().trim(),
      hallCode: (data['hallCode'] ?? data['hallCode '] ?? "").toString().trim(),
      // Defaults to true if the field is missing
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  // Combines building and code, e.g., "A 303"
  String get displayName => "$building $hallCode".trim();

  // Helper getter: It is busy if it is NOT available
  bool get isBusy => !isAvailable;
}