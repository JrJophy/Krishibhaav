import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/barrel_booking_model.dart';
import '../../providers/farmer_provider.dart';
import '../../core/colors.dart';

enum _ActionState { main, cancelConfirm, returnEmptyConfirm, returnFilledConfirm }

class FarmerBarrelActionSheet extends StatefulWidget {
  final BarrelBookingModel booking;

  const FarmerBarrelActionSheet({super.key, required this.booking});

  @override
  State<FarmerBarrelActionSheet> createState() => _FarmerBarrelActionSheetState();
}

class _FarmerBarrelActionSheetState extends State<FarmerBarrelActionSheet> {
  _ActionState _state = _ActionState.main;
  bool _isLoading = false;
  final TextEditingController _cancelReasonController = TextEditingController();

  @override
  void dispose() {
    _cancelReasonController.dispose();
    super.dispose();
  }

  Future<void> _handleAction(Future<void> Function() action) async {
    setState(() => _isLoading = true);
    try {
      await action();
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action failed: $e')),
      );
    }
  }

  Widget _buildMainView(ThemeData theme, Color surfaceTintA, Color ink) {
    final status = widget.booking.status;

    List<Widget> content = [];
    
    if (status == 'requested') {
      content.add(
        ElevatedButton(
          onPressed: () => setState(() => _state = _ActionState.cancelConfirm),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
          ),
          child: const Text('Cancel Request'),
        ),
      );
    } else if (status == 'approved') {
      content.add(
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceTintA.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.hourglass_empty, color: ink.withValues(alpha: 0.6)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Waiting for agent to dispatch.',
                  style: TextStyle(color: ink, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (status == 'dispatched') {
      content.add(
        ElevatedButton(
          onPressed: () => setState(() => _state = _ActionState.returnEmptyConfirm),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.black87,
          ),
          child: const Text('Return Empty (Unused)'),
        ),
      );
      content.add(const SizedBox(height: 12));
      content.add(
        ElevatedButton(
          onPressed: () => setState(() => _state = _ActionState.returnFilledConfirm),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Return Filled (Ready for Collection)'),
        ),
      );
    } else {
      content.add(
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceTintA.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: ink.withValues(alpha: 0.6)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Terminal State: ${status.replaceAll('_', ' ')}',
                  style: TextStyle(color: ink, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: content,
    );
  }

  Widget _buildCancelConfirmView(Color ink) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Cancel this request?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ink),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cancelReasonController,
          decoration: const InputDecoration(
            labelText: 'Reason',
            hintText: 'Why are you cancelling?',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _isLoading ? null : () => setState(() => _state = _ActionState.main),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        final reason = _cancelReasonController.text.trim();
                        if (reason.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a reason')),
                          );
                          return;
                        }
                        final provider = Provider.of<FarmerProvider>(context, listen: false);
                        _handleAction(() => provider.cancelBooking(widget.booking.bookingId, reason));
                      },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white),
                child: _isLoading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Confirm'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReturnEmptyConfirmView(Color ink) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Return these ${widget.booking.quantity} barrels empty?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ink),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _isLoading ? null : () => setState(() => _state = _ActionState.main),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        final provider = Provider.of<FarmerProvider>(context, listen: false);
                        _handleAction(() => provider.returnEmpty(widget.booking.bookingId));
                      },
                child: _isLoading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Confirm'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReturnFilledConfirmView(Color ink) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Confirm Collection',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ink),
        ),
        const SizedBox(height: 8),
        Text(
          'Return ${widget.booking.quantity} filled barrels? The agent will be notified to collect them.',
          style: TextStyle(fontSize: 14, color: ink),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _isLoading ? null : () => setState(() => _state = _ActionState.main),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        final provider = Provider.of<FarmerProvider>(context, listen: false);
                        _handleAction(() => provider.returnFilled(widget.booking.bookingId));
                      },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: _isLoading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Confirm'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceTintA = isDark ? AppColors.darkSurfaceTintA : AppColors.lightSurfaceTintA;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
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
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: surfaceTintA.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Booking Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ink),
          ),
          const SizedBox(height: 16),
          Text('Quantity: ${widget.booking.quantity} Barrels', style: TextStyle(fontSize: 16, color: ink)),
          const SizedBox(height: 4),
          Text('Status: ${widget.booking.status.toUpperCase()}', style: TextStyle(fontSize: 14, color: ink.withValues(alpha: 0.6))),
          const SizedBox(height: 4),
          Text('Requested: ${dateFormat.format(widget.booking.requestedAt.toDate())}', style: TextStyle(fontSize: 14, color: ink.withValues(alpha: 0.6))),
          const SizedBox(height: 24),
          if (_state == _ActionState.main)
            _buildMainView(theme, surfaceTintA, ink)
          else if (_state == _ActionState.cancelConfirm)
            _buildCancelConfirmView(ink)
          else if (_state == _ActionState.returnEmptyConfirm)
            _buildReturnEmptyConfirmView(ink)
          else if (_state == _ActionState.returnFilledConfirm)
            _buildReturnFilledConfirmView(ink),
        ],
      ),
    );
  }
}
