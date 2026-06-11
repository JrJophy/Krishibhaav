import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../providers/agent_provider.dart';

class AddFarmerSheet extends StatefulWidget {
  const AddFarmerSheet({super.key});

  @override
  State<AddFarmerSheet> createState() => _AddFarmerSheetState();
}

class _AddFarmerSheetState extends State<AddFarmerSheet> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _handleAdd() async {
    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();
    final location = _locationController.text.trim();

    if (name.isEmpty || mobile.length != 10) {
      setState(() => _error = "Please provide name and a 10-digit mobile number");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = Provider.of<AgentProvider>(context, listen: false);
      final tempPassword = await provider.addFarmer(name, mobile, location);
      
      setState(() => _isLoading = false);
      
      if (mounted) {
        _showSuccessDialog(name, tempPassword);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _showSuccessDialog(String name, String password) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceTintA = isDark ? AppColors.darkSurfaceTintA : AppColors.lightSurfaceTintA;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;
    final surface = theme.colorScheme.surface;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        title: Text('Share this password with $name', style: TextStyle(color: ink, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Temporary Password:', style: TextStyle(color: ink.withValues(alpha: 0.7))),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceTintA.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                password,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: ink,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: password));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password copied to clipboard')),
              );
            },
            child: const Text('Copy Password', style: TextStyle(color: AppColors.primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;
    final inputFill = isDark ? Colors.grey.shade900 : Colors.grey.shade100;
    final surface = theme.colorScheme.surface;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomInset,
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
              Text('Add New Farmer', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: ink)),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                style: TextStyle(color: ink),
                decoration: InputDecoration(
                  labelText: 'Full Name *',
                  labelStyle: TextStyle(color: ink.withValues(alpha: 0.6)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ink.withValues(alpha: 0.2))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _mobileController,
                style: TextStyle(color: ink),
                keyboardType: TextInputType.number,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: 'Mobile Number *',
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
                  labelText: 'Location (Optional)',
                  labelStyle: TextStyle(color: ink.withValues(alpha: 0.6)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ink.withValues(alpha: 0.2))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: 'Rubber'),
                enabled: false,
                style: TextStyle(color: ink.withValues(alpha: 0.7)),
                decoration: InputDecoration(
                  labelText: 'Crop',
                  labelStyle: TextStyle(color: ink.withValues(alpha: 0.6)),
                  helperText: 'More crops coming soon',
                  helperStyle: TextStyle(color: ink.withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: inputFill,
                  border: UnderlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _handleAdd,
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Add Farmer', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
