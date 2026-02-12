import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    Timer(const Duration(seconds: 3), () {
       if (mounted) {
         Provider.of<AppState>(context, listen: false).setScreen('login');
       }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFC084FC), // Purple-400
              Color(0xFF60A5FA), // Blue-400
              Color(0xFF2DD4BF), // Teal-400
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background Icons (Simulated with absolute positioning)
            const Positioned(
              top: 80,
              left: 40,
              child: Icon(Icons.menu_book, color: Colors.white24, size: 30),
            ),
            const Positioned(
              top: 160,
              right: 60,
              child: Icon(Icons.people, color: Colors.white24, size: 28),
            ),
            const Positioned(
              bottom: 160,
              left: 80,
              child: Icon(Icons.school, color: Colors.white24, size: 32),
            ),
            
            // Main Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _animation,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white30),
                      ),
                      child: const Icon(Icons.school, size: 48, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'EduLink',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Empowering Student Collaboration',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(),
                      const SizedBox(width: 8),
                      _buildDot(delay: 100),
                      const SizedBox(width: 8),
                      _buildDot(delay: 200),
                    ],
                  ),
                ],
              ),
            ),
            
            // Bottom Text
            const Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Connecting Students • Sharing Knowledge',
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot({int delay = 0}) {
    // Simplified dot animation
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}
