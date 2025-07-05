import 'package:flutter/material.dart';
import 'package:mydiary/widgets/note_utils.dart'; // For Timestamp in title

class NoteEditor extends StatelessWidget {
  final String? selectedNoteId;
  final List<Map<String, dynamic>> notes;
  final TextEditingController newEntryController;
  final bool isUploadingImage;
  final VoidCallback onPickImageAndUpload;
  final bool isDarkMode;

  const NoteEditor({
    super.key,
    required this.selectedNoteId,
    required this.notes,
    required this.newEntryController,
    required this.isUploadingImage,
    required this.onPickImageAndUpload,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Helper to get selected note's content for title display
    Map<String, dynamic>? getSelectedNote() {
      if (selectedNoteId == null) return null;
      return firstWhereOrNull(notes, (note) => note['id'] == selectedNoteId);
    }

    final selectedNote = getSelectedNote();
    final noteContentForTitle = selectedNote?['content'] as String? ?? '';
    final title = noteContentForTitle.trim().split('\n')[0].isNotEmpty
        ? noteContentForTitle.trim().split('\n')[0]
        : 'New Note';

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Note Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Note Content Editor Container
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Toolbar for editor
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
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
                          // Image picker button
                          isUploadingImage
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: theme.primaryColor,
                                    strokeWidth: 2,
                                  ),
                                )
                              : IconButton(icon: Icon(Icons.image, color: theme.iconTheme.color), onPressed: onPickImageAndUpload),
                          IconButton(icon: Icon(Icons.lock_outline, color: theme.iconTheme.color), onPressed: () {}),
                          IconButton(icon: Icon(Icons.delete_outline, color: theme.iconTheme.color), onPressed: () {
                            // TODO: Implement delete note functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Delete note functionality to be implemented!")),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TextField(
                        controller: newEntryController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        expands: true,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyLarge?.color),
                        decoration: InputDecoration(
                          hintText: selectedNoteId == null
                              ? 'Click "New Note" to create one, or select an existing note.'
                              : 'Start writing your diary entry...',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(color: isDarkMode ? Colors.grey[500] : Colors.grey[400]),
                          border: InputBorder.none,
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
    );
  }
}
