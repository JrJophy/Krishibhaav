import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/colors.dart';
import 'core/text_styles.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase initialization will go here in Phase 2
  
  runApp(const KrishibhaavApp());
}

class KrishibhaavApp extends StatelessWidget {
  const KrishibhaavApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Basic Provider scaffolding, to be expanded
    return MultiProvider(
      providers: [
        Provider<String>(create: (_) => 'Placeholder Provider'),
      ],
      child: MaterialApp(
        title: 'Krishibhaav',
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
