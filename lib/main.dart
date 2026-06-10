import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/colors.dart';
import 'core/text_styles.dart';
import 'providers/auth_provider.dart';
import 'providers/agent_provider.dart';
import 'providers/farmer_provider.dart';
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(const KrishibhaavApp());
}

class KrishibhaavApp extends StatelessWidget {
  const KrishibhaavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<AgentProvider>(create: (_) => AgentProvider()),
        ChangeNotifierProvider<FarmerProvider>(create: (_) => FarmerProvider()),
      ],
      child: MaterialApp.router(
        title: 'Krishibhaav',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
      ),
    );
  }
}
