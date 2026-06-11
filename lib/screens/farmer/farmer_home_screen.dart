import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../core/market_status.dart';
import '../../providers/farmer_provider.dart';
import '../../widgets/price_chart_widget.dart';
import '../../widgets/stats_grid_widget.dart';
import '../../services/price_history_service.dart';
import '../../models/price_point.dart';
import '../../services/notification_service.dart';
import '../../widgets/profile_sheet.dart';

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
    if (!mounted) return;
    NotificationService().init(context, widget.farmerId);
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final bool isMarketOpen = MarketStatus.isMarketOpen();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final valueGreen = isDark ? AppColors.darkValueGreen : AppColors.lightValueGreen;
    final valueGreenSoft = isDark ? AppColors.darkValueGreenSoft : AppColors.lightValueGreenSoft;
    final danger = isDark ? AppColors.darkDanger : AppColors.lightDanger;
    final dangerSoft = isDark ? AppColors.darkDanger.withValues(alpha: 0.15) : AppColors.lightDanger.withValues(alpha: 0.15);
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;
    final surfaceTintA = isDark ? AppColors.darkSurfaceTintA : AppColors.lightSurfaceTintA;
    final surface = theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Consumer<FarmerProvider>(
          builder: (context, provider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Krishibhaav', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: theme.appBarTheme.foregroundColor)),
                Text('${_getGreeting()}, ${provider.farmerName.isNotEmpty ? provider.farmerName : 'Farmer'}', 
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: isDark ? Colors.grey.shade400 : Colors.white)),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, size: 28, color: theme.appBarTheme.foregroundColor),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => ProfileSheet(uid: widget.farmerId),
              );
            },
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
                        color: isMarketOpen ? valueGreenSoft : dangerSoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isMarketOpen ? '● Market Open' : '● Market Closed',
                        style: TextStyle(
                          color: isMarketOpen ? valueGreen : danger,
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
                  // Hero Price Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: isDark ? surface : AppColors.lightValueGreen,
                      borderRadius: BorderRadius.circular(16),
                      border: isDark ? Border.all(color: valueGreen.withValues(alpha: 0.5), width: 1) : null,
                      boxShadow: isDark ? [BoxShadow(color: valueGreen.withValues(alpha: 0.1), blurRadius: 8, spreadRadius: 2)] : [],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('YOUR PRICE TODAY', style: TextStyle(
                          color: isDark ? AppColors.darkPrimary : Colors.white, 
                          fontSize: 12, 
                          letterSpacing: 1.5, 
                          fontWeight: FontWeight.bold
                        )),
                        const SizedBox(height: 8),
                        Text('₹${provider.effectivePrice.toStringAsFixed(2)}/kg', 
                          style: TextStyle(
                            color: isDark ? valueGreen : Colors.white, 
                            fontSize: 44, 
                            fontWeight: FontWeight.bold
                          )),
                        const SizedBox(height: 8),
                        Text(
                          provider.hasCustomPrice ? 'Special price set by your agent' : 'Standard agent price',
                          style: TextStyle(
                            color: isDark ? ink.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.7), 
                            fontSize: 14
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Secondary Price Cards
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? surface : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: surfaceTintA.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Company Price', style: TextStyle(color: ink.withValues(alpha: 0.6), fontSize: 13)),
                              const SizedBox(height: 8),
                              Text('₹${provider.companyPrice.toStringAsFixed(2)}/kg', 
                                style: TextStyle(color: valueGreen, fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? surface : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: surfaceTintA.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Open Market Price', style: TextStyle(color: ink.withValues(alpha: 0.6), fontSize: 13)),
                              const SizedBox(height: 8),
                              Text('₹${provider.openMarketPrice.toStringAsFixed(2)}/kg', 
                                style: TextStyle(color: valueGreen, fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 32),

                // Price Trend section
                Text('30-Day Market Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ink)),
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
                              color: isDark ? surface : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: surfaceTintA.withValues(alpha: 0.3)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDark ? surface : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: surfaceTintA.withValues(alpha: 0.3)),
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
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? surface : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: surfaceTintA.withValues(alpha: 0.3)),
                          ),
                          child: PriceChartWidget(points: points),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? surface : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: surfaceTintA.withValues(alpha: 0.3)),
                          ),
                          child: StatsGridWidget(stats: stats),
                        ),
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
