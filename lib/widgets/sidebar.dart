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
                suffixIcon: Icon(Icons.mic, color: theme.iconTheme.color),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // New Note Button
          OutlinedButton.icon(
            onPressed: onNavigateToAddNotePage,
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
