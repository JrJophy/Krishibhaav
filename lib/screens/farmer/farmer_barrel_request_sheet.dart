import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/farmer_provider.dart';
import '../../core/colors.dart';

class FarmerBarrelRequestSheet extends StatefulWidget {
  const FarmerBarrelRequestSheet({super.key});

  @override
  State<FarmerBarrelRequestSheet> createState() => _FarmerBarrelRequestSheetState();
}

class _FarmerBarrelRequestSheetState extends State<FarmerBarrelRequestSheet> {
  final TextEditingController _quantityController = TextEditingController();
  String? _errorText;
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() async {
    final text = _quantityController.text.trim();
    if (text.isEmpty) {
      setState(() => _errorText = 'Enter a quantity');
      return;
    }

    final qty = int.tryParse(text);
    if (qty == null || qty < 1) {
      setState(() => _errorText = 'Minimum 1 barrel');
      return;
    }
    final provider = Provider.of<FarmerProvider>(context, listen: false);
    final available = provider.barrelStock?.availableBarrels ?? 0;

    if (qty > 50) {
      setState(() => _errorText = 'Maximum 50 barrels per request');
      return;
    }
    if (qty > available) {
      setState(() => _errorText = 'Only $available barrels available from agent');
      return;
    }

    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    try {
      await provider.createBooking(qty);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to request barrels: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceTintA = isDark ? AppColors.darkSurfaceTintA : AppColors.lightSurfaceTintA;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;

    final provider = Provider.of<FarmerProvider>(context);
    final available = provider.barrelStock?.availableBarrels ?? 0;

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
            'Request Barrels',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Available from agent: $available',
            style: TextStyle(fontSize: 14, color: ink.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Quantity',
              hintText: 'Enter number of barrels (max 50)',
              errorText: _errorText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (val) {
              if (_errorText != null) {
                setState(() => _errorText = null);
              }
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _validateAndSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Request Barrels', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
