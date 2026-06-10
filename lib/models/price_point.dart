class PricePoint {
  final String date;
  final double price;

  PricePoint({required this.date, required this.price});

  factory PricePoint.fromMap(Map<String, dynamic> map) {
    return PricePoint(
      date: map['date'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
    );
  }
}
