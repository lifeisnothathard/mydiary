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
          MaterialPageRoute(builder: (context) => const HomePage()),
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
          MaterialPageRoute(builder: (context) => const HomePage()),
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
    final bool isSmallScreen = screenWidth < 800;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // No shadow for the app bar
        title: const Text(
          'MYDIARY', // Changed from NOTESYNCS
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          // Top right navigation icons
          _buildAppBarIconText(Icons.home, 'Home', () {
            // Implement navigation to Home
            _showErrorSnackbar('Home clicked!');
          }),
          _buildAppBarIconText(Icons.login, 'Login', () {
            // Already on login, perhaps do nothing or scroll to top
          }),
          const SizedBox(width: 16), // Right padding for app bar actions
        ],
      ),
      body: Center(
        child: Container(
          // Constrain the overall content width for larger screens
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.all(16.0),
          child: isSmallScreen
              ? _buildSmallScreenLayout() // Use a single column for small screens
              : _buildLargeScreenLayout(), // Use a row with two panes for large screens
        ),
      ),
    );
  }

  /// Builds the layout for larger screens (two-pane layout).
  Widget _buildLargeScreenLayout() {
    return Row(
      children: [
        // Left Pane (Green) - Flexible to take available space
        Flexible(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50), // Green color
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.solidPenToSquare, // Pencil icon
                    color: Colors.white,
                    size: 80,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'MyDiary', // Changed from Notesyncs
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Write your thoughts and share them with the world',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 30), // Space between panes

        // Right Pane (Login Form Card) - Flexible to take remaining space
        Flexible(
          flex: 1,
          child: Center(
            child: _buildLoginFormCard(), // Reusable login form card
          ),
        ),
      ],
    );
  }

  /// Builds the layout for smaller screens (single column layout).
  Widget _buildSmallScreenLayout() {
    return SingleChildScrollView( // Allow scrolling on small screens if content overflows
      child: Column(
        children: [
          // Left Pane (Green) - Condensed for small screens
          Container(
            height: 200, // Fixed height for the green section on small screens
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50), // Green color
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.solidPenToSquare,
                    color: Colors.white,
                    size: 60,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'MyDiary', // Changed from Notesyncs
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Write your thoughts and share them with the world',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30), // Space between sections

          // Right Pane (Login Form Card)
          _buildLoginFormCard(), // Reusable login form card
        ],
      ),
    );
  }

  /// Reusable widget for the login form card.
  Widget _buildLoginFormCard() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      constraints: const BoxConstraints(maxWidth: 450), // Max width for the login form card
      child: Column(
        mainAxisSize: MainAxisSize.min, // Column takes minimum space required
        crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
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
            decoration: const InputDecoration(
              hintText: 'you@example.com',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true, // Makes the input field more compact
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
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
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
          const SizedBox(height: 20),

          // Sign in button
          ElevatedButton(
            onPressed: _isLoading ? null : _handleEmailPasswordSignIn, // Disable when loading
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50), // Button background color (Green)
              foregroundColor: Colors.white, // Text color
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Rounded corners
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white) // Loading indicator
                : const Text(
                    'Sign in',
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
    );
  }

  /// Helper widget to build app bar icons with text.
  Widget _buildAppBarIconText(IconData icon, String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.black87),
            Text(
              text,
              style: const TextStyle(color: Colors.black87, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
