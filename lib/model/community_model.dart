import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPostModel {
  String id;
  String userId;
  String userName;
  String userRole; // <--- ADDED THIS FIELD
  String userFaculty;
  String title;
  String content;
  DateTime timestamp;
  int replyCount;

  CommunityPostModel({
    this.id = '',
    required this.userId,
    required this.userName,
    required this.userRole, // <--- REQUIRED
    required this.userFaculty,
    required this.title,
    required this.content,
    required this.timestamp,
    this.replyCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userRole': userRole, // <--- SAVE ROLE
      'userFaculty': userFaculty,
      'title': title,
      'content': content,
      'timestamp': timestamp,
      'replyCount': replyCount,
    };
  }

  factory CommunityPostModel.fromMap(Map<String, dynamic> map, String docId) {
    return CommunityPostModel(
      id: docId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      userRole: map['userRole'] ?? 'Student', // <--- DEFAULT TO STUDENT IF MISSING
      userFaculty: map['userFaculty'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      replyCount: map['replyCount'] ?? 0,
    );
  }
}

// (CommunityReplyModel remains the same)
class CommunityReplyModel {
  String id;
  String userId;
  String userName;
  String content;
  DateTime timestamp;

  CommunityReplyModel({
    this.id = '',
    required this.userId,
    required this.userName,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'content': content,
      'timestamp': timestamp,
    };
  }

  factory CommunityReplyModel.fromMap(Map<String, dynamic> map, String docId) {
    return CommunityReplyModel(
      id: docId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}