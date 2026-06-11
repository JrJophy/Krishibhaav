import 'package:cloud_firestore/cloud_firestore.dart';

class FarmerPriceModel {
  final String farmerId;
  final String agentId;
  final double? customPrice;
  final bool hasCustomPrice;
  final bool canSeeBoardRate;
  final bool canSeeOpenMarket;
  final Timestamp updatedAt;

  FarmerPriceModel({
    required this.farmerId,
    required this.agentId,
    this.customPrice,
    required this.hasCustomPrice,
    required this.canSeeBoardRate,
    required this.canSeeOpenMarket,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'farmerId': farmerId,
      'agentId': agentId,
      'customPrice': customPrice,
      'hasCustomPrice': hasCustomPrice,
      'canSeeBoardRate': canSeeBoardRate,
      'canSeeOpenMarket': canSeeOpenMarket,
      'updatedAt': updatedAt,
    };
  }

  factory FarmerPriceModel.fromMap(Map<String, dynamic> map, String documentId) {
    return FarmerPriceModel(
      farmerId: map['farmerId'] ?? documentId,
      agentId: map['agentId'] ?? '',
      customPrice: map['customPrice'] != null ? (map['customPrice'] as num).toDouble() : null,
      hasCustomPrice: map['hasCustomPrice'] ?? false,
      canSeeBoardRate: map['canSeeBoardRate'] ?? false,
      canSeeOpenMarket: map['canSeeOpenMarket'] ?? false,
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }
}
