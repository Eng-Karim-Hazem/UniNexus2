import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/notices_model.dart';

class NoticesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _noticesRef =>
      _db.collection('Notifications');

  Future<void> sendNotice(NoticeModel notice) async {
    if (notice.recipientIds.isEmpty) {
      throw Exception('No recipients found for this notice.');
    }

    await _noticesRef.add(notice.toFirestore());
  }

  Future<List<String>> getAllUserIdsByGroup(String group) async {
    final String normalized = group.trim().toLowerCase();

    QuerySnapshot<Map<String, dynamic>> snapshot;
    switch (normalized) {
      case 'students':
        snapshot = await _db.collection('students').get();
        break;
      case 'faculty':
        snapshot = await _db.collection('faculty').get();
        break;
      case 'it':
      case 'security':
      case 'admin':
        snapshot = await _db
            .collection('staff')
            .where('type', isEqualTo: _normalizeStaffType(group))
            .get();
        break;
      default:
        throw Exception('Unsupported group: $group');
    }

    return snapshot.docs
        .map((doc) => (doc.data()['ID'] ?? '').toString().trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
  }

  String _normalizeStaffType(String group) {
    final String normalized = group.trim().toLowerCase();
    switch (normalized) {
      case 'it':
        return 'IT';
      case 'security':
        return 'Security';
      case 'admin':
        return 'Admin';
      default:
        return group;
    }
  }

  Future<List<String>> getStudentIdsByProgram(String program) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _db
        .collection('students')
        .where('faculty', isEqualTo: program)
        .get();

    return snapshot.docs
        .map((doc) => (doc.data()['ID'] ?? '').toString().trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
  }

  Future<List<String>> getFacultyIdsBySubject(String subject) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _db
        .collection('faculty')
        .where('subjects', arrayContains: subject)
        .get();

    return snapshot.docs
        .map((doc) => (doc.data()['ID'] ?? '').toString().trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
  }

  Future<List<String>> getAvailableSpecializations() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
    await _db.collection('faculty').get();

    final Set<String> subjects = <String>{};

    for (final doc in snapshot.docs) {
      final dynamic rawSubjects = doc.data()['subjects'];
      if (rawSubjects is List) {
        for (final subject in rawSubjects) {
          final String cleaned = subject.toString().trim();
          if (cleaned.isNotEmpty) {
            subjects.add(cleaned);
          }
        }
      } else if (rawSubjects is String) {
        final List<String> parsed = rawSubjects
            .split(',')
            .map((entry) => entry.trim())
            .where((entry) => entry.isNotEmpty)
            .toList();
        subjects.addAll(parsed);
      }
    }

    final List<String> list = subjects.toList()..sort();
    return list;
  }

  Stream<List<NoticeModel>> streamNoticesForUser(String userId) {
    final String cleanedId = userId.trim();
    if (cleanedId.isEmpty) {
      return Stream.value(const []);
    }

    return _noticesRef
        .where('recipientIds', arrayContains: cleanedId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NoticeModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }
}