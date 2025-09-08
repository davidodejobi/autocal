import 'package:flutter/material.dart';
import '../models/parsed_event.dart';

// Service for parsing dates, times, and locations from text
class TextParserService {
  static final TextParserService _instance = TextParserService._internal();
  factory TextParserService() => _instance;
  TextParserService._internal();

  /// Parse event information from shared text
  Future<ParsedEvent> parseEventFromText(String text) async {
    // TODO: Implement text parsing logic
    return ParsedEvent(
      originalText: text,
      confidence: 0.0,
    );
  }

  /// Extract dates from text
  List<DateTime> extractDates(String text) {
    // TODO: Implement date extraction
    return [];
  }

  /// Extract times from text
  List<TimeOfDay> extractTimes(String text) {
    // TODO: Implement time extraction
    return [];
  }

  /// Extract locations from text
  List<String> extractLocations(String text) {
    // TODO: Implement location extraction
    return [];
  }
}