import 'dart:async';
import 'package:flutter/material.dart';
import '../services/farmer_service.dart';
import '../services/cache_service.dart';

class FarmerProvider extends ChangeNotifier {
  final FarmerService _farmerService = FarmerService();
  final CacheService _cacheService = CacheService();

  double _effectivePrice = 0.0;
  double _companyPrice = 0.0;
  double _openMarketPrice = 0.0;
  bool _isOffline = false;
  bool _isLoading = true;
  String _farmerName = '';
  bool _hasCustomPrice = false;

  StreamSubscription? _effectivePriceSub;
  StreamSubscription? _agentSettingsSub;

  double get effectivePrice => _effectivePrice;
  double get companyPrice => _companyPrice;
  double get openMarketPrice => _openMarketPrice;
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

      _effectivePriceSub = _farmerService.streamEffectivePrice(farmerId, agentId).listen(
        (result) {
          _effectivePrice = result.price;
          _hasCustomPrice = result.isCustom;
          _saveToCache();
          _isLoading = false;
          _isOffline = false;
          notifyListeners();
        },
        onError: (e) => _handleOffline(),
      );

      _agentSettingsSub = _farmerService.streamAgentSettings(agentId).listen(
        (settings) {
          _companyPrice = settings.companyPrice;
          _openMarketPrice = settings.openMarketPrice;
          _saveToCache();
          _isLoading = false;
          _isOffline = false;
          notifyListeners();
        },
        onError: (e) => _handleOffline(),
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
        _companyPrice = cached['companyPrice'] ?? 0.0;
        _openMarketPrice = cached['openMarketPrice'] ?? 0.0;
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToCache() async {
    // Only save if not offline
    if (_isOffline) return;
    
    await _cacheService.saveLastKnownPrices(
      effectivePrice: _effectivePrice,
      companyPrice: _companyPrice,
      openMarketPrice: _openMarketPrice,
      timestamp: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _effectivePriceSub?.cancel();
    _agentSettingsSub?.cancel();
    super.dispose();
  }
}
