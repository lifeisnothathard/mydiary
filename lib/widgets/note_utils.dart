import 'package:cloud_firestore/cloud_firestore.dart';
// For DateTime

// Helper for firstWhereOrNull, as it's not directly available on List<Map>
Map<String, dynamic>? firstWhereOrNull(List<Map<String, dynamic>> list, bool Function(Map<String, dynamic>) test) {
  for (var element in list) {
    if (test(element)) {
      return element;
    }
  }
  return null;
}

// Helper to format timestamp for display (e.g., "18:29")
String formatTimestamp(Timestamp? timestamp) {
  if (timestamp == null) return '';
  final date = timestamp.toDate();
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

// Helper to categorize notes by date (Today, Previous 30 Days, Month)
String formatDateForCategory(Timestamp? timestamp) {
  if (timestamp == null) return '';
  final date = timestamp.toDate();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final noteDate = DateTime(date.year, date.month, date.day);

  if (noteDate.isAtSameMomentAs(today)) {
    return 'Today';
  } else if (now.difference(noteDate).inDays <= 30) {
    return 'Previous 30 Days';
  } else {
    return getMonthName(date.month);
  }
}

// Helper to get month name from month number
String getMonthName(int month) {
  switch (month) {
    case 1: return 'January';
    case 2: return 'February';
    case 3: return 'March';
    case 4: return 'April';
    case 5: return 'May';
    case 6: return 'June';
    case 7: return 'July';
    case 8: return 'August';
    case 9: return 'September';
    case 10: return 'October';
    case 11: return 'November';
    case 12: return 'December';
    default: return '';
  }
}
