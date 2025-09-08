import 'action_item.dart';

// Processed notes model for AI-extracted information
class ProcessedNotes {
  final List<ActionItem> actionItems;
  final List<String> participants;
  final List<String> keyDecisions;
  final String summary;
  final double confidence;

  const ProcessedNotes({
    required this.actionItems,
    required this.participants,
    required this.keyDecisions,
    required this.summary,
    required this.confidence,
  });

  ProcessedNotes copyWith({
    List<ActionItem>? actionItems,
    List<String>? participants,
    List<String>? keyDecisions,
    String? summary,
    double? confidence,
  }) {
    return ProcessedNotes(
      actionItems: actionItems ?? this.actionItems,
      participants: participants ?? this.participants,
      keyDecisions: keyDecisions ?? this.keyDecisions,
      summary: summary ?? this.summary,
      confidence: confidence ?? this.confidence,
    );
  }
}