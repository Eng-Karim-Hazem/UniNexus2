import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../model/hall_model.dart';


class HallService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<HallModel>> streamHallsByToday() {
    // Formats today as "Saturday", "Sunday", etc.
    String today = DateFormat('EEEE').format(DateTime.now());

    return _db
        .collection('halls')
        .where('day', isEqualTo: today) //
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => HallModel.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList());
  }
}