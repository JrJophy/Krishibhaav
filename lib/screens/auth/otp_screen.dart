import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';
import '../../providers/auth_provider.dart';

class OtpScreen extends StatefulWidget {
  final String otpGenerated;
  final Map<String, dynamic> userData;

  const OtpScreen({
    super.key,
    required this.otpGenerated,
    required this.userData,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _verifyOtp() async {
    String enteredOtp = _controllers.map((c) => c.text).join();
    if (enteredOtp.length != 4) return;

    final provider = Provider.of<AuthProvider>(context, listen: false);
    final success = await provider.verifyOTP(
      uid: widget.userData['uid'] ?? '',
      otpEntered: enteredOtp,
      otpGenerated: widget.otpGenerated,
      userData: widget.userData,
    );

    if (success && mounted) {
      if (widget.userData['role'] == 'agent') {
        context.go('/agent_dashboard');
      } else {
        context.go('/farmer_dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String mobile = widget.userData['mobile'] ?? '';
    String maskedMobile = mobile.length == 10 
      ? '+91 XXXXXX${mobile.substring(6)}' 
      : '+91 $mobile';

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Sending to $maskedMobile', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.secondary.withOpacity(0.2),
              child: Text(
                'Your OTP is: ${widget.otpGenerated}',
                style: const TextStyle(fontSize: 20, color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 50,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(counterText: ''),
                    onChanged: (val) => _onChanged(val, index),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: _verifyOtp,
                child: const Text('Verify & Continue', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (auth.errorMessage != null) {
                  return Text(auth.errorMessage!, style: const TextStyle(color: Colors.red));
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('← Change Details'),
            ),
          ],
        ),
      ),
    );
  }
}
