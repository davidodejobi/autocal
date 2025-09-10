import 'package:flutter/material.dart';
import '../models/parsed_event.dart';

// Service for parsing dates, times, and locations from text
class TextParserService {
  static final TextParserService _instance = TextParserService._internal();
  factory TextParserService() => _instance;
  TextParserService._internal();

  // Date patterns with confidence scores
  static final List<_DatePattern> _datePatterns = [
    // MM/DD/YYYY, MM-DD-YYYY, MM.DD.YYYY (US format - prioritized)
    _DatePattern(
      RegExp(r'\b(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{4})\b'),
      (match) => _tryParseUSDate(int.parse(match.group(1)!), int.parse(match.group(2)!), int.parse(match.group(3)!)),
      0.9,
    ),
    // YYYY-MM-DD (ISO format)
    _DatePattern(
      RegExp(r'\b(\d{4})-(\d{1,2})-(\d{1,2})\b'),
      (match) => _tryParseDate(int.parse(match.group(1)!), int.parse(match.group(2)!), int.parse(match.group(3)!)),
      0.95,
    ),
    // Month DD, YYYY
    _DatePattern(
      RegExp(r'\b(January|February|March|April|May|June|July|August|September|October|November|December)\s+(\d{1,2}),?\s+(\d{4})\b', caseSensitive: false),
      (match) => _tryParseDate(int.parse(match.group(3)!), _monthNameToNumber(match.group(1)!), int.parse(match.group(2)!)),
      0.95,
    ),
    // DD Month YYYY
    _DatePattern(
      RegExp(r'\b(\d{1,2})\s+(January|February|March|April|May|June|July|August|September|October|November|December)\s+(\d{4})\b', caseSensitive: false),
      (match) => _tryParseDate(int.parse(match.group(3)!), _monthNameToNumber(match.group(2)!), int.parse(match.group(1)!)),
      0.95,
    ),
    // Relative dates
    _DatePattern(
      RegExp(r'\b(today|tomorrow|yesterday)\b', caseSensitive: false),
      (match) => _parseRelativeDate(match.group(1)!.toLowerCase()),
      0.9,
    ),
    // Day of week (next/this week)
    _DatePattern(
      RegExp(r'\b(next|this)?\s*(monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b', caseSensitive: false),
      (match) => _parseDayOfWeek(match.group(2)!.toLowerCase(), match.group(1)?.toLowerCase()),
      0.8,
    ),
  ];

  // Time patterns with confidence scores
  static final List<_TimePattern> _timePatterns = [
    // 12-hour format with AM/PM
    _TimePattern(
      RegExp(r'\b(\d{1,2}):(\d{2})\s*(am|pm)\b', caseSensitive: false),
      (match) => _parse12HourTime(int.parse(match.group(1)!), int.parse(match.group(2)!), match.group(3)!.toLowerCase()),
      0.95,
    ),
    // 12-hour format without minutes
    _TimePattern(
      RegExp(r'\b(\d{1,2})\s*(am|pm)\b', caseSensitive: false),
      (match) => _parse12HourTime(int.parse(match.group(1)!), 0, match.group(2)!.toLowerCase()),
      0.9,
    ),
    // 24-hour format (only if not followed by AM/PM)
    _TimePattern(
      RegExp(r'\b(\d{1,2}):(\d{2})(?!\s*[ap]m)\b', caseSensitive: false),
      (match) => _parse24HourTime(int.parse(match.group(1)!), int.parse(match.group(2)!)),
      0.7, // Lower confidence as it could be other numbers
    ),
    // Relative times
    _TimePattern(
      RegExp(r'\b(noon|midnight)\b', caseSensitive: false),
      (match) => _parseRelativeTime(match.group(1)!.toLowerCase()),
      0.9,
    ),
  ];

  /// Parse event information from shared text
  Future<ParsedEvent> parseEventFromText(String text) async {
    if (text.trim().isEmpty) {
      return ParsedEvent(
        originalText: text,
        confidence: 0.0,
      );
    }

    // Extract dates with confidence
    final dateMatches = extractDatesWithConfidence(text);
    final timeMatches = extractTimesWithConfidence(text);
    final locationMatches = extractLocationsWithConfidence(text);

    // Determine the best date
    DateTime? bestDate;
    double dateConfidence = 0.0;
    if (dateMatches.isNotEmpty) {
      bestDate = dateMatches.first.date;
      dateConfidence = dateMatches.first.confidence;
    }

    // Determine the best times (start and end)
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    double timeConfidence = 0.0;
    if (timeMatches.isNotEmpty) {
      startTime = timeMatches.first.time;
      timeConfidence = timeMatches.first.confidence;
      
      // If there are multiple times, use the second as end time
      if (timeMatches.length > 1) {
        endTime = timeMatches[1].time;
        // Average the confidence of both times
        timeConfidence = (timeConfidence + timeMatches[1].confidence) / 2;
      }
    }

    // Determine the best location
    String? bestLocation;
    double locationConfidence = 0.0;
    if (locationMatches.isNotEmpty) {
      bestLocation = locationMatches.first.location;
      locationConfidence = locationMatches.first.confidence;
    }

    // Extract a potential title from the text
    String? title = _extractTitle(text, bestDate, startTime, bestLocation);
    double titleConfidence = title != null ? 0.3 : 0.0;

    // Calculate overall confidence
    double overallConfidence = _calculateOverallConfidence(
      dateConfidence,
      timeConfidence,
      locationConfidence,
      titleConfidence,
    );

    return ParsedEvent(
      title: title,
      date: bestDate,
      startTime: startTime,
      endTime: endTime,
      location: bestLocation,
      originalText: text,
      confidence: overallConfidence,
      metadata: {
        'dateConfidence': dateConfidence,
        'timeConfidence': timeConfidence,
        'locationConfidence': locationConfidence,
        'dateMatches': dateMatches.length,
        'timeMatches': timeMatches.length,
        'locationMatches': locationMatches.length,
      },
    );
  }

  /// Extract a potential title from the text by removing parsed elements
  String? _extractTitle(String text, DateTime? date, TimeOfDay? time, String? location) {
    String cleanedText = text;

    // Remove date patterns
    for (final pattern in _datePatterns) {
      cleanedText = cleanedText.replaceAll(pattern.regex, '');
    }

    // Remove time patterns
    for (final pattern in _timePatterns) {
      cleanedText = cleanedText.replaceAll(pattern.regex, '');
    }

    // Remove location patterns
    for (final pattern in _locationPatterns) {
      cleanedText = cleanedText.replaceAll(pattern.regex, '');
    }

    // Clean up the remaining text
    cleanedText = cleanedText
        .replaceAll(RegExp(r'\s+'), ' ') // Multiple spaces to single space
        .replaceAll(RegExp(r'[,\-\s]+$'), '') // Remove trailing punctuation
        .replaceAll(RegExp(r'^[,\-\s]+'), '') // Remove leading punctuation
        .trim();

    // If the cleaned text is too short or contains only common words, return null
    if (cleanedText.length < 3 || _isOnlyCommonWords(cleanedText)) {
      return null;
    }

    return cleanedText;
  }

  /// Check if text contains only common words that aren't useful as titles
  bool _isOnlyCommonWords(String text) {
    const commonWords = {
      'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
      'of', 'with', 'by', 'from', 'up', 'about', 'into', 'through', 'during',
      'before', 'after', 'above', 'below', 'between', 'among', 'is', 'are',
      'was', 'were', 'be', 'been', 'being', 'have', 'has', 'had', 'do', 'does',
      'did', 'will', 'would', 'could', 'should', 'may', 'might', 'must', 'can',
    };

    final words = text.toLowerCase().split(RegExp(r'\s+'));
    final meaningfulWords = words.where((word) => !commonWords.contains(word)).toList();
    
    return meaningfulWords.isEmpty || meaningfulWords.length < words.length * 0.3;
  }

  /// Calculate overall confidence based on individual component confidences
  double _calculateOverallConfidence(
    double dateConfidence,
    double timeConfidence,
    double locationConfidence,
    double titleConfidence,
  ) {
    // If no meaningful components were found, return 0
    if (dateConfidence == 0 && timeConfidence == 0 && locationConfidence == 0) {
      return 0.0;
    }

    // Weight the components - date and time are more important
    double weightedSum = 0.0;
    double totalWeight = 0.0;

    if (dateConfidence > 0) {
      weightedSum += dateConfidence * 0.4; // 40% weight
      totalWeight += 0.4;
    }
    if (timeConfidence > 0) {
      weightedSum += timeConfidence * 0.3; // 30% weight
      totalWeight += 0.3;
    }
    if (locationConfidence > 0) {
      weightedSum += locationConfidence * 0.2; // 20% weight
      totalWeight += 0.2;
    }
    if (titleConfidence > 0) {
      weightedSum += titleConfidence * 0.1; // 10% weight
      totalWeight += 0.1;
    }

    return totalWeight > 0 ? weightedSum / totalWeight : 0.0;
  }

  /// Extract dates from text with confidence scoring
  List<_DateMatch> extractDatesWithConfidence(String text) {
    final List<_DateMatch> matches = [];
    
    for (final pattern in _datePatterns) {
      final regexMatches = pattern.regex.allMatches(text);
      for (final match in regexMatches) {
        final date = pattern.parser(match);
        if (date != null) {
          matches.add(_DateMatch(date, pattern.confidence, match.group(0)!));
        }
      }
    }
    
    // Sort by confidence and remove duplicates
    matches.sort((a, b) => b.confidence.compareTo(a.confidence));
    return _removeDuplicateDates(matches);
  }

  /// Extract dates from text (public interface)
  List<DateTime> extractDates(String text) {
    return extractDatesWithConfidence(text).map((match) => match.date).toList();
  }

  /// Extract times from text with confidence scoring
  List<_TimeMatch> extractTimesWithConfidence(String text) {
    final List<_TimeMatch> matches = [];
    
    for (final pattern in _timePatterns) {
      final regexMatches = pattern.regex.allMatches(text);
      for (final match in regexMatches) {
        final time = pattern.parser(match);
        if (time != null) {
          matches.add(_TimeMatch(time, pattern.confidence, match.group(0)!));
        }
      }
    }
    
    // Sort by confidence and remove duplicates
    matches.sort((a, b) => b.confidence.compareTo(a.confidence));
    return _removeDuplicateTimes(matches);
  }

  /// Extract times from text (public interface)
  List<TimeOfDay> extractTimes(String text) {
    return extractTimesWithConfidence(text).map((match) => match.time).toList();
  }

  // Location patterns with confidence scores (ordered by specificity)
  static final List<_LocationPattern> _locationPatterns = [
    // Address patterns (street number + street name) - highest priority
    _LocationPattern(
      RegExp(r'\b\d+\s+[A-Za-z\s]+(?:Street|St|Avenue|Ave|Road|Rd|Boulevard|Blvd|Drive|Dr|Lane|Ln|Way|Place|Pl|Court|Ct)\b', caseSensitive: false),
      (match) => match.group(0)!.trim(),
      0.95,
    ),
    // Room numbers and meeting rooms
    _LocationPattern(
      RegExp(r'\b(?:room|conference room|meeting room)\s+([A-Za-z0-9\-]+)\b', caseSensitive: false),
      (match) => 'Room ${match.group(1)!.trim()}',
      0.9,
    ),
    // Building + room/floor
    _LocationPattern(
      RegExp(r'\b([A-Za-z\s]+(?:Building|Bldg))\s*,?\s*(?:room|floor|level)?\s*([A-Za-z0-9\-]+)?\b', caseSensitive: false),
      (match) {
        final building = match.group(1)!.trim();
        final room = match.group(2)?.trim();
        return room != null && room.isNotEmpty ? '$building, Room $room' : building;
      },
      0.85,
    ),
    // "at" + specific location (simple pattern)
    _LocationPattern(
      RegExp(r'\bat\s+([A-Za-z\s&\-]{2,25})\b', caseSensitive: false),
      (match) => match.group(1)!.trim(),
      0.9,
    ),
    // Zip codes (US format)
    _LocationPattern(
      RegExp(r'\b([A-Za-z\s\-]+),?\s*([A-Z]{2})\s+(\d{5}(?:-\d{4})?)\b'),
      (match) => '${match.group(1)!.trim()}, ${match.group(2)} ${match.group(3)}',
      0.9,
    ),
    // City, State format
    _LocationPattern(
      RegExp(r'\b([A-Za-z\s\-]+),\s*([A-Z]{2})\b'),
      (match) => '${match.group(1)!.trim()}, ${match.group(2)}',
      0.8,
    ),
    // Online meeting indicators
    _LocationPattern(
      RegExp(r'\b(zoom|teams|skype|webex|google meet|hangouts|online|virtual|remote)\b', caseSensitive: false),
      (match) => 'Online (${match.group(1)!.toLowerCase()})',
      0.85,
    ),
    // "in" + location (city, state, country) - lower priority due to ambiguity
    _LocationPattern(
      RegExp(r'\bin\s+([A-Z][A-Za-z\s\-]*(?:,\s*[A-Z]{2})?)\b', caseSensitive: false),
      (match) => match.group(1)!.trim(),
      0.6, // Lower confidence as "in" can be used in many contexts
    ),
  ];

  /// Extract locations from text with confidence scoring
  List<_LocationMatch> extractLocationsWithConfidence(String text) {
    final List<_LocationMatch> matches = [];
    
    for (final pattern in _locationPatterns) {
      final regexMatches = pattern.regex.allMatches(text);
      for (final match in regexMatches) {
        final location = pattern.parser(match);
        if (location.isNotEmpty && _isValidLocation(location)) {
          matches.add(_LocationMatch(location, pattern.confidence, match.group(0)!));
        }
      }
    }
    
    // Sort by confidence and remove duplicates
    matches.sort((a, b) => b.confidence.compareTo(a.confidence));
    return _removeDuplicateLocations(matches);
  }

  /// Extract locations from text (public interface)
  List<String> extractLocations(String text) {
    return extractLocationsWithConfidence(text).map((match) => match.location).toList();
  }

  // Helper method to validate locations
  static bool _isValidLocation(String location) {
    // Filter out common false positives
    final lowercaseLocation = location.toLowerCase().trim();
    
    // Skip very short locations (likely false positives)
    if (lowercaseLocation.length < 2) return false;
    
    // Skip common words that aren't locations
    const commonWords = {
      'in the', 'in a', 'in an', 'at the', 'at a', 'at an',
      'room the', 'room a', 'room an', 'building the', 'building a',
      'online the', 'online a', 'virtual the', 'virtual a',
      'the morning', 'a good', 'good time', 'the time', 'a time',
      'the', 'a', 'an', 'and', 'or', 'but', 'with', 'for', 'to',
      'morning', 'afternoon', 'evening', 'night', 'time', 'good',
    };
    
    if (commonWords.contains(lowercaseLocation)) return false;
    
    // Skip if it's just a single common word
    const singleWords = {
      'in', 'at', 'on', 'the', 'a', 'an', 'and', 'or', 'but',
      'room', 'building', 'floor', 'level', 'online', 'virtual',
      'with', 'for', 'to', 'from', 'by', 'of', 'is', 'are', 'was',
      'morning', 'afternoon', 'evening', 'night', 'time', 'good',
    };
    
    if (singleWords.contains(lowercaseLocation)) return false;
    
    // Skip locations that are too generic or likely false positives
    if (lowercaseLocation.contains('good time') || 
        lowercaseLocation.contains('the morning') ||
        lowercaseLocation.contains('a time')) {
      return false;
    }
    
    return true;
  }

  // Helper method for removing duplicate locations
  static List<_LocationMatch> _removeDuplicateLocations(List<_LocationMatch> matches) {
    final Map<String, _LocationMatch> uniqueMatches = {};
    
    for (final match in matches) {
      final key = match.location.toLowerCase().trim();
      if (!uniqueMatches.containsKey(key) || uniqueMatches[key]!.confidence < match.confidence) {
        uniqueMatches[key] = match;
      }
    }
    
    return uniqueMatches.values.toList()..sort((a, b) => b.confidence.compareTo(a.confidence));
  }

  // Helper methods for date parsing
  static DateTime? _tryParseDate(int year, int month, int day) {
    // Validate ranges before attempting to create DateTime
    if (month < 1 || month > 12 || day < 1 || day > 31 || year < 1900 || year > 2100) {
      return null;
    }
    
    // Special validation for February 29th on non-leap years
    if (month == 2 && day == 29 && !_isLeapYear(year)) {
      return null;
    }
    
    try {
      final date = DateTime(year, month, day);
      // Verify the date wasn't adjusted (e.g., Feb 30 -> Mar 2)
      if (date.year != year || date.month != month || date.day != day) {
        return null;
      }
      return date;
    } catch (e) {
      return null;
    }
  }

  static DateTime? _tryParseUSDate(int month, int day, int year) {
    // Validate ranges before attempting to create DateTime
    if (month < 1 || month > 12 || day < 1 || day > 31 || year < 1900 || year > 2100) {
      return null;
    }
    
    // Special validation for February 29th on non-leap years
    if (month == 2 && day == 29 && !_isLeapYear(year)) {
      return null;
    }
    
    try {
      final date = DateTime(year, month, day);
      // Verify the date wasn't adjusted (e.g., Feb 30 -> Mar 2)
      if (date.year != year || date.month != month || date.day != day) {
        return null;
      }
      return date;
    } catch (e) {
      return null;
    }
  }

  static bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  static int _monthNameToNumber(String monthName) {
    const months = {
      'january': 1, 'february': 2, 'march': 3, 'april': 4,
      'may': 5, 'june': 6, 'july': 7, 'august': 8,
      'september': 9, 'october': 10, 'november': 11, 'december': 12,
    };
    return months[monthName.toLowerCase()] ?? 1;
  }

  static DateTime? _parseRelativeDate(String relative) {
    final now = DateTime.now();
    switch (relative) {
      case 'today':
        return DateTime(now.year, now.month, now.day);
      case 'tomorrow':
        final tomorrow = now.add(const Duration(days: 1));
        return DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
      case 'yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        return DateTime(yesterday.year, yesterday.month, yesterday.day);
      default:
        return null;
    }
  }

  static DateTime? _parseDayOfWeek(String dayName, String? modifier) {
    const days = {
      'monday': 1, 'tuesday': 2, 'wednesday': 3, 'thursday': 4,
      'friday': 5, 'saturday': 6, 'sunday': 7,
    };
    
    final targetDay = days[dayName];
    if (targetDay == null) return null;
    
    final now = DateTime.now();
    final currentDay = now.weekday;
    
    int daysToAdd;
    if (modifier == 'next') {
      daysToAdd = (targetDay - currentDay + 7) % 7;
      if (daysToAdd == 0) daysToAdd = 7; // Next week
    } else {
      // 'this' or no modifier - find next occurrence this week or next
      daysToAdd = (targetDay - currentDay) % 7;
      if (daysToAdd < 0) daysToAdd += 7;
    }
    
    final targetDate = now.add(Duration(days: daysToAdd));
    return DateTime(targetDate.year, targetDate.month, targetDate.day);
  }

  // Helper methods for time parsing
  static TimeOfDay? _parse12HourTime(int hour, int minute, String period) {
    if (hour < 1 || hour > 12 || minute < 0 || minute > 59) return null;
    
    int adjustedHour = hour;
    if (period == 'pm' && hour != 12) {
      adjustedHour += 12;
    } else if (period == 'am' && hour == 12) {
      adjustedHour = 0;
    }
    
    return TimeOfDay(hour: adjustedHour, minute: minute);
  }

  static TimeOfDay? _parse24HourTime(int hour, int minute) {
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static TimeOfDay? _parseRelativeTime(String relative) {
    switch (relative) {
      case 'noon':
        return const TimeOfDay(hour: 12, minute: 0);
      case 'midnight':
        return const TimeOfDay(hour: 0, minute: 0);
      default:
        return null;
    }
  }

  // Helper methods for removing duplicates
  static List<_DateMatch> _removeDuplicateDates(List<_DateMatch> matches) {
    final Map<String, _DateMatch> uniqueMatches = {};
    
    for (final match in matches) {
      final key = '${match.date.year}-${match.date.month}-${match.date.day}';
      if (!uniqueMatches.containsKey(key) || uniqueMatches[key]!.confidence < match.confidence) {
        uniqueMatches[key] = match;
      }
    }
    
    return uniqueMatches.values.toList()..sort((a, b) => b.confidence.compareTo(a.confidence));
  }

  static List<_TimeMatch> _removeDuplicateTimes(List<_TimeMatch> matches) {
    final Map<String, _TimeMatch> uniqueMatches = {};
    
    for (final match in matches) {
      final key = '${match.time.hour}:${match.time.minute}';
      if (!uniqueMatches.containsKey(key) || uniqueMatches[key]!.confidence < match.confidence) {
        uniqueMatches[key] = match;
      }
    }
    
    return uniqueMatches.values.toList()..sort((a, b) => b.confidence.compareTo(a.confidence));
  }
}

// Helper classes for pattern matching
class _DatePattern {
  final RegExp regex;
  final DateTime? Function(RegExpMatch) parser;
  final double confidence;

  _DatePattern(this.regex, this.parser, this.confidence);
}

class _TimePattern {
  final RegExp regex;
  final TimeOfDay? Function(RegExpMatch) parser;
  final double confidence;

  _TimePattern(this.regex, this.parser, this.confidence);
}

class _DateMatch {
  final DateTime date;
  final double confidence;
  final String originalText;

  _DateMatch(this.date, this.confidence, this.originalText);
}

class _TimeMatch {
  final TimeOfDay time;
  final double confidence;
  final String originalText;

  _TimeMatch(this.time, this.confidence, this.originalText);
}

class _LocationPattern {
  final RegExp regex;
  final String Function(RegExpMatch) parser;
  final double confidence;

  _LocationPattern(this.regex, this.parser, this.confidence);
}

class _LocationMatch {
  final String location;
  final double confidence;
  final String originalText;

  _LocationMatch(this.location, this.confidence, this.originalText);
}