import 'package:flutter_test/flutter_test.dart';
import 'package:krishibhaav/core/market_message_parser.dart';

void main() {
  const String verbatimFixture = '''
**MARKET INTERNAL**
BoardRates
KTYM/KOCHI
RSS4:268
RSS5:264
ISNR20:212
LATEX60%:169.05
AGARTALA RATE
RSS4:258
RSS5:255
-----RSS4 PASING-----
PARTY GODOWN 268
KTM 266
MBR 266
RSS5(PSNG) 262
SMOKD5(PSNG) 265
S.LOOSE(PSNG) 260
Ppr
600L/W 715
550L/W 695
DRYLOT 225
KOCHILOT 215
Scrap(80%) 160.00
Scrap(78%) 156.00
Scrap(75%) 150.00
Scrap(70%) 140.00
ISNR 210
Cenex 160
Latex 243 to 245
FLP Association Price:
Cenex - 162/Ltr
Field - 243/Kg
IPSR- 166 /Kg
(Indian Purified Skim Rubber)
For the Daily Rubber Market
Messages & News contact 
Ph: 9446125950
''';

  group('MarketMessageParser Tests', () {
    test('1. Parses both RSS4 and RSS5 successfully from full fixture', () {
      final result = MarketMessageParser.parseMarketMessage(verbatimFixture);
      expect(result.error, isNull);
      expect(result.openMarketRss4, 268.0);
      expect(result.openMarketRss5, 262.0);
    });

    test('2. Missing PARTY GODOWN returns rss4 null, rss5 still found', () {
      final modifiedFixture = verbatimFixture.replaceFirst('PARTY GODOWN 268', 'SOMETHING ELSE 268');
      final result = MarketMessageParser.parseMarketMessage(modifiedFixture);
      expect(result.error, isNull);
      expect(result.openMarketRss4, isNull);
      expect(result.openMarketRss5, 262.0);
    });

    test('3. Garbage text returns error', () {
      final result = MarketMessageParser.parseMarketMessage('Some random string with numbers 123 456');
      expect(result.error, 'Could not find market prices in this message');
      expect(result.openMarketRss4, isNull);
      expect(result.openMarketRss5, isNull);
    });

    test('4. Decimal variant parses correctly', () {
      const decimalFixture = 'PARTY GODOWN 268.50\\nRSS5(PSNG) 262.75';
      final result = MarketMessageParser.parseMarketMessage(decimalFixture);
      expect(result.error, isNull);
      expect(result.openMarketRss4, 268.5);
      expect(result.openMarketRss5, 262.75);
    });

    test('5. Extra whitespace and case variations parse correctly', () {
      const messyFixture = '   party  godown   270.0 \\n  rss5 (  psng )  265   ';
      final result = MarketMessageParser.parseMarketMessage(messyFixture);
      expect(result.error, isNull);
      expect(result.openMarketRss4, 270.0);
      expect(result.openMarketRss5, 265.0);
    });
  });
}
