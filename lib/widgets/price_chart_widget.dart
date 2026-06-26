import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/price_point.dart';
import '../models/open_market_price_point.dart';
import '../core/colors.dart';

enum ChartMode { agent, openMarket }

class PriceChartWidget extends StatelessWidget {
  final List<PricePoint> points;
  final List<OpenMarketPricePoint>? openMarketPoints;
  final ChartMode mode;

  const PriceChartWidget({
    super.key, 
    required this.points,
    this.openMarketPoints,
    this.mode = ChartMode.agent,
  });

  @override
  Widget build(BuildContext context) {
    final isAgent = mode == ChartMode.agent;
    final hasData = isAgent 
        ? points.isNotEmpty 
        : (openMarketPoints != null && openMarketPoints!.isNotEmpty);

    if (!hasData) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            "Price tracking starts soon",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final valueGreen = isDark ? AppColors.darkValueGreen : AppColors.lightValueGreen;
    final valueGreenSoft = isDark ? AppColors.darkValueGreenSoft : AppColors.lightValueGreenSoft;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;
    final mutedInk = ink.withValues(alpha: 0.5);

    final rss4Color = isDark ? Colors.red.shade300 : Colors.red.shade600;
    final rss5Color = isDark ? Colors.blue.shade300 : Colors.blue.shade600;

    final dataLength = isAgent ? points.length : openMarketPoints!.length;
    
    double maxPrice = 0;
    double minPrice = double.infinity;
    
    if (isAgent) {
      final prices = points.map((p) => p.price).toList();
      maxPrice = prices.reduce((a, b) => a > b ? a : b);
      minPrice = prices.reduce((a, b) => a < b ? a : b);
    } else {
      for (var p in openMarketPoints!) {
        if (p.rss4 > maxPrice) maxPrice = p.rss4;
        if (p.rss5 > maxPrice) maxPrice = p.rss5;
        if (p.rss4 > 0 && p.rss4 < minPrice) minPrice = p.rss4;
        if (p.rss5 > 0 && p.rss5 < minPrice) minPrice = p.rss5;
      }
      if (minPrice == double.infinity) minPrice = 0;
    }

    final padding = maxPrice == minPrice ? maxPrice * 0.05 : (maxPrice - minPrice) * 0.05;
    final maxY = maxPrice + padding;
    final minY = (minPrice - padding).clamp(0.0, double.infinity);

    Widget buildLegendItem(String label, Color color) {
      return Row(
        children: [
          Container(width: 12, height: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: mutedInk)),
        ],
      );
    }

    return Column(
      children: [
        if (!isAgent)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildLegendItem('RSS4', rss4Color),
                const SizedBox(width: 16),
                buildLegendItem('RSS5', rss5Color),
              ],
            ),
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            double targetHeight = MediaQuery.of(context).size.height * 0.4;
            targetHeight = targetHeight.clamp(240.0, 450.0);
            
            return SizedBox(
              height: targetHeight,
              child: Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 0, top: 24, bottom: 0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: LineChart(
                key: ValueKey(mode),
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= dataLength) return const SizedBox.shrink();
                          
                          const labelCount = 6;
                          final step = (dataLength / labelCount).ceil().clamp(1, dataLength);
                          
                          if (index == 0 || index == dataLength - 1 || (index % step == 0 && index < dataLength - (step / 2))) {
                            final dateStr = isAgent ? points[index].date : openMarketPoints![index].date;
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                _formatDate(dateStr),
                                style: TextStyle(color: mutedInk, fontSize: 10),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: TextStyle(color: mutedInk, fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: dataLength.toDouble() - 1,
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: isAgent
                    ? [
                        LineChartBarData(
                          spots: points.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.price)).toList(),
                          isCurved: true,
                          color: valueGreen,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            checkToShowDot: (spot, barData) => spot.x == points.length - 1,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: valueGreen,
                                strokeWidth: 2,
                                strokeColor: theme.colorScheme.surface,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [valueGreenSoft, valueGreenSoft.withValues(alpha: 0.0)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ]
                    : [
                        LineChartBarData(
                          spots: openMarketPoints!.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.rss4)).toList(),
                          isCurved: true,
                          color: rss4Color,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            checkToShowDot: (spot, barData) => spot.x == openMarketPoints!.length - 1,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: rss4Color,
                                strokeWidth: 2,
                                strokeColor: theme.colorScheme.surface,
                              );
                            },
                          ),
                        ),
                        LineChartBarData(
                          spots: openMarketPoints!.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.rss5)).toList(),
                          isCurved: true,
                          color: rss5Color,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            checkToShowDot: (spot, barData) => spot.x == openMarketPoints!.length - 1,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: rss5Color,
                                strokeWidth: 2,
                                strokeColor: theme.colorScheme.surface,
                              );
                            },
                          ),
                        ),
                      ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        if (isAgent) {
                          return touchedSpots.map((LineBarSpot touchedSpot) {
                            final point = points[touchedSpot.x.toInt()];
                            return LineTooltipItem(
                              '${_formatDate(point.date)}\n₹${point.price.toStringAsFixed(2)}',
                              TextStyle(color: theme.colorScheme.surface, fontWeight: FontWeight.bold),
                            );
                          }).toList();
                        } else {
                          return touchedSpots.map((LineBarSpot touchedSpot) {
                            final point = openMarketPoints![touchedSpot.x.toInt()];
                            final isRss4 = touchedSpot.barIndex == 0;
                            final value = isRss4 ? point.rss4 : point.rss5;
                            final label = isRss4 ? 'RSS4' : 'RSS5';
                            return LineTooltipItem(
                              '${_formatDate(point.date)}\n$label: ₹${value.toStringAsFixed(2)}',
                              TextStyle(color: theme.colorScheme.surface, fontWeight: FontWeight.bold),
                            );
                          }).toList();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            ),
          );
        },
      ),
    ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]}';
    } catch (e) {
      return dateStr;
    }
  }
}
