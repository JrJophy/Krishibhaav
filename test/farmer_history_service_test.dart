import 'package:flutter_test/flutter_test.dart';
import 'package:krishibhaav/services/farmer_history_service.dart';

void main() {
  group('FarmerHistoryService Tests', () {
    test('1. parseOpenMarketHistory handles missing and null prices gracefully', () {
      final docs = [
        // Valid doc
        {
          'date': '2026-06-18',
          'openMarketPrice': 272.0,
          'openMarketRss5': 266.0,
        },
        // Missing openMarketPrice (e.g. before Phase 9a)
        {
          'date': '2026-06-10',
          'openMarketRss5': 260.0,
        },
        // Null openMarketPrice
        {
          'date': '2026-06-11',
          'openMarketPrice': null,
          'openMarketRss5': 260.0,
        },
        // Missing openMarketRss5
        {
          'date': '2026-06-12',
          'openMarketPrice': 270.0,
        },
        // Zero openMarketPrice
        {
          'date': '2026-06-13',
          'openMarketPrice': 0.0,
          'openMarketRss5': 260.0,
        },
        // Another valid doc
        {
          'date': '2026-06-17',
          'openMarketPrice': 271.0,
          'openMarketRss5': 265.0,
        },
      ];

      final results = FarmerHistoryService.parseOpenMarketHistory(docs);

      // Should only include docs where both rss4 and rss5 are > 0
      // In this case, 2026-06-18 and 2026-06-17
      expect(results.length, 2);

      // reversed.toList() means chronological order (oldest first)
      expect(results[0].date, '2026-06-17');
      expect(results[0].rss4, 271.0);
      expect(results[0].rss5, 265.0);

      expect(results[1].date, '2026-06-18');
      expect(results[1].rss4, 272.0);
      expect(results[1].rss5, 266.0);
    });

    test('2. computeOpenMarketStats computes correct 7-day and 30-day stats', () {
      final rawDocs = [
        {'date': '2026-06-18', 'openMarketPrice': 272.0, 'openMarketRss5': 266.0}, // highest
        {'date': '2026-06-17', 'openMarketPrice': 271.0, 'openMarketRss5': 265.0},
        {'date': '2026-06-16', 'openMarketPrice': 270.0, 'openMarketRss5': 264.0},
        {'date': '2026-06-15', 'openMarketPrice': 269.0, 'openMarketRss5': 263.0},
        {'date': '2026-06-14', 'openMarketPrice': 268.0, 'openMarketRss5': 262.0},
        {'date': '2026-06-13', 'openMarketPrice': 267.0, 'openMarketRss5': 261.0},
        {'date': '2026-06-12', 'openMarketPrice': 266.0, 'openMarketRss5': 260.0}, // lowest 7-day
        {'date': '2026-06-11', 'openMarketPrice': 265.0, 'openMarketRss5': 259.0},
        {'date': '2026-06-10', 'openMarketPrice': 264.0, 'openMarketRss5': 258.0}, // lowest 30-day
      ];

      final points = FarmerHistoryService.parseOpenMarketHistory(rawDocs);
      
      final stats = FarmerHistoryService.computeOpenMarketStats(points);
      
      // Points length is 9
      // highest 30-day is 272
      // lowest 30-day is 264
      expect(stats.thirtyDayHigh, 272.0);
      expect(stats.thirtyDayLow, 264.0);

      // recent 7 days (index 2 to 8 because of reversal)
      // 2026-06-16 to 2026-06-10
      // wait, reversed means older to newer
      // rawDocs is newest to oldest
      // parse reverses it -> oldest to newest
      // sublist(length - 7) -> the 7 newest items (2026-06-12 to 2026-06-18)
      // so 7-day high is 272, 7-day low is 266
      expect(stats.sevenDayHigh, 272.0);
      expect(stats.sevenDayLow, 266.0);
    });
  });
}
