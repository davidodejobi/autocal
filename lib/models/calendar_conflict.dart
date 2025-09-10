import 'package:flutter/foundation.dart';

/// Model for calendar conflicts and resolution suggestions
@immutable
class CalendarConflict {
  final String id;
  final String newEventId;
  final String conflictingEventId;
  final String conflictingEventTitle;
  final DateTime conflictStart;
  final DateTime conflictEnd;
  final ConflictType type;
  final List<TimeSlotSuggestion> suggestions;
  final String? location;
  final int? travelTimeMinutes;
  final DateTime detectedAt;

  const CalendarConflict({
    required this.id,
    required this.newEventId,
    required this.conflictingEventId,
    required this.conflictingEventTitle,
    required this.conflictStart,
    required this.conflictEnd,
    required this.type,
    required this.suggestions,
    this.location,
    this.travelTimeMinutes,
    required this.detectedAt,
  });

  CalendarConflict copyWith({
    String? id,
    String? newEventId,
    String? conflictingEventId,
    String? conflictingEventTitle,
    DateTime? conflictStart,
    DateTime? conflictEnd,
    ConflictType? type,
    List<TimeSlotSuggestion>? suggestions,
    String? location,
    int? travelTimeMinutes,
    DateTime? detectedAt,
  }) {
    return CalendarConflict(
      id: id ?? this.id,
      newEventId: newEventId ?? this.newEventId,
      conflictingEventId: conflictingEventId ?? this.conflictingEventId,
      conflictingEventTitle: conflictingEventTitle ?? this.conflictingEventTitle,
      conflictStart: conflictStart ?? this.conflictStart,
      conflictEnd: conflictEnd ?? this.conflictEnd,
      type: type ?? this.type,
      suggestions: suggestions ?? this.suggestions,
      location: location ?? this.location,
      travelTimeMinutes: travelTimeMinutes ?? this.travelTimeMinutes,
      detectedAt: detectedAt ?? this.detectedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'newEventId': newEventId,
      'conflictingEventId': conflictingEventId,
      'conflictingEventTitle': conflictingEventTitle,
      'conflictStart': conflictStart.toIso8601String(),
      'conflictEnd': conflictEnd.toIso8601String(),
      'type': type.name,
      'suggestions': suggestions.map((s) => s.toJson()).toList(),
      'location': location,
      'travelTimeMinutes': travelTimeMinutes,
      'detectedAt': detectedAt.toIso8601String(),
    };
  }

  factory CalendarConflict.fromJson(Map<String, dynamic> json) {
    return CalendarConflict(
      id: json['id'] as String,
      newEventId: json['newEventId'] as String,
      conflictingEventId: json['conflictingEventId'] as String,
      conflictingEventTitle: json['conflictingEventTitle'] as String,
      conflictStart: DateTime.parse(json['conflictStart'] as String),
      conflictEnd: DateTime.parse(json['conflictEnd'] as String),
      type: ConflictType.values.byName(json['type'] as String),
      suggestions: (json['suggestions'] as List)
          .map((s) => TimeSlotSuggestion.fromJson(s as Map<String, dynamic>))
          .toList(),
      location: json['location'] as String?,
      travelTimeMinutes: json['travelTimeMinutes'] as int?,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarConflict &&
        other.id == id &&
        other.newEventId == newEventId &&
        other.conflictingEventId == conflictingEventId &&
        other.conflictingEventTitle == conflictingEventTitle &&
        other.conflictStart == conflictStart &&
        other.conflictEnd == conflictEnd &&
        other.type == type &&
        listEquals(other.suggestions, suggestions) &&
        other.location == location &&
        other.travelTimeMinutes == travelTimeMinutes &&
        other.detectedAt == detectedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      newEventId,
      conflictingEventId,
      conflictingEventTitle,
      conflictStart,
      conflictEnd,
      type,
      suggestions,
      location,
      travelTimeMinutes,
      detectedAt,
    );
  }

  @override
  String toString() {
    return 'CalendarConflict(id: $id, type: $type, conflictingEventTitle: $conflictingEventTitle)';
  }
}

/// Types of calendar conflicts
enum ConflictType {
  directOverlap,
  insufficientTravelTime,
  backToBackWithoutBuffer,
  recurringConflict,
}

/// Model for suggested alternative time slots
@immutable
class TimeSlotSuggestion {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final double confidence;
  final String reason;
  final bool requiresRescheduling;
  final List<String> affectedEventIds;

  const TimeSlotSuggestion({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.confidence,
    required this.reason,
    required this.requiresRescheduling,
    required this.affectedEventIds,
  });

  TimeSlotSuggestion copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    double? confidence,
    String? reason,
    bool? requiresRescheduling,
    List<String>? affectedEventIds,
  }) {
    return TimeSlotSuggestion(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      confidence: confidence ?? this.confidence,
      reason: reason ?? this.reason,
      requiresRescheduling: requiresRescheduling ?? this.requiresRescheduling,
      affectedEventIds: affectedEventIds ?? this.affectedEventIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'confidence': confidence,
      'reason': reason,
      'requiresRescheduling': requiresRescheduling,
      'affectedEventIds': affectedEventIds,
    };
  }

  factory TimeSlotSuggestion.fromJson(Map<String, dynamic> json) {
    return TimeSlotSuggestion(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      confidence: (json['confidence'] as num).toDouble(),
      reason: json['reason'] as String,
      requiresRescheduling: json['requiresRescheduling'] as bool,
      affectedEventIds: List<String>.from(json['affectedEventIds'] as List),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeSlotSuggestion &&
        other.id == id &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.confidence == confidence &&
        other.reason == reason &&
        other.requiresRescheduling == requiresRescheduling &&
        listEquals(other.affectedEventIds, affectedEventIds);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      startTime,
      endTime,
      confidence,
      reason,
      requiresRescheduling,
      affectedEventIds,
    );
  }

  @override
  String toString() {
    return 'TimeSlotSuggestion(id: $id, startTime: $startTime, confidence: $confidence)';
  }
}