import 'package:flutter_test/flutter_test.dart';

bool validateRegistrationInput({
  required String name,
  required String mobile,
  required String password,
  required String location,
}) {
  if (name.isEmpty || mobile.length != 10 || password.length < 6 || location.isEmpty) {
    return false;
  }
  return true;
}

String decidePostRegistrationRoute({
  required String role,
  required String? agentId,
}) {
  if (role == 'agent') {
    return '/agent/home';
  }
  if ((agentId ?? '').trim().isEmpty) {
    return '/farmer/request_link';
  }
  return '/farmer/home';
}

void main() {
  group('Registration Flow & Validation Tests', () {
    test('validation accepts correct inputs', () {
      expect(
        validateRegistrationInput(
          name: 'John Doe',
          mobile: '9876543210',
          password: 'password123',
          location: 'Kottayam',
        ),
        isTrue,
      );
    });

    test('validation rejects empty name', () {
      expect(
        validateRegistrationInput(
          name: '',
          mobile: '9876543210',
          password: 'password123',
          location: 'Kottayam',
        ),
        isFalse,
      );
    });

    test('validation rejects mobile numbers not 10 digits', () {
      expect(
        validateRegistrationInput(
          name: 'John',
          mobile: '98765',
          password: 'password123',
          location: 'Kottayam',
        ),
        isFalse,
      );
      expect(
        validateRegistrationInput(
          name: 'John',
          mobile: '98765432100',
          password: 'password123',
          location: 'Kottayam',
        ),
        isFalse,
      );
    });

    test('validation rejects password shorter than 6 characters', () {
      expect(
        validateRegistrationInput(
          name: 'John',
          mobile: '9876543210',
          password: '12345',
          location: 'Kottayam',
        ),
        isFalse,
      );
    });

    test('validation rejects empty location', () {
      expect(
        validateRegistrationInput(
          name: 'John',
          mobile: '9876543210',
          password: 'password123',
          location: '',
        ),
        isFalse,
      );
    });

    test('agent post-registration routes directly to /agent/home', () {
      final route = decidePostRegistrationRoute(role: 'agent', agentId: null);
      expect(route, '/agent/home');
    });

    test('new farmer without agentId routes to /farmer/request_link', () {
      final routeEmpty = decidePostRegistrationRoute(role: 'farmer', agentId: '');
      expect(routeEmpty, '/farmer/request_link');

      final routeNull = decidePostRegistrationRoute(role: 'farmer', agentId: null);
      expect(routeNull, '/farmer/request_link');

      final routeWhitespace = decidePostRegistrationRoute(role: 'farmer', agentId: '   ');
      expect(routeWhitespace, '/farmer/request_link');
    });

    test('farmer with existing agentId routes to /farmer/home', () {
      final route = decidePostRegistrationRoute(role: 'farmer', agentId: 'agent_abc123');
      expect(route, '/farmer/home');
    });
  });
}
