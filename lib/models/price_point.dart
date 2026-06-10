class PricePoint {
  final String date;
  final double price;

  PricePoint({required this.date, required this.price});

  factory PricePoint.fromMap(Map<String, dynamic> map) {
    final raw = map['rss4Price'] ?? map['price'];
    double parsed = 0.0;
    if (raw is num) {
      parsed = raw.toDouble();
    } else if (raw is String) {
      parsed = double.tryParse(raw) ?? 0.0;
    }
    return PricePoint(
      date: map['date'] ?? '',
      price: parsed,
    );
  }
}
