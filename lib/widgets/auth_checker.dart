import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/routes.dart';

class AuthChecker extends StatefulWidget {
  final Widget child;
  final bool requireAuth;
  
  const AuthChecker({
    super.key,
    required this.child,
    this.requireAuth = true,
  });

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  bool _isChecking = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    if (!widget.requireAuth) {
      setState(() {
        _isChecking = false;
        _isAuthenticated = true;
      });
      return;
    }

    final isAuth = await AuthService.isAuthenticated();
    setState(() {
      _isChecking = false;
      _isAuthenticated = isAuth;
    });

    if (!isAuth) {
      // Navigate to login screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.requireAuth) {
      return widget.child;
    }

    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAuthenticated) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Authentication Required',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please login to continue',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
