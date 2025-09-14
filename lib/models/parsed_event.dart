import 'package:flutter/material.dart';

// Core data model for parsed event information
class ParsedEvent {
  final String? title;
  final DateTime? date;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final String? location;
  final String originalText;
  final double confidence;
  final Map<String, dynamic> metadata;

  // Enhanced AI-generated fields
  final String? summary;
  final String? description;
  final DateTime? endDate;
  final EventType? eventType;
  final EventImportance? importance;
  final List<SmartReminder>? suggestedReminders;
  final List<String>? keyPoints;

  const ParsedEvent({
    this.title,
    this.date,
    this.startTime,
    this.endTime,
    this.location,
    required this.originalText,
    required this.confidence,
    this.metadata = const {},
    // Enhanced fields
    this.summary,
    this.description,
    this.endDate,
    this.eventType,
    this.importance,
    this.suggestedReminders,
    this.keyPoints,
  });

  ParsedEvent copyWith({
    String? title,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? location,
    String? originalText,
    double? confidence,
    Map<String, dynamic>? metadata,
    String? summary,
    String? description,
    DateTime? endDate,
    EventType? eventType,
    EventImportance? importance,
    List<SmartReminder>? suggestedReminders,
    List<String>? keyPoints,
  }) {
    return ParsedEvent(
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      originalText: originalText ?? this.originalText,
      confidence: confidence ?? this.confidence,
      metadata: metadata ?? this.metadata,
      summary: summary ?? this.summary,
      description: description ?? this.description,
      endDate: endDate ?? this.endDate,
      eventType: eventType ?? this.eventType,
      importance: importance ?? this.importance,
      suggestedReminders: suggestedReminders ?? this.suggestedReminders,
      keyPoints: keyPoints ?? this.keyPoints,
    );
  }

  /// Get the event duration in a human-readable format
  String get durationText {
    if (startTime == null || endTime == null) return '';

    final start = DateTime(2024, 1, 1, startTime!.hour, startTime!.minute);
    final end = DateTime(2024, 1, 1, endTime!.hour, endTime!.minute);
    final duration = end.difference(start);

    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  /// Get importance color
  Color get importanceColor {
    switch (importance) {
      case EventImportance.high:
        return Colors.red;
      case EventImportance.medium:
        return Colors.orange;
      case EventImportance.low:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Get event type icon
  IconData get eventTypeIcon {
    switch (eventType) {
      case EventType.meeting:
        return Icons.people;
      case EventType.appointment:
        return Icons.schedule;
      case EventType.deadline:
        return Icons.flag;
      case EventType.social:
        return Icons.celebration;
      case EventType.travel:
        return Icons.flight;
      default:
        return Icons.event;
    }
  }

  /// Create ParsedEvent from JSON data extracted from AI response
  factory ParsedEvent.fromJson(Map<String, dynamic> json, String originalText) {
    // Parse date and time fields
    DateTime? eventDate;
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    DateTime? endDate;

    // Parse start date
    if (json['startDate'] != null) {
      try {
        eventDate = DateTime.parse(json['startDate'] as String);
      } catch (e) {
        print('Failed to parse start date: ${json['startDate']}');
      }
    }

    // Parse start time
    if (json['startTime'] != null) {
      try {
        final timeParts = (json['startTime'] as String).split(':');
        if (timeParts.length >= 2) {
          startTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
        }
      } catch (e) {
        print('Failed to parse start time: ${json['startTime']}');
      }
    }

    // Parse end time
    if (json['endTime'] != null) {
      try {
        final timeParts = (json['endTime'] as String).split(':');
        if (timeParts.length >= 2) {
          endTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
        }
      } catch (e) {
        print('Failed to parse end time: ${json['endTime']}');
      }
    }

    // Parse end date
    if (json['endDate'] != null && json['endDate'] != 'null') {
      try {
        endDate = DateTime.parse(json['endDate'] as String);
      } catch (e) {
        print('Failed to parse end date: ${json['endDate']}');
      }
    }

    // Parse event type
    EventType? eventType;
    if (json['eventType'] != null) {
      try {
        eventType = EventType.values.firstWhere(
          (type) => type.name == json['eventType'],
          orElse: () => EventType.other,
        );
      } catch (e) {
        eventType = EventType.other;
      }
    }

    // Parse importance
    EventImportance? importance;
    if (json['importance'] != null) {
      try {
        importance = EventImportance.values.firstWhere(
          (imp) => imp.name == json['importance'],
          orElse: () => EventImportance.medium,
        );
      } catch (e) {
        importance = EventImportance.medium;
      }
    }

    // Parse suggested reminders
    List<SmartReminder>? suggestedReminders;
    if (json['suggestedReminders'] != null) {
      try {
        final remindersList = json['suggestedReminders'] as List<dynamic>;
        suggestedReminders = remindersList
            .map((reminderJson) {
              try {
                return SmartReminder.fromJson(
                  reminderJson as Map<String, dynamic>,
                );
              } catch (e) {
                print('Failed to parse reminder: $reminderJson');
                return null;
              }
            })
            .where((reminder) => reminder != null)
            .cast<SmartReminder>()
            .toList();
      } catch (e) {
        print('Failed to parse reminders: $e');
      }
    }

    // Parse key points
    List<String>? keyPoints;
    if (json['keyPoints'] != null) {
      try {
        keyPoints = (json['keyPoints'] as List<dynamic>)
            .map((point) => point.toString())
            .toList();
      } catch (e) {
        print('Failed to parse key points: ${json['keyPoints']}');
      }
    }

    // Get confidence, default to 0.5 if not provided or invalid
    double confidence = 0.5;
    if (json['confidence'] != null) {
      try {
        confidence = (json['confidence'] as num).toDouble();
        // Ensure confidence is between 0 and 1
        confidence = confidence.clamp(0.0, 1.0);
      } catch (e) {
        print('Failed to parse confidence: ${json['confidence']}');
      }
    }

    return ParsedEvent(
      title: json['title'] as String?,
      date: eventDate,
      startTime: startTime,
      endTime: endTime,
      location: json['location'] as String?,
      originalText: originalText,
      confidence: confidence,
      metadata: {'aiGenerated': true, 'parsedJson': json},
      // Enhanced AI fields
      summary: json['summary'] as String?,
      description: json['description'] as String?,
      endDate: endDate,
      eventType: eventType,
      importance: importance,
      suggestedReminders: suggestedReminders,
      keyPoints: keyPoints,
    );
  }

  @override
  String toString() {
    return '''ParsedEvent(title: $title, date: $date, startTime: $startTime, endTime: $endTime, location: $location, originalText: $originalText, confidence: $confidence, metadata: $metadata, summary: $summary, description: $description, endDate: $endDate, eventType: $eventType, importance: $importance, suggestedReminders: $suggestedReminders, keyPoints: $keyPoints)''';
  }
}

/// Event types for better categorization
enum EventType { meeting, appointment, deadline, social, travel, other }

/// Event importance levels
enum EventImportance { high, medium, low }

/// Smart reminder with contextual messaging
class SmartReminder {
  final DateTime reminderTime;
  final String message;
  final ReminderType type;

  const SmartReminder({
    required this.reminderTime,
    required this.message,
    required this.type,
  });

  factory SmartReminder.fromJson(Map<String, dynamic> json) {
    return SmartReminder(
      reminderTime: DateTime.parse(json['time'] as String),
      message: json['message'] as String,
      type: ReminderType.values.firstWhere(
        (type) => type.name == (json['type'] as String? ?? 'general'),
        orElse: () => ReminderType.general,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': reminderTime.toIso8601String(),
      'message': message,
      'type': type.name,
    };
  }

  /// Get reminder urgency based on time until event
  ReminderUrgency get urgency {
    final now = DateTime.now();
    final timeUntilReminder = reminderTime.difference(now);

    if (timeUntilReminder.inMinutes <= 15) {
      return ReminderUrgency.immediate;
    } else if (timeUntilReminder.inHours <= 2) {
      return ReminderUrgency.soon;
    } else if (timeUntilReminder.inDays <= 1) {
      return ReminderUrgency.today;
    } else {
      return ReminderUrgency.upcoming;
    }
  }
}

/// Types of reminders
enum ReminderType { preparation, departure, general, followUp }

/// Reminder urgency levels
enum ReminderUrgency { immediate, soon, today, upcoming }
