import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/agent_provider.dart';
import '../../services/agent_service.dart';
import '../../services/fcm_dispatch_service.dart';
import '../../core/colors.dart';

class FarmerDetailSheet extends StatefulWidget {
  final UserModel farmer;

  const FarmerDetailSheet({super.key, required this.farmer});

  @override
  State<FarmerDetailSheet> createState() => _FarmerDetailSheetState();
}

class _FarmerDetailSheetState extends State<FarmerDetailSheet> {
  final AgentService _agentService = AgentService();
  
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  
  bool _useCustomPrice = false;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.farmer.name);
    _locationController = TextEditingController(text: widget.farmer.location);
    _priceController = TextEditingController();
    _loadCustomPrice();
  }

  Future<void> _loadCustomPrice() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('farmer_prices').doc(widget.farmer.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          _useCustomPrice = data['hasCustomPrice'] ?? false;
          if (data['customPrice'] != null) {
            _priceController.text = data['customPrice'].toString();
          }
        });
      }
    } catch (e) {
      // Ignore
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    final globalPrice = Provider.of<AgentProvider>(context, listen: false).agentSettings?.globalAgentPrice ?? 0.0;
    try {
      final newName = _nameController.text.trim();
      final newLocation = _locationController.text.trim();
      
      if (newName.isNotEmpty && newLocation.isNotEmpty) {
        if (newName != widget.farmer.name || newLocation != widget.farmer.location) {
          await _agentService.updateFarmerProfile(widget.farmer.uid, newName, newLocation);
        }
      }
      
      if (_useCustomPrice) {
        final price = double.tryParse(_priceController.text.trim());
        if (price != null) {
          await _agentService.setCustomPrice(widget.farmer.uid, price);
          FcmDispatchService().notifyCustomPriceSet(widget.farmer.uid, price);
        } else {
          throw Exception("Invalid price format");
        }
      } else {
        await _agentService.clearCustomPrice(widget.farmer.uid);
        FcmDispatchService().notifyCustomPriceReverted(widget.farmer.uid, globalPrice);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Farmer updated successfully'), backgroundColor: AppColors.primary));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final globalPrice = Provider.of<AgentProvider>(context).agentSettings?.globalAgentPrice ?? 0.0;
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: Text(_getInitials(widget.farmer.name), style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.farmer.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(widget.farmer.mobile, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('Rubber', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              
              // Editable Profile
              const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              
              // Custom Price Section
              const Text('Pricing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: const Text('Use custom price for this farmer'),
                      value: _useCustomPrice,
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() {
                          _useCustomPrice = val;
                          if (!val) {
                            _priceController.clear();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _priceController,
                      enabled: _useCustomPrice,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Custom Price',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: !_useCustomPrice,
                        fillColor: _useCustomPrice ? Colors.transparent : Colors.grey.shade100,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!_useCustomPrice)
                      Text(
                        'Using global price: ₹${globalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                  ],
                ),
                
              const SizedBox(height: 32),
              
              // Buttons
              ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
