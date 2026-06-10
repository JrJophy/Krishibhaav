import 'dart:async';
import 'package:flutter/material.dart';
import '../models/agent_settings_model.dart';
import '../models/user_model.dart';
import '../services/agent_service.dart';
import '../services/fcm_dispatch_service.dart';

class AgentProvider extends ChangeNotifier {
  final AgentService _agentService = AgentService();

  AgentSettingsModel? _agentSettings;
  List<UserModel> _farmerList = [];
  String _searchQuery = '';
  bool _isLoading = false;

  StreamSubscription<AgentSettingsModel>? _settingsSub;
  StreamSubscription<List<UserModel>>? _farmersSub;

  AgentSettingsModel? get agentSettings => _agentSettings;
  List<UserModel> get farmerList => _farmerList;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

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
  }

  Future<void> updatePrice(String type, double price) async {
    if (_agentSettings == null) return;
    final agentId = _agentSettings!.agentId;

    if (type == 'Open Market Price') {
      await _agentService.updateOpenMarketPrice(agentId, price);
      FcmDispatchService().notifyOpenMarketPriceUpdate(agentId, price);
    } else if (type == 'Company Price') {
      await _agentService.updateCompanyPrice(agentId, price);
      FcmDispatchService().notifyCompanyPriceUpdate(agentId, price);
    } else if (type == 'Global Agent Price') {
      await _agentService.updateGlobalAgentPrice(agentId, price);
      FcmDispatchService().notifyAgentPriceUpdate(agentId, price);
    }
  }

  Future<String> addFarmer(String name, String mobile, String location) async {
    if (_agentSettings == null) throw Exception("Agent not loaded");
    return await _agentService.addFarmer(_agentSettings!.agentId, name, mobile, location);
  }

  Future<void> removeFarmer(String farmerId) async {
    await _agentService.removeFarmer(farmerId);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  @override
  void dispose() {
    _settingsSub?.cancel();
    _farmersSub?.cancel();
    super.dispose();
  }
}
