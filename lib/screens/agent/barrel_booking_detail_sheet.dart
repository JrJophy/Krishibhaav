import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/barrel_booking_model.dart';
import '../../providers/agent_provider.dart';
import '../../core/colors.dart';
import 'package:intl/intl.dart';

class BarrelBookingDetailSheet extends StatefulWidget {
  final BarrelBookingModel booking;

  const BarrelBookingDetailSheet({super.key, required this.booking});

  @override
  State<BarrelBookingDetailSheet> createState() => _BarrelBookingDetailSheetState();
}

class _BarrelBookingDetailSheetState extends State<BarrelBookingDetailSheet> {
  bool _isCancelling = false;
  bool _isLoading = false;
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleAction(Future<void> Function() action) async {
    setState(() => _isLoading = true);
    try {
      await action();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;
    final surface = theme.colorScheme.surface;
    final danger = isDark ? AppColors.darkDanger : AppColors.lightDanger;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ink.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(widget.booking.farmerName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: ink)),
          const SizedBox(height: 8),
          Text('Quantity: ${widget.booking.quantity} Barrels', style: TextStyle(fontSize: 16, color: ink.withValues(alpha: 0.8))),
          Text('Status: ${widget.booking.status.toUpperCase()}', style: TextStyle(fontSize: 14, color: ink.withValues(alpha: 0.6))),
          Text('Updated: ${DateFormat('dd MMM yyyy, hh:mm a').format(widget.booking.updatedAt.toDate())}', style: TextStyle(fontSize: 12, color: ink.withValues(alpha: 0.5))),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_isCancelling) ...[
            Text('Cancel Reason', style: TextStyle(fontWeight: FontWeight.bold, color: ink)),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: 'Enter reason...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => setState(() => _isCancelling = false),
                  child: Text('Back', style: TextStyle(color: ink.withValues(alpha: 0.5))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: danger),
                  onPressed: () {
                    final reason = _reasonController.text.trim();
                    if (reason.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reason is required')));
                      return;
                    }
                    _handleAction(() => Provider.of<AgentProvider>(context, listen: false).cancelBooking(widget.booking.bookingId, reason));
                  },
                  child: const Text('Confirm Cancel', style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ] else ...[
            if (widget.booking.status == 'requested') ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () => _handleAction(() => Provider.of<AgentProvider>(context, listen: false).approveBooking(widget.booking.bookingId)),
                child: const Text('Approve', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(foregroundColor: danger, side: BorderSide(color: danger)),
                onPressed: () => setState(() => _isCancelling = true),
                child: const Text('Cancel Booking'),
              ),
            ] else if (widget.booking.status == 'approved') ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () => _handleAction(() => Provider.of<AgentProvider>(context, listen: false).dispatchBooking(widget.booking.bookingId)),
                child: const Text('Dispatch', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(foregroundColor: danger, side: BorderSide(color: danger)),
                onPressed: () => setState(() => _isCancelling = true),
                child: const Text('Cancel Booking'),
              ),
            ] else ...[
              Center(child: Text('Terminal State: No further actions.', style: TextStyle(color: ink.withValues(alpha: 0.5)))),
            ]
          ],
        ],
      ),
    );
  }
}
