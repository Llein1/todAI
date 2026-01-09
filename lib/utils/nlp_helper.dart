import 'package:intl/intl.dart';

/// NLP Helper for extracting dates, times, and other information
/// from natural language text (Turkish and English support)
/// This serves as an offline fallback when AI API is unavailable
class NLPHelper {
  // Turkish date keywords
  static const Map<String, int> _turkishDayKeywords = {
    'bugün': 0,
    'bugun': 0,
    'yarın': 1,
    'yarin': 1,
    'öbür gün': 2,
    'obur gun': 2,
    'gelecek hafta': 7,
    'önümüzdeki hafta': 7,
    'onumuzdeki hafta': 7,
  };

  // English date keywords
  static const Map<String, int> _englishDayKeywords = {
    'today': 0,
    'tomorrow': 1,
    'next week': 7,
    'next month': 30,
  };

  // Priority keywords
  static const List<String> _highPriorityKeywords = [
    'urgent', 'acil', 'önemli', 'onemli', 'important', 'critical', 'kritik',
    'asap', 'deadline', 'son tarih'
  ];

  static const List<String> _lowPriorityKeywords = [
    'later', 'sonra', 'maybe', 'belki', 'sometime', 'birgun', 'bir gün'
  ];

  // Category keywords
  static const Map<String, List<String>> _categoryKeywords = {
    'work': ['work', 'iş', 'is', 'meeting', 'toplantı', 'toplanti', 'project', 'proje'],
    'personal': ['personal', 'kişisel', 'kisisel', 'home', 'ev', 'family', 'aile'],
    'urgent': ['urgent', 'acil', 'emergency', 'aciliyet'],
  };

  /// Extract date from natural language text
  static DateTime? extractDate(String text) {
    final lowerText = text.toLowerCase().trim();
    final now = DateTime.now();

    // Check Turkish keywords
    for (var entry in _turkishDayKeywords.entries) {
      if (lowerText.contains(entry.key)) {
        return DateTime(now.year, now.month, now.day).add(Duration(days: entry.value));
      }
    }

    // Check English keywords
    for (var entry in _englishDayKeywords.entries) {
      if (lowerText.contains(entry.key)) {
        return DateTime(now.year, now.month, now.day).add(Duration(days: entry.value));
      }
    }

    // Pattern: "in X days" or "X gün sonra"
    final daysPattern = RegExp(r'(\d+)\s*(day|days|gün|gun)\s*(sonra|later)?');
    final daysMatch = daysPattern.firstMatch(lowerText);
    if (daysMatch != null) {
      final days = int.tryParse(daysMatch.group(1) ?? '0') ?? 0;
      return DateTime(now.year, now.month, now.day).add(Duration(days: days));
    }

    // Pattern: "15 Ocak", "January 15", "15/01", "01/15"
    final datePattern = RegExp(r'(\d{1,2})[/\-\.](\d{1,2})');
    final dateMatch = datePattern.firstMatch(lowerText);
    if (dateMatch != null) {
      final day = int.tryParse(dateMatch.group(1) ?? '0') ?? 0;
      final month = int.tryParse(dateMatch.group(2) ?? '0') ?? 0;
      if (day > 0 && day <= 31 && month > 0 && month <= 12) {
        return DateTime(now.year, month, day);
      }
    }

    return null;
  }

  /// Extract time from text (e.g., "5pm", "17:00", "saat 5")
  static DateTime? extractTime(String text) {
    final lowerText = text.toLowerCase().trim();

    // Pattern: "5pm", "5 pm", "17:00"
    final timePattern = RegExp(r'(\d{1,2})(?::(\d{2}))?\s*(pm|am|p|a)?');
    final matches = timePattern.allMatches(lowerText);

    for (var match in matches) {
      var hour = int.tryParse(match.group(1) ?? '0') ?? 0;
      final minute = int.tryParse(match.group(2) ?? '0') ?? 0;
      final modifier = match.group(3)?.toLowerCase();

      // Handle PM/AM
      if (modifier != null && (modifier.startsWith('p')) && hour < 12) {
        hour += 12;
      } else if (modifier != null && (modifier.startsWith('a')) && hour == 12) {
        hour = 0;
      }

      if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, hour, minute);
      }
    }

    // Pattern: "saat 5", "saat 17"
    final turkishTimePattern = RegExp(r'saat\s*(\d{1,2})');
    final turkishMatch = turkishTimePattern.firstMatch(lowerText);
    if (turkishMatch != null) {
      final hour = int.tryParse(turkishMatch.group(1) ?? '0') ?? 0;
      if (hour >= 0 && hour < 24) {
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, hour, 0);
      }
    }

    return null;
  }

  /// Combine date and time extraction
  static DateTime? combineDateTime(String text) {
    final date = extractDate(text);
    final time = extractTime(text);

    if (date != null && time != null) {
      return DateTime(date.year, date.month, date.day, time.hour, time.minute);
    } else if (date != null) {
      return date;
    } else if (time != null) {
      return time;
    }

    return null;
  }

  /// Detect priority from text
  static String? detectPriority(String text) {
    final lowerText = text.toLowerCase();

    for (var keyword in _highPriorityKeywords) {
      if (lowerText.contains(keyword)) {
        return 'high';
      }
    }

    for (var keyword in _lowPriorityKeywords) {
      if (lowerText.contains(keyword)) {
        return 'low';
      }
    }

    return 'medium'; // Default
  }

  /// Detect category from text
  static String? detectCategory(String text) {
    final lowerText = text.toLowerCase();

    for (var entry in _categoryKeywords.entries) {
      for (var keyword in entry.value) {
        if (lowerText.contains(keyword)) {
          return entry.key;
        }
      }
    }

    return null;
  }

  /// Format DateTime for display
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateOnly == today) {
      return 'Today ${DateFormat('HH:mm').format(dateTime)}';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      return DateFormat('dd MMM HH:mm').format(dateTime);
    }
  }

  /// Format date only
  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow';
    } else {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }
}
