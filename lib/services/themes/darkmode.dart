import 'package:flutter/material.dart';

// Define your dark mode theme data
final ThemeData darkModeTheme = ThemeData(
  brightness: Brightness.dark, // Explicitly set brightness to dark
  primarySwatch: Colors.green, // A primary color for your app
  primaryColor: const Color(0xFF4CAF50), // Main green color (can be adjusted for dark mode if needed)

  // Scaffold background color (overall page background in dark mode)
  scaffoldBackgroundColor: const Color(0xFF121212), // Very dark grey/black

  // AppBar Theme
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E), // Darker grey for app bar background
    elevation: 0, // No shadow
    iconTheme: IconThemeData(color: Colors.white), // White icons
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
  ),

  // Button Themes
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4CAF50), // Green button background
      foregroundColor: Colors.white, // White text on buttons
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 2, // Slight elevation for buttons
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: Colors.grey[700]!), // Lighter grey border for contrast
      foregroundColor: Colors.white, // White text for outlined buttons
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF4CAF50), // Green text for text buttons
    ),
  ),

  // Input Decoration Theme (for TextField styling)
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2C2C2C), // Dark grey background for input fields
    hintStyle: TextStyle(color: Colors.grey[500]), // Lighter hint text
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none, // No border by default
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),

  // Text Themes
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.grey[200]), // Default body text color (light grey)
    bodyMedium: TextStyle(color: Colors.grey[200]),
    titleLarge: TextStyle(color: Colors.grey[200]),
    titleMedium: TextStyle(color: Colors.grey[200]),
    // You can define more specific text styles as needed
  ),

  // Icon Theme
  iconTheme: IconThemeData(
    color: Colors.grey[300], // Default icon color (light grey)
  ),

  // Card Theme (if you use Card widgets)
  cardTheme: CardThemeData(
    color: const Color(0xFF1E1E1E), // Darker grey for cards
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
  ),

  // Add more theme properties as needed (e.g., colorScheme, dividerTheme, etc.)
);
