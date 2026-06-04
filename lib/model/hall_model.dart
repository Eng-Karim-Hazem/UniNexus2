class HallModel {
  final String building;
  final String hallCode;
  final bool isAvailable;

  // --- 1. NEW PROPERTY ADDED ---
  final bool hasError;

  HallModel({
    required this.building,
    required this.hallCode,
    required this.isAvailable,
    // --- 2. ADDED TO CONSTRUCTOR ---
    required this.hasError,
  });

  factory HallModel.fromFirestore(Map<String, dynamic> data) {
    return HallModel(
      building: (data['building'] ?? data['building '] ?? "").toString().trim(),
      hallCode: (data['hallCode'] ?? data['hallCode '] ?? "").toString().trim(),
      // Defaults to true if the field is missing
      isAvailable: data['isAvailable'] ?? true,

      // --- 3. READ FROM FIREBASE ---
      // Defaults to false so existing halls don't randomly turn yellow
      hasError: data['hasError'] ?? false,
    );
  }

  // Combines building and code, e.g., "A 303"
  String get displayName => "$building $hallCode".trim();

  // Helper getter: It is busy if it is NOT available
  bool get isBusy => !isAvailable;
}