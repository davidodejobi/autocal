import 'reminder.dart';
import 'meeting_notes.dart';

// Main event model for calendar events
class Event {
  final String id;
  final String title;
  final DateTime startDateTime;
  final DateTime? endDateTime;
  final String? location;
  final String? description;
  final List<Reminder> reminders;
  final MeetingNotes? meetingNotes; // Pro feature
  final DateTime createdAt;

  const Event({
    required this.id,
    required this.title,
    required this.startDateTime,
    this.endDateTime,
    this.location,
    this.description,
    this.reminders = const [],
    this.meetingNotes,
    required this.createdAt,
  });

  Event copyWith({
    String? id,
    String? title,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? location,
    String? description,
    List<Reminder>? reminders,
    MeetingNotes? meetingNotes,
    DateTime? createdAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      location: location ?? this.location,
      description: description ?? this.description,
      reminders: reminders ?? this.reminders,
      meetingNotes: meetingNotes ?? this.meetingNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}