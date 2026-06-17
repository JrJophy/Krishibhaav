import 'package:cloud_firestore/cloud_firestore.dart';

class BarrelBookingModel {
  final String bookingId;
  final String agentId;
  final String farmerId;
  final String farmerName;
  final String location;
  final int quantity;
  final String status;
  final String? cancelReason;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final Timestamp requestedAt;
  final Timestamp? approvedAt;
  final Timestamp? dispatchedAt;
  final Timestamp? returnedAt;
  final Timestamp? cancelledAt;

  BarrelBookingModel({
    required this.bookingId,
    required this.agentId,
    required this.farmerId,
    required this.farmerName,
    required this.location,
    required this.quantity,
    required this.status,
    this.cancelReason,
    required this.createdAt,
    required this.updatedAt,
    required this.requestedAt,
    this.approvedAt,
    this.dispatchedAt,
    this.returnedAt,
    this.cancelledAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'agentId': agentId,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'location': location,
      'quantity': quantity,
      'status': status,
      'cancelReason': cancelReason,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'requestedAt': requestedAt,
      'approvedAt': approvedAt,
      'dispatchedAt': dispatchedAt,
      'returnedAt': returnedAt,
      'cancelledAt': cancelledAt,
    };
  }

  factory BarrelBookingModel.fromMap(Map<String, dynamic> map, String docId) {
    return BarrelBookingModel(
      bookingId: map['bookingId'] ?? docId,
      agentId: map['agentId'] ?? '',
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      location: map['location'] ?? '',
      quantity: ((map['quantity'] ?? 0) as num).toInt(),
      status: map['status'] ?? 'requested',
      cancelReason: map['cancelReason'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
      requestedAt: map['requestedAt'] ?? Timestamp.now(),
      approvedAt: map['approvedAt'],
      dispatchedAt: map['dispatchedAt'],
      returnedAt: map['returnedAt'],
      cancelledAt: map['cancelledAt'],
    );
  }

  BarrelBookingModel copyWith({
    String? bookingId,
    String? agentId,
    String? farmerId,
    String? farmerName,
    String? location,
    int? quantity,
    String? status,
    String? cancelReason,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Timestamp? requestedAt,
    Timestamp? approvedAt,
    Timestamp? dispatchedAt,
    Timestamp? returnedAt,
    Timestamp? cancelledAt,
  }) {
    return BarrelBookingModel(
      bookingId: bookingId ?? this.bookingId,
      agentId: agentId ?? this.agentId,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      location: location ?? this.location,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      cancelReason: cancelReason ?? this.cancelReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      requestedAt: requestedAt ?? this.requestedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      dispatchedAt: dispatchedAt ?? this.dispatchedAt,
      returnedAt: returnedAt ?? this.returnedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }
}
