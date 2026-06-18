import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/barrel_stock_model.dart';
import '../models/barrel_booking_model.dart';
import '../core/barrel_logic.dart';

class BarrelService {
  final FirebaseFirestore _firestore;
  BarrelService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createBooking({
    required String bookingId,
    required String agentId,
    required String farmerId,
    required String farmerName,
    required String location,
    required int quantity,
  }) async {
    await _firestore.collection('barrel_bookings').doc(bookingId).set({
      'bookingId': bookingId,
      'agentId': agentId,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'location': location,
      'quantity': quantity,
      'status': 'requested',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'requestedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> approveBooking(String bookingId, String agentId) async {
    final bookingRef = _firestore.collection('barrel_bookings').doc(bookingId);
    final stockRef = _firestore.collection('barrel_stock').doc(agentId);

    await _firestore.runTransaction((transaction) async {
      final bookingSnapshot = await transaction.get(bookingRef);
      if (!bookingSnapshot.exists) throw Exception('Booking not found');

      final bookingData = bookingSnapshot.data()!;
      final currentStatus = bookingData['status'] as String;
      final quantity = ((bookingData['quantity'] ?? 0) as num).toInt();

      final stockSnapshot = await transaction.get(stockRef);
      if (!stockSnapshot.exists) throw Exception('Stock not found');

      final stockData = stockSnapshot.data()!;
      final availableBarrels = ((stockData['availableBarrels'] ?? 0) as num).toInt();

      final decision = decideApprove(currentStatus, quantity, availableBarrels);
      if (decision.newStatus == null) return; // No-op

      if (decision.availableDelta != 0) {
        transaction.update(stockRef, {
          'availableBarrels': FieldValue.increment(decision.availableDelta),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      transaction.set(bookingRef, {
        'status': decision.newStatus,
        'approvedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> dispatchBooking(String bookingId) async {
    final bookingRef = _firestore.collection('barrel_bookings').doc(bookingId);
    final bookingSnapshot = await bookingRef.get();
    
    if (!bookingSnapshot.exists) throw Exception('Booking not found');
    final bookingData = bookingSnapshot.data()!;
    final currentStatus = bookingData['status'] as String;

    final decision = decideDispatch(currentStatus);
    if (decision.newStatus == null) return; // No-op

    await bookingRef.set({
      'status': decision.newStatus,
      'dispatchedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> returnBooking(String bookingId, String agentId) async {
    final bookingRef = _firestore.collection('barrel_bookings').doc(bookingId);
    final stockRef = _firestore.collection('barrel_stock').doc(agentId);

    await _firestore.runTransaction((transaction) async {
      final bookingSnapshot = await transaction.get(bookingRef);
      if (!bookingSnapshot.exists) throw Exception('Booking not found');

      final bookingData = bookingSnapshot.data()!;
      final currentStatus = bookingData['status'] as String;
      final quantity = ((bookingData['quantity'] ?? 0) as num).toInt();

      final decision = decideReturn(currentStatus, quantity);
      if (decision.newStatus == null) return; // No-op

      if (decision.availableDelta != 0) {
        transaction.update(stockRef, {
          'availableBarrels': FieldValue.increment(decision.availableDelta),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      transaction.set(bookingRef, {
        'status': decision.newStatus,
        'returnedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> cancelBooking(String bookingId, String agentId, String cancelReason) async {
    final bookingRef = _firestore.collection('barrel_bookings').doc(bookingId);
    final stockRef = _firestore.collection('barrel_stock').doc(agentId);

    await _firestore.runTransaction((transaction) async {
      final bookingSnapshot = await transaction.get(bookingRef);
      if (!bookingSnapshot.exists) throw Exception('Booking not found');

      final bookingData = bookingSnapshot.data()!;
      final currentStatus = bookingData['status'] as String;
      final quantity = ((bookingData['quantity'] ?? 0) as num).toInt();

      final decision = decideCancel(currentStatus, quantity);
      if (decision.newStatus == null) return; // No-op

      if (decision.availableDelta != 0) {
        transaction.update(stockRef, {
          'availableBarrels': FieldValue.increment(decision.availableDelta),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      transaction.set(bookingRef, {
        'status': decision.newStatus,
        'cancelReason': cancelReason,
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> upsertStock(String agentId, int newTotalBarrels) async {
    final stockRef = _firestore.collection('barrel_stock').doc(agentId);

    await _firestore.runTransaction((transaction) async {
      final stockSnapshot = await transaction.get(stockRef);

      if (!stockSnapshot.exists) {
        // First create
        transaction.set(stockRef, {
          'agentId': agentId,
          'totalBarrels': newTotalBarrels,
          'availableBarrels': newTotalBarrels,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        // Update of existing
        final stockData = stockSnapshot.data()!;
        final oldTotal = ((stockData['totalBarrels'] ?? 0) as num).toInt();
        final currentAvailable = ((stockData['availableBarrels'] ?? 0) as num).toInt();
        final delta = validatedUpsertDelta(oldTotal, newTotalBarrels, currentAvailable);

        final updateData = <String, dynamic>{
          'totalBarrels': newTotalBarrels,
          'lastUpdated': FieldValue.serverTimestamp(),
        };
        if (delta != 0) {
          updateData['availableBarrels'] = FieldValue.increment(delta);
        }

        transaction.set(stockRef, updateData, SetOptions(merge: true));
      }
    });
  }

  Stream<BarrelStockModel> streamBarrelStock(String agentId) {
    return FirebaseAuth.instance.authStateChanges()
        .map((user) => user != null)
        .distinct()
        .asyncExpand((isLoggedIn) {
      if (!isLoggedIn) {
        return Stream.value(BarrelStockModel(
          agentId: agentId,
          totalBarrels: 0,
          availableBarrels: 0,
          lastUpdated: Timestamp.now(),
        ));
      }
      return _firestore.collection('barrel_stock').doc(agentId).snapshots().map((doc) {
        if (!doc.exists) {
          return BarrelStockModel(
            agentId: agentId,
            totalBarrels: 0,
            availableBarrels: 0,
            lastUpdated: Timestamp.now(),
          );
        }
        return BarrelStockModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      });
    });
  }

  Stream<List<BarrelBookingModel>> streamAgentBookings(String agentId) {
    return FirebaseAuth.instance.authStateChanges()
        .map((user) => user != null)
        .distinct()
        .asyncExpand((isLoggedIn) {
      if (!isLoggedIn) return Stream.value(<BarrelBookingModel>[]);
      return _firestore.collection('barrel_bookings')
          .where('agentId', isEqualTo: agentId)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => BarrelBookingModel.fromMap(doc.data(), doc.id)).toList());
    });
  }

  Stream<List<BarrelBookingModel>> streamFarmerBookings(String farmerId) {
    return FirebaseAuth.instance.authStateChanges()
        .map((user) => user != null)
        .distinct()
        .asyncExpand((isLoggedIn) {
      if (!isLoggedIn) return Stream.value(<BarrelBookingModel>[]);
      return _firestore.collection('barrel_bookings')
          .where('farmerId', isEqualTo: farmerId)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => BarrelBookingModel.fromMap(doc.data(), doc.id)).toList());
    });
  }
}
