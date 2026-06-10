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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Share this password with $name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Temporary Password:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade200,
              child: SelectableText(
                password,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
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
            child: const Text('Copy Password'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 24, bottom: bottomInset + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add New Farmer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full Name *'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _mobileController,
            keyboardType: TextInputType.number,
            maxLength: 10,
            decoration: const InputDecoration(labelText: 'Mobile Number *'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(labelText: 'Location (Optional)'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: 'Rubber'),
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Crop',
              helperText: 'More crops coming soon',
              filled: true,
            ),
          ),
          const SizedBox(height: 24),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: _isLoading ? null : _handleAdd,
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Add Farmer', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
