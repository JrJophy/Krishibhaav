import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String mobile;
  final String role;
  final String location;
  final String crop;
  final String? agentId;
  final String fcmToken;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.mobile,
    required this.role,
    required this.location,
    required this.crop,
    this.agentId,
    required this.fcmToken,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'uid': uid,
      'name': name,
      'mobile': mobile,
      'role': role,
      'location': location,
      'crop': crop,
      'fcmToken': fcmToken,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
    if (agentId != null) map['agentId'] = agentId;
    return map;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      mobile: map['mobile'] ?? '',
      role: map['role'] ?? '',
      location: map['location'] ?? '',
      crop: map['crop'] ?? '',
      agentId: map['agentId'],
      fcmToken: map['fcmToken'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }
}
