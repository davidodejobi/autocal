import '../models/action_item.dart';
import '../models/processed_notes.dart';

// Service for offline AI processing of meeting notes (Pro feature)
class MeetingNotesAIService {
  static final MeetingNotesAIService _instance =
      MeetingNotesAIService._internal();
  factory MeetingNotesAIService() => _instance;
  MeetingNotesAIService._internal();

  /// Process meeting notes with AI
  Future<ProcessedNotes> processNotes(String notes) async {
    try {
      // final aiService = AILeapService();

      // Try AI processing first
      // final aiResult = await aiService.processMeetingNotes(notes);
      // if (aiResult != null) {
      //   return aiResult;
      // }

      // Fallback to basic processing
      return _basicProcessing(notes);
    } catch (e) {
      print('AI processing failed, using fallback: $e');
      return _basicProcessing(notes);
    }
  }

  /// Basic fallback processing without AI
  ProcessedNotes _basicProcessing(String notes) {
    // Simple keyword-based extraction as fallback
    final actionItems = <ActionItem>[];
    final participants = <String>[];
    final keyDecisions = <String>[];

    // Look for action items
    final actionRegex = RegExp(
      r'(?:action|todo|task|follow.?up):\s*(.+)',
      caseSensitive: false,
    );
    final actionMatches = actionRegex.allMatches(notes);

    for (final match in actionMatches) {
      actionItems.add(
        ActionItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          description: match.group(1)?.trim() ?? '',
          assignee: null,
          dueDate: null,
          isCompleted: false,
        ),
      );
    }

    // Look for participants (names with @ or mentioned)
    final participantRegex = RegExp(
      r'@(\w+)|(?:with|from|by)\s+([A-Z][a-z]+\s+[A-Z][a-z]+)',
      caseSensitive: false,
    );
    final participantMatches = participantRegex.allMatches(notes);

    for (final match in participantMatches) {
      final name = match.group(1) ?? match.group(2);
      if (name != null && !participants.contains(name)) {
        participants.add(name);
      }
    }

    // Look for decisions
    final decisionRegex = RegExp(
      r'(?:decided|agreed|resolved):\s*(.+)',
      caseSensitive: false,
    );
    final decisionMatches = decisionRegex.allMatches(notes);

    for (final match in decisionMatches) {
      final decision = match.group(1)?.trim();
      if (decision != null) {
        keyDecisions.add(decision);
      }
    }

    return ProcessedNotes(
      actionItems: actionItems,
      participants: participants,
      keyDecisions: keyDecisions,
      summary: notes.length > 200 ? '${notes.substring(0, 200)}...' : notes,
      confidence: 0.6, // Lower confidence for basic processing
    );
  }

  /// Extract action items from notes
  List<ActionItem> extractActionItems(String notes) {
    // TODO: Implement action item extraction
    return [];
  }

  /// Identify participants in meeting notes
  List<String> identifyParticipants(String notes) {
    // TODO: Implement participant identification
    return [];
  }

  /// Summarize key decisions from notes
  List<String> summarizeKeyDecisions(String notes) {
    // TODO: Implement key decision summarization
    return [];
  }

  /// Load AI model for processing
  Future<bool> loadAIModel() async {
    // TODO: Implement AI model loading
    return false;
  }
}
