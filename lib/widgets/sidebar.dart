import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mydiary/widgets/note_utils.dart'; // For Timestamp

class Sidebar extends StatelessWidget {
  final List<Map<String, dynamic>> notes;
  final String? selectedNoteId;
  final Function(String) onSelectNote;
  final VoidCallback onNavigateToAddNotePage;
  final bool isSmallScreen;
  final bool isDarkMode;

  const Sidebar({
    super.key,
    required this.notes,
    required this.selectedNoteId,
    required this.onSelectNote,
    required this.onNavigateToAddNotePage,
    required this.isSmallScreen,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Group notes by category
    final Map<String, List<Map<String, dynamic>>> categorizedNotes = {};
    for (var note in notes) {
      final category = formatDateForCategory(note['createdAt'] as Timestamp?);
      if (!categorizedNotes.containsKey(category)) {
        categorizedNotes[category] = [];
      }
      categorizedNotes[category]!.add(note);
    }

    return Container(
      width: isSmallScreen ? 200 : 300,
      color: theme.appBarTheme.backgroundColor,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'stuff',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 20 : 24, // Responsive font size
            ),
          ),
          const SizedBox(height: 10),
          // ... rest of the sidebar content
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
                      // Ensure snippet is not just empty space or the same as title if only one line
                      String snippet = '';
                      if (lines.length > 1 && lines[1].trim().isNotEmpty) {
                        snippet = lines[1].trim();
                      } else if (lines.length > 2 && lines[2].trim().isNotEmpty) {
                        snippet = lines[2].trim();
                      }

                      final createdAt = note['createdAt'] as Timestamp?;
                      final isLocked = note['isLocked'] as bool? ?? false;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: GestureDetector(
                          onTap: () => onSelectNote(note['id']),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selectedNoteId == note['id']
                                  ? (isDarkMode ? Colors.grey[800] : Colors.grey[300])
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
                                      formatTimestamp(createdAt),
                                      style: theme.textTheme.bodySmall?.copyWith(color: isDarkMode ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
                                    ),
                                    if (snippet.isNotEmpty)
                                      Text(
                                        ' ${snippet}...',
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
    );
  }
}