import 'dart:convert';
import 'dart:developer' show log;

/// Utility class for extracting JSON from AI responses with multiple fallback strategies
class AIResponseParser {
  /// Extract JSON from AI response using multiple strategies
  static Map<String, dynamic>? getJsonContent(String messageContent) {
    try {
      // Check if message content exists
      if (messageContent.isEmpty) {
        log('Empty message content provided');
        return null;
      }

      log('Raw message content: $messageContent');

      // Strategy 1: Try to parse the entire response as JSON
      try {
        final decoded = json.decode(messageContent);
        log('Direct JSON parsing successful');
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (e) {
        log('Direct JSON parsing failed, trying extraction: $e');
      }

      // Strategy 2: Remove markdown code blocks if present
      String cleanedContent = messageContent;

      // Remove markdown json code blocks
      if (cleanedContent.contains('```json')) {
        final startIndex =
            cleanedContent.indexOf('```json') + 7; // Length of '```json'
        final endIndex = cleanedContent.indexOf('```', startIndex);
        if (endIndex != -1) {
          cleanedContent = cleanedContent
              .substring(startIndex, endIndex)
              .trim();
          log('Extracted from markdown: $cleanedContent');

          try {
            final decoded = json.decode(cleanedContent);
            log('Markdown extraction successful');
            if (decoded is Map<String, dynamic>) {
              return decoded;
            }
          } catch (e) {
            log('Markdown extraction failed: $e');
          }
        }
      }

      // Strategy 3: Use regex to find JSON objects with improved pattern
      final jsonRegex = RegExp(r'(\{[\s\S]*?\})', multiLine: true);
      final matches = jsonRegex.allMatches(messageContent);

      for (final match in matches) {
        final jsonStr = match.group(1);
        if (jsonStr != null) {
          try {
            final decoded = json.decode(jsonStr);
            log('Regex extraction successful');
            if (decoded is Map<String, dynamic>) {
              return decoded;
            }
          } catch (e) {
            log('Regex extraction failed for match: $e');
            // Continue to next match
          }
        }
      }

      // Strategy 4: Find opening and closing braces manually with better logic
      int braceCount = 0;
      int startIndex = -1;
      int endIndex = -1;

      for (int i = 0; i < messageContent.length; i++) {
        final char = messageContent[i];
        if (char == '{') {
          if (braceCount == 0) {
            startIndex = i;
          }
          braceCount++;
        } else if (char == '}') {
          braceCount--;
          if (braceCount == 0 && startIndex != -1) {
            endIndex = i + 1;
            break;
          }
        }
      }

      if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
        final jsonStr = messageContent.substring(startIndex, endIndex);
        try {
          final decoded = json.decode(jsonStr);
          log('Manual brace extraction successful');
          if (decoded is Map<String, dynamic>) {
            return decoded;
          }
        } catch (e) {
          log('Manual brace extraction failed: $e');
        }
      }

      // Strategy 5: Try to clean and fix common JSON issues
      final cleanedJson = _cleanJsonString(messageContent);
      if (cleanedJson != null) {
        try {
          final decoded = json.decode(cleanedJson);
          log('Cleaned JSON parsing successful');
          if (decoded is Map<String, dynamic>) {
            return decoded;
          }
        } catch (e) {
          log('Cleaned JSON parsing failed: $e');
        }
      }

      log('All JSON extraction methods failed');
      return null;
    } catch (e) {
      log('getJsonContent error: $e');
      return null;
    }
  }

  /// Clean and fix common JSON formatting issues
  static String? _cleanJsonString(String content) {
    try {
      // Look for potential JSON content
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}');

      if (jsonStart == -1 || jsonEnd == -1 || jsonEnd <= jsonStart) {
        return null;
      }

      String jsonStr = content.substring(jsonStart, jsonEnd + 1);

      // Clean up common issues
      jsonStr = jsonStr
          // Remove control characters
          .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '')
          // Remove trailing commas before closing braces/brackets
          .replaceAll(RegExp(r',\s*}'), '}')
          .replaceAll(RegExp(r',\s*]'), ']')
          // Fix malformed confidence values like "0.0-1.0" to "0.8"
          .replaceAll(
            RegExp(r'"confidence":\s*"?0\.0-1\.0"?'),
            '"confidence": 0.8',
          )
          .replaceAll(
            RegExp(r'"confidence":\s*"?[0-9]+\.[0-9]+-[0-9]+\.[0-9]+"?'),
            '"confidence": 0.8',
          )
          // Fix malformed eventType values like "meeting|other" to "meeting"
          .replaceAll(
            RegExp(r'"eventType":\s*"([^"|]+)\|[^"]*"'),
            '"eventType": "\$1"',
          )
          // Remove confidence field entirely if it exists (since we don't need it)
          .replaceAll(RegExp(r',?\s*"confidence":\s*[^,}]+'), '')
          // Fix unescaped quotes in strings (basic attempt)
          .replaceAll(RegExp(r'(?<!\\)"(?![,\]\}:\s])'), '\\"')
          // Remove extra whitespace
          .trim();

      return jsonStr;
    } catch (e) {
      log('Error cleaning JSON string: $e');
      return null;
    }
  }

  /// Extract JSON from AI response and parse it using a model's fromJson method
  static T? parseAIResponse<T>(
    String aiResponse,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      final jsonData = getJsonContent(aiResponse);
      if (jsonData == null) {
        log('Failed to extract JSON from AI response');
        return null;
      }

      log('Extracted JSON data: $jsonData');
      return fromJson(jsonData);
    } catch (e) {
      log('Error parsing AI response to model: $e');
      return null;
    }
  }

  /// Validate if a string contains valid JSON
  static bool isValidJson(String jsonString) {
    try {
      json.decode(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Extract multiple JSON objects from a single response
  static List<Map<String, dynamic>> extractMultipleJsonObjects(String content) {
    final results = <Map<String, dynamic>>[];

    try {
      // Find all JSON-like patterns
      final jsonRegex = RegExp(
        r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}',
        multiLine: true,
      );
      final matches = jsonRegex.allMatches(content);

      for (final match in matches) {
        final jsonStr = match.group(0);
        if (jsonStr != null) {
          try {
            final decoded = json.decode(jsonStr);
            if (decoded is Map<String, dynamic>) {
              results.add(decoded);
            }
          } catch (e) {
            // Skip invalid JSON
            continue;
          }
        }
      }
    } catch (e) {
      log('Error extracting multiple JSON objects: $e');
    }

    return results;
  }
}
