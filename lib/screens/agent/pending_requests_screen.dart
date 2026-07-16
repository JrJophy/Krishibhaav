import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../providers/agent_provider.dart';

class PendingRequestsScreen extends StatelessWidget {
  final String agentName;
  const PendingRequestsScreen({super.key, required this.agentName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;
    final surfaceTintA = isDark ? AppColors.darkSurfaceTintA : AppColors.lightSurfaceTintA;
    final surface = theme.colorScheme.surface;

    return Scaffold(
      appBar: AppBar(title: const Text('Link Requests')),
      body: Consumer<AgentProvider>(
        builder: (context, agentProvider, _) {
          final requests = agentProvider.linkRequests;

          if (requests.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: ink.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'No pending requests.',
                      style: TextStyle(fontSize: 18, color: ink.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final farmerName = req['farmerName'] ?? 'Unknown Farmer';
              final farmerMobile = req['farmerMobile'] ?? '';
              final farmerId = req['farmerId'] ?? '';
              final requestId = req['id'];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? surface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: surfaceTintA.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(farmerName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ink)),
                        Text('Pending', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('+91 $farmerMobile', style: TextStyle(fontSize: 14, color: ink.withValues(alpha: 0.6))),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              await agentProvider.rejectLinkRequest(requestId, farmerId, agentName);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.lightDanger,
                              side: const BorderSide(color: AppColors.lightDanger),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Reject'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await agentProvider.acceptLinkRequest(requestId, farmerId, farmerName, agentName);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
