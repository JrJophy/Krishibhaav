import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/agent_provider.dart';
import '../../widgets/price_edit_dialog.dart';
import '../../widgets/farmer_list_card.dart';
import 'add_farmer_sheet.dart';
import 'farmer_detail_sheet.dart';
import '../../widgets/price_chart_widget.dart';
import '../../widgets/stats_grid_widget.dart';
import '../../services/price_history_service.dart';
import '../../models/price_point.dart';
import '../../services/notification_service.dart';
import '../../widgets/profile_sheet.dart';

class AgentHomeScreen extends StatefulWidget {
  const AgentHomeScreen({super.key});

  @override
  State<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends State<AgentHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<PricePoint>>? _priceHistoryFuture;
  final PriceHistoryService _priceHistoryService = PriceHistoryService();
  String _agentName = 'Agent';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final agentProvider = Provider.of<AgentProvider>(context, listen: false);
    if (authProvider.userId != null) {
      FirebaseFirestore.instance.collection('users').doc(authProvider.userId!).get().then((doc) {
        if (mounted && doc.exists) {
          setState(() => _agentName = doc.data()?['name'] ?? 'Agent');
        }
      }).catchError((_) {});

      agentProvider.loadAgent(authProvider.userId!);
      NotificationService().init(context, authProvider.userId!);
    }
    setState(() {
      _priceHistoryFuture = _priceHistoryService.fetchPriceHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showPriceDialog(String type, double currentValue) async {
    final newPrice = await showDialog<double>(
      context: context,
      builder: (context) => PriceEditDialog(priceName: type, currentValue: currentValue),
    );
    if (newPrice != null) {
      if (mounted) {
        Provider.of<AgentProvider>(context, listen: false).updatePrice(type, newPrice);
      }
    }
  }

  Widget _buildPriceRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          Row(
            children: [
              Text('₹${value.toStringAsFixed(2)} /kg', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit, size: 20, color: AppColors.primary),
                onPressed: () => _showPriceDialog(label, value),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          )
        ],
      ),
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
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Krishibhaav', style: AppTextStyles.poppinsHeading.copyWith(fontSize: 20)),
            Text('${_getGreeting()}, $_agentName', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 28),
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              if (authProvider.userId != null) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => ProfileSheet(uid: authProvider.userId!),
                );
              }
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Consumer<AgentProvider>(
          builder: (context, agentProvider, _) {
            final settings = agentProvider.agentSettings;
            final farmers = agentProvider.filteredFarmerList;
            final lastUpdatedText = settings != null
                ? DateFormat('dd MMM, hh:mm a').format(settings.lastUpdated.toDate())
                : '--';

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Price Control Panel
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Today's Prices", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const Divider(),
                        if (settings != null) ...[
                          _buildPriceRow('Open Market Price', settings.openMarketPrice),
                          _buildPriceRow('Company Price', settings.companyPrice),
                          _buildPriceRow('Global Agent Price', settings.globalAgentPrice),
                        ] else ...[
                          const Center(child: CircularProgressIndicator()),
                        ],
                        const SizedBox(height: 8),
                        Text('Last Updated: $lastUpdatedText', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Stats Strip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Farmers: ${agentProvider.farmerList.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Last Updated: $lastUpdatedText', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 16),

                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or location...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              agentProvider.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onChanged: (val) => agentProvider.setSearchQuery(val),
                ),
                const SizedBox(height: 24),

                // Farmer List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('All Farmers (${farmers.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Farmer'),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => const AddFarmerSheet(),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // List
                if (agentProvider.isLoading)
                  ...List.generate(3, (index) => Container(
                    height: 80,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)),
                  ))
                else if (farmers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        agentProvider.searchQuery.isNotEmpty 
                            ? "No farmers match your search." 
                            : "No farmers yet. Tap + Add Farmer to begin.", 
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...farmers.map((farmer) => FarmerListCard(
                    farmer: farmer,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => FarmerDetailSheet(farmer: farmer),
                      );
                    },
                    onRemove: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Remove ${farmer.name}?'),
                          content: const Text('They will no longer see your prices.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
                            TextButton(
                              onPressed: () {
                                agentProvider.removeFarmer(farmer.uid);
                                Navigator.pop(ctx);
                              },
                              child: const Text('Remove', style: TextStyle(color: AppColors.danger)),
                            ),
                          ],
                        ),
                      );
                    },
                  )),
                const SizedBox(height: 24),
                // Expansion tile for the chart
                ExpansionTile(
                  title: const Text('30-Day Market Trend', style: TextStyle(fontWeight: FontWeight.bold)),
                  children: [
                    FutureBuilder<List<PricePoint>>(
                      future: _priceHistoryFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final points = snapshot.data!;
                        final stats = _priceHistoryService.computeStats(points);
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PriceChartWidget(points: points),
                              const SizedBox(height: 16),
                              StatsGridWidget(stats: stats),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
