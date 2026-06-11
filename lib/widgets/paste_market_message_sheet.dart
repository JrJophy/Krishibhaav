import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/market_message_parser.dart';
import '../../providers/agent_provider.dart';
import '../../utils/theme.dart';

class PasteMarketMessageSheet extends StatefulWidget {
  final double currentRss4;
  final double currentRss5;

  const PasteMarketMessageSheet({
    super.key,
    required this.currentRss4,
    required this.currentRss5,
  });

  @override
  State<PasteMarketMessageSheet> createState() => _PasteMarketMessageSheetState();
}

class _PasteMarketMessageSheetState extends State<PasteMarketMessageSheet> {
  final TextEditingController _controller = TextEditingController();
  MarketMessageResult? _result;
  String? _errorText;
  bool _isParsing = false;

  void _parse() {
    setState(() {
      _errorText = null;
      _result = null;
    });

    final text = _controller.text;
    if (text.isEmpty) {
      setState(() => _errorText = 'Please paste the message first.');
      return;
    }

    final parsed = MarketMessageParser.parseMarketMessage(text);
    if (parsed.error != null) {
      setState(() => _errorText = parsed.error);
    } else {
      setState(() => _result = parsed);
    }
  }

  void _confirm() {
    if (_result == null) return;
    
    final rss4 = _result!.openMarketRss4 ?? widget.currentRss4;
    final rss5 = _result!.openMarketRss5 ?? widget.currentRss5;

    Provider.of<AgentProvider>(context, listen: false).updatePrice('Open Market Price', rss4, rss5);
    
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Open Market Price updated successfully'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;
    final surfaceTintB = isDark ? AppColors.darkSurfaceTintB : AppColors.lightSurfaceTintB;
    final valueGreen = isDark ? AppColors.darkValueGreen : AppColors.lightValueGreen;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Paste Market Message', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ink)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 8,
            minLines: 4,
            style: TextStyle(color: ink),
            decoration: InputDecoration(
              hintText: 'Paste the WhatsApp market message here...',
              filled: true,
              fillColor: surfaceTintB.withValues(alpha: 0.1),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              errorText: _errorText,
            ),
          ),
          const SizedBox(height: 16),
          if (_result == null)
            ElevatedButton(
              onPressed: _parse,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Parse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: valueGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: valueGreen.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Preview', style: TextStyle(fontWeight: FontWeight.bold, color: valueGreen)),
                  const SizedBox(height: 8),
                  if (_result!.openMarketRss4 != null && _result!.openMarketRss5 != null)
                    Text('Open Market RSS4: ₹${_result!.openMarketRss4!.toStringAsFixed(2)} / RSS5: ₹${_result!.openMarketRss5!.toStringAsFixed(2)}', style: TextStyle(color: ink, fontSize: 16))
                  else ...[
                    if (_result!.openMarketRss4 != null)
                      Text('Open Market RSS4: ₹${_result!.openMarketRss4!.toStringAsFixed(2)}', style: TextStyle(color: ink, fontSize: 16)),
                    if (_result!.openMarketRss4 == null)
                      Text('RSS4 not found — will keep current value (₹${widget.currentRss4.toStringAsFixed(2)})', style: TextStyle(color: ink.withValues(alpha: 0.6), fontSize: 14)),
                    const SizedBox(height: 4),
                    if (_result!.openMarketRss5 != null)
                      Text('Open Market RSS5: ₹${_result!.openMarketRss5!.toStringAsFixed(2)}', style: TextStyle(color: ink, fontSize: 16)),
                    if (_result!.openMarketRss5 == null)
                      Text('RSS5 not found — will keep current value (₹${widget.currentRss5.toStringAsFixed(2)})', style: TextStyle(color: ink.withValues(alpha: 0.6), fontSize: 14)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => _result = null),
                    child: Text('Cancel', style: TextStyle(color: ink.withValues(alpha: 0.7))),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: valueGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
