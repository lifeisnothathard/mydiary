import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mydiary/firebase_options.dart';
import 'package:mydiary/pages/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notesyncs',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // fontFamily: 'Inter', // Uncomment if you want a specific font
      ),
      home: const LoginPage(), // Start with your login page
    );
  }
}