import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class DummyScreen extends StatelessWidget {
  final String title;
  const DummyScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)), body: Center(child: Text(title)));
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    // Auth guard logic
    final bool isAuthenticated = false; // Replace with actual auth state
    final bool isAuthRoute = state.matchedLocation == '/login';
    
    if (!isAuthenticated && !isAuthRoute && state.matchedLocation != '/') return '/login';
    if (isAuthenticated && isAuthRoute) return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const DummyScreen(title: 'Splash')),
    GoRoute(path: '/login', builder: (context, state) => const DummyScreen(title: 'Login')),
    GoRoute(path: '/home', builder: (context, state) => const DummyScreen(title: 'Home')),
    GoRoute(path: '/agent_dashboard', builder: (context, state) => const DummyScreen(title: 'Agent Dashboard')),
    GoRoute(path: '/farmer_dashboard', builder: (context, state) => const DummyScreen(title: 'Farmer Dashboard')),
    GoRoute(path: '/profile', builder: (context, state) => const DummyScreen(title: 'Profile')),
    GoRoute(path: '/settings', builder: (context, state) => const DummyScreen(title: 'Settings')),
    GoRoute(path: '/notifications', builder: (context, state) => const DummyScreen(title: 'Notifications')),
    GoRoute(path: '/charts', builder: (context, state) => const DummyScreen(title: 'Charts')),
  ],
);
