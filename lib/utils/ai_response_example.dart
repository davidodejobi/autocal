import '../models/parsed_event.dart';
import 'ai_response_parser.dart';

/// Example demonstrating how to use the new JSON extraction approach
class AIResponseExample {
  /// Example of parsing a ParsedEvent from AI response
  static ParsedEvent? parseEventFromAIResponse(
    String aiResponse,
    String originalText,
  ) {
    // Method 1: Direct extraction and parsing
    final jsonData = AIResponseParser.getJsonContent(aiResponse);
    if (jsonData != null) {
      return ParsedEvent.fromJson(jsonData, originalText);
    }
    return null;
  }

  /// Example of using the generic parser method
  static ParsedEvent? parseEventUsingGenericParser(
    String aiResponse,
    String originalText,
  ) {
    // Method 2: Using the generic parseAIResponse method
    return AIResponseParser.parseAIResponse<ParsedEvent>(
      aiResponse,
      (json) => ParsedEvent.fromJson(json, originalText),
    );
  }

  /// Example AI responses that the parser can handle
  static const List<String> exampleAIResponses = [
    // Standard JSON response
    '''
    {
      "title": "Team Meeting",
      "startDate": "2024-01-15",
      "startTime": "10:00",
      "endTime": "11:00",
      "location": "Conference Room A",
      "description": "Weekly team sync meeting",
      "eventType": "meeting",
      "importance": "high",
      "confidence": 0.9
    }
    ''',

    // JSON wrapped in markdown
    '''
    Here's the extracted event information:
    
    ```json
    {
      "title": "Doctor Appointment",
      "startDate": "2024-01-20",
      "startTime": "14:30",
      "location": "Medical Center",
      "eventType": "appointment",
      "importance": "high",
      "confidence": 0.85
    }
    ```
    
    This appears to be a medical appointment.
    ''',

    // JSON with extra text
    '''
    I found an event in the image. The extracted information is:
    
    {
      "title": "Birthday Party",
      "startDate": "2024-02-10",
      "startTime": "18:00",
      "endTime": "22:00",
      "location": "123 Main St",
      "description": "Sarah's birthday celebration",
      "eventType": "social",
      "importance": "medium",
      "confidence": 0.8,
      "keyPoints": ["Bring gift", "RSVP required"]
    }
    
    Hope this helps!
    ''',

    // Malformed JSON that the parser can handle
    '''
    {
      "title": "Project Deadline",
      "startDate": "2024-03-01",
      "eventType": "deadline",
      "importance": "high",
      "confidence": 0.95,
      "description": "Final submission for Project Alpha",
    }
    ''',
  ];

  /// Test the parser with example responses
  static void testParser() {
    print('Testing AI Response Parser...\n');

    for (int i = 0; i < exampleAIResponses.length; i++) {
      final response = exampleAIResponses[i];
      print('--- Example ${i + 1} ---');
      print('Input: ${response.substring(0, 100)}...');

      final parsedEvent = parseEventFromAIResponse(response, 'Test input');

      if (parsedEvent != null) {
        print('✅ Successfully parsed:');
        print('   Title: ${parsedEvent.title}');
        print('   Date: ${parsedEvent.date}');
        print('   Type: ${parsedEvent.eventType}');
        print('   Confidence: ${parsedEvent.confidence}');
      } else {
        print('❌ Failed to parse');
      }
      print('');
    }
  }
}
