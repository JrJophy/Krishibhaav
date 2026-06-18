import 'package:flutter/material.dart';
import '../models/barrel_booking_model.dart';
import '../core/colors.dart';

class BarrelBookingCard extends StatelessWidget {
  final BarrelBookingModel booking;
  final VoidCallback onTap;

  const BarrelBookingCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'requested':
        return Colors.amber;
      case 'approved':
        return AppColors.lightValueGreen;
      case 'dispatched':
        return Colors.blue;
      case 'returned':
        return Colors.grey;
      case 'cancelled':
        return AppColors.lightDanger;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;
    final surfaceTintB = isDark ? AppColors.darkSurfaceTintB : AppColors.lightSurfaceTintB;
    final surface = theme.colorScheme.surface;
    
    final statusColor = _getStatusColor(booking.status);
    final statusText = booking.status.toUpperCase();

    return Card(
      color: surface,
      elevation: isDark ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark ? BorderSide(color: Colors.grey.shade800) : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: surfaceTintB.withValues(alpha: 0.2),
                child: Text(_getInitials(booking.farmerName), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.farmerName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ink)),
                    const SizedBox(height: 4),
                    Text('${booking.location} • ${booking.quantity} Barrels', style: TextStyle(color: ink.withValues(alpha: 0.6), fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
