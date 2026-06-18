import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/colors.dart';

class BarrelStockEditDialog extends StatefulWidget {
  final int currentTotal;
  final int currentAvailable;

  const BarrelStockEditDialog({
    super.key,
    required this.currentTotal,
    required this.currentAvailable,
  });

  @override
  State<BarrelStockEditDialog> createState() => _BarrelStockEditDialogState();
}

class _BarrelStockEditDialogState extends State<BarrelStockEditDialog> {
  late TextEditingController _controller;
  String? _errorText;
  late int _outstanding;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentTotal.toString());
    _outstanding = widget.currentTotal - widget.currentAvailable;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _errorText = 'Cannot be empty');
      return;
    }
    
    final newTotal = int.tryParse(text);
    if (newTotal == null) {
      setState(() => _errorText = 'Invalid number');
      return;
    }

    if (newTotal < _outstanding) {
      setState(() => _errorText = 'Cannot drop below $_outstanding (currently booked)');
      return;
    }

    Navigator.of(context).pop(newTotal);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;
    final surface = theme.colorScheme.surface;

    return AlertDialog(
      backgroundColor: surface,
      title: Text('Edit Total Barrels', style: TextStyle(color: ink, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(color: ink, fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              errorText: _errorText,
              prefixText: 'Total: ',
              prefixStyle: TextStyle(color: ink.withValues(alpha: 0.5), fontSize: 16),
            ),
            onSubmitted: (_) => _submit(),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          Text(
            'Available: ${widget.currentAvailable}\nOutstanding: $_outstanding',
            style: TextStyle(color: ink.withValues(alpha: 0.6), fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: ink.withValues(alpha: 0.5))),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: _submit,
          child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
