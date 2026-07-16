import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/farmer_service.dart';
import '../services/agent_service.dart';
import '../services/cache_service.dart';
import '../models/board_rate_model.dart';
import '../services/board_rate_service.dart';
import '../services/barrel_service.dart';
import '../models/barrel_booking_model.dart';
import '../models/barrel_stock_model.dart';

class FarmerProvider extends ChangeNotifier {
  final FarmerService _farmerService = FarmerService();
  final AgentService _agentService = AgentService();
  final CacheService _cacheService = CacheService();
  final BoardRateService _boardRateService = BoardRateService();
  final BarrelService _barrelService = BarrelService();

  double _effectivePrice = 0.0;
  double _openMarketPrice = 0.0;
  double _openMarketRss5 = 0.0;
  bool _canSeeBoardRate = false;
  bool _canSeeOpenMarket = false;
  BoardRateModel? _boardRate;

  bool _isOffline = false;
  bool _isLoading = true;
  String _farmerId = '';
  String _farmerName = '';
  String _agentId = '';
  String _location = '';
  bool _hasCustomPrice = false;
  BarrelStockModel? _barrelStock;
  List<BarrelBookingModel> _barrelBookings = [];

  StreamSubscription? _effectivePriceSub;
  StreamSubscription? _agentSettingsSub;
  StreamSubscription? _boardRateSub;
  StreamSubscription? _barrelStockSub;
  StreamSubscription? _barrelBookingsSub;

  double get effectivePrice => _effectivePrice;
  double get openMarketPrice => _openMarketPrice;
  double get openMarketRss5 => _openMarketRss5;
  bool get canSeeBoardRate => _canSeeBoardRate;
  bool get canSeeOpenMarket => _canSeeOpenMarket;
  BoardRateModel? get boardRate => _boardRate;
  bool get isOffline => _isOffline;
  bool get isLoading => _isLoading;
  String get farmerName => _farmerName;
  String get agentId => _agentId;
  String get location => _location;
  bool get hasCustomPrice => _hasCustomPrice;
  BarrelStockModel? get barrelStock => _barrelStock;
  List<BarrelBookingModel> get barrelBookings => _barrelBookings;

  Future<void> loadFarmer(String farmerId) async {
    _isLoading = true;
    _isOffline = false;
    notifyListeners();

    try {
      final user = await _farmerService.getFarmerUser(farmerId);
      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      _farmerId = farmerId;
      _farmerName = user.name;
      _agentId = user.agentId ?? '';
      _location = user.location;
      final agentId = user.agentId;

      if (agentId == null || agentId.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      _effectivePriceSub?.cancel();
      _agentSettingsSub?.cancel();
      _boardRateSub?.cancel();
      _barrelStockSub?.cancel();
      _barrelBookingsSub?.cancel();

      _effectivePriceSub = _farmerService.streamEffectivePrice(farmerId, agentId).listen(
        (result) {
          _effectivePrice = result.price;
          _hasCustomPrice = result.isCustom;
          _canSeeBoardRate = result.canSeeBoardRate;
          _canSeeOpenMarket = result.canSeeOpenMarket;
          _saveToCache();
          _isLoading = false;
          _isOffline = false;
          notifyListeners();
        },
        onError: (e) => _handleOffline(),
      );

      _agentSettingsSub = _agentService.streamAgentSettings(agentId).listen(
        (settings) {
          _openMarketPrice = settings.openMarketPrice;
          _openMarketRss5 = settings.openMarketRss5;
          _saveToCache();
          _isLoading = false;
          _isOffline = false;
          notifyListeners();
        },
        onError: (e) => _handleOffline(),
      );

      _boardRateSub = _boardRateService.streamBoardRate().listen(
        (rate) {
          _boardRate = rate;
          notifyListeners();
        },
        onError: (e) {
          if (kDebugMode) {
            debugPrint('Error streaming board rate: $e');
          }
        },
      );

      _barrelStockSub = _barrelService.streamBarrelStock(agentId).listen(
        (stock) {
          _barrelStock = stock;
          notifyListeners();
        },
        onError: (e) {
          if (kDebugMode) {
            debugPrint('Error streaming barrel stock: $e');
          }
        },
      );

      _barrelBookingsSub = _barrelService.streamFarmerBookings(farmerId).listen(
        (bookings) {
          _barrelBookings = bookings;
          notifyListeners();
        },
        onError: (e) {
          if (kDebugMode) {
            debugPrint('Error streaming barrel bookings: $e');
          }
        },
      );
    } catch (e) {
      await _handleOffline();
    }
  }

  Future<void> _handleOffline() async {
    if (!_isOffline) {
      _isOffline = true;
      final cached = await _cacheService.getLastKnownPrices();
      if (cached != null) {
        _effectivePrice = cached['effectivePrice'] ?? 0.0;
        _openMarketPrice = cached['openMarketPrice'] ?? 0.0;
        // Not aggressively caching new fields yet since offline isn't primarily focused in this sub-phase, but we can do our best
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToCache() async {
    // Only save if not offline
    if (_isOffline) return;
    
    try {
      await _cacheService.saveLastKnownPrices(
        effectivePrice: _effectivePrice,
        companyPrice: 0.0, // Legacy fallback for cache layer
        openMarketPrice: _openMarketPrice,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save to cache: $e');
      }
    }
  }

  Future<void> createBooking(int quantity) async {
    if (_agentId.isEmpty) throw Exception('Agent ID missing');
    final bookingId = FirebaseFirestore.instance.collection('barrel_bookings').doc().id;
    await _barrelService.createBooking(
      bookingId: bookingId,
      agentId: _agentId,
      farmerId: _farmerId,
      farmerName: _farmerName,
      location: _location,
      quantity: quantity,
    );
  }

  Future<void> cancelBooking(String bookingId, String reason) async {
    await _barrelService.cancelBooking(bookingId, _agentId, reason);
  }

  Future<void> returnEmpty(String bookingId) async {
    await _barrelService.returnBookingEmpty(bookingId, _agentId);
  }

  Future<void> returnFilled(String bookingId) async {
    await _barrelService.returnBookingFilled(bookingId, _agentId);
  }

  @override
  void dispose() {
    _effectivePriceSub?.cancel();
    _agentSettingsSub?.cancel();
    _boardRateSub?.cancel();
    _barrelStockSub?.cancel();
    _barrelBookingsSub?.cancel();
    super.dispose();
  }
}
