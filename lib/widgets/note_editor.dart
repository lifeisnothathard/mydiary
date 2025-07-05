// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp in title
import 'package:image_picker/image_picker.dart'; // For ImageSource enum
import 'package:mydiary/widgets/note_utils.dart'; // Import helper functions

class NoteEditor extends StatelessWidget {
  final String? selectedNoteId;
  final List<Map<String, dynamic>> notes;
  final TextEditingController newEntryController;
  final bool isUploadingImage;
  final Function(ImageSource) onPickImageAndUpload; // Changed to accept ImageSource
  final VoidCallback onDeleteCurrentNote;
  final bool isDarkMode;

  const NoteEditor({
    super.key,
    required this.selectedNoteId,
    required this.notes,
    required this.newEntryController,
    required this.isUploadingImage,
    required this.onPickImageAndUpload,
    required this.onDeleteCurrentNote,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width; // Get screen width here
    final bool isSmallScreen = screenWidth < 800; 

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
                padding: const EdgeInsets.all(20), // Padding inside the note container
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
                      child: SingleChildScrollView( // Added SingleChildScrollView here
                        scrollDirection: Axis.horizontal, // Allow horizontal scrolling for toolbar
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start, // Changed to start
                          children: [
                            const SizedBox(width: 8), // Add some initial padding
                            IconButton(icon: Icon(Icons.text_format, color: theme.iconTheme.color), onPressed: () {}),
                            IconButton(icon: Icon(Icons.format_list_bulleted, color: theme.iconTheme.color), onPressed: () {}),
                            IconButton(icon: Icon(Icons.checklist, color: theme.iconTheme.color), onPressed: () {}),
                            IconButton(icon: Icon(Icons.attach_file, color: theme.iconTheme.color), onPressed: () {}),
                            isUploadingImage
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: theme.primaryColor,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : PopupMenuButton<ImageSource>(
                                    icon: Icon(Icons.image, color: theme.iconTheme.color), // Changed to image icon
                                    onSelected: (ImageSource source) {
                                      onPickImageAndUpload(source);
                                    },
                                    itemBuilder: (BuildContext context) => <PopupMenuEntry<ImageSource>>[
                                      PopupMenuItem<ImageSource>(
                                        value: ImageSource.gallery,
                                        child: Row(
                                          children: [
                                            Icon(Icons.photo_library, color: theme.iconTheme.color),
                                            const SizedBox(width: 8),
                                            Text('Upload Image', style: theme.textTheme.bodyMedium),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem<ImageSource>(
                                        value: ImageSource.camera,
                                        child: Row(
                                          children: [
                                            Icon(Icons.camera_alt, color: theme.iconTheme.color),
                                            const SizedBox(width: 8),
                                            Text('Take Photo', style: theme.textTheme.bodyMedium),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                            IconButton(icon: Icon(Icons.lock_outline, color: theme.iconTheme.color), onPressed: () {}),
                            IconButton(icon: Icon(Icons.delete_outline, color: theme.iconTheme.color), onPressed: onDeleteCurrentNote),
                            const SizedBox(width: 8), // Add some trailing padding
                          ],
                        ),
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