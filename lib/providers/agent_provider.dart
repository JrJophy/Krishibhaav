import 'dart:async';
import 'package:flutter/material.dart';
import '../models/agent_settings_model.dart';
import '../models/user_model.dart';
import '../services/agent_service.dart';
import '../services/fcm_dispatch_service.dart';
import '../services/barrel_service.dart';
import '../models/barrel_stock_model.dart';
import '../models/barrel_booking_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgentProvider extends ChangeNotifier {
  final AgentService _agentService = AgentService();
  final BarrelService _barrelService = BarrelService();

  AgentSettingsModel? _agentSettings;
  List<UserModel> _farmerList = [];
  String _searchQuery = '';
  bool _isLoading = false;

  BarrelStockModel? _barrelStock;
  List<BarrelBookingModel> _barrelBookings = [];

  StreamSubscription<AgentSettingsModel>? _settingsSub;
  StreamSubscription<List<UserModel>>? _farmersSub;
  StreamSubscription<BarrelStockModel>? _barrelStockSub;
  StreamSubscription<List<BarrelBookingModel>>? _barrelBookingsSub;
  StreamSubscription<QuerySnapshot>? _linkRequestsSub;

  List<Map<String, dynamic>> _linkRequests = [];
  List<Map<String, dynamic>> get linkRequests => _linkRequests;

  AgentSettingsModel? get agentSettings => _agentSettings;
  List<UserModel> get farmerList => _farmerList;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  
  BarrelStockModel? get barrelStock => _barrelStock;
  List<BarrelBookingModel> get barrelBookings => _barrelBookings;

  List<UserModel> get filteredFarmerList {
    if (_searchQuery.isEmpty) return _farmerList;
    final lowerQuery = _searchQuery.toLowerCase();
    return _farmerList.where((farmer) {
      final nameMatches = farmer.name.toLowerCase().contains(lowerQuery);
      final locationMatches = farmer.location.toLowerCase().contains(lowerQuery);
      return nameMatches || locationMatches;
    }).toList();
  }

  void loadAgent(String agentId) {
    _isLoading = true;
    notifyListeners();

    _settingsSub?.cancel();
    _settingsSub = _agentService.streamAgentSettings(agentId).listen((settings) {
      _agentSettings = settings;
      _isLoading = false;
      notifyListeners();
    });

    _farmersSub?.cancel();
    _farmersSub = _agentService.streamFarmerList(agentId).listen((farmers) {
      _farmerList = farmers;
      notifyListeners();
    });

    _barrelStockSub?.cancel();
    _barrelStockSub = _barrelService.streamBarrelStock(agentId).listen((stock) {
      _barrelStock = stock;
      notifyListeners();
    });

    _barrelBookingsSub?.cancel();
    _barrelBookingsSub = _barrelService.streamAgentBookings(agentId).listen((bookings) {
      _barrelBookings = bookings;
      notifyListeners();
    });

    _linkRequestsSub?.cancel();
    _linkRequestsSub = FirebaseFirestore.instance
        .collection('link_requests')
        .where('agentId', isEqualTo: agentId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      _linkRequests = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      notifyListeners();
    });
  }

  Future<void> updatePrice(String type, double price, [double? price2]) async {
    if (_agentSettings == null) return;
    final agentId = _agentSettings!.agentId;

    if (type == 'Open Market Price') {
      final rss5 = price2 ?? 0.0;
      await _agentService.updateOpenMarketPrice(agentId, price, rss5);
      FcmDispatchService().notifyOpenMarketPriceUpdate(agentId, price, rss5);
    } else if (type == 'Company Price' || type == 'Board Rate') {
      await _agentService.updateCompanyPrice(agentId, price);
      // FcmDispatchService().notifyBoardRateUpdate handles this now, but wait, agent doesn't edit Board Rate!
      // This path won't be called for Board Rate since it's read-only.
    } else if (type == 'Global Agent Price') {
      await _agentService.updateGlobalAgentPrice(agentId, price);
      FcmDispatchService().notifyAgentPriceUpdate(agentId, price);
    }
  }



  Future<void> removeFarmer(String farmerId) async {
    await _agentService.removeFarmer(farmerId);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> upsertStock(int totalBarrels) async {
    if (_agentSettings == null) throw Exception("Agent not loaded");
    await _barrelService.upsertStock(_agentSettings!.agentId, totalBarrels);
  }

  Future<void> approveBooking(String bookingId) async {
    if (_agentSettings == null) throw Exception("Agent not loaded");
    await _barrelService.approveBooking(bookingId, _agentSettings!.agentId);
  }

  Future<void> dispatchBooking(String bookingId) async {
    await _barrelService.dispatchBooking(bookingId);
  }

  Future<void> returnBooking(String bookingId) async {
    if (_agentSettings == null) throw Exception("Agent not loaded");
    await _barrelService.returnBooking(bookingId, _agentSettings!.agentId);
  }

  Future<void> cancelBooking(String bookingId, String cancelReason) async {
    if (_agentSettings == null) throw Exception("Agent not loaded");
    await _barrelService.cancelBooking(bookingId, _agentSettings!.agentId, cancelReason);
  }

  Future<void> acceptLinkRequest(String requestId, String farmerId, String farmerName, String agentName) async {
    if (_agentSettings == null) throw Exception("Agent not loaded");
    await FcmDispatchService().acceptLinkRequest(requestId, farmerId, agentName);
  }

  Future<void> rejectLinkRequest(String requestId, String farmerId, String agentName) async {
    await FcmDispatchService().rejectLinkRequest(requestId, farmerId, agentName);
  }

  @override
  void dispose() {
    _settingsSub?.cancel();
    _farmersSub?.cancel();
    _barrelStockSub?.cancel();
    _barrelBookingsSub?.cancel();
    _linkRequestsSub?.cancel();
    super.dispose();
  }
}
