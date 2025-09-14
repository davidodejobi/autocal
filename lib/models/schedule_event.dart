import 'package:flutter/material.dart';

/// Represents a scheduled event/lesson in the timetable
class ScheduleEvent {
  final String id;
  final String title;
  final String? subtitle;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final Color? color;
  final int priority; // 1-5, higher number = higher priority
  final String? description;
  final List<String> tags;
  final bool isCompleted;
  final bool isRecurring;

  const ScheduleEvent({
    required this.id,
    required this.title,
    this.subtitle,
    required this.startTime,
    required this.endTime,
    this.location,
    this.color,
    this.priority = 1,
    this.description,
    this.tags = const [],
    this.isCompleted = false,
    this.isRecurring = false,
  });

  /// Duration of the event
  Duration get duration => endTime.difference(startTime);

  /// Check if the event is currently active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Check if the event is upcoming (starts within next hour)
  bool get isUpcoming {
    final now = DateTime.now();
    final oneHourFromNow = now.add(const Duration(hours: 1));
    return startTime.isAfter(now) && startTime.isBefore(oneHourFromNow);
  }

  /// Format time range as string (e.g., "8:00 — 8:45")
  String get timeRange {
    final startFormatted =
        '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
    final endFormatted =
        '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$startFormatted — $endFormatted';
  }

  /// Create a copy with updated fields
  ScheduleEvent copyWith({
    String? id,
    String? title,
    String? subtitle,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    Color? color,
    int? priority,
    String? description,
    List<String>? tags,
    bool? isCompleted,
    bool? isRecurring,
  }) {
    return ScheduleEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      color: color ?? this.color,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      isCompleted: isCompleted ?? this.isCompleted,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleEvent &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ScheduleEvent{id: $id, title: $title, timeRange: $timeRange}';
  }
}

/// Represents a day's schedule
class DaySchedule {
  final DateTime date;
  final List<ScheduleEvent> events;
  final String? dayNote;

  const DaySchedule({required this.date, required this.events, this.dayNote});

  /// Get events sorted by start time
  List<ScheduleEvent> get sortedEvents {
    final sortedList = List<ScheduleEvent>.from(events);
    sortedList.sort((a, b) => a.startTime.compareTo(b.startTime));
    return sortedList;
  }

  /// Get currently active events
  List<ScheduleEvent> get activeEvents {
    return events.where((event) => event.isActive).toList();
  }

  /// Get upcoming events
  List<ScheduleEvent> get upcomingEvents {
    return events.where((event) => event.isUpcoming).toList();
  }

  /// Get next event
  ScheduleEvent? get nextEvent {
    final now = DateTime.now();
    final futureEvents = events
        .where((event) => event.startTime.isAfter(now))
        .toList();

    if (futureEvents.isEmpty) return null;

    futureEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
    return futureEvents.first;
  }

  /// Check if this is today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Format date as string
  String get formattedDate {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}';
  }

  /// Get total events count
  int get totalEvents => events.length;

  /// Create a copy with updated fields
  DaySchedule copyWith({
    DateTime? date,
    List<ScheduleEvent>? events,
    String? dayNote,
  }) {
    return DaySchedule(
      date: date ?? this.date,
      events: events ?? this.events,
      dayNote: dayNote ?? this.dayNote,
    );
  }
}
