// Action item model for meeting notes
class ActionItem {
  final String id;
  final String description;
  final String? assignee;
  final DateTime? dueDate;
  final bool isCompleted;

  const ActionItem({
    required this.id,
    required this.description,
    this.assignee,
    this.dueDate,
    this.isCompleted = false,
  });

  ActionItem copyWith({
    String? id,
    String? description,
    String? assignee,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return ActionItem(
      id: id ?? this.id,
      description: description ?? this.description,
      assignee: assignee ?? this.assignee,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}