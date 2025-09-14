import 'dart:developer' show log;

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/parsed_event.dart';
import '../models/schedule_event.dart';

// Service for managing event creation and calendar integration
class EventManager {
  static final EventManager _instance = EventManager._internal();
  factory EventManager() => _instance;
  EventManager._internal();

  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  /// Convert ParsedEvent to ScheduleEvent
  ScheduleEvent convertToScheduleEvent(ParsedEvent parsedEvent) {
    // Create start and end DateTime objects
    DateTime startDateTime;
    DateTime endDateTime;

    if (parsedEvent.date != null) {
      // Use the parsed date
      final baseDate = parsedEvent.date!;

      if (parsedEvent.startTime != null) {
        startDateTime = DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          parsedEvent.startTime!.hour,
          parsedEvent.startTime!.minute,
        );
      } else {
        // Default to 9 AM if no start time
        startDateTime = DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          9,
          0,
        );
      }

      if (parsedEvent.endTime != null) {
        final endDate = parsedEvent.endDate ?? baseDate;
        endDateTime = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          parsedEvent.endTime!.hour,
          parsedEvent.endTime!.minute,
        );
      } else {
        // Default to 1 hour duration
        endDateTime = startDateTime.add(const Duration(hours: 1));
      }
    } else {
      // Default to today if no date parsed
      final now = DateTime.now();
      startDateTime = DateTime(now.year, now.month, now.day, 9, 0);
      endDateTime = startDateTime.add(const Duration(hours: 1));
    }

    // Determine color based on event type and importance
    Color eventColor = _getEventColor(
      parsedEvent.eventType,
      parsedEvent.importance,
    );

    // Determine priority based on importance
    int priority = _getEventPriority(parsedEvent.importance);

    return ScheduleEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: parsedEvent.title ?? 'Untitled Event',
      subtitle: parsedEvent.summary,
      startTime: startDateTime,
      endTime: endDateTime,
      location: parsedEvent.location,
      color: eventColor,
      priority: priority,
      description: parsedEvent.description,
      isRecurring: false,
      isCompleted: false,
    );
  }

  /// Get event color based on type and importance
  Color _getEventColor(EventType? eventType, EventImportance? importance) {
    // High importance events get red tint
    if (importance == EventImportance.high) {
      return Colors.red.shade400;
    }

    // Color based on event type
    switch (eventType) {
      case EventType.meeting:
        return Colors.blue.shade400;
      case EventType.appointment:
        return Colors.green.shade400;
      case EventType.deadline:
        return Colors.orange.shade400;
      case EventType.social:
        return Colors.purple.shade400;
      case EventType.travel:
        return Colors.teal.shade400;
      default:
        return Colors.indigo.shade400;
    }
  }

  /// Get event priority based on importance
  int _getEventPriority(EventImportance? importance) {
    switch (importance) {
      case EventImportance.high:
        return 3;
      case EventImportance.medium:
        return 2;
      case EventImportance.low:
        return 1;
      default:
        return 2; // Default to medium priority
    }
  }

  /// Request calendar permission
  Future<bool> requestCalendarPermission() async {
    try {
      log('📅 Requesting calendar permission...');

      final status = await Permission.calendar.status;
      if (status.isGranted) {
        log('✅ Calendar permission already granted');
        return true;
      }

      if (status.isDenied) {
        final result = await Permission.calendar.request();
        final granted = result.isGranted;
        log(
          granted
              ? '✅ Calendar permission granted'
              : '❌ Calendar permission denied',
        );
        return granted;
      }

      log('❌ Calendar permission permanently denied');
      return false;
    } catch (e) {
      log('❌ Error requesting calendar permission: $e');
      return false;
    }
  }

  /// Get available calendars
  Future<List<Calendar>> getCalendars() async {
    try {
      log('📅 Fetching available calendars...');

      final permissionGranted = await requestCalendarPermission();
      if (!permissionGranted) {
        log('❌ Calendar permission not granted');
        return [];
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();

      if (calendarsResult.isSuccess && calendarsResult.data != null) {
        final calendars = calendarsResult.data!
            .where((cal) => cal.isReadOnly != null && !cal.isReadOnly!)
            .toList();

        log('✅ Found ${calendars.length} writable calendars');
        return calendars;
      } else {
        log('❌ Failed to retrieve calendars: ${calendarsResult.errors}');
        return [];
      }
    } catch (e) {
      log('❌ Error getting calendars: $e');
      return [];
    }
  }

  /// Save event to device calendar
  Future<bool> saveToDeviceCalendar(ScheduleEvent scheduleEvent) async {
    try {
      log('💾 Calendar integration temporarily disabled for stability');
      log('📝 Event will be saved locally: ${scheduleEvent.title}');

      // TODO: Implement proper calendar integration with correct API
      // For now, we'll save locally and return false to indicate calendar save failed
      // but this is non-critical

      return false; // Indicates calendar save failed, but app continues
    } catch (e) {
      log('❌ Error in calendar save attempt: $e');
      return false;
    }
  }

  /// Validate event data
  ValidationResult validateEventData(ScheduleEvent event) {
    final errors = <String>[];

    // Validate title
    if (event.title.trim().isEmpty) {
      errors.add('Event title is required');
    }

    // Validate times
    if (event.endTime.isBefore(event.startTime)) {
      errors.add('End time must be after start time');
    }

    // Validate duration (not too long)
    final duration = event.endTime.difference(event.startTime);
    if (duration.inDays > 7) {
      errors.add('Event duration cannot exceed 7 days');
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Check if daily limit is reached for free users
  bool checkDailyLimit() {
    // TODO: Implement daily limit checking based on subscription status
    // For now, return false (no limit)
    return false;
  }
}

// Validation result model
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  const ValidationResult({required this.isValid, required this.errors});
}

// Provider for EventManager
final eventManagerProvider = Provider<EventManager>((ref) {
  return EventManager();
});
