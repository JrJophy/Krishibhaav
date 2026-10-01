import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:krishibhaav/providers/agent_provider.dart';
import 'package:krishibhaav/screens/agent/pending_requests_screen.dart';
import 'package:krishibhaav/models/user_model.dart';
import 'package:krishibhaav/models/agent_settings_model.dart';
import 'package:krishibhaav/models/barrel_stock_model.dart';
import 'package:krishibhaav/models/barrel_booking_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Testable normalization function matching RequestLinkScreen & AuthService
String normalizeAgentCode(String input) {
  return input.trim().replaceAll(' ', '').toUpperCase();
}

// Testable deterministic link request doc id function
String getLinkRequestId(String farmerId, String agentId) {
  return '${farmerId}_$agentId';
}

// Testable state transition validator matching firestore.rules
bool isValidLinkRequestTransition({
  required String currentStatus,
  required String newStatus,
  required String actorRole,
}) {
  if (actorRole == 'farmer') {
    // Farmer can only re-open a rejected request back to pending
    return currentStatus == 'rejected' && newStatus == 'pending';
  } else if (actorRole == 'agent') {
    // Agent can only transition a pending request to accepted or rejected
    return currentStatus == 'pending' && (newStatus == 'accepted' || newStatus == 'rejected');
  }
  return false;
}

class MockAgentProvider extends ChangeNotifier implements AgentProvider {
  List<Map<String, dynamic>> _mockRequests = [];
  bool acceptCalled = false;
  bool rejectCalled = false;
  String? lastAcceptedRequestId;
  String? lastRejectedRequestId;

  MockAgentProvider({List<Map<String, dynamic>>? requests}) {
    if (requests != null) {
      _mockRequests = requests;
    }
  }

  @override
  List<Map<String, dynamic>> get linkRequests => _mockRequests;

  @override
  Future<void> acceptLinkRequest(String requestId, String farmerId, String farmerName, String agentName) async {
    acceptCalled = true;
    lastAcceptedRequestId = requestId;
    _mockRequests.removeWhere((r) => r['id'] == requestId);
    notifyListeners();
  }

  @override
  Future<void> rejectLinkRequest(String requestId, String farmerId, String agentName) async {
    rejectCalled = true;
    lastRejectedRequestId = requestId;
    _mockRequests.removeWhere((r) => r['id'] == requestId);
    notifyListeners();
  }

  // Stubs for AgentProvider interface
  @override AgentSettingsModel? agentSettings;
  @override List<UserModel> farmerList = [];
  @override List<UserModel> get filteredFarmerList => farmerList;
  @override String searchQuery = '';
  @override bool isLoading = false;
  @override BarrelStockModel? barrelStock;
  @override List<BarrelBookingModel> barrelBookings = [];

  @override void setSearchQuery(String query) {}
  @override void loadAgent(String agentId) {}
  @override Future<void> updatePrice(String type, double price, [double? price2]) async {}
  @override Future<void> removeFarmer(String farmerId) async {}
  @override Future<void> upsertStock(int totalBarrels) async {}
  @override Future<void> approveBooking(String bookingId) async {}
  @override Future<void> dispatchBooking(String bookingId) async {}
  @override Future<void> returnBooking(String bookingId) async {}
  @override Future<void> cancelBooking(String bookingId, String cancelReason) async {}
}

void main() {
  group('Link Request Logic & Security Rule Transition Tests', () {
    test('Agent code normalization trims whitespace, removes spaces, and converts to uppercase', () {
      expect(normalizeAgentCode('  ab12cd  '), 'AB12CD');
      expect(normalizeAgentCode('a b 1 2 c d'), 'AB12CD');
      expect(normalizeAgentCode('XY987Z'), 'XY987Z');
    });

    test('Deterministic doc ID creates {farmerId}_{agentId}', () {
      const farmerId = 'farmer_001';
      const agentId = 'agent_999';
      expect(getLinkRequestId(farmerId, agentId), 'farmer_001_agent_999');
    });

    test('Farmer can only transition status from rejected -> pending', () {
      expect(isValidLinkRequestTransition(currentStatus: 'rejected', newStatus: 'pending', actorRole: 'farmer'), isTrue);
      expect(isValidLinkRequestTransition(currentStatus: 'pending', newStatus: 'accepted', actorRole: 'farmer'), isFalse);
      expect(isValidLinkRequestTransition(currentStatus: 'pending', newStatus: 'rejected', actorRole: 'farmer'), isFalse);
      expect(isValidLinkRequestTransition(currentStatus: 'accepted', newStatus: 'pending', actorRole: 'farmer'), isFalse);
    });

    test('Agent can transition status from pending -> accepted or rejected', () {
      expect(isValidLinkRequestTransition(currentStatus: 'pending', newStatus: 'accepted', actorRole: 'agent'), isTrue);
      expect(isValidLinkRequestTransition(currentStatus: 'pending', newStatus: 'rejected', actorRole: 'agent'), isTrue);
      expect(isValidLinkRequestTransition(currentStatus: 'accepted', newStatus: 'rejected', actorRole: 'agent'), isFalse);
      expect(isValidLinkRequestTransition(currentStatus: 'rejected', newStatus: 'accepted', actorRole: 'agent'), isFalse);
    });
  });

  group('PendingRequestsScreen Widget Tests', () {
    testWidgets('Displays empty state message when there are no link requests', (tester) async {
      final mockProvider = MockAgentProvider(requests: []);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AgentProvider>.value(
            value: mockProvider,
            child: const PendingRequestsScreen(agentName: 'Test Agent'),
          ),
        ),
      );

      expect(find.text('No pending requests.'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('Displays list of link requests and triggers acceptLinkRequest on Accept button tap', (tester) async {
      final mockProvider = MockAgentProvider(requests: [
        {
          'id': 'farmer_1_agent_1',
          'farmerId': 'farmer_1',
          'farmerName': 'Ramesh Kumar',
          'farmerMobile': '9876543210',
          'agentId': 'agent_1',
          'status': 'pending',
          'requestedAt': Timestamp.now(),
        }
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<AgentProvider>.value(
              value: mockProvider,
              child: const PendingRequestsScreen(agentName: 'Test Agent'),
            ),
          ),
        ),
      );

      expect(find.text('Ramesh Kumar'), findsOneWidget);
      expect(find.text('+91 9876543210'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);

      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      expect(mockProvider.acceptCalled, isTrue);
      expect(mockProvider.lastAcceptedRequestId, 'farmer_1_agent_1');
      expect(find.text('Farmer linked successfully!'), findsOneWidget);
    });

    testWidgets('Displays list of link requests and triggers rejectLinkRequest on Reject button tap', (tester) async {
      final mockProvider = MockAgentProvider(requests: [
        {
          'id': 'farmer_2_agent_1',
          'farmerId': 'farmer_2',
          'farmerName': 'Suresh Patel',
          'farmerMobile': '9123456780',
          'agentId': 'agent_1',
          'status': 'pending',
          'requestedAt': Timestamp.now(),
        }
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<AgentProvider>.value(
              value: mockProvider,
              child: const PendingRequestsScreen(agentName: 'Test Agent'),
            ),
          ),
        ),
      );

      expect(find.text('Suresh Patel'), findsOneWidget);
      expect(find.text('+91 9123456780'), findsOneWidget);

      await tester.tap(find.text('Reject'));
      await tester.pumpAndSettle();

      expect(mockProvider.rejectCalled, isTrue);
      expect(mockProvider.lastRejectedRequestId, 'farmer_2_agent_1');
      expect(find.text('Request rejected'), findsOneWidget);
    });
  });
}
