import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../models/farmer_price_model.dart';
import '../providers/agent_provider.dart';
import '../core/colors.dart';

class FarmerListCard extends StatelessWidget {
  final UserModel farmer;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const FarmerListCard({
    super.key,
    required this.farmer,
    required this.onTap,
    required this.onRemove,
  });

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;
    final surfaceTintB = isDark ? AppColors.darkSurfaceTintB : AppColors.lightSurfaceTintB;
    final surface = theme.colorScheme.surface;

    return Card(
      color: surface,
      elevation: isDark ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark ? BorderSide(color: Colors.grey.shade800) : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: surfaceTintB.withValues(alpha: 0.2),
                child: Text(_getInitials(farmer.name), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(farmer.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ink)),
                    const SizedBox(height: 4),
                    Text('${farmer.location} • ${farmer.mobile}', style: TextStyle(color: ink.withValues(alpha: 0.5))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('farmer_prices').doc(farmer.uid).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox(width: 80, height: 20);
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  if (data == null) return const SizedBox.shrink();
                  
                  final priceModel = FarmerPriceModel.fromMap(data, snapshot.data!.id);
                  
                  return Consumer<AgentProvider>(
                    builder: (context, agentProvider, _) {
                      final globalPrice = agentProvider.agentSettings?.globalAgentPrice ?? 0.0;
                      
                      final isCustom = priceModel.hasCustomPrice;
                      final displayPrice = isCustom ? (priceModel.customPrice ?? 0.0) : globalPrice;
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCustom ? const Color(0xFFF9A825).withValues(alpha: 0.2) : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${isCustom ? 'Custom' : 'Global'} ₹${displayPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isCustom ? (isDark ? Colors.amber.shade300 : Colors.amber.shade900) : (isDark ? Colors.grey.shade300 : Colors.grey.shade800),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.close, color: ink.withValues(alpha: 0.4)),
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
