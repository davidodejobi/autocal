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

  @override
  String toString() {
    return '''ParsedEvent(title: $title, date: $date, startTime: $startTime, endTime: $endTime, location: $location, originalText: $originalText, confidence: $confidence, metadata: $metadata, summary: $summary, description: $description, endDate: $endDate, eventType: $eventType, importance: $importance, suggestedReminders: $suggestedReminders, keyPoints: $keyPoints)''';
  }
}

/// Event types for better categorization
enum EventType {
  meeting,
  appointment,
  deadline,
  social,
  travel,
  other,
}

/// Event importance levels
enum EventImportance {
  high,
  medium,
  low,
}

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
enum ReminderType {
  preparation,
  departure,
  general,
  followUp,
}

/// Reminder urgency levels
enum ReminderUrgency {
  immediate,
  soon,
  today,
  upcoming,
}