import 'processed_notes.dart';

// Meeting notes model for Pro feature
class MeetingNotes {
  final String id;
  final String rawNotes;
  final ProcessedNotes? processedNotes;
  final DateTime createdAt;
  final bool isProcessed;

  const MeetingNotes({
    required this.id,
    required this.rawNotes,
    this.processedNotes,
    required this.createdAt,
    this.isProcessed = false,
  });

  MeetingNotes copyWith({
    String? id,
    String? rawNotes,
    ProcessedNotes? processedNotes,
    DateTime? createdAt,
    bool? isProcessed,
  }) {
    return MeetingNotes(
      id: id ?? this.id,
      rawNotes: rawNotes ?? this.rawNotes,
      processedNotes: processedNotes ?? this.processedNotes,
      createdAt: createdAt ?? this.createdAt,
      isProcessed: isProcessed ?? this.isProcessed,
    );
  }
}