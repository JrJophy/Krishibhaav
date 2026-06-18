import 'package:flutter/material.dart';
import '../services/farmer_history_service.dart';
import '../core/colors.dart';

class StatsGridWidget extends StatelessWidget {
  final FarmerPriceStats? stats;

  const StatsGridWidget({super.key, this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final valueGreen = isDark ? AppColors.darkValueGreen : AppColors.lightValueGreen;
    final danger = isDark ? AppColors.darkDanger : AppColors.lightDanger;
    final surface = theme.colorScheme.surface;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 72,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      children: [
        _buildStatCard('7-Day High', stats?.sevenDayHigh, valueGreen, surface, ink, isDark),
        _buildStatCard('7-Day Low', stats?.sevenDayLow, danger, surface, ink, isDark),
        _buildStatCard('30-Day High', stats?.thirtyDayHigh, valueGreen, surface, ink, isDark),
        _buildStatCard('30-Day Low', stats?.thirtyDayLow, danger, surface, ink, isDark),
      ],
    );
  }

  Widget _buildStatCard(String label, double? value, Color valueColor, Color surface, Color ink, bool isDark) {
    final displayValue = (value == null || value == 0) ? '—' : '₹${value.toStringAsFixed(2)}';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label, 
              style: TextStyle(color: ink.withValues(alpha: 0.6), fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              displayValue,
              style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
