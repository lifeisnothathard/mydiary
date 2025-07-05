import 'package:flutter/material.dart';
import 'package:mydiary/pages/splash.dart';
import 'package:mydiary/services/themes/themeprovider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'firebase_options.dart'; // Import your Firebase options file

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Initialize Firebase
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      title: 'MyDiary',
      theme: themeProvider.currentThemeData, // Use the current theme data
      home: const SplashPage(), // Set SplashPage as the initial screen
    );
  }
}
