import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/barrel_booking_model.dart';
import '../../core/colors.dart';

class FarmerBarrelBookingCard extends StatelessWidget {
  final BarrelBookingModel booking;
  final VoidCallback onTap;

  const FarmerBarrelBookingCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceTintA = isDark ? AppColors.darkSurfaceTintA : AppColors.lightSurfaceTintA;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;

    Color statusColor;
    String statusText;

    switch (booking.status) {
      case 'requested':
        statusColor = Colors.grey;
        statusText = 'Requested';
        break;
      case 'approved':
        statusColor = Colors.amber;
        statusText = 'Approved';
        break;
      case 'dispatched':
        statusColor = AppColors.lightValueGreen;
        statusText = 'Dispatched';
        break;
      case 'returned_empty':
        statusColor = Colors.grey.shade600;
        statusText = 'Returned Empty';
        break;
      case 'returned_filled':
        statusColor = Colors.grey.shade600;
        statusText = 'Returned Filled';
        break;
      case 'returned':
        statusColor = Colors.grey.shade600;
        statusText = 'Returned';
        break;
      case 'cancelled':
        statusColor = Colors.grey.shade600;
        statusText = 'Cancelled';
        break;
      default:
        statusColor = Colors.grey;
        statusText = booking.status;
    }

    final dateFormat = DateFormat('dd MMM yyyy');
    final dateStr = dateFormat.format(booking.requestedAt.toDate());

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: surfaceTintA.withValues(alpha: 0.3)),
      ),
      color: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${booking.quantity} Barrels',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Requested: $dateStr',
                    style: TextStyle(
                      fontSize: 13,
                      color: ink.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  statusText,
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
      ),
    );
  }
}
