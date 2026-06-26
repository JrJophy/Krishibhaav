import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/barrel_booking_model.dart';
import '../core/colors.dart';
import '../core/barrel_logic.dart';

class BookingHistoryRow extends StatelessWidget {
  final BarrelBookingModel booking;
  final bool showFarmerName;

  const BookingHistoryRow({
    super.key,
    required this.booking,
    required this.showFarmerName,
  });

  Color _getStatusColor(String status) {
    switch (status.trim()) {
      case 'requested':
      case 'approved':
        return Colors.amber;
      case 'dispatched':
        return Colors.green;
      case 'returned':
      case 'returned_empty':
      case 'returned_filled':
      case 'cancelled':
        return Colors.grey.shade600;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceTintA = isDark ? AppColors.darkSurfaceTintA : AppColors.lightSurfaceTintA;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;

    final statusColor = _getStatusColor(booking.status);
    final dateFormat = DateFormat('dd MMM yyyy');
    final dateStr = dateFormat.format(booking.completedAt.toDate());

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: surfaceTintA.withValues(alpha: 0.3)),
      ),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showFarmerName) ...[
                    Text(
                      booking.farmerName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${booking.location} • ${booking.quantity} Barrels',
                      style: TextStyle(
                        fontSize: 13,
                        color: ink.withValues(alpha: 0.6),
                      ),
                    ),
                  ] else ...[
                    Text(
                      '${booking.quantity} Barrels',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ink,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'Completed: $dateStr',
                    style: TextStyle(
                      fontSize: 13,
                      color: ink.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withValues(alpha: 0.5)),
              ),
              child: Text(
                bookingStatusLabel(booking.status),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
