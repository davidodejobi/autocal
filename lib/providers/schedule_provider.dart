// import 'package:flutter/material.dart'; // Not needed after removing hardcoded Colors
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/schedule_event.dart';

/// Schedule state management
class ScheduleState {
  final DateTime selectedDate;
  final Map<DateTime, DaySchedule> schedules;
  final bool isLoading;
  final String? error;

  const ScheduleState({
    required this.selectedDate,
    required this.schedules,
    this.isLoading = false,
    this.error,
  });

  ScheduleState copyWith({
    DateTime? selectedDate,
    Map<DateTime, DaySchedule>? schedules,
    bool? isLoading,
    String? error,
  }) {
    return ScheduleState(
      selectedDate: selectedDate ?? this.selectedDate,
      schedules: schedules ?? this.schedules,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get schedule for selected date
  DaySchedule get currentDaySchedule {
    final dateKey = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    return schedules[dateKey] ?? DaySchedule(date: selectedDate, events: []);
  }

  /// Get today's schedule
  DaySchedule get todaySchedule {
    final today = DateTime.now();
    final dateKey = DateTime(today.year, today.month, today.day);
    return schedules[dateKey] ?? DaySchedule(date: today, events: []);
  }
}

/// Schedule provider
class ScheduleNotifier extends StateNotifier<ScheduleState> {
  ScheduleNotifier()
    : super(ScheduleState(selectedDate: DateTime.now(), schedules: {})) {
    _initializeMockData();
  }

  /// Initialize with mock data for demonstration
  void _initializeMockData() {
    final today = DateTime.now();
    final mockSchedules = <DateTime, DaySchedule>{};

    // Create mock data for today and next few days
    for (int i = 0; i < 7; i++) {
      final date = today.add(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);

      mockSchedules[dateKey] = _createMockDaySchedule(date, i);
    }

    state = state.copyWith(schedules: mockSchedules);
  }

  DaySchedule _createMockDaySchedule(DateTime date, int dayOffset) {
    // Return empty schedule - all events will be added dynamically
    final events = <ScheduleEvent>[];
    return DaySchedule(date: date, events: events);
  }

  /// Change selected date
  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  /// Add a new event
  void addEvent(ScheduleEvent event) {
    final dateKey = DateTime(
      event.startTime.year,
      event.startTime.month,
      event.startTime.day,
    );
    final currentSchedule =
        state.schedules[dateKey] ?? DaySchedule(date: dateKey, events: []);

    final updatedEvents = [...currentSchedule.events, event];
    final updatedSchedule = currentSchedule.copyWith(events: updatedEvents);

    final updatedSchedules = Map<DateTime, DaySchedule>.from(state.schedules);
    updatedSchedules[dateKey] = updatedSchedule;

    state = state.copyWith(schedules: updatedSchedules);
  }

  /// Update an existing event
  void updateEvent(ScheduleEvent updatedEvent) {
    final dateKey = DateTime(
      updatedEvent.startTime.year,
      updatedEvent.startTime.month,
      updatedEvent.startTime.day,
    );
    final currentSchedule = state.schedules[dateKey];

    if (currentSchedule == null) return;

    final updatedEvents = currentSchedule.events.map((event) {
      return event.id == updatedEvent.id ? updatedEvent : event;
    }).toList();

    final updatedSchedule = currentSchedule.copyWith(events: updatedEvents);

    final updatedSchedules = Map<DateTime, DaySchedule>.from(state.schedules);
    updatedSchedules[dateKey] = updatedSchedule;

    state = state.copyWith(schedules: updatedSchedules);
  }

  /// Remove an event
  void removeEvent(String eventId, DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    final currentSchedule = state.schedules[dateKey];

    if (currentSchedule == null) return;

    final updatedEvents = currentSchedule.events
        .where((event) => event.id != eventId)
        .toList();
    final updatedSchedule = currentSchedule.copyWith(events: updatedEvents);

    final updatedSchedules = Map<DateTime, DaySchedule>.from(state.schedules);
    updatedSchedules[dateKey] = updatedSchedule;

    state = state.copyWith(schedules: updatedSchedules);
  }

  /// Mark event as completed
  void toggleEventCompletion(String eventId, DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    final currentSchedule = state.schedules[dateKey];

    if (currentSchedule == null) return;

    final updatedEvents = currentSchedule.events.map((event) {
      if (event.id == eventId) {
        return event.copyWith(isCompleted: !event.isCompleted);
      }
      return event;
    }).toList();

    final updatedSchedule = currentSchedule.copyWith(events: updatedEvents);

    final updatedSchedules = Map<DateTime, DaySchedule>.from(state.schedules);
    updatedSchedules[dateKey] = updatedSchedule;

    state = state.copyWith(schedules: updatedSchedules);
  }

  /// Get events for a date range
  List<ScheduleEvent> getEventsInRange(DateTime start, DateTime end) {
    final events = <ScheduleEvent>[];

    for (final schedule in state.schedules.values) {
      if (schedule.date.isAfter(start.subtract(const Duration(days: 1))) &&
          schedule.date.isBefore(end.add(const Duration(days: 1)))) {
        events.addAll(schedule.events);
      }
    }

    events.sort((a, b) => a.startTime.compareTo(b.startTime));
    return events;
  }
}

/// Provider for schedule state
final scheduleProvider = StateNotifierProvider<ScheduleNotifier, ScheduleState>(
  (ref) {
    return ScheduleNotifier();
  },
);
