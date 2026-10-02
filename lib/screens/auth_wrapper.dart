import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/period_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'dart:async';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  late AuthProvider _authProvider;
  late PeriodProvider _periodProvider;
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Simplified initialization
    _initializeProviders();
  }

  Future<void> _initializeProviders() async {
    try {
      // Get providers
      _authProvider = Provider.of<AuthProvider>(context, listen: false);
      _periodProvider = Provider.of<PeriodProvider>(context, listen: false);

      // Check auth state with a timeout
      await _checkAuthWithTimeout();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error during initialization: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _error = 'Failed to initialize: $e';
        });
      }
    }
  }

  Future<void> _checkAuthWithTimeout() async {
    bool completed = false;

    // Start a timeout
    Timer(const Duration(seconds: 3), () {
      if (!completed && mounted) {
        print('Auth check timed out, proceeding anyway');
        // Just continue without waiting for auth check
        setState(() {
          _isInitialized = true;
        });
      }
    });

    try {
      // Attempt to check auth state
      await _authProvider.checkAuthState();
      completed = true;
    } catch (e) {
      print('Error checking auth state: $e');
      completed = true;
      // Continue even if there's an error
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app resumes, check authentication status again
    if (state == AppLifecycleState.resumed) {
      _authProvider.checkAuthState();

      // If user is authenticated, sync period data
      if (_authProvider.isAuthenticated) {
        _periodProvider.initialize();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we encountered an error during initialization
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _isInitialized = false;
                  });
                  _initializeProviders();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // If not yet initialized, show loading
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing...'),
            ],
          ),
        ),
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show a loading indicator while checking authentication
        if (!authProvider.hasCheckedInitialAuth) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Navigate to LoginScreen or HomeScreen based on authentication
        return authProvider.isAuthenticated
            ? const HomeScreen()
            : const LoginScreen();
      },
    );
  }
}
