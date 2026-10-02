import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_icon.dart';
import '../widgets/shimmer_text.dart';
import '../widgets/particle_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    // Simple navigation with a single timer to prevent multiple navigations
    Timer(const Duration(milliseconds: 2000), _navigateToAuthScreen);
  }

  void _navigateToAuthScreen() {
    if (!mounted || _hasNavigated) return;

    _hasNavigated = true;

    // Use a simpler navigation approach
    Navigator.of(context).pushReplacementNamed('/auth');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    isDarkMode
                        ? [const Color(0xFF2D3748), const Color(0xFF1A202C)]
                        : [const Color(0xFFFCE4EC), const Color(0xFFF8BBD0)],
              ),
            ),
          ),

          // Particle background - wrapped with error handling
          Builder(
            builder: (context) {
              try {
                return ParticleBackground(
                  color:
                      isDarkMode
                          ? Colors.white.withOpacity(0.3)
                          : Colors.pink.withOpacity(0.3),
                  numberOfParticles: 40,
                );
              } catch (e) {
                // Return an empty container if the particle background fails
                print('Error rendering particle background: $e');
                return Container();
              }
            },
          ),

          // Content
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App icon - wrapped with error handling
                        Builder(
                          builder: (context) {
                            try {
                              return AppIcon(
                                size: size.width * 0.4,
                                color:
                                    isDarkMode
                                        ? Colors.pink.shade200
                                        : Colors.pink.shade700,
                              );
                            } catch (e) {
                              // Fallback to a simple icon if the custom one fails
                              print('Error rendering app icon: $e');
                              return Icon(
                                Icons.favorite,
                                size: size.width * 0.3,
                                color:
                                    isDarkMode
                                        ? Colors.pink.shade200
                                        : Colors.pink.shade700,
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        // Shimmer text - wrapped with error handling
                        Builder(
                          builder: (context) {
                            try {
                              return ShimmerText(
                                text: 'Period Tracker',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDarkMode
                                          ? Colors.white
                                          : Colors.pink.shade900,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      offset: const Offset(1, 1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              );
                            } catch (e) {
                              // Fallback to a simple text if the shimmer text fails
                              print('Error rendering shimmer text: $e');
                              return Text(
                                'Period Tracker',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDarkMode
                                          ? Colors.white
                                          : Colors.pink.shade900,
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        // Shimmer text - wrapped with error handling
                        Builder(
                          builder: (context) {
                            try {
                              return ShimmerText(
                                text: 'Track your cycle with ease',
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      isDarkMode
                                          ? Colors.grey.shade300
                                          : Colors.pink.shade800,
                                  letterSpacing: 0.5,
                                ),
                                duration: const Duration(milliseconds: 2000),
                              );
                            } catch (e) {
                              // Fallback to a simple text if the shimmer text fails
                              print('Error rendering shimmer text: $e');
                              return Text(
                                'Track your cycle with ease',
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      isDarkMode
                                          ? Colors.grey.shade300
                                          : Colors.pink.shade800,
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDarkMode
                                  ? Colors.pink.shade200
                                  : Colors.pink.shade700,
                            ),
                            strokeWidth: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
