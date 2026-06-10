import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/auth/login_register_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/agent/agent_home_screen.dart';

class DummyScreen extends StatelessWidget {
  final String title;
  const DummyScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)), body: Center(child: Text(title)));
}

String? _cachedRole;

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final user = FirebaseAuth.instance.currentUser;
    final isAuthRoute = state.matchedLocation == '/auth' || state.matchedLocation == '/otp';
    final isSplash = state.matchedLocation == '/';

    if (isSplash) return null;

    if (user == null) {
      if (!isAuthRoute) return '/auth';
    } else {
      if (isAuthRoute) {
        if (_cachedRole == null) {
          try {
            final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
            if (doc.exists) {
              _cachedRole = doc.get('role');
            }
          } catch (_) {}
        }
        
        if (_cachedRole == 'agent') {
          return '/agent/home';
        } else {
          return '/farmer/home';
        }
      }
    }
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/auth', builder: (context, state) => const LoginRegisterScreen()),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return OtpScreen(
          otpGenerated: extra['otpGenerated'] ?? '',
          userData: extra['userData'] ?? {},
        );
      },
    ),
    GoRoute(
      path: '/farmer/home', 
      builder: (context, state) {
        final user = FirebaseAuth.instance.currentUser;
        return FarmerHomeScreen(farmerId: user?.uid ?? '');
      },
    ),
    GoRoute(path: '/agent/home', builder: (context, state) => const AgentHomeScreen()),
    GoRoute(path: '/agent/profile', builder: (context, state) => const DummyScreen(title: 'Coming in Phase 8')),
    GoRoute(path: '/farmer/profile', builder: (context, state) => const DummyScreen(title: 'Coming in Phase 8')),
    GoRoute(path: '/profile', builder: (context, state) => const DummyScreen(title: 'Profile')),
    GoRoute(path: '/settings', builder: (context, state) => const DummyScreen(title: 'Settings')),
    GoRoute(path: '/notifications', builder: (context, state) => const DummyScreen(title: 'Notifications')),
    GoRoute(path: '/charts', builder: (context, state) => const DummyScreen(title: 'Charts')),
  ],
);
