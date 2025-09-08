// Reminder model for event notifications
class Reminder {
  final String id;
  final Duration beforeEvent;
  final String? customMessage;
  final bool isCustom; // Pro feature

  const Reminder({
    required this.id,
    required this.beforeEvent,
    this.customMessage,
    this.isCustom = false,
  });

  Reminder copyWith({
    String? id,
    Duration? beforeEvent,
    String? customMessage,
    bool? isCustom,
  }) {
    return Reminder(
      id: id ?? this.id,
      beforeEvent: beforeEvent ?? this.beforeEvent,
      customMessage: customMessage ?? this.customMessage,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}