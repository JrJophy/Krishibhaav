import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../app_router.dart';

class OtpScreen extends StatefulWidget {
  final String otpGenerated;
  final Map<String, dynamic> userData;
  final String password;

  const OtpScreen({
    super.key,
    required this.otpGenerated,
    required this.userData,
    required this.password,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

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
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _verifyOtp() async {
    String enteredOtp = _controllers.map((c) => c.text).join();
    if (enteredOtp.length != 6) return;

    final provider = Provider.of<AuthProvider>(context, listen: false);
    final success = await provider.verifyOTP(
      otpEntered: enteredOtp,
      otpGenerated: widget.otpGenerated,
      userData: widget.userData,
      password: widget.password,
    );

    if (success && mounted) {
      isAwaitingOtp = false;
      setCachedRole(widget.userData['role']);
      if (widget.userData['role'] == 'agent') {
        context.go('/agent/home');
      } else {
        final user = FirebaseAuth.instance.currentUser;
        bool shouldRouteToLink = false;
        
        if (user != null) {
          try {
            final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
            if (doc.exists) {
              final agentId = doc.data()?['agentId'] ?? '';
              if (agentId.isEmpty) {
                shouldRouteToLink = true;
              }
            }
          } catch (_) {}
        }
        
        if (mounted) {
          if (shouldRouteToLink && user != null) {
            context.go('/farmer/request_link', extra: {'farmerId': user.uid});
          } else {
            context.go('/farmer/home');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String mobile = widget.userData['mobile'] ?? '';
    String maskedMobile = mobile.length == 10 
      ? '+91 XXXXXX${mobile.substring(6)}' 
      : '+91 $mobile';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Verify OTP', style: TextStyle(color: ink, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Sending to $maskedMobile', style: TextStyle(fontSize: 18, color: ink.withValues(alpha: 0.7))),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 40,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ink),
                    decoration: InputDecoration(
                      counterText: '',
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ink.withValues(alpha: 0.2))),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                    ),
                    onChanged: (val) => _onChanged(val, index),
                  ),
                );
              }),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _verifyOtp,
                child: const Text('Verify & Continue', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
              child: Text('← Change Details', style: TextStyle(color: ink.withValues(alpha: 0.6))),
            ),
          ],
        ),
      ),
    );
  }
}
