import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/parsed_event.dart';
import '../services/text_parser_service.dart';
import '../services/ai_leap_service.dart';

/// Provider for text parsing service
final textParserServiceProvider = Provider<TextParserService>((ref) {
  return TextParserService();
});

/// Provider for enhanced text parsing with AI integration
final textParsingProvider = Provider<TextParsingService>((ref) {
  final textParser = ref.read(textParserServiceProvider);
  final aiService = ref.read(aiLeapServiceProvider);
  return TextParsingService(textParser, aiService);
});

/// Enhanced text parsing service that integrates AI and regex parsing
class TextParsingService {
  final TextParserService _textParser;
  final AILeapService _aiService;

  TextParsingService(this._textParser, this._aiService);

  /// Parse text with AI enhancement when available, fallback to regex
  Future<ParsedEvent> parseText(String text) async {
    if (text.trim().isEmpty) {
      return ParsedEvent(
        originalText: text,
        confidence: 0.0,
      );
    }

    // Try AI-enhanced parsing first if AI service is ready
    try {
      if (_aiService.isReady) {
        final aiResult = await _aiService.parseTextWithAI(text);
        if (aiResult != null && aiResult.confidence > 0.7) {
          return aiResult;
        }
      }
    } catch (e) {
      print('AI parsing failed, using fallback: $e');
    }

    // Fallback to regex-based parsing
    return await _textParser.parseEventFromText(text);
  }

  /// Check if AI enhancement is available
  bool get isAIReady => _aiService.isReady;

  /// Get current AI model info
  AIModelInfo? get currentAIModel => _aiService.currentModel;
}