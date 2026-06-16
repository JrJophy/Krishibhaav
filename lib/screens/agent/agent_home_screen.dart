import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/colors.dart';

import '../../providers/auth_provider.dart';
import '../../providers/agent_provider.dart';
import '../../widgets/price_edit_dialog.dart';
import '../../widgets/farmer_list_card.dart';
import 'add_farmer_sheet.dart';
import 'farmer_detail_sheet.dart';
import '../../services/notification_service.dart';
import '../../widgets/profile_sheet.dart';
import '../../widgets/paste_market_message_sheet.dart';
import '../../models/board_rate_model.dart';
import '../../services/board_rate_service.dart';

class AgentHomeScreen extends StatefulWidget {
  const AgentHomeScreen({super.key});

  @override
  State<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends State<AgentHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BoardRateService _boardRateService = BoardRateService();
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

  Widget _buildSinglePriceRow(String label, double value, Color surfaceTintA, Color valueGreen, Color ink, {bool editable = true}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: surfaceTintA.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: ink.withValues(alpha: 0.7)))),
          const SizedBox(width: 8),
          Flexible(
            flex: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(text: '₹${value.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: valueGreen)),
                        TextSpan(text: ' /kg', style: TextStyle(fontSize: 12, color: valueGreen.withValues(alpha: 0.7))),
                      ],
                    ),
                  ),
                ),
                if (editable) ...[
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                    onPressed: () => _showPriceDialog(label, value),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDualPriceRow(String label, double rss4, double rss5, Color surfaceTint, Color valueGreen, Color ink, {String? caption, bool showPaste = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceTint.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 14, color: ink.withValues(alpha: 0.7))),
                if (caption != null)
                  Text(caption, style: TextStyle(fontSize: 11, color: ink.withValues(alpha: 0.4))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(text: 'RSS4 ', style: TextStyle(fontSize: 12, color: valueGreen.withValues(alpha: 0.7))),
                        TextSpan(text: '₹${rss4.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: valueGreen)),
                        TextSpan(text: ' · RSS5 ', style: TextStyle(fontSize: 12, color: valueGreen.withValues(alpha: 0.7))),
                        TextSpan(text: '₹${rss5.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: valueGreen)),
                        TextSpan(text: ' /kg', style: TextStyle(fontSize: 12, color: valueGreen.withValues(alpha: 0.7))),
                      ],
                    ),
                  ),
                ),
                if (showPaste) ...[
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.content_paste, size: 18, color: AppColors.primary),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => PasteMarketMessageSheet(currentRss4: rss4, currentRss5: rss5),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBoardRatePlaceholder(Color surfaceTintA, Color ink) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: surfaceTintA.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Board Rate', style: TextStyle(fontSize: 14, color: ink.withValues(alpha: 0.7))),
                Text('auto · awaiting scraper', style: TextStyle(fontSize: 11, color: ink.withValues(alpha: 0.4))),
              ],
            ),
          ),
          Text('—', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: ink.withValues(alpha: 0.3))),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final valueGreen = isDark ? AppColors.darkValueGreen : AppColors.lightValueGreen;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;
    final surfaceTintA = isDark ? AppColors.darkSurfaceTintA : AppColors.lightSurfaceTintA;
    final danger = isDark ? AppColors.darkDanger : AppColors.lightDanger;
    final surface = theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            Image.asset(isDark ? 'assets/branding/symbol.png' : 'assets/branding/symbol_white.png', width: 32),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Krishibhaav', overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: theme.appBarTheme.foregroundColor)),
                  Text('${_getGreeting()}, $_agentName', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: isDark ? Colors.grey.shade400 : Colors.white)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, size: 28, color: theme.appBarTheme.foregroundColor),
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
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    border: isDark ? Border.all(color: surfaceTintA.withValues(alpha: 0.3)) : Border.all(color: Colors.transparent),
                    boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Today's Prices", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: ink)),
                          Text('Last Updated: $lastUpdatedText', style: TextStyle(color: ink.withValues(alpha: 0.5), fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (settings != null) ...[
                        StreamBuilder<BoardRateModel?>(
                          stream: _boardRateService.streamBoardRate(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data == null) {
                              return _buildBoardRatePlaceholder(surfaceTintA, ink);
                            }
                            final br = snapshot.data!;
                            return _buildDualPriceRow(
                              'Board Rate', 
                              br.rss4, 
                              br.rss5, 
                              surfaceTintA, 
                              valueGreen, 
                              ink, 
                              showPaste: false,
                              caption: 'auto · ${br.date}',
                            );
                          },
                        ),
                        _buildDualPriceRow('Open Market Price', settings.openMarketPrice, settings.openMarketRss5, surfaceTintA, valueGreen, ink, showPaste: true),
                        _buildSinglePriceRow('Global Agent Price', settings.globalAgentPrice, surfaceTintA, valueGreen, ink),
                      ] else ...[
                        const Center(child: CircularProgressIndicator()),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Stats Strip
                Text('Total Farmers: ${agentProvider.farmerList.length}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ink)),
                const SizedBox(height: 16),

                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or location...',
                    hintStyle: TextStyle(color: ink.withValues(alpha: 0.5)),
                    prefixIcon: Icon(Icons.search, color: ink.withValues(alpha: 0.5)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: ink.withValues(alpha: 0.5)),
                            onPressed: () {
                              _searchController.clear();
                              agentProvider.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: surfaceTintA.withValues(alpha: 0.1),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  ),
                  onChanged: (val) => agentProvider.setSearchQuery(val),
                ),
                const SizedBox(height: 24),

                // Farmer List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('All Farmers (${farmers.length})', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: ink)),
                    TextButton.icon(
                      icon: const Icon(Icons.add, color: AppColors.primary),
                      label: const Text('Add Farmer', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
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
                    decoration: BoxDecoration(color: surfaceTintA.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
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
                        style: TextStyle(color: ink.withValues(alpha: 0.6)),
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
                          title: Text('Remove ${farmer.name}?', style: TextStyle(color: ink)),
                          content: Text('They will no longer see your prices.', style: TextStyle(color: ink.withValues(alpha: 0.7))),
                          backgroundColor: surface,
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: ink.withValues(alpha: 0.5)))),
                            TextButton(
                              onPressed: () {
                                agentProvider.removeFarmer(farmer.uid);
                                Navigator.pop(ctx);
                              },
                              child: Text('Remove', style: TextStyle(color: danger, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    },
                  )),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}

