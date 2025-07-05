import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mydiary/pages/login.dart';
import 'package:mydiary/services/auth.dart';
import 'package:mydiary/services/new_entry.dart';
import 'package:mydiary/services/themes/themeprovider.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // For Timer

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;

  List<Map<String, dynamic>> _notes = [];
  String? _selectedNoteId;
  final TextEditingController _newEntryController = TextEditingController();

  Timer? _debounceTimer; // Timer for auto-save debounce

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

    // Listen for changes in the text controller for auto-save
    // This listener will now be for the *main editor* on HomeScreen
    _newEntryController.addListener(_onNoteContentChanged);
  }

  @override
  void dispose() {
    _newEntryController.removeListener(_onNoteContentChanged);
    _newEntryController.dispose();
    _debounceTimer?.cancel(); // Cancel any active timer
    super.dispose();
  }

  // --- Auto-Save Logic ---
  void _onNoteContentChanged() {
    // Only auto-save if a note is currently selected
    if (_selectedNoteId != null) {
      // Cancel the previous timer if it exists
      if (_debounceTimer?.isActive ?? false) {
        _debounceTimer!.cancel();
      }
      // Start a new timer
      _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
        _saveCurrentNote(showSnackbar: false); // Auto-save without showing snackbar
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

        // If no note is selected or selected note was deleted, select the first one
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
            // Only update controller if content from Firestore is different
            // to avoid infinite loop with listener and onChanged
            if (_newEntryController.text != (currentSelectedNote['content'] ?? '')) {
              // Temporarily remove listener to prevent auto-save trigger
              _newEntryController.removeListener(_onNoteContentChanged);
              _newEntryController.text = currentSelectedNote['content'] ?? '';
              // Re-add listener
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
        // Temporarily remove listener to prevent auto-save trigger
        _newEntryController.removeListener(_onNoteContentChanged);
        _newEntryController.text = selectedNote['content'] ?? '';
        // Re-add listener
        _newEntryController.addListener(_onNoteContentChanged);
      }
    });
  }

  // This method will now navigate to the AddNotePage
  void _navigateToAddNotePage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddNotePage()),
    );
    // After returning from AddNotePage, ensure the latest notes are loaded
    // (The listener already handles this, but a manual refresh could be added if needed)
  }

  Future<void> _saveCurrentNote({bool showSnackbar = true}) async {
    if (_selectedNoteId == null) {
      if (showSnackbar) _showErrorSnackbar("No note selected or created to save.");
      return;
    }

    final currentContent = _newEntryController.text.trim();
    // Allow saving empty notes, but if it's a new empty note, maybe delete it later.
    // For now, it will save the empty string.

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

  // Helper to format timestamp for display
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateForCategory(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final noteDate = DateTime(date.year, date.month, date.day);

    if (noteDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (now.difference(noteDate).inDays <= 30) {
      return 'Previous 30 Days';
    } else {
      return '${_getMonthName(date.month)}';
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'January';
      case 2: return 'February';
      case 3: return 'March';
      case 4: return 'April';
      case 5: return 'May';
      case 6: return 'June';
      case 7: return 'July';
      case 8: return 'August';
      case 9: return 'September';
      case 10: return 'October';
      case 11: return 'November';
      case 12: return 'December';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 800;

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Group notes by category
    final Map<String, List<Map<String, dynamic>>> categorizedNotes = {};
    for (var note in _notes) {
      final category = _formatDateForCategory(note['createdAt'] as Timestamp?);
      if (!categorizedNotes.containsKey(category)) {
        categorizedNotes[category] = [];
      }
      categorizedNotes[category]!.add(note);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Top App Bar
          Container(
            color: theme.appBarTheme.backgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              children: [
                IconButton(icon: Icon(Icons.menu, color: theme.iconTheme.color), onPressed: () {}),
                const SizedBox(width: 8),
                IconButton(icon: Icon(Icons.folder_open, color: theme.iconTheme.color), onPressed: () {}),
                IconButton(icon: Icon(Icons.share, color: theme.iconTheme.color), onPressed: () {}),
                const Spacer(),
                IconButton(icon: Icon(Icons.person, color: theme.iconTheme.color), onPressed: () {}),
                IconButton(icon: Icon(Icons.settings, color: theme.iconTheme.color), onPressed: () {}),
                // Logout Icon
                IconButton(
                  icon: Icon(Icons.logout, color: theme.iconTheme.color),
                  onPressed: () async {
                    await AuthService().signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    }
                  },
                ),
                // Theme Toggle Icon
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
          ),
          // Main Content Area
          Expanded(
            child: Row(
              children: [
                // Left Sidebar (Notes List)
                Container(
                  width: isSmallScreen ? 200 : 300, // Adjusted width for sidebar
                  color: theme.appBarTheme.backgroundColor, // Use app bar background for sidebar
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'stuff', // Hardcoded "stuff" title
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Search Bar in Sidebar
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.inputDecorationTheme.fillColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyLarge?.color),
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: theme.inputDecorationTheme.hintStyle,
                            prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
                            suffixIcon: Icon(Icons.mic, color: theme.iconTheme.color), // Microphone icon
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // New Note Button (Plus button functionality)
                      OutlinedButton.icon(
                        onPressed: _navigateToAddNotePage, // Navigate to AddNotePage
                        icon: Icon(Icons.add_circle_outline, color: theme.primaryColor),
                        label: Text('New Note', style: TextStyle(color: theme.primaryColor)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: theme.primaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: categorizedNotes.keys.length,
                          itemBuilder: (context, categoryIndex) {
                            final category = categorizedNotes.keys.elementAt(categoryIndex);
                            final notesInCategory = categorizedNotes[category]!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    category,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: theme.textTheme.bodyLarge?.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ...notesInCategory.map((note) {
                                  final noteContent = note['content'] as String? ?? '';
                                  final lines = noteContent.trim().split('\n');
                                  final title = lines.isNotEmpty && lines[0].isNotEmpty ? lines[0] : 'New Note';
                                  final snippet = lines.length > 1 && lines[1].isNotEmpty ? lines[1] : '';
                                  final createdAt = note['createdAt'] as Timestamp?;
                                  final isLocked = note['isLocked'] as bool? ?? false; // Assuming a 'isLocked' field

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: GestureDetector(
                                      onTap: () => _selectNote(note['id']),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: _selectedNoteId == note['id']
                                              ? (isDarkMode ? Colors.grey[800] : Colors.grey[300]) // Highlight selected
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                if (isLocked)
                                                  Icon(Icons.lock, size: 16, color: theme.iconTheme.color),
                                                if (isLocked) const SizedBox(width: 5),
                                                Expanded(
                                                  child: Text(
                                                    title,
                                                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(
                                                  _formatTimestamp(createdAt), // Time
                                                  style: theme.textTheme.bodySmall?.copyWith(color: isDarkMode ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
                                                ),
                                                if (snippet.isNotEmpty)
                                                  Text(
                                                    ' ${snippet}...', // Snippet
                                                    style: theme.textTheme.bodySmall?.copyWith(color: isDarkMode ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Main Content Area (Note Editor)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Toolbar for editor (placeholder icons)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color: theme.appBarTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(icon: Icon(Icons.text_format, color: theme.iconTheme.color), onPressed: () {}),
                              IconButton(icon: Icon(Icons.format_list_bulleted, color: theme.iconTheme.color), onPressed: () {}),
                              IconButton(icon: Icon(Icons.checklist, color: theme.iconTheme.color), onPressed: () {}),
                              IconButton(icon: Icon(Icons.attach_file, color: theme.iconTheme.color), onPressed: () {}),
                              IconButton(icon: Icon(Icons.camera_alt, color: theme.iconTheme.color), onPressed: () {}),
                              IconButton(icon: Icon(Icons.image, color: theme.iconTheme.color), onPressed: () {}),
                              IconButton(icon: Icon(Icons.lock_outline, color: theme.iconTheme.color), onPressed: () {}),
                              IconButton(icon: Icon(Icons.delete_outline, color: theme.iconTheme.color), onPressed: () {
                                // TODO: Implement delete note functionality
                                _showErrorSnackbar("Delete note functionality to be implemented!");
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Note Title (New Note)
                        Text(
                          _selectedNoteId != null
                              ? (_firstWhereOrNull(_notes, (note) => note['id'] == _selectedNoteId)?['content'] as String? ?? '').trim().split('\n')[0].isNotEmpty
                                  ? (_firstWhereOrNull(_notes, (note) => note['id'] == _selectedNoteId)?['content'] as String? ?? '').trim().split('\n')[0]
                                  : 'New Note'
                              : 'New Note',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Note Content Editor
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.cardTheme.color, // Use theme's card color
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: TextField(
                              controller: _newEntryController,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              expands: true,
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyLarge?.color),
                              decoration: InputDecoration(
                                hintText: _selectedNoteId == null
                                    ? 'Click the plus button to create a new note, or select an existing one.'
                                    : 'Start writing your diary entry...',
                                hintStyle: theme.textTheme.bodyMedium?.copyWith(color: isDarkMode ? Colors.grey[500] : Colors.grey[400]),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
