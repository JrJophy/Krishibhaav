import 'package:cloud_firestore/cloud_firestore.dart';

class AgentSettingsModel {
  final String agentId;
  final double openMarketPrice;
  final double openMarketRss5;
  final double companyPrice;
  final double globalAgentPrice;
  final Timestamp lastUpdated;

  AgentSettingsModel({
    required this.agentId,
    required this.openMarketPrice,
    this.openMarketRss5 = 0.0,
    required this.companyPrice,
    required this.globalAgentPrice,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'agentId': agentId,
      'openMarketPrice': openMarketPrice,
      'openMarketRss5': openMarketRss5,
      'companyPrice': companyPrice,
      'globalAgentPrice': globalAgentPrice,
      'lastUpdated': lastUpdated,
    };
  }

  factory AgentSettingsModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AgentSettingsModel(
      agentId: map['agentId'] ?? documentId,
      openMarketPrice: (map['openMarketPrice'] ?? 0.0).toDouble(),
      openMarketRss5: (map['openMarketRss5'] ?? 0.0).toDouble(),
      companyPrice: (map['companyPrice'] ?? 0.0).toDouble(),
      globalAgentPrice: (map['globalAgentPrice'] ?? 0.0).toDouble(),
      lastUpdated: map['lastUpdated'] ?? Timestamp.now(),
    );
  }
}
