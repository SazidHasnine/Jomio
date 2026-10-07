import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'providers/app_provider.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Dependency Injection setup
  final authService = FirebaseAuthService();
  final databaseService = FirestoreDatabaseService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider(authService, databaseService)),
      ],
      child: const JomioApp(),
    ),
  );
}

class JomioApp extends StatelessWidget {
  const JomioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jomio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE53935),
          primary: const Color(0xFFE53935),
          secondary: const Color(0xFF4CAF50),
        ),
        fontFamily: GoogleFonts.inter().fontFamily,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
