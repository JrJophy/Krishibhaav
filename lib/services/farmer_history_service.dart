import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/price_point.dart';
import '../models/open_market_price_point.dart';

class FarmerPriceStats {
  final double sevenDayHigh;
  final double sevenDayLow;
  final double thirtyDayHigh;
  final double thirtyDayLow;

  FarmerPriceStats({
    required this.sevenDayHigh,
    required this.sevenDayLow,
    required this.thirtyDayHigh,
    required this.thirtyDayLow,
  });
}

class FarmerHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<PricePoint>> fetchHistory(String farmerId, {int days = 30}) async {
    try {
      final snapshot = await _firestore
          .collection('farmer_prices')
          .doc(farmerId)
          .collection('history')
          .orderBy('date', descending: true)
          .limit(days)
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      final points = snapshot.docs
          .where((doc) => doc.data().containsKey('effectivePrice') && doc.data()['effectivePrice'] != null)
          .map((doc) => PricePoint.fromMap(doc.data()))
          .toList()
          .reversed
          .toList();
          
      return points;
    } catch (e) {
      return [];
    }
  }

  static List<OpenMarketPricePoint> parseOpenMarketHistory(List<Map<String, dynamic>> rawDocs) {
    return rawDocs
        .map((data) => OpenMarketPricePoint.fromMap(data))
        .where((p) => p.rss4 > 0 && p.rss5 > 0)
        .toList()
        .reversed
        .toList();
  }

  Future<List<OpenMarketPricePoint>> fetchOpenMarketHistory({int days = 30}) async {
    try {
      final snapshot = await _firestore
          .collection('price_history')
          .orderBy('date', descending: true)
          .limit(days)
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      final rawDocs = snapshot.docs.map((doc) => doc.data()).toList();
      return parseOpenMarketHistory(rawDocs);
    } catch (e) {
      return [];
    }
  }

  static FarmerPriceStats computeOpenMarketStats(List<OpenMarketPricePoint> points) {
    if (points.isEmpty) {
      return FarmerPriceStats(
        sevenDayHigh: 0,
        sevenDayLow: 0,
        thirtyDayHigh: 0,
        thirtyDayLow: 0,
      );
    }

    final thirtyDayPrices = points.map((p) => p.rss4).toList();
    final thirtyDayHigh = thirtyDayPrices.reduce((a, b) => a > b ? a : b);
    final thirtyDayLow = thirtyDayPrices.reduce((a, b) => a < b ? a : b);

    final recentPoints = points.length > 7 ? points.sublist(points.length - 7) : points;
    final sevenDayPrices = recentPoints.map((p) => p.rss4).toList();
    final sevenDayHigh = sevenDayPrices.reduce((a, b) => a > b ? a : b);
    final sevenDayLow = sevenDayPrices.reduce((a, b) => a < b ? a : b);

    return FarmerPriceStats(
      sevenDayHigh: sevenDayHigh,
      sevenDayLow: sevenDayLow,
      thirtyDayHigh: thirtyDayHigh,
      thirtyDayLow: thirtyDayLow,
    );
  }

  static FarmerPriceStats computeStats(List<PricePoint> points) {
    if (points.isEmpty) {
      return FarmerPriceStats(
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

    return FarmerPriceStats(
      sevenDayHigh: sevenDayHigh,
      sevenDayLow: sevenDayLow,
      thirtyDayHigh: thirtyDayHigh,
      thirtyDayLow: thirtyDayLow,
    );
  }
}
