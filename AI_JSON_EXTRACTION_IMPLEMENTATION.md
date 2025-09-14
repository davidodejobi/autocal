# AI JSON Extraction Implementation

## Overview

I've implemented a robust JSON extraction system for handling AI responses that uses multiple fallback strategies to extract JSON data from various AI response formats, then uses standard `fromJson` methods for model parsing.

## Key Components

### 1. `AIResponseParser` Utility (`lib/utils/ai_response_parser.dart`)

A comprehensive utility class that handles JSON extraction with 5 different strategies:

#### Strategy 1: Direct JSON Parsing

- Attempts to parse the entire response as JSON
- Works for clean JSON responses

#### Strategy 2: Markdown Code Block Extraction

- Extracts JSON from markdown code blocks (`json ... `)
- Common format when AI wraps JSON in markdown

#### Strategy 3: Regex Pattern Matching

- Uses improved regex to find JSON objects
- Handles multiple JSON objects in a single response

#### Strategy 4: Manual Brace Matching

- Intelligently finds matching opening/closing braces
- Handles nested JSON structures properly

#### Strategy 5: JSON Cleanup and Repair

- Fixes common JSON formatting issues:
  - Removes control characters
  - Fixes trailing commas
  - Repairs basic syntax errors

### 2. Enhanced `ParsedEvent` Model (`lib/models/parsed_event.dart`)

Added a robust `fromJson` factory constructor that:

- Handles all field parsing with proper error handling
- Provides sensible defaults for missing/invalid data
- Maintains backwards compatibility

### 3. Updated AI Service (`lib/services/ai_leap_service.dart`)

Refactored `_parseEnhancedAIResponse` method to:

- Use the new `AIResponseParser.getJsonContent()` for extraction
- Use `ParsedEvent.fromJson()` for model creation
- Remove duplicate parsing logic
- Maintain existing smart reminder generation

## Usage Examples

### Basic Usage

```dart
// Extract JSON and parse to model
final jsonData = AIResponseParser.getJsonContent(aiResponse);
if (jsonData != null) {
  final event = ParsedEvent.fromJson(jsonData, originalText);
}
```

### Generic Parser Method

```dart
// One-line parsing with error handling
final event = AIResponseParser.parseAIResponse<ParsedEvent>(
  aiResponse,
  (json) => ParsedEvent.fromJson(json, originalText),
);
```

## Supported AI Response Formats

The system can handle:

1. **Clean JSON responses**
2. **Markdown-wrapped JSON** (`json ... `)
3. **JSON with extra text** before/after
4. **Malformed JSON** with common syntax errors
5. **Multiple JSON objects** in a single response

## Benefits

### 1. Robustness

- Multiple fallback strategies ensure high success rate
- Graceful handling of malformed AI responses
- Comprehensive error logging for debugging

### 2. Maintainability

- Centralized JSON extraction logic
- Standard `fromJson` pattern for all models
- Clear separation of concerns

### 3. Extensibility

- Easy to add new parsing strategies
- Generic `parseAIResponse` method works with any model
- Support for multiple JSON objects in one response

### 4. Performance

- Strategies ordered by likelihood of success
- Early exit on successful parsing
- Minimal overhead for clean responses

## Integration Points

The system integrates seamlessly with existing code:

- `AILeapService.parseImageWithAI()` uses the new extraction
- All existing AI response handling is improved
- No breaking changes to existing APIs

## Testing

See `lib/utils/ai_response_example.dart` for comprehensive examples and test cases demonstrating various AI response formats that the system can handle.

## Future Enhancements

Potential improvements:

1. Add support for YAML responses
2. Implement response format auto-detection
3. Add response validation against schemas
4. Support for streaming JSON parsing
5. Custom extraction strategies per AI model
