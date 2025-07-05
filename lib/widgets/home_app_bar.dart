import 'package:flutter/material.dart';
import 'package:mydiary/widgets/filter/sort_option.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDarkMode;
  final VoidCallback onLogout;
  final VoidCallback onToggleTheme;
  final VoidCallback onNavigateToSearchPage;

  const HomeAppBar({
    super.key,
    required this.isDarkMode,
    required this.onLogout,
    required this.onToggleTheme,
    required this.onNavigateToSearchPage, required void Function(SortOption selectedOption) onSortOptionSelected, required SortOption currentSortOption,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: theme.appBarTheme.elevation,
      leading: IconButton(icon: Icon(Icons.menu, color: theme.iconTheme.color), onPressed: () {}),
      title: Text('MyDiary', style: theme.textTheme.titleLarge),
      actions: [
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
