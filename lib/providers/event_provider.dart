import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/parsed_event.dart';
import '../models/event.dart';

// Event state data class
class EventState {
  final ParsedEvent? currentParsedEvent;
  final Event? currentEvent;
  final bool isEditing;
  final bool isProcessing;

  const EventState({
    this.currentParsedEvent,
    this.currentEvent,
    required this.isEditing,
    required this.isProcessing,
  });

  EventState copyWith({
    ParsedEvent? currentParsedEvent,
    Event? currentEvent,
    bool? isEditing,
    bool? isProcessing,
  }) {
    return EventState(
      currentParsedEvent: currentParsedEvent ?? this.currentParsedEvent,
      currentEvent: currentEvent ?? this.currentEvent,
      isEditing: isEditing ?? this.isEditing,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

// Notifier for event-specific state management
class EventNotifier extends Notifier<EventState> {
  @override
  EventState build() {
    return const EventState(
      isEditing: false,
      isProcessing: false,
    );
  }

  // Set parsed event from shared content
  void setParsedEvent(ParsedEvent parsedEvent) {
    state = state.copyWith(
      currentParsedEvent: parsedEvent,
      isEditing: false,
    );
  }

  // Start editing mode
  void startEditing() {
    state = state.copyWith(isEditing: true);
  }

  // Update parsed event during editing
  void updateParsedEvent(ParsedEvent updatedEvent) {
    state = state.copyWith(currentParsedEvent: updatedEvent);
  }

  // Set processing state
  void setProcessing(bool processing) {
    state = state.copyWith(isProcessing: processing);
  }

  // Create final event from parsed data
  void createEvent(Event event) {
    state = state.copyWith(
      currentEvent: event,
      isEditing: false,
    );
  }

  // Clear current event data
  void clearCurrentEvent() {
    state = const EventState(
      isEditing: false,
      isProcessing: false,
    );
  }
}

// Provider for the event state
final eventProvider = NotifierProvider<EventNotifier, EventState>(() {
  return EventNotifier();
});