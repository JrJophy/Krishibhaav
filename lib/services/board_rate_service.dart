import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/board_rate_model.dart';

class BoardRateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<BoardRateModel?> streamBoardRate() {
    return _firestore.collection('board_rates').doc('current').snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return BoardRateModel.fromMap(doc.data() as Map<String, dynamic>);
    });
  }
}
