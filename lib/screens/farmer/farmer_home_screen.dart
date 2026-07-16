import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/barrel_logic.dart';
import '../../core/colors.dart';
import '../../core/market_status.dart';
import '../../providers/farmer_provider.dart';
import '../../widgets/price_chart_widget.dart';
import '../../widgets/stats_grid_widget.dart';
import '../../services/farmer_history_service.dart';
import '../../models/price_point.dart';
import '../../models/open_market_price_point.dart';
import '../../services/notification_service.dart';
import '../../widgets/profile_sheet.dart';
import 'farmer_barrel_request_sheet.dart';
import 'farmer_barrel_action_sheet.dart';
import '../../widgets/farmer_barrel_booking_card.dart';
import 'request_link_screen.dart';

class FarmerHomeScreen extends StatefulWidget {
  final String farmerId;
  final FarmerHistoryService? historyService;
  final bool enableNotifications;
  
  const FarmerHomeScreen({
    super.key, 
    required this.farmerId,
    this.historyService,
    this.enableNotifications = true,
  });

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  Future<List<PricePoint>>? _priceHistoryFuture;
  Future<List<OpenMarketPricePoint>>? _openMarketHistoryFuture;
  ChartMode _chartMode = ChartMode.agent;
  bool _chartsExpanded = false;
  late final FarmerHistoryService _historyService;

  @override
  void initState() {
    super.initState();
    _historyService = widget.historyService ?? FarmerHistoryService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = Provider.of<FarmerProvider>(context, listen: false);
    await provider.loadFarmer(widget.farmerId);
    if (!mounted) return;
    if (widget.enableNotifications) NotificationService().init(context, widget.farmerId);
    setState(() {
      _priceHistoryFuture = _historyService.fetchHistory(widget.farmerId);
      if (provider.canSeeOpenMarket) {
        _openMarketHistoryFuture = _historyService.fetchOpenMarketHistory();
      } else {
        _openMarketHistoryFuture = Future.value([]);
      }
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
        centerTitle: false,
        title: Consumer<FarmerProvider>(
          builder: (context, provider, _) {
            return Row(
              children: [
                Image.asset(isDark ? 'assets/branding/symbol.png' : 'assets/branding/symbol_white.png', width: 32),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Krishibhaav', overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: theme.appBarTheme.foregroundColor)),
                      Text('${_getGreeting()}, ${provider.farmerName.isNotEmpty ? provider.farmerName : 'Farmer'}', 
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: isDark ? Colors.grey.shade400 : Colors.white)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, size: 26, color: theme.appBarTheme.foregroundColor),
            onPressed: () => context.push('/history', extra: {'role': 'farmer'}),
          ),
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
                  else if (provider.agentId.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? surface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: surfaceTintA.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.link_off, size: 48, color: ink.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text('Not linked to an Agent', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ink)),
                          const SizedBox(height: 8),
                          Text(
                            'You need to link with an agent to view live market rates, see price trends, and request barrels.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: ink.withValues(alpha: 0.7)),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => RequestLinkScreen(farmerId: widget.farmerId)));
                            },
                            icon: const Icon(Icons.link),
                            label: const Text('Link with Agent', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
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
                        Text("Today's Rate", style: TextStyle(
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (provider.agentId.isNotEmpty) ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const FarmerBarrelRequestSheet(),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Request Barrels', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // My Barrel Requests Section
                  Text(
                    'My Barrel Requests',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ink),
                  ),
                  const SizedBox(height: 16),
                  ...(() {
                    final activeBookings = provider.barrelBookings.where((b) => !isTerminalBookingStatus(b.status)).toList();
                    if (activeBookings.isEmpty) {
                      return [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text('No barrel requests yet.', style: TextStyle(color: ink.withValues(alpha: 0.5), fontStyle: FontStyle.italic)),
                          ),
                        )
                      ];
                    }
                    activeBookings.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
                    return activeBookings.map((booking) => FarmerBarrelBookingCard(
                          booking: booking,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => FarmerBarrelActionSheet(booking: booking),
                            );
                          },
                        )).toList();
                  })(),
                  const SizedBox(height: 32),

                  // Secondary Price Cards
                  if (provider.canSeeBoardRate || provider.canSeeOpenMarket) ...[
                    Row(
                      children: [
                        if (provider.canSeeBoardRate)
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
                                  Text('Board Rate', style: TextStyle(color: ink.withValues(alpha: 0.6), fontSize: 13)),
                                  const SizedBox(height: 8),
                                  if (provider.boardRate != null) ...[
                                    Text('RSS4 ₹${provider.boardRate!.rss4.toStringAsFixed(2)}', 
                                      style: TextStyle(color: valueGreen, fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('RSS5 ₹${provider.boardRate!.rss5.toStringAsFixed(2)}', 
                                      style: TextStyle(color: valueGreen, fontSize: 16, fontWeight: FontWeight.bold)),
                                  ] else
                                    Text('Awaiting data', style: TextStyle(color: ink.withValues(alpha: 0.5), fontSize: 14, fontStyle: FontStyle.italic)),
                                ],
                              ),
                            ),
                          ),
                        if (provider.canSeeBoardRate && provider.canSeeOpenMarket)
                          const SizedBox(width: 16),
                        if (provider.canSeeOpenMarket)
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
                                  Text('RSS4 ₹${provider.openMarketPrice.toStringAsFixed(2)}', 
                                    style: TextStyle(color: valueGreen, fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('RSS5 ₹${provider.openMarketRss5.toStringAsFixed(2)}', 
                                    style: TextStyle(color: valueGreen, fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                  
                  // Price Trend section
                  InkWell(
                    onTap: () {
                      setState(() {
                        _chartsExpanded = !_chartsExpanded;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Price Trends',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ink),
                          ),
                          Icon(
                            _chartsExpanded ? Icons.expand_less : Icons.expand_more,
                            color: ink,
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_chartsExpanded) ...[
                    const SizedBox(height: 16),
                    Builder(builder: (context) {
                      // Only render the segmented button if the farmer can see the Open Market
                      if (provider.canSeeOpenMarket) {
                        return SegmentedButton<ChartMode>(
                          segments: const [
                            ButtonSegment(value: ChartMode.agent, label: Text('Agent')),
                            ButtonSegment(value: ChartMode.openMarket, label: Text('Open Market')),
                          ],
                          selected: {_chartMode},
                          onSelectionChanged: (Set<ChartMode> newSelection) {
                            setState(() {
                              _chartMode = newSelection.first;
                            });
                          },
                          style: SegmentedButton.styleFrom(
                            selectedBackgroundColor: valueGreenSoft,
                            selectedForegroundColor: valueGreen,
                          ),
                        );
                      }
                      // If not, return empty container
                      return const SizedBox.shrink();
                    }),
                    const SizedBox(height: 16),
                    Text(
                      _chartMode == ChartMode.agent ? 'Effective Price Trend' : 'Open Market Price Trend', 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ink.withValues(alpha: 0.8))
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<PricePoint>>(
                      future: _priceHistoryFuture,
                      builder: (context, snapshot) {
                        return FutureBuilder<List<OpenMarketPricePoint>>(
                          future: _openMarketHistoryFuture,
                          builder: (context, omSnapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData || (provider.canSeeOpenMarket && (omSnapshot.connectionState == ConnectionState.waiting || !omSnapshot.hasData))) {
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
                            final omPoints = omSnapshot.data;

                            // We render the widget structure without returning empty early, so the empty state appears within the styled container
                            final stats = _chartMode == ChartMode.agent 
                                ? FarmerHistoryService.computeStats(points)
                                : FarmerHistoryService.computeOpenMarketStats(omPoints ?? []);
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? surface : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: surfaceTintA.withValues(alpha: 0.3)),
                                  ),
                                  child: PriceChartWidget(
                                    points: points,
                                    openMarketPoints: omPoints,
                                    mode: _chartMode,
                                  ),
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
                        );
                      },
                    ),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
