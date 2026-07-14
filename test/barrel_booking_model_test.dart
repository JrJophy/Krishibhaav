import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:krishibhaav/models/barrel_booking_model.dart';

void main() {
  group('BarrelBookingModel', () {
    test('completedAt returns the correct timestamp based on status', () {
      final now = Timestamp.now();
      final tUpdated = Timestamp.fromDate(DateTime.parse('2026-06-01'));
      final tEmpty = Timestamp.fromDate(DateTime.parse('2026-06-02'));
      final tFilled = Timestamp.fromDate(DateTime.parse('2026-06-03'));
      final tReturned = Timestamp.fromDate(DateTime.parse('2026-06-04'));
      final tCancelled = Timestamp.fromDate(DateTime.parse('2026-06-05'));

      final baseModel = BarrelBookingModel(
        bookingId: 'test',
        agentId: 'agent',
        farmerId: 'farmer',
        farmerName: 'John',
        location: 'Loc',
        quantity: 5,
        status: 'requested',
        createdAt: now,
        updatedAt: tUpdated,
        requestedAt: now,
        returnedEmptyAt: tEmpty,
        returnedFilledAt: tFilled,
        returnedAt: tReturned,
        cancelledAt: tCancelled,
      );

      // 1. requested -> returns updatedAt
      expect(baseModel.completedAt, tUpdated);

      // 2. returned_empty -> returns returnedEmptyAt
      final emptyModel = baseModel.copyWith(status: 'returned_empty');
      expect(emptyModel.completedAt, tEmpty);

      // 3. returned_filled -> returns returnedFilledAt
      final filledModel = baseModel.copyWith(status: 'returned_filled');
      expect(filledModel.completedAt, tFilled);

      // 4. returned -> returns returnedAt
      final returnedModel = baseModel.copyWith(status: 'returned');
      expect(returnedModel.completedAt, tReturned);

      // 5. cancelled -> returns cancelledAt
      final cancelledModel = baseModel.copyWith(status: 'cancelled');
      expect(cancelledModel.completedAt, tCancelled);
      
      // 6. fallback when specific timestamp is missing
      final missingTimestampModel = BarrelBookingModel(
        bookingId: 'test2',
        agentId: 'a',
        farmerId: 'f',
        farmerName: 'n',
        location: 'l',
        quantity: 5,
        status: 'cancelled',
        createdAt: now,
        updatedAt: tUpdated,
        requestedAt: now,
      );
      expect(missingTimestampModel.completedAt, tUpdated);
    });
  });
}
