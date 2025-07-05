import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mydiary/services/themes/themeprovider.dart';
import 'package:mydiary/widgets/note_editor.dart';
import 'dart:async'; // For Timer
import 'package:provider/provider.dart';

class NoteDetailPage extends StatefulWidget {
  final String noteId;
  final String initialContent;

  const NoteDetailPage({
    super.key,
    required this.noteId,
    required this.initialContent,
  });

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final TextEditingController _noteContentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  User? _currentUser;

  Timer? _debounceTimer;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _noteContentController.text = widget.initialContent; // Set initial content

    // Listen for changes in the text controller for auto-save
    _noteContentController.addListener(_onNoteContentChanged);
  }

  @override
  void dispose() {
    _noteContentController.removeListener(_onNoteContentChanged);
    _noteContentController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // --- Auto-Save Logic ---
  void _onNoteContentChanged() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
      _saveCurrentNote(showSnackbar: false); // Auto-save without showing snackbar
    });
  }

  // --- Firestore Data Management ---
  Future<void> _saveCurrentNote({bool showSnackbar = true}) async {
    if (_currentUser == null) {
      if (showSnackbar) _showErrorSnackbar("User not logged in. Cannot save note.");
      return;
    }
    if (widget.noteId.isEmpty) { // Should not happen if a note is always passed
      if (showSnackbar) _showErrorSnackbar("Invalid note ID. Cannot save note.");
      return;
    }

    final currentContent = _noteContentController.text.trim();

    try {
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('notes')
          .doc(widget.noteId)
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
    if (_currentUser == null) {
      _showErrorSnackbar("User not logged in. Cannot delete note.");
      return;
    }
    if (widget.noteId.isEmpty) {
      _showErrorSnackbar("Invalid note ID. Cannot delete note.");
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
          .doc(widget.noteId)
          .delete();

      _showSuccessSnackbar("Note deleted successfully!");
      if (mounted) {
        Navigator.of(context).pop(); // Go back to HomeScreen after deletion
      }
    } catch (e) {
      debugPrint("Error deleting note: $e");
      _showErrorSnackbar("Failed to delete note: $e");
    }
  }

  // --- Image Picking and Upload ---
  Future<void> _pickImageAndUpload(ImageSource source) async {
    if (_currentUser == null) {
      _showErrorSnackbar("User not logged in. Cannot upload image.");
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

      final int cursorPosition = _noteContentController.selection.baseOffset;
      final String currentText = _noteContentController.text;
      final String newText = '${currentText.substring(0, cursorPosition)}\n![Image]($downloadUrl)\n${currentText.substring(cursorPosition)}';

      _noteContentController.text = newText;
      _noteContentController.selection = TextSelection.fromPosition(
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Use NoteEditor directly, passing necessary callbacks and controller
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
        iconTheme: theme.appBarTheme.iconTheme,
        title: Text(
          'Edit Note', // Title for the edit page
          style: theme.appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: theme.iconTheme.color),
            onPressed: _saveCurrentNote,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: theme.iconTheme.color),
            onPressed: _deleteCurrentNote,
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
      body: NoteEditor(
        selectedNoteId: widget.noteId, // Pass the noteId from constructor
        notes: const [], // Not needed here, as we're editing a single note
        newEntryController: _noteContentController,
        isUploadingImage: _isUploadingImage,
        onPickImageAndUpload: _pickImageAndUpload,
        onDeleteCurrentNote: _deleteCurrentNote,
        isDarkMode: isDarkMode,
      ),
    );
  }
}
