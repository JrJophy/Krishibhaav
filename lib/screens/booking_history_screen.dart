import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/colors.dart';
import '../core/barrel_logic.dart';
import '../models/barrel_booking_model.dart';
import '../providers/farmer_provider.dart';
import '../providers/agent_provider.dart';
import '../widgets/booking_history_row.dart';

class BookingHistoryScreen extends StatefulWidget {
  final String role;

  const BookingHistoryScreen({
    super.key,
    required this.role,
  });

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  late DateTimeRange _dateRange;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
    );
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime(2024),
      lastDate: now,
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppColors.lightPrimary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  List<BarrelBookingModel> _filterBookings(List<BarrelBookingModel> bookings) {
    final startNormalized = DateTime(_dateRange.start.year, _dateRange.start.month, _dateRange.start.day);
    final endNormalized = DateTime(_dateRange.end.year, _dateRange.end.month, _dateRange.end.day, 23, 59, 59, 999);
    final query = _searchQuery.trim().toLowerCase();

    final filtered = bookings.where((b) {
      // 1. Terminal statuses only
      if (!isTerminalBookingStatus(b.status)) {
        return false;
      }

      // 2. Date range check
      final completedDate = b.completedAt.toDate();
      final withinRange = completedDate.isAfter(startNormalized.subtract(const Duration(milliseconds: 1))) &&
          completedDate.isBefore(endNormalized.add(const Duration(milliseconds: 1)));
      if (!withinRange) {
        return false;
      }

      // 3. Search query check
      if (query.isNotEmpty) {
        final statusLabel = bookingStatusLabel(b.status).toLowerCase();
        final qty = b.quantity.toString();
        final matchesStatus = statusLabel.contains(query);
        final matchesQty = qty.contains(query);
        final matchesFarmerName = widget.role == 'agent' && b.farmerName.toLowerCase().contains(query);

        if (!matchesStatus && !matchesQty && !matchesFarmerName) {
          return false;
        }
      }

      return true;
    }).toList();

    // 4. Sort descending by completedAt
    filtered.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;
    final surface = theme.colorScheme.surface;
    final surfaceTintA = isDark ? AppColors.darkSurfaceTintA : AppColors.lightSurfaceTintA;

    final dateFormat = DateFormat('dd MMM');
    final dateRangeStr = '${dateFormat.format(_dateRange.start)} - ${dateFormat.format(_dateRange.end)}';

    Widget buildList(List<BarrelBookingModel> rawBookings) {
      final filtered = _filterBookings(rawBookings);

      if (filtered.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
              'No completed bookings in this range.',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          return BookingHistoryRow(
            booking: filtered[index],
            showFarmerName: widget.role == 'agent',
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Booking History',
          style: TextStyle(color: theme.appBarTheme.foregroundColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Controls row/container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: surfaceTintA.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  // Date range selector button
                  InkWell(
                    onTap: () => _selectDateRange(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: ink.withValues(alpha: 0.2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.date_range, color: AppColors.lightPrimary),
                              const SizedBox(width: 12),
                              Text(
                                dateRangeStr,
                                style: TextStyle(color: ink, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Icon(Icons.arrow_drop_down, color: ink.withValues(alpha: 0.6)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search Text Field
                  TextField(
                    controller: _searchController,
                    style: TextStyle(color: ink),
                    decoration: InputDecoration(
                      hintText: widget.role == 'agent'
                          ? 'Search by status, quantity, or farmer...'
                          : 'Search by status or quantity...',
                      hintStyle: TextStyle(color: ink.withValues(alpha: 0.4)),
                      prefixIcon: Icon(Icons.search, color: ink.withValues(alpha: 0.6)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ink.withValues(alpha: 0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ink.withValues(alpha: 0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Listings
            if (widget.role == 'farmer')
              Consumer<FarmerProvider>(
                builder: (context, provider, _) => buildList(provider.barrelBookings),
              )
            else
              Consumer<AgentProvider>(
                builder: (context, provider, _) => buildList(provider.barrelBookings),
              ),
          ],
        ),
      ),
    );
  }
}
