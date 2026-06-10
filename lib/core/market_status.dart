class MarketStatus {
  static bool isMarketOpen() {
    final now = DateTime.now();
    // Monday is 1, Sunday is 7
    if (now.weekday == DateTime.sunday) {
      return false;
    }
    
    // Check if between 9:00 AM and 5:00 PM (17:00)
    // 17:00 is exactly 5:00 PM. So up to 16:59:59 is < 17
    final hour = now.hour;
    if (hour >= 9 && hour < 17) {
      return true;
    }
    
    return false;
  }
}
