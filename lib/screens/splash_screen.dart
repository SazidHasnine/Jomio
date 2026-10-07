import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'auth_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.primary,
            highlightColor: Colors.red.shade200,
            child: Image.asset(
              'assets/jomio-custom-lettering.png',
              width: 250,
            ),
          ),
        ),
      );
    }

    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.currentUserId == null) {
          return const AuthScreen();
        }
        return const DashboardScreen();
      },
    );
  }
}
