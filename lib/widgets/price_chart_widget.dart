import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/price_point.dart';
import '../core/colors.dart';

class PriceChartWidget extends StatelessWidget {
  final List<PricePoint> points;

  const PriceChartWidget({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            "Price history will appear after market data is collected",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
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

    final lineColor = valueGreen;

    final prices = points.map((p) => p.price).toList();
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    
    final padding = maxPrice == minPrice ? maxPrice * 0.05 : (maxPrice - minPrice) * 0.05;
    final maxY = maxPrice + padding;
    final minY = minPrice - padding;

    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0, left: 0, top: 24, bottom: 0),
        child: LineChart(
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
                    if (index < 0 || index >= points.length) return const SizedBox.shrink();
                    
                    const labelCount = 6;
                    final step = (points.length / labelCount).ceil().clamp(1, points.length);
                    
                    // Always show first, last, and points that fall on the step interval
                    if (index == 0 || index == points.length - 1 || (index % step == 0 && index < points.length - (step / 2))) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          _formatDate(points[index].date),
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
            maxX: points.length.toDouble() - 1,
            minY: minY,
            maxY: maxY,
            lineBarsData: [
              LineChartBarData(
                spots: points.asMap().entries.map((e) {
                  return FlSpot(e.key.toDouble(), e.value.price);
                }).toList(),
                isCurved: true,
                color: lineColor,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  checkToShowDot: (spot, barData) {
                    return spot.x == points.length - 1; // Only show for the last point
                  },
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: lineColor,
                      strokeWidth: 2,
                      strokeColor: theme.colorScheme.surface,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      valueGreenSoft,
                      valueGreenSoft.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((LineBarSpot touchedSpot) {
                    final point = points[touchedSpot.x.toInt()];
                    return LineTooltipItem(
                      '${_formatDate(point.date)}\n₹${point.price.toStringAsFixed(2)}',
                      TextStyle(color: theme.colorScheme.surface, fontWeight: FontWeight.bold),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
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
