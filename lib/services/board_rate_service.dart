import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/board_rate_model.dart';

class BoardRateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<BoardRateModel?> streamBoardRate() {
    return FirebaseAuth.instance.authStateChanges()
        .map((user) => user != null)
        .distinct()
        .asyncExpand((isLoggedIn) {
      if (!isLoggedIn) return Stream.value(null);
      return _firestore.collection('board_rates').doc('current').snapshots().map((doc) {
        if (!doc.exists || doc.data() == null) {
          return null;
        }
        return BoardRateModel.fromMap(doc.data() as Map<String, dynamic>);
      });
    });
  }
}
