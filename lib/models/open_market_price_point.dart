class OpenMarketPricePoint {
  final String date;
  final double rss4;
  final double rss5;

  double get averagePrice => (rss4 + rss5) / 2;

  OpenMarketPricePoint({required this.date, required this.rss4, required this.rss5});

  factory OpenMarketPricePoint.fromMap(Map<String, dynamic> map) {
    double parse(dynamic raw) {
      if (raw is num) return raw.toDouble();
      if (raw is String) return double.tryParse(raw) ?? 0.0;
      return 0.0;
    }
    return OpenMarketPricePoint(
      date: map['date'] ?? '',
      rss4: parse(map['openMarketPrice']),
      rss5: parse(map['openMarketRss5']),
    );
  }
}
