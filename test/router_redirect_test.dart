import 'package:flutter_test/flutter_test.dart';
import 'package:krishibhaav/app_router.dart';

void main() {
  group('decideRedirect', () {
    test('agent on /farmer/home -> /agent/home', () {
      final result = decideRedirect(
        isAwaitingOtp: false,
        loggedIn: true,
        cachedRole: 'agent',
        location: '/farmer/home',
      );
      expect(result, '/agent/home');
    });

    test('farmer on /agent/home -> /farmer/home', () {
      final result = decideRedirect(
        isAwaitingOtp: false,
        loggedIn: true,
        cachedRole: 'farmer',
        location: '/agent/home',
      );
      expect(result, '/farmer/home');
    });

    test('logged-out on any protected route -> /auth', () {
      final result = decideRedirect(
        isAwaitingOtp: false,
        loggedIn: false,
        cachedRole: null,
        location: '/farmer/home',
      );
      expect(result, '/auth');
    });

    test('isAwaitingOtp on a protected route -> /otp', () {
      final result = decideRedirect(
        isAwaitingOtp: true,
        loggedIn: false,
        cachedRole: null,
        location: '/farmer/home',
      );
      expect(result, '/otp');
    });

    test('isAwaitingOtp on /otp or /auth -> null', () {
      final resultAuth = decideRedirect(
        isAwaitingOtp: true,
        loggedIn: false,
        cachedRole: null,
        location: '/auth',
      );
      expect(resultAuth, isNull);

      final resultOtp = decideRedirect(
        isAwaitingOtp: true,
        loggedIn: false,
        cachedRole: null,
        location: '/otp',
      );
      expect(resultOtp, isNull);
    });

    test('logged-in user on /auth -> their home', () {
      final resultAgent = decideRedirect(
        isAwaitingOtp: false,
        loggedIn: true,
        cachedRole: 'agent',
        location: '/auth',
      );
      expect(resultAgent, '/agent/home');

      final resultFarmer = decideRedirect(
        isAwaitingOtp: false,
        loggedIn: true,
        cachedRole: 'farmer',
        location: '/auth',
      );
      expect(resultFarmer, '/farmer/home');
    });

    test('null role -> fail-closed path (/auth)', () {
      final result = decideRedirect(
        isAwaitingOtp: false,
        loggedIn: true,
        cachedRole: null,
        location: '/agent/home',
      );
      expect(result, '/auth');
    });
  });
}
