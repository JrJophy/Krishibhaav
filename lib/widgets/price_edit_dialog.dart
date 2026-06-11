import 'package:flutter/material.dart';
import '../core/colors.dart';

class PriceEditDialog extends StatefulWidget {
  final String priceName;
  final double currentValue;

  const PriceEditDialog({
    super.key,
    required this.priceName,
    required this.currentValue,
    this.currentValue2,
  });

  final double? currentValue2;

  @override
  State<PriceEditDialog> createState() => _PriceEditDialogState();
}

class _PriceEditDialogState extends State<PriceEditDialog> {
  late TextEditingController _controller;
  late TextEditingController _controller2;
  String? _errorText;
  String? _errorText2;

  bool get isDual => widget.priceName == 'Open Market Price';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller2 = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller2.dispose();
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

    if (isDual) {
      final text2 = _controller2.text;
      if (text2.isEmpty) {
        setState(() => _errorText2 = 'Please enter RSS5 value');
        return;
      }
      final value2 = double.tryParse(text2);
      if (value2 == null || value2 < 0) {
        setState(() => _errorText2 = 'Invalid number');
        return;
      }
      Navigator.of(context).pop([value, value2]);
    } else {
      Navigator.of(context).pop([value]);
    }
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
              labelText: isDual ? 'RSS4 (Current: ₹${widget.currentValue.toStringAsFixed(2)})' : 'Current: ₹${widget.currentValue.toStringAsFixed(2)}',
              prefixText: '₹ ',
              errorText: _errorText,
            ),
          ),
          if (isDual) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _controller2,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'RSS5 (Current: ₹${(widget.currentValue2 ?? 0.0).toStringAsFixed(2)})',
                prefixText: '₹ ',
                errorText: _errorText2,
              ),
            ),
          ],
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
