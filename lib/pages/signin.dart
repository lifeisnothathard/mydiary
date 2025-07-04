import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('This is the Sign Up Page'),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Go back to login
              },
              child: const Text('Go Back to Login'),
            ),
          ],
        ),
      ),
      // You might want to pass the AuthService instance to SignUpPage if it also uses auth methods
    );
  }
}
// --- End of Placeholder Screens ---

