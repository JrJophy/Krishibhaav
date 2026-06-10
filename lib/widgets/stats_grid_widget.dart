import 'package:flutter/material.dart';
import '../services/price_history_service.dart';
import '../core/colors.dart';

class StatsGridWidget extends StatelessWidget {
  final PriceStats? stats;

  const StatsGridWidget({super.key, this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.8,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        _buildStatCard('7-Day High', stats?.sevenDayHigh, AppColors.priceGreen),
        _buildStatCard('7-Day Low', stats?.sevenDayLow, AppColors.priceRed),
        _buildStatCard('30-Day High', stats?.thirtyDayHigh, AppColors.priceGreen),
        _buildStatCard('30-Day Low', stats?.thirtyDayLow, AppColors.priceRed),
      ],
    );
  }

  Widget _buildStatCard(String label, double? value, Color valueColor) {
    final displayValue = (value == null || value == 0) ? '—' : '₹${value.toStringAsFixed(2)}';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
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
              style: const TextStyle(color: Colors.grey, fontSize: 12),
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
