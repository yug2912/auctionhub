// Author: Arsh
// Role: Lead Developer / Repository Manager
// Description: Splash screen shown on app launch before navigating to login
import 'package:flutter/material.dart';
import 'login_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E2A),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top orange bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: const Color(0xFFFF6B00),
              child: const SafeArea(
                child: Center(
                  child: Text(
                    'Auction Hub',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),

            // Center content
            ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                children: [
                  // Logo image
                  Image.asset(
                    'assets/logo.png',
                    width: 160,
                    height: 160,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome To\nAuction Hub',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom section
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Column(
                children: [
                  // Get Started button
                  SizedBox(
                    width: 220,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tagline
                  const Text(
                    'Bid.Win.Save',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
