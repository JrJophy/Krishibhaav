import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/colors.dart';
import '../../providers/farmer_provider.dart';

class RequestLinkScreen extends StatefulWidget {
  final String farmerId;
  const RequestLinkScreen({super.key, required this.farmerId});

  @override
  State<RequestLinkScreen> createState() => _RequestLinkScreenState();
}

class _RequestLinkScreenState extends State<RequestLinkScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      setState(() => _errorMessage = 'Please enter a valid 6-character agent code.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final farmerProvider = Provider.of<FarmerProvider>(context, listen: false);
      final farmerName = farmerProvider.farmerName;
      
      // Find the agent with this code
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'agent')
          .where('agentCode', isEqualTo: code)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'No agent found with this code.';
          });
        }
        return;
      }

      final agentDoc = query.docs.first;
      final agentId = agentDoc.id;

      // Get farmer mobile directly from firestore since it's not in FarmerProvider
      final farmerDoc = await FirebaseFirestore.instance.collection('users').doc(widget.farmerId).get();
      final farmerMobile = farmerDoc.data()?['mobile'] ?? '';

      // Create a link request
      await FirebaseFirestore.instance.collection('link_requests').add({
        'farmerId': widget.farmerId,
        'farmerName': farmerName,
        'farmerMobile': farmerMobile,
        'agentId': agentId,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context, true); // Return true on success
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to submit request. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;

    return Scaffold(
      appBar: AppBar(title: const Text('Link with Agent')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter Agent Code',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ink),
            ),
            const SizedBox(height: 12),
            Text(
              'Ask your agent for their 6-character code to link your account and access live prices and barrel requests.',
              style: TextStyle(fontSize: 16, color: ink.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8, color: ink),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                counterText: '',
                hintText: 'XXXXXX',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) {
                if (_errorMessage != null) setState(() => _errorMessage = null);
              },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Submit Request', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
