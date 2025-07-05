import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Only for FirebaseAuthException
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mydiary/pages/login.dart';
import 'package:mydiary/services/auth.dart'; // For the pencil icon

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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

  /// Handles user registration with email and password by calling AuthService.
  Future<void> _handleSignUp() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });
    try {
      await _authService.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // If registration is successful, navigate to the home screen
      if (mounted) {
        _showSuccessSnackbar('Registration successful! You can now log in.');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Authentication errors
      String message;
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else {
        message = e.message ?? 'An unexpected registration error occurred.';
      }
      if (mounted) {
        _showErrorSnackbar(message); // Show error message to the user
      }
    } catch (e) {
      // Catch any other unexpected errors from AuthService
      if (mounted) {
        _showErrorSnackbar(e.toString()); // Display generic error message
      }
      debugPrint('Registration error: $e'); // Print error to console for debugging
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

  /// Shows a SnackBar with a success message.
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
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
          'MYDIARY', // Consistent with login page
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          // Top right navigation icons (consistent with login page)
          _buildAppBarIconText(Icons.home, 'Home', () {
            _showErrorSnackbar('Home clicked!');
          }),
          _buildAppBarIconText(Icons.shopping_cart, 'Add to Cart', () {
            _showErrorSnackbar('Add to Cart clicked!');
          }),
          _buildAppBarIconText(Icons.login, 'Login', () {
            // Navigate back to login page
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
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
        // Left Pane (Green) - Consistent with login page
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
                    'MyDiary', // Consistent with login page
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Start your journey', // Changed text for sign-up context
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

        // Right Pane (Sign Up Form Card) - Flexible to take remaining space
        Flexible(
          flex: 1,
          child: Center(
            child: _buildSignUpFormCard(), // Reusable sign-up form card
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
                    'MyDiary', // Consistent with login page
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Start your journey', // Changed text for sign-up context
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

          // Right Pane (Sign Up Form Card)
          _buildSignUpFormCard(), // Reusable sign-up form card
        ],
      ),
    );
  }

  /// Reusable widget for the sign-up form card.
  Widget _buildSignUpFormCard() {
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
      constraints: const BoxConstraints(maxWidth: 450), // Max width for the form card
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
          const SizedBox(height: 30), // Increased spacing before button

          // Sign Up button
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSignUp, // Disable when loading
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white) // Loading indicator
                : const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 18),
                  ),
          ),
          const SizedBox(height: 20),

          // "Already have an account? Sign in" text and button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Already have an account?",
                style: TextStyle(color: Colors.black87),
              ),
              TextButton(
                onPressed: () {
                  // Navigate back to the login page
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text(
                  'Log in',
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

extension on Function({dynamic child, dynamic onPressed}) {
}
