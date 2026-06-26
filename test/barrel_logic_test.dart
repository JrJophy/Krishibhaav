import 'package:flutter_test/flutter_test.dart';
import 'package:krishibhaav/core/barrel_logic.dart';

void main() {
  group('BarrelLogic', () {
    test('1 decideApprove from requested, available>=qty -> approved, -qty', () {
      final decision = decideApprove('requested', 5, 10);
      expect(decision.newStatus, 'approved');
      expect(decision.availableDelta, -5);
    });

    test('2 decideApprove from approved -> null, 0 (idempotent)', () {
      final decision = decideApprove('approved', 5, 10);
      expect(decision.newStatus, isNull);
      expect(decision.availableDelta, 0);
    });

    test('3 decideApprove from requested, available<qty -> throws overbooking', () {
      expect(() => decideApprove('requested', 15, 10), throwsArgumentError);
    });

    test('4 decideApprove from cancelled/dispatched -> null, 0', () {
      final dec1 = decideApprove('cancelled', 5, 10);
      expect(dec1.newStatus, isNull);
      expect(dec1.availableDelta, 0);

      final dec2 = decideApprove('dispatched', 5, 10);
      expect(dec2.newStatus, isNull);
      expect(dec2.availableDelta, 0);
    });

    test('5 decideDispatch approved -> dispatched, 0; other -> null, 0', () {
      final dec1 = decideDispatch('approved');
      expect(dec1.newStatus, 'dispatched');
      expect(dec1.availableDelta, 0);

      final dec2 = decideDispatch('requested');
      expect(dec2.newStatus, isNull);
      expect(dec2.availableDelta, 0);
    });

    test('6 decideReturn dispatched -> returned, qty; other -> null, 0', () {
      final dec1 = decideReturn('dispatched', 5);
      expect(dec1.newStatus, 'returned');
      expect(dec1.availableDelta, 5);

      final dec2 = decideReturn('approved', 5);
      expect(dec2.newStatus, isNull);
      expect(dec2.availableDelta, 0);
    });

    test('7 decideCancel requested -> cancelled, 0', () {
      final decision = decideCancel('requested', 5);
      expect(decision.newStatus, 'cancelled');
      expect(decision.availableDelta, 0);
    });

    test('8 decideCancel approved -> cancelled, qty', () {
      final decision = decideCancel('approved', 5);
      expect(decision.newStatus, 'cancelled');
      expect(decision.availableDelta, 5);
    });

    test('9 decideCancel dispatched -> null, 0', () {
      final decision = decideCancel('dispatched', 5);
      expect(decision.newStatus, isNull);
      expect(decision.availableDelta, 0);
    });

    test('10 upsertAvailableDelta logic', () {
      expect(upsertAvailableDelta(0, 5), 5);
      expect(upsertAvailableDelta(5, 8), 3);
      expect(upsertAvailableDelta(10, 4), -6);
    });

    test('11 validatedUpsertDelta tests', () {
      expect(validatedUpsertDelta(0, 10, 0), 10);
      expect(validatedUpsertDelta(10, 8, 5), -2);
      expect(() => validatedUpsertDelta(10, 4, 2), throwsArgumentError);
      expect(validatedUpsertDelta(10, 10, 0), 0);
    });
  });

  group('isTerminalBookingStatus', () {
    test('12 terminal statuses return true', () {
      expect(isTerminalBookingStatus('returned'), isTrue);
      expect(isTerminalBookingStatus('returned_empty'), isTrue);
      expect(isTerminalBookingStatus('returned_filled'), isTrue);
      expect(isTerminalBookingStatus('cancelled'), isTrue);
    });

    test('13 active statuses return false', () {
      expect(isTerminalBookingStatus('requested'), isFalse);
      expect(isTerminalBookingStatus('approved'), isFalse);
      expect(isTerminalBookingStatus('dispatched'), isFalse);
    });

    test('14 whitespace is trimmed before lookup', () {
      expect(isTerminalBookingStatus('returned_empty '), isTrue);
      expect(isTerminalBookingStatus(' requested '), isFalse);
    });
  });

  group('bookingStatusLabel', () {
    test('15 maps each status to its expected label', () {
      expect(bookingStatusLabel('requested'), 'Requested');
      expect(bookingStatusLabel('approved'), 'Approved');
      expect(bookingStatusLabel('dispatched'), 'Dispatched');
      expect(bookingStatusLabel('returned'), 'Returned');
      expect(bookingStatusLabel('returned_empty'), 'Returned Empty');
      expect(bookingStatusLabel('returned_filled'), 'Returned Filled');
      expect(bookingStatusLabel('cancelled'), 'Cancelled');
    });

    test('16 trims whitespace from input', () {
      expect(bookingStatusLabel('cancelled '), 'Cancelled');
      expect(bookingStatusLabel('  requested  '), 'Requested');
    });

    test('17 returns unknown status trimmed', () {
      expect(bookingStatusLabel('  weird '), 'weird');
    });
  });
}

