import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mydiary/services/themes/themeprovider.dart';
import 'package:provider/provider.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final TextEditingController _noteContentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser == null) {
      // If for some reason user is not logged in, navigate back to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop(); // Or navigate to login page
      });
    }
  }

  @override
  void dispose() {
    _noteContentController.dispose();
    super.dispose();
  }

  Future<void> _saveNewNote() async {
    if (_noteContentController.text.trim().isEmpty) {
      _showErrorSnackbar('Note content cannot be empty.');
      return;
    }
    if (_currentUser == null) {
      _showErrorSnackbar('User not logged in. Please log in again.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('notes')
          .add({
        'content': _noteContentController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isLocked': false, // Default to unlocked
      });
      _showSuccessSnackbar('Note added successfully!');
      if (mounted) {
        Navigator.of(context).pop(); // Go back to the previous screen (HomeScreen)
      }
    } catch (e) {
      debugPrint('Error adding new note: $e');
      _showErrorSnackbar('Failed to add note: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
        iconTheme: theme.appBarTheme.iconTheme,
        title: Text(
          'Add New Note',
          style: theme.appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: theme.iconTheme.color),
            onPressed: _isLoading ? null : _saveNewNote,
          ),
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: theme.iconTheme.color,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!),
                ),
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: _noteContentController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  expands: true,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    hintText: 'Start writing your new diary entry here...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(color: isDarkMode ? Colors.grey[500] : Colors.grey[400]),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(color: theme.primaryColor),
              ),
          ],
        ),
      ),
    );
  }
}
