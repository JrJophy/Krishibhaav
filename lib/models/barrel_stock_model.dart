import 'package:cloud_firestore/cloud_firestore.dart';

class BarrelStockModel {
  final String agentId;
  final int totalBarrels;
  final int availableBarrels;
  // PHASE 3: inert. NOT incremented yet. V3 payout ledger wires this. Do not wire.
  final int filledBarrels;
  final Timestamp lastUpdated;

  BarrelStockModel({
    required this.agentId,
    required this.totalBarrels,
    required this.availableBarrels,
    this.filledBarrels = 0,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'agentId': agentId,
      'totalBarrels': totalBarrels,
      'availableBarrels': availableBarrels,
      'filledBarrels': filledBarrels,
      'lastUpdated': lastUpdated,
    };
  }

  factory BarrelStockModel.fromMap(Map<String, dynamic> map, String docId) {
    return BarrelStockModel(
      agentId: map['agentId'] ?? docId,
      totalBarrels: ((map['totalBarrels'] ?? 0) as num).toInt(),
      availableBarrels: ((map['availableBarrels'] ?? 0) as num).toInt(),
      filledBarrels: ((map['filledBarrels'] ?? 0) as num).toInt(),
      lastUpdated: map['lastUpdated'] ?? Timestamp.now(),
    );
  }

  BarrelStockModel copyWith({
    String? agentId,
    int? totalBarrels,
    int? availableBarrels,
    int? filledBarrels,
    Timestamp? lastUpdated,
  }) {
    return BarrelStockModel(
      agentId: agentId ?? this.agentId,
      totalBarrels: totalBarrels ?? this.totalBarrels,
      availableBarrels: availableBarrels ?? this.availableBarrels,
      filledBarrels: filledBarrels ?? this.filledBarrels,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
