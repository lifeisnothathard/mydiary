import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mydiary/pages/login.dart';
import 'package:mydiary/services/themes/themeprovider.dart';
import 'dart:async'; // Required for Timer

import 'package:provider/provider.dart'; // To use Provider for theme

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  // Animation controller for the spinning effect
  late AnimationController _animationController;
  // Animation for the rotation
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Duration for one full spin cycle
    )..repeat(); // Repeat the animation indefinitely

    // Define the rotation animation
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    // After 5 seconds, navigate to the LoginPage
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose the controller to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentThemeData; // Get the current theme data

    return Scaffold(
      backgroundColor: theme.primaryColor, // Use your app's primary color as background
      body: Center(
        child: RotationTransition(
          turns: _rotationAnimation, // Apply the spinning animation
          child: const Icon(
            FontAwesomeIcons.solidPenToSquare, // The pencil icon
            color: Colors.white, // White color for the pencil
            size: 150, // Make the pencil large and prominent
          ),
        ),
      ),
    );
  }
}
