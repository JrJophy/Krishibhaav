import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../app_router.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  // Sign In Controllers
  final _signInMobileController = TextEditingController();
  final _signInPasswordController = TextEditingController();
  bool _obscureSignInPassword = true;

  // Register Controllers
  final _regNameController = TextEditingController();
  final _regMobileController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regLocationController = TextEditingController();
  bool _obscureRegPassword = true;
  String _selectedRole = 'farmer';

  // Animation for shake
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInMobileController.dispose();
    _signInPasswordController.dispose();
    _regNameController.dispose();
    _regMobileController.dispose();
    _regPasswordController.dispose();
    _regLocationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    final mobile = _signInMobileController.text.trim();
    final password = _signInPasswordController.text.trim();

    if (mobile.isEmpty || password.isEmpty) return;

    final provider = Provider.of<AuthProvider>(context, listen: false);
    final success = await provider.signIn(mobile, password);

    if (success) {
      if (mounted) {
        final role = provider.userRole;
        if (role == 'agent') {
          context.go('/agent/home');
        } else {
          context.go('/farmer/home');
        }
      }
    } else {
      _shakeController.forward(from: 0.0).then((_) => _shakeController.reset());
    }
  }

  void _handleRegister() async {
    final name = _regNameController.text.trim();
    final mobile = _regMobileController.text.trim();
    final password = _regPasswordController.text.trim();
    final location = _regLocationController.text.trim();

    if (name.isEmpty || mobile.length != 10 || password.length < 6 || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields correctly.')));
      return;
    }

    final provider = Provider.of<AuthProvider>(context, listen: false);
    isAwaitingOtp = true;
    final otp = await provider.register(
      name: name,
      mobile: mobile,
      password: password,
      role: _selectedRole,
      location: location,
    );

    if (otp != null && mounted) {
      context.push('/otp', extra: {
        'otpGenerated': otp,
        'userData': {
          'uid': provider.userId,
          'name': name,
          'mobile': mobile,
          'role': _selectedRole,
          'location': location,
          'crop': 'Rubber',
          'fcmToken': '',
        }
      });
    }
  }

  Widget _buildSignInTab(ThemeData theme, bool isDark, Color ink) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final dx = sin(_shakeController.value * pi * 4) * 8;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _signInMobileController,
              keyboardType: TextInputType.number,
              maxLength: 10,
              style: TextStyle(color: ink),
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                labelStyle: TextStyle(color: ink.withValues(alpha: 0.6)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ink.withValues(alpha: 0.2))),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _signInPasswordController,
              obscureText: _obscureSignInPassword,
              style: TextStyle(color: ink),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: ink.withValues(alpha: 0.6)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ink.withValues(alpha: 0.2))),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                suffixIcon: IconButton(
                  icon: Icon(_obscureSignInPassword ? Icons.visibility : Icons.visibility_off, color: ink.withValues(alpha: 0.5)),
                  onPressed: () {
                    setState(() {
                      _obscureSignInPassword = !_obscureSignInPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _handleSignIn,
                child: const Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (auth.errorMessage != null && _tabController.index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(auth.errorMessage!, style: const TextStyle(color: Colors.red)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterTab(ThemeData theme, bool isDark, Color ink) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          TextField(
            controller: _regNameController,
            style: TextStyle(color: ink),
            decoration: InputDecoration(
              labelText: 'Full Name',
              labelStyle: TextStyle(color: ink.withValues(alpha: 0.6)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ink.withValues(alpha: 0.2))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _regMobileController,
            keyboardType: TextInputType.number,
            maxLength: 10,
            style: TextStyle(color: ink),
            decoration: InputDecoration(
              labelText: 'Mobile Number',
              labelStyle: TextStyle(color: ink.withValues(alpha: 0.6)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ink.withValues(alpha: 0.2))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _regPasswordController,
            obscureText: _obscureRegPassword,
            style: TextStyle(color: ink),
            decoration: InputDecoration(
              labelText: 'Password (min 6 chars)',
              labelStyle: TextStyle(color: ink.withValues(alpha: 0.6)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ink.withValues(alpha: 0.2))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
              suffixIcon: IconButton(
                icon: Icon(_obscureRegPassword ? Icons.visibility : Icons.visibility_off, color: ink.withValues(alpha: 0.5)),
                onPressed: () {
                  setState(() {
                    _obscureRegPassword = !_obscureRegPassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _regLocationController,
            style: TextStyle(color: ink),
            decoration: InputDecoration(
              labelText: 'Location',
              labelStyle: TextStyle(color: ink.withValues(alpha: 0.6)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ink.withValues(alpha: 0.2))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('I am a Farmer'),
                selected: _selectedRole == 'farmer',
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(color: _selectedRole == 'farmer' ? AppColors.primary : ink, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: _selectedRole == 'farmer' ? AppColors.primary : ink.withValues(alpha: 0.2)),
                ),
                onSelected: (val) {
                  if (val) setState(() => _selectedRole = 'farmer');
                },
              ),
              const SizedBox(width: 16),
              ChoiceChip(
                label: const Text('I am an Agent'),
                selected: _selectedRole == 'agent',
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(color: _selectedRole == 'agent' ? AppColors.primary : ink, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: _selectedRole == 'agent' ? AppColors.primary : ink.withValues(alpha: 0.2)),
                ),
                onSelected: (val) {
                  if (val) setState(() => _selectedRole = 'agent');
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _handleRegister,
              child: const Text('Send OTP', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              if (auth.errorMessage != null && _tabController.index == 1) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(auth.errorMessage!, style: const TextStyle(color: Colors.red)),
                );
              }
              return const SizedBox.shrink();
            },
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            Image.asset('assets/branding/lockup.png', width: 220),
            const SizedBox(height: 48),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: ink.withValues(alpha: 0.5),
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              tabs: const [
                Tab(text: 'Sign In'),
                Tab(text: 'Register'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSignInTab(theme, isDark, ink),
                  _buildRegisterTab(theme, isDark, ink),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
