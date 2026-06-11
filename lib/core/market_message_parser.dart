class MarketMessageResult {
  final double? openMarketRss4;
  final double? openMarketRss5;
  final String? error;

  MarketMessageResult({this.openMarketRss4, this.openMarketRss5, this.error});
}

class MarketMessageParser {
  static MarketMessageResult parseMarketMessage(String raw) {
    if (raw.trim().isEmpty) {
      return MarketMessageResult(error: 'Message is empty.');
    }

    // Match PARTY GODOWN followed by a number
    final rss4RegEx = RegExp(r'PARTY\s+GODOWN\s+(\d+(?:\.\d+)?)', caseSensitive: false);
    // Match RSS5(PSNG) followed by a number (tolerant of spaces around parens)
    final rss5RegEx = RegExp(r'RSS5\s*\(\s*PSNG\s*\)\s+(\d+(?:\.\d+)?)', caseSensitive: false);

    double? rss4;
    double? rss5;

    final match4 = rss4RegEx.firstMatch(raw);
    if (match4 != null && match4.groupCount >= 1) {
      rss4 = double.tryParse(match4.group(1)!);
    }

    final match5 = rss5RegEx.firstMatch(raw);
    if (match5 != null && match5.groupCount >= 1) {
      rss5 = double.tryParse(match5.group(1)!);
    }

    if (rss4 == null && rss5 == null) {
      return MarketMessageResult(error: 'Could not find market prices in this message');
    }

    return MarketMessageResult(
      openMarketRss4: rss4,
      openMarketRss5: rss5,
    );
  }
}
