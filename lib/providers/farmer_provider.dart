import 'dart:async';
import 'package:flutter/material.dart';
import '../services/farmer_service.dart';
import '../services/cache_service.dart';
import '../models/board_rate_model.dart';
import '../services/board_rate_service.dart';

class FarmerProvider extends ChangeNotifier {
  final FarmerService _farmerService = FarmerService();
  final CacheService _cacheService = CacheService();
  final BoardRateService _boardRateService = BoardRateService();

  double _effectivePrice = 0.0;
  double _openMarketPrice = 0.0;
  double _openMarketRss5 = 0.0;
  bool _canSeeBoardRate = false;
  bool _canSeeOpenMarket = false;
  BoardRateModel? _boardRate;

  bool _isOffline = false;
  bool _isLoading = true;
  String _farmerName = '';
  bool _hasCustomPrice = false;

  StreamSubscription? _effectivePriceSub;
  StreamSubscription? _agentSettingsSub;
  StreamSubscription? _boardRateSub;

  double get effectivePrice => _effectivePrice;
  double get openMarketPrice => _openMarketPrice;
  double get openMarketRss5 => _openMarketRss5;
  bool get canSeeBoardRate => _canSeeBoardRate;
  bool get canSeeOpenMarket => _canSeeOpenMarket;
  BoardRateModel? get boardRate => _boardRate;
  bool get isOffline => _isOffline;
  bool get isLoading => _isLoading;
  String get farmerName => _farmerName;
  bool get hasCustomPrice => _hasCustomPrice;

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

      _farmerName = user.name;
      final agentId = user.agentId;

      if (agentId == null || agentId.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      _effectivePriceSub?.cancel();
      _agentSettingsSub?.cancel();
      _boardRateSub?.cancel();

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

      _agentSettingsSub = _farmerService.streamAgentSettings(agentId).listen(
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
        onError: (e) => debugPrint('Error streaming board rate: $e'),
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
      debugPrint('Failed to save to cache: $e');
    }
  }

  @override
  void dispose() {
    _effectivePriceSub?.cancel();
    _agentSettingsSub?.cancel();
    _boardRateSub?.cancel();
    super.dispose();
  }
}
