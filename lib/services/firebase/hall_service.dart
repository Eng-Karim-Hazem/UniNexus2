import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/hall_model.dart';

class HallService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Streams all halls. The availability is now determined by the 'isAvailable' field in real-time.
  Stream<List<HallModel>> streamAllHalls() {
    return _db
        .collection('halls')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => HallModel.fromFirestore(doc.data()))
        .toList());
  }
}