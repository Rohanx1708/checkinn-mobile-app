import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../utils/routes.dart';
import '../../widgets/checkinn_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait a bit for splash screen visibility
    await Future.delayed(const Duration(milliseconds: 600));
    
    if (!mounted) return;
    
    // Check if user is authenticated
    final isAuthenticated = await AuthService.isAuthenticated();
    
    if (!mounted) return;
    
    // Navigate based on authentication status
    if (isAuthenticated) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CheckInnLogo(
              iconSize: 80,
              fontSize: 32,
            ),
          ],
        ),
      ),
    );
  }
}

