import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _keyEffectivePrice = 'effective_price';
  static const String _keyCompanyPrice = 'company_price';
  static const String _keyOpenMarketPrice = 'open_market_price';
  static const String _keyTimestamp = 'last_timestamp';

  Future<void> saveLastKnownPrices({
    required double effectivePrice,
    required double companyPrice,
    required double openMarketPrice,
    required DateTime timestamp,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyEffectivePrice, effectivePrice);
    await prefs.setDouble(_keyCompanyPrice, companyPrice);
    await prefs.setDouble(_keyOpenMarketPrice, openMarketPrice);
    await prefs.setString(_keyTimestamp, timestamp.toIso8601String());
  }

  Future<Map<String, dynamic>?> getLastKnownPrices() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_keyEffectivePrice)) {
      return null;
    }
    
    final effectivePrice = prefs.getDouble(_keyEffectivePrice);
    final companyPrice = prefs.getDouble(_keyCompanyPrice);
    final openMarketPrice = prefs.getDouble(_keyOpenMarketPrice);
    final timestampStr = prefs.getString(_keyTimestamp);
    
    if (effectivePrice == null || companyPrice == null || openMarketPrice == null || timestampStr == null) {
      return null;
    }

    return {
      'effectivePrice': effectivePrice,
      'companyPrice': companyPrice,
      'openMarketPrice': openMarketPrice,
      'timestamp': DateTime.tryParse(timestampStr),
    };
  }
}
