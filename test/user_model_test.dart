import 'package:flutter_test/flutter_test.dart';
import 'package:krishibhaav/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromMap trims agentId and preserves null', () {
      final minimalMap = {
        'uid': 'u1',
        'name': 'Bob',
        'mobile': '123',
        'role': 'farmer',
        'location': 'loc',
        'crop': 'crop',
        'fcmToken': 'fcm',
      };

      // 1. Missing agentId stays null
      var user = UserModel.fromMap(minimalMap);
      expect(user.agentId, isNull);

      // 2. Clean agentId is preserved
      user = UserModel.fromMap({...minimalMap, 'agentId': 'abc123'});
      expect(user.agentId, 'abc123');

      // 3. Whitespace-padded agentId is trimmed
      user = UserModel.fromMap({...minimalMap, 'agentId': 'abc123   '});
      expect(user.agentId, 'abc123');
    });
  });
}
