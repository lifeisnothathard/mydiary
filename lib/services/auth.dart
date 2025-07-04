import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Required for Google Sign-In

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get the currently logged-in user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Stream of authentication state changes (user login/logout)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs in a user with email and password.
  /// Returns the UserCredential on success, null on failure.
  /// Throws FirebaseAuthException on specific auth errors.
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException {
      rethrow; // Re-throw the exception to be handled by the UI layer
    } catch (e) {
      // Catch any other unexpected errors
      throw Exception('An unknown error occurred during sign-in: $e');
    }
  }

  /// Registers a new user with email and password.
  /// Returns the UserCredential on success, null on failure.
  /// Throws FirebaseAuthException on specific auth errors.
  Future<UserCredential?> registerWithEmail(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException {
      rethrow; // Re-throw the exception to be handled by the UI layer
    } catch (e) {
      throw Exception('An unknown error occurred during registration: $e');
    }
  }

  /// Signs in a user with Google.
  /// Returns the UserCredential on success, null on failure.
  /// Throws FirebaseAuthException on specific auth errors.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Begin interactive sign in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException {
      rethrow; // Re-throw the exception to be handled by the UI layer
    } catch (e) {
      throw Exception('An unknown error occurred during Google sign-in: $e');
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut(); // Also sign out from Google if signed in via Google
  }

  /// Gets the Firebase ID token for the current user.
  /// This token can be used to authenticate with your backend (e.g., MongoDB Atlas App Services).
  Future<String?> getIdToken() async {
    return await _auth.currentUser?.getIdToken();
  }
}
