import 'package:flutter/material.dart';
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
    // Create different schedules for different days
    final events = <ScheduleEvent>[];

    if (dayOffset == 0) {
      // Today - full schedule like in the image
      events.addAll([
        ScheduleEvent(
          id: '1',
          title: 'Russian Literature',
          subtitle: 'Read pages 78-81. Review highlighted terms. Repeat...',
          startTime: DateTime(date.year, date.month, date.day, 8, 0),
          endTime: DateTime(date.year, date.month, date.day, 8, 45),
          location: 'Room 209',
          priority: 4,
          color: Colors.green,
        ),
        ScheduleEvent(
          id: '2',
          title: 'English Language',
          subtitle:
              'Write an essay on the lesson topic, at least 10 sentences.',
          startTime: DateTime(date.year, date.month, date.day, 9, 0),
          endTime: DateTime(date.year, date.month, date.day, 9, 45),
          location: 'Room 307',
          priority: 2,
          color: Colors.blue,
        ),
        ScheduleEvent(
          id: '3',
          title: 'Physical Education',
          subtitle: 'Sports uniform required',
          startTime: DateTime(date.year, date.month, date.day, 10, 0),
          endTime: DateTime(date.year, date.month, date.day, 10, 45),
          location: 'Gym',
          priority: 1,
          color: Colors.orange,
        ),
        ScheduleEvent(
          id: '4',
          title: 'Mathematics',
          subtitle: 'Algebra test',
          startTime: DateTime(date.year, date.month, date.day, 11, 0),
          endTime: DateTime(date.year, date.month, date.day, 11, 45),
          location: 'Room 105',
          priority: 5,
          color: Colors.red,
        ),
        ScheduleEvent(
          id: '5',
          title: 'History',
          subtitle: 'Topic: World War II',
          startTime: DateTime(date.year, date.month, date.day, 12, 0),
          endTime: DateTime(date.year, date.month, date.day, 12, 45),
          location: 'Room 201',
          priority: 3,
          color: Colors.purple,
        ),
        ScheduleEvent(
          id: '6',
          title: 'Chemistry',
          subtitle: 'Laboratory work #3',
          startTime: DateTime(date.year, date.month, date.day, 13, 30),
          endTime: DateTime(date.year, date.month, date.day, 14, 15),
          location: 'Room 301',
          priority: 4,
          color: Colors.teal,
        ),
        ScheduleEvent(
          id: '7',
          title: 'Computer Science',
          subtitle: 'Python programming',
          startTime: DateTime(date.year, date.month, date.day, 14, 25),
          endTime: DateTime(date.year, date.month, date.day, 15, 10),
          location: 'Room 401',
          priority: 3,
          color: Colors.indigo,
        ),
      ]);
    } else if (dayOffset == 1) {
      // Tomorrow - lighter schedule
      events.addAll([
        ScheduleEvent(
          id: 't1',
          title: 'Physics',
          subtitle: 'Mechanics. Newton\'s Laws',
          startTime: DateTime(date.year, date.month, date.day, 8, 0),
          endTime: DateTime(date.year, date.month, date.day, 8, 45),
          location: 'Room 205',
          priority: 3,
          color: Colors.cyan,
        ),
        ScheduleEvent(
          id: 't2',
          title: 'Russian Language',
          subtitle: 'Syntax and punctuation',
          startTime: DateTime(date.year, date.month, date.day, 9, 0),
          endTime: DateTime(date.year, date.month, date.day, 9, 45),
          location: 'Room 209',
          priority: 4,
          color: Colors.green,
        ),
        ScheduleEvent(
          id: 't3',
          title: 'Biology',
          subtitle: 'Cell structure',
          startTime: DateTime(date.year, date.month, date.day, 10, 0),
          endTime: DateTime(date.year, date.month, date.day, 10, 45),
          location: 'Room 302',
          priority: 2,
          color: Colors.lightGreen,
        ),
      ]);
    } else if (dayOffset % 2 == 0) {
      // Even days - some events
      events.addAll([
        ScheduleEvent(
          id: 'e${dayOffset}1',
          title: 'Mathematics',
          startTime: DateTime(date.year, date.month, date.day, 9, 0),
          endTime: DateTime(date.year, date.month, date.day, 9, 45),
          location: 'Room 105',
          priority: 4,
          color: Colors.red,
        ),
        ScheduleEvent(
          id: 'e${dayOffset}2',
          title: 'Geography',
          startTime: DateTime(date.year, date.month, date.day, 10, 0),
          endTime: DateTime(date.year, date.month, date.day, 10, 45),
          location: 'Room 203',
          priority: 2,
          color: Colors.brown,
        ),
      ]);
    }
    // Odd days (except tomorrow) will be empty

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
