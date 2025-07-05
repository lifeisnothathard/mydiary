import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mydiary/pages/login.dart';
import 'package:mydiary/services/auth.dart';
import 'package:mydiary/services/new_entry.dart';
import 'package:mydiary/services/themes/themeprovider.dart';
import 'package:mydiary/widgets/home_app_bar.dart';
import 'package:mydiary/widgets/note_editor.dart';
import 'package:mydiary/widgets/sidebar.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // For Timer

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  User? _currentUser;

  List<Map<String, dynamic>> _notes = [];
  String? _selectedNoteId;
  final TextEditingController _newEntryController = TextEditingController();

  Timer? _debounceTimer;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _listenToNotes();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    }

    _newEntryController.addListener(_onNoteContentChanged);
  }

  @override
  void dispose() {
    _newEntryController.removeListener(_onNoteContentChanged);
    _newEntryController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // --- Auto-Save Logic ---
  void _onNoteContentChanged() {
    if (_selectedNoteId != null) {
      if (_debounceTimer?.isActive ?? false) {
        _debounceTimer!.cancel();
      }
      _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
        _saveCurrentNote(showSnackbar: false);
      });
    }
  }

  // --- Firestore Data Management ---

  void _listenToNotes() {
    _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _notes = snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();

        if (_selectedNoteId == null ||
            !_notes.any((note) => note['id'] == _selectedNoteId)) {
          if (_notes.isNotEmpty) {
            _selectedNoteId = _notes[0]['id'];
            _newEntryController.text = _notes[0]['content'] ?? '';
          } else {
            _selectedNoteId = null;
            _newEntryController.clear();
          }
        } else {
          final currentSelectedNote = _firstWhereOrNull(_notes, (note) => note['id'] == _selectedNoteId);
          if (currentSelectedNote != null) {
            if (_newEntryController.text != (currentSelectedNote['content'] ?? '')) {
              _newEntryController.removeListener(_onNoteContentChanged);
              _newEntryController.text = currentSelectedNote['content'] ?? '';
              _newEntryController.addListener(_onNoteContentChanged);
            }
          } else {
            _selectedNoteId = null;
            _newEntryController.clear();
          }
        }
      });
    }, onError: (error) {
      debugPrint("Error listening to notes: $error");
      _showErrorSnackbar("Failed to load notes: $error");
    });
  }

  Map<String, dynamic>? _firstWhereOrNull(List<Map<String, dynamic>> list, bool Function(Map<String, dynamic>) test) {
    for (var element in list) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }

  void _selectNote(String noteId) {
    setState(() {
      _selectedNoteId = noteId;
      final selectedNote = _firstWhereOrNull(_notes, (note) => note['id'] == noteId);
      if (selectedNote != null) {
        _newEntryController.removeListener(_onNoteContentChanged);
        _newEntryController.text = selectedNote['content'] ?? '';
        _newEntryController.addListener(_onNoteContentChanged);
      }
    });
  }

  void _navigateToAddNotePage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddNotePage()),
    );
  }

  Future<void> _saveCurrentNote({bool showSnackbar = true}) async {
    if (_selectedNoteId == null) {
      if (showSnackbar) _showErrorSnackbar("No note selected or created to save.");
      return;
    }

    final currentContent = _newEntryController.text.trim();

    try {
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('notes')
          .doc(_selectedNoteId)
          .set(
            {
              'content': currentContent,
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
      if (showSnackbar) _showSuccessSnackbar("Note saved successfully!");
    } catch (e) {
      debugPrint("Error saving note: $e");
      if (showSnackbar) _showErrorSnackbar("Failed to save note.");
    }
  }

  // --- Image Picking and Upload ---
  Future<void> _pickImageAndUpload() async {
    if (_selectedNoteId == null) {
      _showErrorSnackbar("Please select or create a note before adding an image.");
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      return;
    }

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final Reference storageRef = _firebaseStorage
          .ref()
          .child('users/${_currentUser!.uid}/notes_images/$fileName');

      final UploadTask uploadTask = storageRef.putFile(
        (await image.readAsBytes()) as File,
        SettableMetadata(contentType: 'image/${image.name.split('.').last}'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      final int cursorPosition = _newEntryController.selection.baseOffset;
      final String currentText = _newEntryController.text;
      final String newText = '${currentText.substring(0, cursorPosition)}\n![Image]($downloadUrl)\n${currentText.substring(cursorPosition)}';

      _newEntryController.text = newText;
      _newEntryController.selection = TextSelection.fromPosition(
        TextPosition(offset: cursorPosition + '\n![Image]($downloadUrl)\n'.length),
      );

      _showSuccessSnackbar("Image uploaded and added to note!");
      _saveCurrentNote(showSnackbar: false);
    } catch (e) {
      debugPrint("Error uploading image: $e");
      _showErrorSnackbar("Failed to upload image: $e");
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  // --- UI Helpers ---

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
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 800;

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: HomeAppBar( // Using the new HomeAppBar widget
        isDarkMode: isDarkMode,
        onLogout: () async {
          await AuthService().signOut();
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        },
        onToggleTheme: () {
          Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
        },
      ),
      body: Row(
        children: [
          Sidebar( // Using the new Sidebar widget
            notes: _notes,
            selectedNoteId: _selectedNoteId,
            onSelectNote: _selectNote,
            onNavigateToAddNotePage: _navigateToAddNotePage,
            isSmallScreen: isSmallScreen,
            isDarkMode: isDarkMode,
          ),
          NoteEditor( // Using the new NoteEditor widget
            selectedNoteId: _selectedNoteId,
            notes: _notes,
            newEntryController: _newEntryController,
            isUploadingImage: _isUploadingImage,
            onPickImageAndUpload: _pickImageAndUpload,
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }
}
