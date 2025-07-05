import 'package:flutter/material.dart';

// Define your light mode theme data (Green based)
final ThemeData lightModeTheme = ThemeData(
  brightness: Brightness.light, // Explicitly set brightness to light
  primarySwatch: Colors.green, // Primary color for your app
  primaryColor: const Color(0xFF4CAF50), // Main green color (Material Green 500)

  // Scaffold background color (matches the overall page background in light mode)
  scaffoldBackgroundColor: const Color(0xFFF0F5F0), // Very light green-tinted grey

  // AppBar Theme
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.lightGreen, // Light green app bar background
    elevation: 0, // No shadow
    iconTheme: IconThemeData(color: Colors.black87), // Dark icons
    titleTextStyle: TextStyle(
      color: Colors.black,
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
      side: const BorderSide(color: Colors.grey), // Grey border
      foregroundColor: Colors.black87, // Dark text for outlined buttons
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
    fillColor: Colors.grey[100], // Light grey background for input fields
    hintStyle: TextStyle(color: Colors.grey[500]), // Lighter hint text
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none, // No border by default
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),

  // Text Themes
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.grey[800]), // Default body text color
    bodyMedium: TextStyle(color: Colors.grey[800]),
    titleLarge: TextStyle(color: Colors.grey[800]),
    titleMedium: TextStyle(color: Colors.grey[800]),
    // You can define more specific text styles as needed
  ),

  // Icon Theme
  iconTheme: IconThemeData(
    color: Colors.grey[700], // Default icon color
  ),

  // Card Theme (if you use Card widgets)
  cardTheme: CardThemeData(
    color: Colors.green[100], // Light green card background
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
  ),

  // Divider Theme (for subtle separators)
  dividerTheme: DividerThemeData(
    color: Colors.grey[300],
    thickness: 0.5,
  ),
);
