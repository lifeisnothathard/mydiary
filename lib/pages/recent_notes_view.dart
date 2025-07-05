import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mydiary/widgets/note_utils.dart';

typedef NavigateToNoteDetailPageCallback = void Function(String noteId, String initialContent);

class RecentNotesView extends StatelessWidget {
  final List<Map<String, dynamic>> notes;
  final NavigateToNoteDetailPageCallback onNavigateToNoteDetailPage;
  final bool isDarkMode;

  const RecentNotesView({
    super.key,
    required this.notes,
    required this.onNavigateToNoteDetailPage,
    required this.isDarkMode,
  });

  // Group notes by formatted date category
  Map<String, List<Map<String, dynamic>>> _groupNotesByCategory(List<Map<String, dynamic>> notes) {
    final Map<String, List<Map<String, dynamic>>> categorized = {};
    for (final note in notes) {
      final Timestamp? timestamp = note['createdAt'] as Timestamp?;
      final String category = formatDateForCategory(timestamp);
      categorized.putIfAbsent(category, () => []).add(note);
    }
    return categorized;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categorizedNotes = _groupNotesByCategory(notes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent notes',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.search, color: theme.iconTheme.color),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Search functionality to be implemented!')),
                  );
                },
              ),
            ],
          ),
        ),

        // Search Field (non-functional placeholder)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: theme.inputDecorationTheme.fillColor ?? Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: theme.inputDecorationTheme.hintStyle,
                prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyLarge?.color),
              enabled: false, // Placeholder for future logic
            ),
          ),
        ),

        // Notes list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: categorizedNotes.keys.length,
            itemBuilder: (context, categoryIndex) {
              final category = categorizedNotes.keys.elementAt(categoryIndex);
              final notesInCategory = categorizedNotes[category]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Header
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

                  // Notes under this category
                  ...notesInCategory.map((note) {
                    final String content = note['content'] as String? ?? '';
                    final List<String> lines = content.trim().split('\n');
                    final String title = lines.isNotEmpty && lines[0].trim().isNotEmpty ? lines[0].trim() : 'New Note';
                    final String snippet = lines.skip(1).firstWhere(
                      (line) => line.trim().isNotEmpty,
                      orElse: () => 'No additional content.',
                    );
                    final Timestamp? createdAt = note['createdAt'] as Timestamp?;

                    return Padding(
                      key: ValueKey(note['id']),
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          onNavigateToNoteDetailPage(note['id'] as String, content);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
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
                                  formatDateForCategory(createdAt),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                    fontSize: 12,
                                  ),
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
                                snippet,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
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
    );
  }
}
