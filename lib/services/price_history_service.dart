import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/price_point.dart';

class PriceStats {
  final double sevenDayHigh;
  final double sevenDayLow;
  final double thirtyDayHigh;
  final double thirtyDayLow;

  PriceStats({
    required this.sevenDayHigh,
    required this.sevenDayLow,
    required this.thirtyDayHigh,
    required this.thirtyDayLow,
  });
}

class PriceHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<PricePoint>> fetchPriceHistory({int days = 30}) async {
    try {
      final snapshot = await _firestore
          .collection('price_history')
          .orderBy('date', descending: true)
          .limit(days)
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      final points = snapshot.docs
          .where((doc) => doc.data().containsKey('agentGlobalPrice') && doc.data()['agentGlobalPrice'] != null)
          .map((doc) => PricePoint.fromMap(doc.data()))
          .toList()
          .reversed
          .toList();
          
      return points;
    } catch (e) {
      return [];
    }
  }

  PriceStats computeStats(List<PricePoint> points) {
    if (points.isEmpty) {
      return PriceStats(
        sevenDayHigh: 0,
        sevenDayLow: 0,
        thirtyDayHigh: 0,
        thirtyDayLow: 0,
      );
    }

    final thirtyDayPrices = points.map((p) => p.price).toList();
    final thirtyDayHigh = thirtyDayPrices.reduce((a, b) => a > b ? a : b);
    final thirtyDayLow = thirtyDayPrices.reduce((a, b) => a < b ? a : b);

    final recentPoints = points.length > 7 ? points.sublist(points.length - 7) : points;
    final sevenDayPrices = recentPoints.map((p) => p.price).toList();
    final sevenDayHigh = sevenDayPrices.reduce((a, b) => a > b ? a : b);
    final sevenDayLow = sevenDayPrices.reduce((a, b) => a < b ? a : b);

    return PriceStats(
      sevenDayHigh: sevenDayHigh,
      sevenDayLow: sevenDayLow,
      thirtyDayHigh: thirtyDayHigh,
      thirtyDayLow: thirtyDayLow,
    );
  }
}
