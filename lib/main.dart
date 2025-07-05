import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mydiary/firebase_options.dart';
import 'package:mydiary/pages/login.dart';
import 'package:mydiary/services/themes/themeprovider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    // Provide the ThemeProvider to the entire app
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
    // Access the ThemeProvider and use its currentThemeData
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'MyDiary',
      theme: themeProvider.currentThemeData, // Apply the current theme
      home: const LoginPage(),
    );
  }
}