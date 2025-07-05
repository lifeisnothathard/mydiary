import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Only for User type and FirebaseAuthException
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mydiary/pages/homepage.dart';
import 'package:mydiary/pages/signin.dart';
import 'package:mydiary/services/auth.dart'; // For the pencil icon

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text controllers for email and password input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State variables for UI feedback
  bool _isLoading = false; // To show loading indicator during auth operations
  bool _isPasswordVisible = false; // To toggle password visibility

  // Instance of our AuthService
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    // Dispose controllers to free up resources when the widget is removed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handles email and password sign-in by calling AuthService.
  Future<void> _handleEmailPasswordSignIn() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });
    try {
      await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // If sign-in is successful, navigate to the home screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Authentication errors from AuthService
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else {
        message = e.message ?? 'An unexpected authentication error occurred.';
      }
      if (mounted) {
        _showErrorSnackbar(message); // Show error message to the user
      }
    } catch (e) {
      // Catch any other unexpected errors from AuthService
      if (mounted) {
        _showErrorSnackbar(e.toString()); // Display generic error message
      }
      debugPrint('Sign-in error: $e'); // Print error to console for debugging
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  /// Handles Google Sign-In by calling AuthService.
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });
    try {
      await _authService.signInWithGoogle();
      // If successful, navigate to the home screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth exceptions specific to Google Sign-In from AuthService
      String message;
      if (e.code == 'account-exists-with-different-credential') {
        message = 'An account already exists with the same email but different sign-in method.';
      } else if (e.code == 'popup-closed-by-user') {
        message = 'Google sign-in popup was closed.';
      } else {
        message = e.message ?? 'Google Sign-in failed. Please try again.';
      }
      if (mounted) {
        _showErrorSnackbar(message);
      }
    } catch (e) {
      // Catch any other errors during Google sign-in from AuthService
      if (mounted) {
        _showErrorSnackbar(e.toString());
      }
      debugPrint('Google Sign-in error: $e'); // For debugging
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  /// Shows a SnackBar with an error message.
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    // Determine if we are on a smaller screen (e.g., mobile)
    final bool isSmallScreen = screenWidth < 600; // Adjusted breakpoint for a single column

    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50), // Green background color
      body: Center(
        child: SingleChildScrollView( // Allow scrolling if content overflows on small screens
          padding: const EdgeInsets.all(24.0), // Overall padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // MyDiary Logo and Text
              Column(
                children: [
                  const Icon(
                    FontAwesomeIcons.solidPenToSquare, // Pencil icon
                    color: Colors.white,
                    size: 80,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'MyDiary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Write your thoughts and share them with the world',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 40), // Space between logo and form card

              // Login Form Card
              Container(
                width: isSmallScreen ? double.infinity : 450, // Full width on small, fixed on large
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15), // Rounded corners for the card
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Email Address field
                    const Text(
                      'Email Address',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'you@example.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8), // Rounded input field
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100], // Light grey background for input
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password field
                    const Text(
                      'Password',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible, // Toggles visibility
                      decoration: InputDecoration(
                        hintText: '*********',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8), // Rounded input field
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100], // Light grey background for input
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible; // Update state to toggle visibility
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Forgot password button
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password logic
                          _showErrorSnackbar('Forgot password functionality to be implemented!');
                        },
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(color: Color(0xFF4CAF50)), // Green color
                        ),
                      ),
                    ),
                    const SizedBox(height: 30), // Increased spacing before button

                    // Log in button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleEmailPasswordSignIn, // Disable when loading
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50), // Button background color (Green)
                        foregroundColor: Colors.white, // Text color
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Rounded corners
                        ),
                        elevation: 0, // No shadow for the button
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white) // Loading indicator
                          : const Text(
                              'Log in',
                              style: TextStyle(fontSize: 18),
                              
                            ),
                    ),
                    const SizedBox(height: 20),

                    // "Or continue with" text
                    const Center(
                      child: Text(
                        'Or continue with',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Google Sign-in button
                    OutlinedButton(
                      onPressed: _isLoading ? null : _handleGoogleSignIn, // Disable when loading
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey), // Grey border
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Google logo image (ensure 'assets/google_logo.png' exists and is declared in pubspec.yaml)
                          Image.asset(
                            'assets/google_logo.png',
                            height: 24,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Sign in with Google',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // "Don't have an account? Sign up" text and button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.black87),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to the sign-up page
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const SignUpPage()),
                            );
                          },
                          child: const Text(
                            'Sign up',
                            style: TextStyle(color: Color(0xFF4CAF50)), // Green color
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Removed _buildAppBarIconText as the new design doesn't have a top app bar like before.
  // If you need top navigation, you would re-introduce an AppBar with appropriate icons.
}
