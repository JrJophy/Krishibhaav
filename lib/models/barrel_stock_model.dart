import 'package:cloud_firestore/cloud_firestore.dart';

class BarrelStockModel {
  final String agentId;
  final int totalBarrels;
  final int availableBarrels;

  final Timestamp lastUpdated;

  BarrelStockModel({
    required this.agentId,
    required this.totalBarrels,
    required this.availableBarrels,

    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'agentId': agentId,
      'totalBarrels': totalBarrels,
      'availableBarrels': availableBarrels,

      'lastUpdated': lastUpdated,
    };
  }

  factory BarrelStockModel.fromMap(Map<String, dynamic> map, String docId) {
    return BarrelStockModel(
      agentId: map['agentId'] ?? docId,
      totalBarrels: ((map['totalBarrels'] ?? 0) as num).toInt(),
      availableBarrels: ((map['availableBarrels'] ?? 0) as num).toInt(),

      lastUpdated: map['lastUpdated'] ?? Timestamp.now(),
    );
  }

  BarrelStockModel copyWith({
    String? agentId,
    int? totalBarrels,
    int? availableBarrels,

    Timestamp? lastUpdated,
  }) {
    return BarrelStockModel(
      agentId: agentId ?? this.agentId,
      totalBarrels: totalBarrels ?? this.totalBarrels,
      availableBarrels: availableBarrels ?? this.availableBarrels,

      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
