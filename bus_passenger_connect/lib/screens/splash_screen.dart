import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  final VoidCallback onInitializationComplete;

  const SplashScreen({super.key, required this.onInitializationComplete});

  @override
  Widget build(BuildContext context) {
    // Start the timer to simulate initialization process
    _startTimer();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade800, Colors.blue.shade500],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_bus,
                  size: 80,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 30),
              // App Name
              const Text(
                'Bus Passenger Connect',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              // Tagline
              const Text(
                'Making your commute easier',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 50),
              // Loading indicator
              const SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startTimer() {
    // Simulate app initialization with a delay
    Future.delayed(const Duration(seconds: 2), () {
      onInitializationComplete();
    });
  }
}
