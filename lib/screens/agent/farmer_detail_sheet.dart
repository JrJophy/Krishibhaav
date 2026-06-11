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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = theme.colorScheme.surface;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;
    final surfaceTintB = isDark ? AppColors.darkSurfaceTintB : AppColors.lightSurfaceTintB;
    final danger = isDark ? AppColors.darkDanger : AppColors.lightDanger;
    final inputFill = isDark ? Colors.grey.shade900 : Colors.grey.shade100;
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: surfaceTintB.withValues(alpha: 0.2),
                    child: Text(_getInitials(widget.farmer.name), style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.farmer.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: ink)),
                        const SizedBox(height: 4),
                        Text('${widget.farmer.location} • ${widget.farmer.mobile}', style: TextStyle(color: ink.withValues(alpha: 0.5), fontSize: 14)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('Rubber', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Divider(color: ink.withValues(alpha: 0.1)),
              const SizedBox(height: 16),
              
              // Editable Profile
              Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ink)),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                style: TextStyle(color: ink),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: ink.withValues(alpha: 0.6)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ink.withValues(alpha: 0.2))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationController,
                style: TextStyle(color: ink),
                decoration: InputDecoration(
                  labelText: 'Location',
                  labelStyle: TextStyle(color: ink.withValues(alpha: 0.6)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ink.withValues(alpha: 0.2))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                ),
              ),
              
              const SizedBox(height: 24),
              Divider(color: ink.withValues(alpha: 0.1)),
              const SizedBox(height: 16),
              
              // Custom Price Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pricing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ink)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _useCustomPrice ? const Color(0xFFF9A825).withValues(alpha: 0.2) : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _useCustomPrice ? 'Custom' : 'Global',
                      style: TextStyle(
                        fontSize: 12,
                        color: _useCustomPrice ? (isDark ? Colors.amber.shade300 : Colors.amber.shade900) : (isDark ? Colors.grey.shade300 : Colors.grey.shade800),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: Text('Use custom price for this farmer', style: TextStyle(color: ink)),
                      value: _useCustomPrice,
                      activeThumbColor: AppColors.primary,
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
                      style: TextStyle(color: ink),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Custom Price',
                        labelStyle: TextStyle(color: ink.withValues(alpha: 0.6)),
                        prefixText: '₹ ',
                        prefixStyle: TextStyle(color: ink),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ink.withValues(alpha: 0.2))),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                        disabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                        filled: !_useCustomPrice,
                        fillColor: _useCustomPrice ? Colors.transparent : inputFill,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!_useCustomPrice)
                      Text(
                        'Using global price: ₹${globalPrice.toStringAsFixed(2)}',
                        style: TextStyle(color: ink.withValues(alpha: 0.5), fontSize: 12),
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
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Remove ${widget.farmer.name}?', style: TextStyle(color: ink)),
                      content: Text('They will no longer see your prices.', style: TextStyle(color: ink.withValues(alpha: 0.7))),
                      backgroundColor: surface,
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: ink.withValues(alpha: 0.5)))),
                        TextButton(
                          onPressed: () {
                            Provider.of<AgentProvider>(context, listen: false).removeFarmer(widget.farmer.uid);
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                          },
                          child: Text('Remove', style: TextStyle(color: danger, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(Icons.delete, color: danger),
                label: Text('Remove Farmer', style: TextStyle(color: danger, fontSize: 16, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: danger.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
