import 'package:flutter_test/flutter_test.dart';
import 'package:krishibhaav/app_router.dart';

void main() {
  group('decideRedirect', () {
    test('agent on /farmer/home -> /agent/home', () {
      final result = decideRedirect(
        loggedIn: true,
        cachedRole: 'agent',
        location: '/farmer/home',
      );
      expect(result, '/agent/home');
    });

    test('farmer on /agent/home -> /farmer/home', () {
      final result = decideRedirect(
        loggedIn: true,
        cachedRole: 'farmer',
        location: '/agent/home',
      );
      expect(result, '/farmer/home');
    });

    test('logged-out on any protected route -> /auth', () {
      final result = decideRedirect(
        loggedIn: false,
        cachedRole: null,
        location: '/farmer/home',
      );
      expect(result, '/auth');
    });

    test('logged-out on /auth -> null', () {
      final result = decideRedirect(
        loggedIn: false,
        cachedRole: null,
        location: '/auth',
      );
      expect(result, isNull);
    });

    test('logged-in user on /auth -> their home', () {
      final resultAgent = decideRedirect(
        loggedIn: true,
        cachedRole: 'agent',
        location: '/auth',
      );
      expect(resultAgent, '/agent/home');

      final resultFarmer = decideRedirect(
        loggedIn: true,
        cachedRole: 'farmer',
        location: '/auth',
      );
      expect(resultFarmer, '/farmer/home');
    });

    test('null role -> fail-closed path (/auth)', () {
      final result = decideRedirect(
        loggedIn: true,
        cachedRole: null,
        location: '/agent/home',
      );
      expect(result, '/auth');
    });

    test('splash route (/) always returns null', () {
      final result = decideRedirect(
        loggedIn: false,
        cachedRole: null,
        location: '/',
      );
      expect(result, isNull);
    });

    test('logged-out on obsolete /otp route redirects to /auth', () {
      final result = decideRedirect(
        loggedIn: false,
        cachedRole: null,
        location: '/otp',
      );
      expect(result, '/auth');
    });
  });
}
