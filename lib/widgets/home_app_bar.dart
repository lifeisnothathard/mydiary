import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDarkMode;
  final VoidCallback onLogout;
  final VoidCallback onToggleTheme;

  const HomeAppBar({
    super.key,
    required this.isDarkMode,
    required this.onLogout,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: theme.appBarTheme.elevation,
      leading: IconButton(icon: Icon(Icons.menu, color: theme.iconTheme.color), onPressed: () {}),
      title: Row( // Grouping these icons in the title area
        children: [
          IconButton(icon: Icon(Icons.folder_open, color: theme.iconTheme.color), onPressed: () {}),
          IconButton(icon: Icon(Icons.share, color: theme.iconTheme.color), onPressed: () {}),
        ],
      ),
      actions: [
        IconButton(icon: Icon(Icons.person, color: theme.iconTheme.color), onPressed: () {}),
        IconButton(icon: Icon(Icons.settings, color: theme.iconTheme.color), onPressed: () {}),
        IconButton(
          icon: Icon(Icons.logout, color: theme.iconTheme.color),
          onPressed: onLogout,
        ),
        IconButton(
          icon: Icon(
            isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: theme.iconTheme.color,
          ),
          onPressed: onToggleTheme,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // Standard AppBar height
}
