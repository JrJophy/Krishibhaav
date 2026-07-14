import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/auth/login_register_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/agent/agent_home_screen.dart';
import 'screens/farmer/farmer_home_screen.dart';
import 'screens/booking_history_screen.dart';

String? _cachedRole;
bool isAwaitingOtp = false;

void resetAuthCache() {
  _cachedRole = null;
  isAwaitingOtp = false;
}

void setCachedRole(String role) {
  _cachedRole = role;
}

String? decideRedirect({
  required bool isAwaitingOtp,
  required bool loggedIn,
  String? cachedRole,
  required String location,
}) {
  final isAuthRoute = location == '/auth' || location == '/otp';
  final isSplash = location == '/';

  if (isSplash) return null;

  if (isAwaitingOtp) {
    if (isAuthRoute) return null;
    return '/otp';
  }

  if (!loggedIn) {
    if (!isAuthRoute) return '/auth';
    return null;
  }

  if (cachedRole == null) {
    return '/auth';
  }

  if (location.startsWith('/agent') && cachedRole != 'agent') {
    return '/farmer/home';
  }
  if (location.startsWith('/farmer') && cachedRole != 'farmer') {
    return '/agent/home';
  }

  if (isAuthRoute) {
    return cachedRole == 'agent' ? '/agent/home' : '/farmer/home';
  }

  return null;
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final user = FirebaseAuth.instance.currentUser;
    final location = state.matchedLocation;
    
    // Only fetch if we actually need the role (logged in, no role, not awaiting OTP, not splash)
    if (user != null && _cachedRole == null && !isAwaitingOtp && location != '/') {
      try {
        // Note: Firestore's default get() falls back to local cache when offline, preserving offline mode.
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          _cachedRole = doc.get('role');
        } else {
          await FirebaseAuth.instance.signOut();
          resetAuthCache();
        }
      } catch (_) {
        await FirebaseAuth.instance.signOut();
        resetAuthCache();
      }
    }

    if (user != null && _cachedRole == null && !isAwaitingOtp && location != '/') {
      // Failsafe if role still null after fetch
      await FirebaseAuth.instance.signOut();
      resetAuthCache();
    }

    return decideRedirect(
      isAwaitingOtp: isAwaitingOtp,
      loggedIn: user != null,
      cachedRole: _cachedRole,
      location: location,
    );
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
    GoRoute(
      path: '/history',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return BookingHistoryScreen(role: extra['role'] ?? 'farmer');
      },
    ),

  ],
);
