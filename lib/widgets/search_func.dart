import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mydiary/pages/note_detail_page.dart';
import 'package:mydiary/services/themes/themeprovider.dart';
import 'package:mydiary/widgets/note_utils.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  List<Map<String, dynamic>> _allNotes = []; // All notes fetched once
  List<Map<String, dynamic>> _filteredNotes = []; // Notes filtered by search query

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _fetchAllNotes(); // Fetch all notes when the page initializes
    }

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllNotes() async {
    if (_currentUser == null) return;
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('notes')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _allNotes = snapshot.docs.map((doc) {
          // Explicitly cast doc.data() to Map<String, dynamic>
          final data = doc.data() as Map<String, dynamic>;
          return {...data, 'id': doc.id};
        }).toList();
        _filteredNotes = _allNotes; // Initially, all notes are shown
      });
    } catch (e) {
      debugPrint("Error fetching all notes for search: $e");
      _showErrorSnackbar("Failed to load notes for search.");
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredNotes = _allNotes; // Show all notes if search is empty
      } else {
        _filteredNotes = _allNotes.where((note) {
          final content = (note['content'] as String? ?? '').toLowerCase();
          // You can add more fields to search, e.g., 'title' if you add one
          return content.contains(query);
        }).toList();
      }
    });
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
    // When returning, refresh the notes to reflect any changes made in detail page
    _fetchAllNotes();
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
        title: TextField(
          controller: _searchController,
          autofocus: true, // Automatically focus the search bar
          style: theme.textTheme.titleMedium?.copyWith(color: theme.textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: 'Search notes...',
            hintStyle: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[500]),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: theme.iconTheme.color),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged(); // Manually trigger search update
                    },
                  )
                : null,
          ),
        ),
        actions: [
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
      body: _filteredNotes.isEmpty && _searchController.text.isNotEmpty
          ? Center(
              child: Text(
                'No results found for "${_searchController.text}"',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _filteredNotes.length,
              itemBuilder: (context, index) {
                final note = _filteredNotes[index];
                final noteContent = note['content'] as String? ?? '';
                final lines = noteContent.trim().split('\n');
                final title = lines.isNotEmpty && lines[0].isNotEmpty ? lines[0] : 'New Note';
                String snippet = '';
                if (lines.length > 1 && lines[1].trim().isNotEmpty) {
                  snippet = lines[1].trim();
                } else if (lines.length > 2 && lines[2].trim().isNotEmpty) {
                  snippet = lines[2].trim();
                }
                final createdAt = note['createdAt'] as Timestamp?;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      _navigateToNoteDetailPage(note['id'], noteContent);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: Text(
                              formatDateForCategory(createdAt), // Using utility function
                              style: theme.textTheme.bodySmall?.copyWith(color: isDarkMode ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snippet.isNotEmpty ? snippet : 'No additional content.',
                            style: theme.textTheme.bodyMedium?.copyWith(color: isDarkMode ? Colors.grey[300] : Colors.grey[700]),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
