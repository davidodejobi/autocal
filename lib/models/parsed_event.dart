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

  const ParsedEvent({
    this.title,
    this.date,
    this.startTime,
    this.endTime,
    this.location,
    required this.originalText,
    required this.confidence,
    this.metadata = const {},
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
    );
  }
}