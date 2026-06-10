import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../core/market_status.dart';
import '../../providers/farmer_provider.dart';
import '../../widgets/price_chart_widget.dart';
import '../../widgets/stats_grid_widget.dart';
import '../../services/price_history_service.dart';
import '../../models/price_point.dart';

class FarmerHomeScreen extends StatefulWidget {
  final String farmerId;
  const FarmerHomeScreen({super.key, required this.farmerId});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  Future<List<PricePoint>>? _priceHistoryFuture;
  final PriceHistoryService _priceHistoryService = PriceHistoryService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = Provider.of<FarmerProvider>(context, listen: false);
    await provider.loadFarmer(widget.farmerId);
    setState(() {
      _priceHistoryFuture = _priceHistoryService.fetchPriceHistory();
    });
  }

  Widget _buildLoadingSkeletons() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          height: index == 0 ? 140 : 80,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMarketOpen = MarketStatus.isMarketOpen();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Consumer<FarmerProvider>(
          builder: (context, provider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Krishibhaav', style: AppTextStyles.poppinsHeading.copyWith(fontSize: 20)),
                Text('Hello, ${provider.farmerName.isNotEmpty ? provider.farmerName : 'Farmer'}', 
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 28),
            onPressed: () => context.push('/farmer/profile'),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Consumer<FarmerProvider>(
          builder: (context, provider, _) {
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Market Status Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isMarketOpen ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isMarketOpen ? '● Market Open' : '● Market Closed',
                        style: TextStyle(
                          color: isMarketOpen ? Colors.green.shade800 : Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Offline Banner
                if (provider.isOffline)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.wifi_off, color: Colors.amber.shade900),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "You're offline. Showing last known prices.",
                            style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (provider.isLoading)
                  _buildLoadingSkeletons()
                else ...[
                  // Card 1 - YOUR PRICE
                  Card(
                    color: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Your Price Today', style: TextStyle(color: Colors.white, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('₹${provider.effectivePrice.toStringAsFixed(2)} /kg', 
                            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            provider.hasCustomPrice ? 'Special price set by your agent' : 'Standard agent price',
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Card 2 - Company Price
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Company Price', style: TextStyle(fontSize: 16, color: Colors.black87)),
                          Text('₹${provider.companyPrice.toStringAsFixed(2)} /kg', 
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Card 3 - Open Market Price
                  Card(
                    color: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Open Market Price', style: TextStyle(fontSize: 16, color: Colors.black54)),
                          Text('₹${provider.openMarketPrice.toStringAsFixed(2)} /kg', 
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),

                // Price Trend section
                const Text('30-Day Market Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                FutureBuilder<List<PricePoint>>(
                  future: _priceHistoryFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                      return Column(
                        children: [
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ],
                      );
                    }

                    final points = snapshot.data!;
                    final stats = _priceHistoryService.computeStats(points);
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PriceChartWidget(points: points),
                        const SizedBox(height: 16),
                        StatsGridWidget(stats: stats),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
