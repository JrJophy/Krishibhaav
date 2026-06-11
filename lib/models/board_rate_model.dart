import 'package:cloud_firestore/cloud_firestore.dart';

class BoardRateModel {
  final double rss4;
  final double rss5;
  final String date;
  final Timestamp updatedAt;

  BoardRateModel({
    required this.rss4,
    required this.rss5,
    required this.date,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'rss4': rss4,
      'rss5': rss5,
      'date': date,
      'updatedAt': updatedAt,
    };
  }

  factory BoardRateModel.fromMap(Map<String, dynamic> map) {
    return BoardRateModel(
      rss4: (map['rss4'] ?? 0.0).toDouble(),
      rss5: (map['rss5'] ?? 0.0).toDouble(),
      date: map['date'] ?? '',
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }
}
