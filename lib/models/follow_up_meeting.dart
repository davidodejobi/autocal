import 'package:flutter/foundation.dart';

/// Model for follow-up meetings automatically generated from meeting notes
@immutable
class FollowUpMeeting {
  final String id;
  final String originalMeetingId;
  final String title;
  final DateTime suggestedDateTime;
  final List<String> participantEmails;
  final String agenda;
  final List<String> relatedActionItems;
  final String context;
  final bool isScheduled;
  final DateTime createdAt;
  final double confidence;

  const FollowUpMeeting({
    required this.id,
    required this.originalMeetingId,
    required this.title,
    required this.suggestedDateTime,
    required this.participantEmails,
    required this.agenda,
    required this.relatedActionItems,
    required this.context,
    required this.isScheduled,
    required this.createdAt,
    required this.confidence,
  });

  FollowUpMeeting copyWith({
    String? id,
    String? originalMeetingId,
    String? title,
    DateTime? suggestedDateTime,
    List<String>? participantEmails,
    String? agenda,
    List<String>? relatedActionItems,
    String? context,
    bool? isScheduled,
    DateTime? createdAt,
    double? confidence,
  }) {
    return FollowUpMeeting(
      id: id ?? this.id,
      originalMeetingId: originalMeetingId ?? this.originalMeetingId,
      title: title ?? this.title,
      suggestedDateTime: suggestedDateTime ?? this.suggestedDateTime,
      participantEmails: participantEmails ?? this.participantEmails,
      agenda: agenda ?? this.agenda,
      relatedActionItems: relatedActionItems ?? this.relatedActionItems,
      context: context ?? this.context,
      isScheduled: isScheduled ?? this.isScheduled,
      createdAt: createdAt ?? this.createdAt,
      confidence: confidence ?? this.confidence,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalMeetingId': originalMeetingId,
      'title': title,
      'suggestedDateTime': suggestedDateTime.toIso8601String(),
      'participantEmails': participantEmails,
      'agenda': agenda,
      'relatedActionItems': relatedActionItems,
      'context': context,
      'isScheduled': isScheduled,
      'createdAt': createdAt.toIso8601String(),
      'confidence': confidence,
    };
  }

  factory FollowUpMeeting.fromJson(Map<String, dynamic> json) {
    return FollowUpMeeting(
      id: json['id'] as String,
      originalMeetingId: json['originalMeetingId'] as String,
      title: json['title'] as String,
      suggestedDateTime: DateTime.parse(json['suggestedDateTime'] as String),
      participantEmails: List<String>.from(json['participantEmails'] as List),
      agenda: json['agenda'] as String,
      relatedActionItems: List<String>.from(json['relatedActionItems'] as List),
      context: json['context'] as String,
      isScheduled: json['isScheduled'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FollowUpMeeting &&
        other.id == id &&
        other.originalMeetingId == originalMeetingId &&
        other.title == title &&
        other.suggestedDateTime == suggestedDateTime &&
        listEquals(other.participantEmails, participantEmails) &&
        other.agenda == agenda &&
        listEquals(other.relatedActionItems, relatedActionItems) &&
        other.context == context &&
        other.isScheduled == isScheduled &&
        other.createdAt == createdAt &&
        other.confidence == confidence;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      originalMeetingId,
      title,
      suggestedDateTime,
      participantEmails,
      agenda,
      relatedActionItems,
      context,
      isScheduled,
      createdAt,
      confidence,
    );
  }

  @override
  String toString() {
    return 'FollowUpMeeting(id: $id, title: $title, suggestedDateTime: $suggestedDateTime, confidence: $confidence)';
  }
}