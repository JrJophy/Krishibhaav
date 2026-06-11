import 'package:flutter/material.dart';
import '../core/colors.dart';

class PriceEditDialog extends StatefulWidget {
  final String priceName;
  final double currentValue;

  const PriceEditDialog({
    super.key,
    required this.priceName,
    required this.currentValue,
  });

  @override
  State<PriceEditDialog> createState() => _PriceEditDialogState();
}

class _PriceEditDialogState extends State<PriceEditDialog> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final text = _controller.text;
    if (text.isEmpty) {
      setState(() => _errorText = 'Please enter a value');
      return;
    }
    final value = double.tryParse(text);
    if (value == null || value < 0) {
      setState(() => _errorText = 'Invalid number');
      return;
    }

    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update ${widget.priceName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Current: ₹${widget.currentValue.toStringAsFixed(2)}',
              prefixText: '₹ ',
              errorText: _errorText,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: _confirm,
          child: const Text('Confirm', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
