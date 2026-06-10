class PricePoint {
  final String date;
  final double price;

  PricePoint({required this.date, required this.price});

  factory PricePoint.fromMap(Map<String, dynamic> map) {
    dynamic p = map['price'] ?? map['openMarketPrice'] ?? map['marketPrice'] ?? map['value'] ?? 0;
    double parsedPrice = 0.0;
    if (p is num) {
      parsedPrice = p.toDouble();
    } else if (p is String) {
      parsedPrice = double.tryParse(p) ?? 0.0;
    }
    
    return PricePoint(
      date: map['date']?.toString() ?? '',
      price: parsedPrice,
    );
  }
}
