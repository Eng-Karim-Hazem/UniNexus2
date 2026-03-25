import 'package:cloud_firestore/cloud_firestore.dart';

enum NoticeTargetType { individual, group, specialization, program }

class NoticeModel {
  final String? docId;
  final String title;
  final String description;
  final NoticeTargetType targetType;
  final String targetValue;
  final List<String> recipientIds;
  final DateTime createdAt;
  final String sentBy;

  const NoticeModel({
    this.docId,
    required this.title,
    required this.description,
    required this.targetType,
    required this.targetValue,
    required this.recipientIds,
    required this.createdAt,
    required this.sentBy,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': targetType.name,
      'targetValue': targetValue,
      'recipientIds': recipientIds,
      'date': Timestamp.fromDate(createdAt),
      'sentBy': sentBy,
      // Backward-compatible fields for existing schema screenshots.
      'ID': recipientIds.isNotEmpty ? recipientIds.first : '',
    };
  }

  factory NoticeModel.fromFirestore(Map<String, dynamic> data, String id) {
    final Timestamp? timestamp = data['date'] as Timestamp?;

    return NoticeModel(
      docId: id,
      title: (data['title'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      targetType: NoticeTargetType.values.firstWhere(
            (type) => type.name == (data['type'] ?? '').toString(),
        orElse: () => NoticeTargetType.individual,
      ),
      targetValue: (data['targetValue'] ?? '').toString(),
      recipientIds: List<String>.from(data['recipientIds'] ?? const []),
      createdAt: timestamp?.toDate() ?? DateTime.now(),
      sentBy: (data['sentBy'] ?? '').toString(),
    );
  }
}