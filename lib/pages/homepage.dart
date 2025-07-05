import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mydiary/pages/login.dart';
import 'package:mydiary/pages/note_detail_page.dart';
import 'package:mydiary/pages/recent_notes_view.dart';
import 'package:mydiary/services/auth.dart';
import 'package:mydiary/services/new_entry.dart';
import 'package:mydiary/services/themes/themeprovider.dart';
import 'package:mydiary/widgets/home_app_bar.dart';
import 'package:mydiary/widgets/note_editor.dart';
import 'package:mydiary/widgets/note_utils.dart';
import 'package:mydiary/widgets/sidebar.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // For Timer
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:firebase_storage/firebase_storage.dart'; // For Firebase Storage
import 'package:flutter_image_compress/flutter_image_compress.dart'; // For image compression

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
          final currentSelectedNote = firstWhereOrNull(_notes, (note) => note['id'] == _selectedNoteId);
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


  void _selectNote(String noteId) {
    setState(() {
      _selectedNoteId = noteId;
      final selectedNote = firstWhereOrNull(_notes, (note) => note['id'] == noteId);
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

  void _navigateToNoteDetailPage(String noteId, String initialContent) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteDetailPage(
          noteId: noteId,
          initialContent: initialContent,
        ),
      ),
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

  Future<void> _deleteCurrentNote() async {
    if (_selectedNoteId == null) {
      _showErrorSnackbar("No note selected to delete.");
      return;
    }

    final bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmDelete) {
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('notes')
          .doc(_selectedNoteId)
          .delete();

      _showSuccessSnackbar("Note deleted successfully!");

      setState(() {
        _selectedNoteId = null;
        _newEntryController.clear();
      });
    } catch (e) {
      debugPrint("Error deleting note: $e");
      _showErrorSnackbar("Failed to delete note: $e");
    }
  }


  // --- Image Picking and Upload ---
  Future<void> _pickImageAndUpload(ImageSource source) async {
    if (_selectedNoteId == null) {
      _showErrorSnackbar("Please select or create a note before adding an image.");
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

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

      final Uint8List? imageBytes = await image.readAsBytes();

      if (imageBytes == null) {
        _showErrorSnackbar("Failed to read image bytes.");
        return;
      }

      final Uint8List compressedBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        minHeight: 800,
        minWidth: 800,
        quality: 85,
        format: CompressFormat.jpeg,
      );

      final UploadTask uploadTask = storageRef.putData(
        compressedBytes,
        SettableMetadata(contentType: 'image/jpeg'),
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
    final bool isSmallScreen = screenWidth < 800; // Define breakpoint for small screen

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: HomeAppBar(
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
      body: isSmallScreen
          ? RecentNotesView( // Use the new RecentNotesView widget
              notes: _notes,
              onNavigateToNoteDetailPage: _navigateToNoteDetailPage,
              isDarkMode: isDarkMode,
            )
          : Row(
              children: [
                Sidebar(
                  notes: _notes,
                  selectedNoteId: _selectedNoteId,
                  onSelectNote: _selectNote,
                  onNavigateToAddNotePage: _navigateToAddNotePage,
                  isSmallScreen: isSmallScreen,
                  isDarkMode: isDarkMode,
                ),
                NoteEditor(
                  selectedNoteId: _selectedNoteId,
                  notes: _notes,
                  newEntryController: _newEntryController,
                  isUploadingImage: _isUploadingImage,
                  onPickImageAndUpload: _pickImageAndUpload,
                  onDeleteCurrentNote: _deleteCurrentNote,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
    );
  }
}
