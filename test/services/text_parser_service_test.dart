import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocal/services/text_parser_service.dart';

void main() {
  group('TextParserService Date Parsing', () {
    late TextParserService parser;

    setUp(() {
      parser = TextParserService();
    });

    group('Date Extraction', () {
      test('should parse MM/DD/YYYY format', () {
        final dates = parser.extractDates('Meeting on 12/25/2024');
        expect(dates.length, 1);
        expect(dates.first, DateTime(2024, 12, 25));
      });

      test('should parse MM-DD-YYYY format', () {
        final dates = parser.extractDates('Event scheduled for 03-15-2024');
        expect(dates.length, 1);
        expect(dates.first, DateTime(2024, 3, 15));
      });

      test('should parse MM.DD.YYYY format', () {
        final dates = parser.extractDates('Deadline is 06.30.2024');
        expect(dates.length, 1);
        expect(dates.first, DateTime(2024, 6, 30));
      });

      test('should parse YYYY-MM-DD ISO format', () {
        final dates = parser.extractDates('Conference on 2024-09-15');
        expect(dates.length, 1);
        expect(dates.first, DateTime(2024, 9, 15));
      });

      test('should parse Month DD, YYYY format', () {
        final dates = parser.extractDates('Party on January 15, 2024');
        expect(dates.length, 1);
        expect(dates.first, DateTime(2024, 1, 15));
      });

      test('should parse DD Month YYYY format', () {
        final dates = parser.extractDates('Meeting on 20 March 2024');
        expect(dates.length, 1);
        expect(dates.first, DateTime(2024, 3, 20));
      });

      test('should parse relative dates', () {
        final today = DateTime.now();
        final todayNormalized = DateTime(today.year, today.month, today.day);
        final tomorrow = todayNormalized.add(const Duration(days: 1));

        final todayDates = parser.extractDates('Meeting today');
        expect(todayDates.length, 1);
        expect(todayDates.first, todayNormalized);

        final tomorrowDates = parser.extractDates('Call tomorrow');
        expect(tomorrowDates.length, 1);
        expect(tomorrowDates.first, tomorrow);
      });

      test('should parse day of week', () {
        final dates = parser.extractDates('Meeting next Monday');
        expect(dates.length, 1);
        expect(dates.first.weekday, DateTime.monday);
      });

      test('should handle multiple dates in text', () {
        final dates = parser.extractDates('Meeting on 12/25/2024 and follow-up on January 15, 2025');
        expect(dates.length, 2);
        expect(dates.contains(DateTime(2024, 12, 25)), true);
        expect(dates.contains(DateTime(2025, 1, 15)), true);
      });

      test('should handle invalid dates gracefully', () {
        final dates = parser.extractDates('Invalid date 13/45/2024');
        expect(dates.length, 0);
      });

      test('should remove duplicate dates', () {
        final dates = parser.extractDates('Meeting on 12/25/2024 and reminder on December 25, 2024');
        expect(dates.length, 1);
        expect(dates.first, DateTime(2024, 12, 25));
      });
    });

    group('Time Extraction', () {
      test('should parse 12-hour format with AM/PM', () {
        final times = parser.extractTimes('Meeting at 2:30 PM');
        expect(times.length, 1);
        expect(times.first, const TimeOfDay(hour: 14, minute: 30));
      });

      test('should parse 12-hour format without minutes', () {
        final times = parser.extractTimes('Call at 9 AM');
        expect(times.length, 1);
        expect(times.first, const TimeOfDay(hour: 9, minute: 0));
      });

      test('should parse 24-hour format', () {
        final times = parser.extractTimes('Meeting at 14:30');
        expect(times.length, 1);
        expect(times.first, const TimeOfDay(hour: 14, minute: 30));
      });

      test('should parse noon and midnight', () {
        final noonTimes = parser.extractTimes('Lunch at noon');
        expect(noonTimes.length, 1);
        expect(noonTimes.first, const TimeOfDay(hour: 12, minute: 0));

        final midnightTimes = parser.extractTimes('Event starts at midnight');
        expect(midnightTimes.length, 1);
        expect(midnightTimes.first, const TimeOfDay(hour: 0, minute: 0));
      });

      test('should handle 12 AM and 12 PM correctly', () {
        final amTimes = parser.extractTimes('Meeting at 12 AM');
        expect(amTimes.length, 1);
        expect(amTimes.first, const TimeOfDay(hour: 0, minute: 0));

        final pmTimes = parser.extractTimes('Lunch at 12 PM');
        expect(pmTimes.length, 1);
        expect(pmTimes.first, const TimeOfDay(hour: 12, minute: 0));
      });

      test('should handle multiple times in text', () {
        final times = parser.extractTimes('Meeting from 9:00 AM to 10:30 AM');
        expect(times.length, 2);
        expect(times[0], const TimeOfDay(hour: 9, minute: 0));
        expect(times[1], const TimeOfDay(hour: 10, minute: 30));
      });

      test('should handle invalid times gracefully', () {
        final times = parser.extractTimes('Invalid time 25:70');
        expect(times.length, 0);
      });

      test('should remove duplicate times', () {
        final times = parser.extractTimes('Meeting at 2:30 PM and reminder at 14:30');
        expect(times.length, 1);
        expect(times.first, const TimeOfDay(hour: 14, minute: 30));
      });
    });

    group('Edge Cases', () {
      test('should handle empty text', () {
        final dates = parser.extractDates('');
        final times = parser.extractTimes('');
        expect(dates.length, 0);
        expect(times.length, 0);
      });

      test('should handle text with no dates or times', () {
        final dates = parser.extractDates('This is just regular text without dates');
        final times = parser.extractTimes('This is just regular text without times');
        expect(dates.length, 0);
        expect(times.length, 0);
      });

      test('should handle mixed case text', () {
        final dates = parser.extractDates('MEETING ON JANUARY 15, 2024');
        final times = parser.extractTimes('CALL AT 2:30 PM');
        expect(dates.length, 1);
        expect(times.length, 1);
      });

      test('should handle text with numbers that are not dates/times', () {
        final dates = parser.extractDates('Room 123 has 45 chairs and costs \$200');
        final times = parser.extractTimes('Room 123 has 45 chairs and costs \$200');
        expect(dates.length, 0);
        expect(times.length, 0);
      });

      test('should handle leap year dates', () {
        final dates = parser.extractDates('Meeting on February 29, 2024');
        expect(dates.length, 1);
        expect(dates.first, DateTime(2024, 2, 29));
      });

      test('should reject invalid leap year dates', () {
        final dates = parser.extractDates('Meeting on February 29, 2023');
        expect(dates.length, 0);
      });
    });

    group('Location Extraction', () {
      test('should parse street addresses', () {
        final locations = parser.extractLocations('Meeting at 123 Main Street');
        expect(locations.length, 1);
        expect(locations.first, '123 Main Street');
      });

      test('should parse venue names with "at"', () {
        final locations = parser.extractLocations('Dinner at Starbucks Coffee');
        expect(locations.length, 1);
        expect(locations.first, 'Starbucks Coffee');
      });

      test('should parse city and state', () {
        final locations = parser.extractLocations('Conference in San Francisco, CA');
        expect(locations.length, 1);
        expect(locations.first, 'San Francisco, CA');
      });

      test('should parse room numbers', () {
        final locations = parser.extractLocations('Meeting in conference room A-123');
        expect(locations.length, 1);
        expect(locations.first, 'Room A-123');
      });

      test('should parse building and room combinations', () {
        final locations = parser.extractLocations('Event at Smith Building room 205');
        expect(locations.length, 1);
        expect(locations.first, 'Smith Building, Room 205');
      });

      test('should parse common venue types', () {
        final locations = parser.extractLocations('Party at Central Park');
        expect(locations.length, 1);
        expect(locations.first, 'Central Park');
      });

      test('should parse addresses with zip codes', () {
        final locations = parser.extractLocations('Office in New York, NY 10001');
        expect(locations.length, 1);
        expect(locations.first, 'New York, NY 10001');
      });

      test('should parse online meeting indicators', () {
        final locations = parser.extractLocations('Call on Zoom');
        expect(locations.length, 1);
        expect(locations.first, 'Online (zoom)');
      });

      test('should handle multiple locations', () {
        final locations = parser.extractLocations('Meeting at 123 Main St and backup at Central Park');
        expect(locations.length, 2);
        expect(locations.contains('123 Main St'), true);
        expect(locations.contains('Central Park'), true);
      });

      test('should filter out invalid locations', () {
        final locations = parser.extractLocations('Meeting in the morning at a good time');
        expect(locations.length, 0);
      });

      test('should remove duplicate locations', () {
        final locations = parser.extractLocations('Meeting at Central Park and backup at central park');
        expect(locations.length, 1);
        expect(locations.first, 'Central Park');
      });

      test('should handle various address formats', () {
        final locations1 = parser.extractLocations('Event at 456 Oak Avenue');
        expect(locations1.length, 1);
        expect(locations1.first, '456 Oak Avenue');

        final locations2 = parser.extractLocations('Meeting at 789 Pine Blvd');
        expect(locations2.length, 1);
        expect(locations2.first, '789 Pine Blvd');
      });

      test('should parse hotel and restaurant names', () {
        final locations = parser.extractLocations('Dinner at Grand Hotel Restaurant');
        expect(locations.length, 1);
        expect(locations.first, 'Grand Hotel Restaurant');
      });

      test('should handle case insensitive matching', () {
        final locations = parser.extractLocations('MEETING AT STARBUCKS COFFEE');
        expect(locations.length, 1);
        expect(locations.first, 'STARBUCKS COFFEE');
      });
    });

    group('Complete Event Parsing', () {
      test('should parse complete event with date, time, and location', () async {
        final event = await parser.parseEventFromText('Meeting on January 15, 2024 at 2:30 PM at Starbucks Coffee');
        
        expect(event.date, DateTime(2024, 1, 15));
        expect(event.startTime, const TimeOfDay(hour: 14, minute: 30));
        expect(event.location, 'Starbucks Coffee');
        expect(event.confidence, greaterThan(0.5));
        expect(event.originalText, 'Meeting on January 15, 2024 at 2:30 PM at Starbucks Coffee');
      });

      test('should parse event with multiple times as start and end', () async {
        final event = await parser.parseEventFromText('Conference from 9:00 AM to 5:00 PM on March 20, 2024');
        
        expect(event.date, DateTime(2024, 3, 20));
        expect(event.startTime, const TimeOfDay(hour: 9, minute: 0));
        expect(event.endTime, const TimeOfDay(hour: 17, minute: 0));
        expect(event.confidence, greaterThan(0.5));
      });

      test('should extract title by removing parsed elements', () async {
        final event = await parser.parseEventFromText('Team standup meeting tomorrow at 10 AM in conference room A');
        
        expect(event.title, isNotNull);
        expect(event.title!.toLowerCase(), contains('team'));
        expect(event.title!.toLowerCase(), contains('standup'));
        expect(event.confidence, greaterThan(0.3));
      });

      test('should handle text with only date', () async {
        final event = await parser.parseEventFromText('Important deadline on December 25, 2024');
        
        expect(event.date, DateTime(2024, 12, 25));
        expect(event.startTime, isNull);
        expect(event.location, isNull);
        expect(event.title, isNotNull);
        expect(event.confidence, greaterThan(0.2));
      });

      test('should handle text with only time', () async {
        final event = await parser.parseEventFromText('Call at 3:30 PM');
        
        expect(event.date, isNull);
        expect(event.startTime, const TimeOfDay(hour: 15, minute: 30));
        expect(event.location, isNull);
        expect(event.title, isNotNull);
        expect(event.confidence, greaterThan(0.2));
      });

      test('should handle text with only location', () async {
        final event = await parser.parseEventFromText('Meeting at Central Park');
        
        expect(event.date, isNull);
        expect(event.startTime, isNull);
        expect(event.location, 'Central Park');
        expect(event.title, isNotNull);
        expect(event.confidence, greaterThan(0.2));
      });

      test('should return low confidence for text with no parseable elements', () async {
        final event = await parser.parseEventFromText('This is just regular text without any event information');
        
        expect(event.date, isNull);
        expect(event.startTime, isNull);
        expect(event.location, isNull);
        expect(event.confidence, equals(0.0));
      });

      test('should handle empty text', () async {
        final event = await parser.parseEventFromText('');
        
        expect(event.date, isNull);
        expect(event.startTime, isNull);
        expect(event.location, isNull);
        expect(event.confidence, equals(0.0));
        expect(event.originalText, '');
      });

      test('should include metadata about parsing results', () async {
        final event = await parser.parseEventFromText('Meeting on January 15, 2024 at 2:30 PM at Starbucks Coffee');
        
        expect(event.metadata['dateMatches'], greaterThan(0));
        expect(event.metadata['timeMatches'], greaterThan(0));
        expect(event.metadata['locationMatches'], greaterThan(0));
        expect(event.metadata['dateConfidence'], greaterThan(0.0));
        expect(event.metadata['timeConfidence'], greaterThan(0.0));
        expect(event.metadata['locationConfidence'], greaterThan(0.0));
      });

      test('should handle complex real-world text', () async {
        final event = await parser.parseEventFromText(
          'Hey, don\'t forget about the team lunch tomorrow at 12:30 PM at the new Italian restaurant on Main Street. We need to discuss the Q4 planning.'
        );
        
        expect(event.date, isNotNull);
        expect(event.startTime, const TimeOfDay(hour: 12, minute: 30));
        expect(event.location, isNotNull);
        expect(event.title, isNotNull);
        expect(event.confidence, greaterThan(0.4));
      });

      test('should prioritize higher confidence matches', () async {
        final event = await parser.parseEventFromText('Meeting on 2024-01-15 and also on January 20, 2024');
        
        // Should pick the higher confidence date format
        expect(event.date, isNotNull);
        expect(event.confidence, greaterThan(0.5));
      });
    });
  });
}