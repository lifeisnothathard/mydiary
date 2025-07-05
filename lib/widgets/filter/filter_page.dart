import 'package:flutter/material.dart';
import 'package:mydiary/services/themes/themeprovider.dart';
import 'package:mydiary/widgets/filter/sort_option.dart';
import 'package:provider/provider.dart';

class FilterPage extends StatefulWidget {
  final SortOption currentSortOption;

  const FilterPage({
    super.key,
    required this.currentSortOption,
  });

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late SortOption _selectedSortOption;

  @override
  void initState() {
    super.initState();
    _selectedSortOption = widget.currentSortOption;
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
        title: Text(
          'Sort Notes',
          style: theme.appBarTheme.titleTextStyle,
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
          IconButton(
            icon: Icon(Icons.check, color: theme.iconTheme.color),
            onPressed: () {
              // Return the selected sort option to the previous page
              Navigator.of(context).pop(_selectedSortOption);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort by:',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Date (Newest First)
            RadioListTile<SortOption>(
              title: Text(SortOption.dateNewest.displayName, style: theme.textTheme.bodyLarge),
              value: SortOption.dateNewest,
              groupValue: _selectedSortOption,
              onChanged: (SortOption? value) {
                setState(() {
                  _selectedSortOption = value!;
                });
              },
              activeColor: theme.primaryColor,
            ),
            // Date (Oldest First)
            RadioListTile<SortOption>(
              title: Text(SortOption.dateOldest.displayName, style: theme.textTheme.bodyLarge),
              value: SortOption.dateOldest,
              groupValue: _selectedSortOption,
              onChanged: (SortOption? value) {
                setState(() {
                  _selectedSortOption = value!;
                });
              },
              activeColor: theme.primaryColor,
            ),
            // Alphabetical (A-Z)
            RadioListTile<SortOption>(
              title: Text(SortOption.alphabeticalAsc.displayName, style: theme.textTheme.bodyLarge),
              value: SortOption.alphabeticalAsc,
              groupValue: _selectedSortOption,
              onChanged: (SortOption? value) {
                setState(() {
                  _selectedSortOption = value!;
                });
              },
              activeColor: theme.primaryColor,
            ),
            // Alphabetical (Z-A)
            RadioListTile<SortOption>(
              title: Text(SortOption.alphabeticalDesc.displayName, style: theme.textTheme.bodyLarge),
              value: SortOption.alphabeticalDesc,
              groupValue: _selectedSortOption,
              onChanged: (SortOption? value) {
                setState(() {
                  _selectedSortOption = value!;
                });
              },
              activeColor: theme.primaryColor,
            ),
            // Favorites
            RadioListTile<SortOption>(
              title: Text(SortOption.favorites.displayName, style: theme.textTheme.bodyLarge),
              value: SortOption.favorites,
              groupValue: _selectedSortOption,
              onChanged: (SortOption? value) {
                setState(() {
                  _selectedSortOption = value!;
                });
              },
              activeColor: theme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
