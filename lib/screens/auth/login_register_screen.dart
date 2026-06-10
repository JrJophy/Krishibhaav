import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../providers/auth_provider.dart';

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
    final password = _signInPasswordController.text;

    if (mobile.isEmpty || password.isEmpty) return;

    final provider = Provider.of<AuthProvider>(context, listen: false);
    final success = await provider.signIn(mobile, password);

    if (success) {
      if (mounted) {
        final role = provider.userRole;
        if (role == 'agent') {
          context.go('/agent_dashboard');
        } else {
          context.go('/farmer_dashboard');
        }
      }
    } else {
      _shakeController.forward(from: 0.0).then((_) => _shakeController.reset());
    }
  }

  void _handleRegister() async {
    final name = _regNameController.text.trim();
    final mobile = _regMobileController.text.trim();
    final password = _regPasswordController.text;
    final location = _regLocationController.text.trim();

    if (name.isEmpty || mobile.length != 10 || password.length < 6 || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields correctly.')));
      return;
    }

    final provider = Provider.of<AuthProvider>(context, listen: false);
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

  Widget _buildSignInTab() {
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _signInMobileController,
              keyboardType: TextInputType.number,
              maxLength: 10,
              decoration: const InputDecoration(labelText: 'Mobile Number'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _signInPasswordController,
              obscureText: _obscureSignInPassword,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(_obscureSignInPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscureSignInPassword = !_obscureSignInPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: _handleSignIn,
                child: const Text('Sign In', style: TextStyle(color: Colors.white)),
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

  Widget _buildRegisterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _regNameController,
            decoration: const InputDecoration(labelText: 'Full Name'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _regMobileController,
            keyboardType: TextInputType.number,
            maxLength: 10,
            decoration: const InputDecoration(labelText: 'Mobile Number'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _regPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password (min 6 chars)'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _regLocationController,
            decoration: const InputDecoration(labelText: 'Location'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('I am a Farmer'),
                selected: _selectedRole == 'farmer',
                onSelected: (val) {
                  if (val) setState(() => _selectedRole = 'farmer');
                },
              ),
              const SizedBox(width: 16),
              ChoiceChip(
                label: const Text('I am an Agent'),
                selected: _selectedRole == 'agent',
                onSelected: (val) {
                  if (val) setState(() => _selectedRole = 'agent');
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: _handleRegister,
              child: const Text('Send OTP', style: TextStyle(color: Colors.white)),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome', style: AppTextStyles.poppinsHeading),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sign In'),
            Tab(text: 'Register'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSignInTab(),
          _buildRegisterTab(),
        ],
      ),
    );
  }
}
