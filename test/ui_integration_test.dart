import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:krishibhaav/screens/farmer/farmer_home_screen.dart';
import 'package:krishibhaav/screens/agent/agent_home_screen.dart';
import 'package:krishibhaav/providers/farmer_provider.dart';
import 'package:krishibhaav/providers/agent_provider.dart';
import 'package:krishibhaav/providers/auth_provider.dart';
import 'package:krishibhaav/models/barrel_booking_model.dart';
import 'package:krishibhaav/models/barrel_stock_model.dart';
import 'package:krishibhaav/models/board_rate_model.dart';
import 'package:krishibhaav/services/farmer_history_service.dart';
import 'package:krishibhaav/services/board_rate_service.dart';
import 'package:krishibhaav/models/price_point.dart';
import 'package:krishibhaav/models/open_market_price_point.dart';
import 'package:krishibhaav/widgets/farmer_barrel_booking_card.dart';
import 'package:krishibhaav/widgets/barrel_booking_card.dart';
import 'package:krishibhaav/screens/farmer/farmer_barrel_request_sheet.dart';
import 'package:krishibhaav/models/user_model.dart';
import 'package:krishibhaav/models/agent_settings_model.dart';

// -----------------------------------------------------------------------------
// FAKE PROVIDERS
// -----------------------------------------------------------------------------

class FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  @override String? get userId => 'test_uid';
  String? get role => 'farmer';
  @override bool get isLoading => false;
  String? get otpSessionId => null;
  bool get isAwaitingOtp => false;
  @override String? get errorMessage => null;
  @override String? get userRole => 'farmer';

  Future<void> sendOtp(String mobile) async {}
  Future<bool> verifyOtp(String otp) async => true;
  @override Future<bool> verifyOTP({required String otpEntered, required String otpGenerated, required String uid, required Map<String, dynamic> userData}) async => true;
  Future<void> checkAuthState() async {}
  Future<void> logout() async {}
  @override Future<void> signOut() async {}
  @override Future<bool> signIn(String mobile, String password) async => true;
  @override Future<String?> register({required String location, required String mobile, required String name, required String password, required String role}) async => null;
}

class FakeFarmerProvider extends ChangeNotifier implements FarmerProvider {
  @override double effectivePrice = 200.0;
  @override double openMarketPrice = 250.0;
  @override double openMarketRss5 = 240.0;
  @override bool canSeeBoardRate = true;
  @override bool canSeeOpenMarket = true;
  @override BoardRateModel? boardRate;
  @override bool isOffline = false;
  @override bool isLoading = false;
  @override String farmerName = 'Test Farmer';
  @override String agentId = 'test_agent';
  @override String location = 'Test Loc';
  @override bool hasCustomPrice = false;
  @override BarrelStockModel? barrelStock = BarrelStockModel(agentId: 'test_agent', totalBarrels: 100, availableBarrels: 50, lastUpdated: Timestamp.now());
  @override List<BarrelBookingModel> barrelBookings = [];

  @override Future<void> loadFarmer(String farmerId) async {}
  @override Future<void> createBooking(int quantity) async {}
  @override Future<void> cancelBooking(String bookingId, String reason) async {}
  @override Future<void> returnEmpty(String bookingId) async {}
  @override Future<void> returnFilled(String bookingId) async {}
}

class FakeAgentProvider extends ChangeNotifier implements AgentProvider {
  double rss4Price = 200.0;
  double rss5Price = 190.0;
  double ungradedPrice = 180.0;
  bool isOffline = false;
  @override bool isLoading = false;
  @override List<UserModel> farmerList = [];
  @override List<UserModel> get filteredFarmerList => farmerList;
  @override String searchQuery = '';
  @override void setSearchQuery(String query) {}
  @override AgentSettingsModel? agentSettings;
  @override BarrelStockModel? barrelStock = BarrelStockModel(agentId: 'test_agent', totalBarrels: 100, availableBarrels: 50, lastUpdated: Timestamp.now());
  @override List<BarrelBookingModel> barrelBookings = [];

  @override Future<void> loadAgent(String agentId) async {}
  @override Future<void> updatePrice(String type, double price, [double? price2]) async {}
  @override Future<String> addFarmer(String name, String mobile, String location) async => 'fid';
  @override Future<void> removeFarmer(String farmerId) async {}
  @override Future<void> upsertStock(int totalBarrels) async {}
  @override Future<void> approveBooking(String bookingId) async {}
  @override Future<void> dispatchBooking(String bookingId) async {}
  @override Future<void> returnBooking(String bookingId) async {}
  @override Future<void> cancelBooking(String bookingId, String cancelReason) async {}
}

class FakeFarmerHistoryService implements FarmerHistoryService {
  final List<PricePoint> agentHistory;
  final List<OpenMarketPricePoint> omHistory;

  FakeFarmerHistoryService({this.agentHistory = const [], this.omHistory = const []});

  @override Future<List<PricePoint>> fetchHistory(String farmerId, {int days = 30}) async => agentHistory;
  @override Future<List<OpenMarketPricePoint>> fetchOpenMarketHistory({int days = 30}) async => omHistory;
}

class FakeBoardRateService implements BoardRateService {
  Stream<BoardRateModel?> streamCurrentRate() => Stream.value(null);
  @override Stream<BoardRateModel?> streamBoardRate() => Stream.value(null);
  Future<void> publishDailyRate(double rss4, double rss5, double ungraded) async {}
}

// -----------------------------------------------------------------------------
// TESTS
// -----------------------------------------------------------------------------

void main() {
  group('V2 Phase 7 Integration Tests', () {
    testWidgets('1. Farmer Home: Chart and Stats swap when toggling Agent vs OM', (tester) async {
      final fakeFarmer = FakeFarmerProvider();
      final fakeHistory = FakeFarmerHistoryService(
        agentHistory: [
          PricePoint(date: '2026-06-18', price: 230.0), // Agent max
          PricePoint(date: '2026-06-17', price: 210.0), // Agent min
        ],
        omHistory: [
          OpenMarketPricePoint(date: '2026-06-18', rss4: 272.0, rss5: 266.0), // OM max
          OpenMarketPricePoint(date: '2026-06-17', rss4: 264.0, rss5: 258.0), // OM min
        ],
      );

      await tester.pumpWidget(MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<FarmerProvider>.value(value: fakeFarmer),
          ],
          child: FarmerHomeScreen(farmerId: 'fid', historyService: fakeHistory, enableNotifications: false),
        ),
      ));

      await tester.pump(); await tester.pump(const Duration(seconds: 1));

      await tester.scrollUntilVisible(find.text('Price Trends'), 100.0, scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Price Trends'));
      await tester.pump(); await tester.pump(const Duration(seconds: 1));

      expect(find.textContaining('230.00', skipOffstage: false), findsWidgets); 
      expect(find.textContaining('272.00', skipOffstage: false), findsNothing);

      await tester.scrollUntilVisible(find.text('Open Market'), 100.0, scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open Market'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.textContaining('272.00', skipOffstage: false), findsWidgets);
      expect(find.textContaining('264.00', skipOffstage: false), findsWidgets);
    });

    testWidgets('2. Farmer Home: Empty states display correctly', (tester) async {
      final fakeFarmer = FakeFarmerProvider();
      final fakeHistory = FakeFarmerHistoryService(agentHistory: [], omHistory: []);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MultiProvider(
            providers: [
              ChangeNotifierProvider<FarmerProvider>.value(value: fakeFarmer),
            ],
            child: FarmerHomeScreen(farmerId: 'fid', historyService: fakeHistory, enableNotifications: false),
          ),
        ),
      ));

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.scrollUntilVisible(find.text('Price Trends'), 100.0, scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Price Trends'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.scrollUntilVisible(find.text('Price tracking starts soon'), 100.0, scrollable: find.byType(Scrollable).first);
      expect(find.text('Price tracking starts soon'), findsOneWidget);

      await tester.tap(find.text('Open Market'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.scrollUntilVisible(find.text('Price tracking starts soon'), 100.0, scrollable: find.byType(Scrollable).first);
      expect(find.text('Price tracking starts soon'), findsOneWidget);
    });

    testWidgets('3. Farmer Home: Terminal bookings are filtered out', (tester) async {
      final fakeFarmer = FakeFarmerProvider();
      final t = Timestamp.now();
      fakeFarmer.barrelBookings = [
        BarrelBookingModel(bookingId: '1', farmerId: 'fid', farmerName: 'Fn', location: 'loc', agentId: 'aid', quantity: 2, status: 'requested', createdAt: t, updatedAt: t, requestedAt: t),
        BarrelBookingModel(bookingId: '2', farmerId: 'fid', farmerName: 'Fn', location: 'loc', agentId: 'aid', quantity: 1, status: 'returned_filled', createdAt: t, updatedAt: t, requestedAt: t),
      ];

      await tester.pumpWidget(MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<FarmerProvider>.value(value: fakeFarmer),
          ],
          child: FarmerHomeScreen(farmerId: 'fid', historyService: FakeFarmerHistoryService(), enableNotifications: false),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(FarmerBarrelBookingCard), findsOneWidget);
    });

    testWidgets('4. Agent Home: Terminal bookings are filtered out', (tester) async {
      final fakeAuth = FakeAuthProvider();
      final fakeAgent = FakeAgentProvider();
      final t = Timestamp.now();
      fakeAgent.barrelBookings = [
        BarrelBookingModel(bookingId: '1', farmerId: 'fid', farmerName: 'Fn', location: 'loc', agentId: 'aid', quantity: 2, status: 'approved', createdAt: t, updatedAt: t, requestedAt: t),
        BarrelBookingModel(bookingId: '2', farmerId: 'fid', farmerName: 'Fn', location: 'loc', agentId: 'aid', quantity: 1, status: 'cancelled', createdAt: t, updatedAt: t, requestedAt: t),
      ];

      await tester.pumpWidget(MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: fakeAuth),
            ChangeNotifierProvider<AgentProvider>.value(value: fakeAgent),
          ],
          child: AgentHomeScreen(
            boardRateService: FakeBoardRateService(),
            fetchAgentName: (id) async => 'Test Agent',
            enableNotifications: false,
          ),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(BarrelBookingCard), findsOneWidget);
    });

    testWidgets('5. Farmer Barrel Request: Validates against available stock', (tester) async {
      final fakeFarmer = FakeFarmerProvider();
      fakeFarmer.barrelStock = BarrelStockModel(agentId: 'aid', totalBarrels: 100, availableBarrels: 3, lastUpdated: Timestamp.now());

      await tester.pumpWidget(MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<FarmerProvider>.value(value: fakeFarmer),
          ],
          child: const Scaffold(body: FarmerBarrelRequestSheet()),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.enterText(find.byType(TextField), '4');
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Only 3 barrels available from agent'), findsOneWidget);
    });
  });
}
