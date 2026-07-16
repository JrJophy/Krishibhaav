import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:krishibhaav/screens/farmer/farmer_home_screen.dart';
import 'package:krishibhaav/providers/farmer_provider.dart';
import 'package:krishibhaav/models/board_rate_model.dart';
import 'package:krishibhaav/services/farmer_history_service.dart';
import 'package:krishibhaav/models/price_point.dart';
import 'package:krishibhaav/models/open_market_price_point.dart';
import 'package:krishibhaav/models/barrel_stock_model.dart';
import 'package:krishibhaav/models/barrel_booking_model.dart';


// Fake providers and services
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
  @override String agentId = '';
  @override String location = 'Test Loc';
  @override bool hasCustomPrice = false;
  @override BarrelStockModel? barrelStock;
  @override List<BarrelBookingModel> barrelBookings = [];

  @override Future<void> loadFarmer(String farmerId) async {}
  @override Future<void> createBooking(int quantity) async {}
  @override Future<void> cancelBooking(String bookingId, String reason) async {}
  @override Future<void> returnEmpty(String bookingId) async {}
  @override Future<void> returnFilled(String bookingId) async {}
}

class FakeFarmerHistoryService implements FarmerHistoryService {
  @override Future<List<PricePoint>> fetchHistory(String farmerId, {int days = 30}) async => [];
  @override Future<List<OpenMarketPricePoint>> fetchOpenMarketHistory({int days = 30}) async => [];
}

void main() {
  group('Gatekeeper Link Workflow Tests', () {
    testWidgets('Unlinked farmer sees the blank state and no agent data leaks', (tester) async {
      final fakeFarmer = FakeFarmerProvider();
      fakeFarmer.agentId = ''; // Blank state
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MultiProvider(
            providers: [
              ChangeNotifierProvider<FarmerProvider>.value(value: fakeFarmer),
            ],
            child: FarmerHomeScreen(farmerId: 'fid', historyService: FakeFarmerHistoryService(), enableNotifications: false),
          ),
        ),
      ));

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify blank state UI is shown
      expect(find.text('Not linked to an Agent'), findsOneWidget);
      expect(find.text('Link with Agent'), findsOneWidget);
      
      // Verify no sensitive agent data is shown (prices, trends, booking cards)
      expect(find.text('Price Trends'), findsNothing);
      expect(find.text('Open Market'), findsNothing);
      expect(find.text('Request Barrels'), findsNothing);
    });

    testWidgets('Accepting a request unlocks data', (tester) async {
      final fakeFarmer = FakeFarmerProvider();
      fakeFarmer.agentId = 'agent123'; // Linked state
      fakeFarmer.effectivePrice = 210.0;
      fakeFarmer.openMarketPrice = 215.0;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MultiProvider(
            providers: [
              ChangeNotifierProvider<FarmerProvider>.value(value: fakeFarmer),
            ],
            child: FarmerHomeScreen(farmerId: 'fid', historyService: FakeFarmerHistoryService(), enableNotifications: false),
          ),
        ),
      ));

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify dashboard is shown
      expect(find.text('Not linked to an Agent'), findsNothing);
      
      await tester.scrollUntilVisible(find.text('Price Trends'), 100.0, scrollable: find.byType(Scrollable).first);
      
      // Verify prices and data are unlocked
      expect(find.text('Price Trends'), findsOneWidget);
      expect(find.textContaining('210.00', skipOffstage: false), findsWidgets);
    });
  });
}
