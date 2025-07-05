enum SortOption {
  dateNewest,
  dateOldest,
  alphabeticalAsc, // A-Z
  alphabeticalDesc, // Z-A
  favorites,
  // Add more options as needed
}

// Extension to provide human-readable names for the sort options
extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.dateNewest:
        return 'Date (Newest First)';
      case SortOption.dateOldest:
        return 'Date (Oldest First)';
      case SortOption.alphabeticalAsc:
        return 'Alphabetical (A-Z)';
      case SortOption.alphabeticalDesc:
        return 'Alphabetical (Z-A)';
      case SortOption.favorites:
        return 'Favorites';
    }
  }
}
