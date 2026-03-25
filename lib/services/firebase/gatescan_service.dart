import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/gate_scan_model.dart';

class GateService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<GateScan>> getGateScans() {
    // This query triggers the index requirement
    return _db.collection('gate_scans')
        .orderBy('date', descending: true)
        .orderBy('time', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => GateScan.fromFirestore(doc.id, doc.data())).toList());
  }
}