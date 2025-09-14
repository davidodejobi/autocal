import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/schedule_event.dart';
import '../providers/schedule_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';

/// Screen for adding new events to the schedule
class AddEventScreen extends HookConsumerWidget {
  final DateTime? selectedDate;

  const AddEventScreen({super.key, this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController();
    final subtitleController = useTextEditingController();
    final locationController = useTextEditingController();
    final descriptionController = useTextEditingController();

    final selectedEventDate = useState(selectedDate ?? DateTime.now());
    final startTime = useState(TimeOfDay.now());
    final endTime = useState(
      TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute),
    );
    final selectedColor = useState(Colors.blue);
    final priority = useState(1);
    final isRecurring = useState(false);

    final formKey = useMemoized(() => GlobalKey<FormState>());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Event'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => _saveEvent(
              context,
              ref,
              formKey,
              titleController,
              subtitleController,
              locationController,
              descriptionController,
              selectedEventDate.value,
              startTime.value,
              endTime.value,
              selectedColor.value,
              priority.value,
              isRecurring.value,
            ),
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Title
              _buildSectionTitle(context, 'Event Details'),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title',
                  hintText: 'Enter event title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an event title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Subtitle/Description
              TextFormField(
                controller: subtitleController,
                decoration: const InputDecoration(
                  labelText: 'Subtitle (Optional)',
                  hintText: 'Brief description',
                  prefixIcon: Icon(Icons.abc),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.md),

              // Location
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (Optional)',
                  hintText: 'Room, address, or venue',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Date and Time
              _buildSectionTitle(context, 'Date & Time'),
              const SizedBox(height: AppSpacing.sm),

              // Date Picker
              _buildDateTimeTile(
                context,
                'Date',
                _formatDate(selectedEventDate.value),
                Icons.calendar_today,
                () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedEventDate.value,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    selectedEventDate.value = picked;
                  }
                },
              ),
              const SizedBox(height: AppSpacing.sm),

              // Time Pickers
              Row(
                children: [
                  Expanded(
                    child: _buildDateTimeTile(
                      context,
                      'Start Time',
                      startTime.value.format(context),
                      Icons.access_time,
                      () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: startTime.value,
                        );
                        if (picked != null) {
                          startTime.value = picked;
                          // Auto-adjust end time to be 1 hour later
                          final newEndTime = TimeOfDay(
                            hour: (picked.hour + 1) % 24,
                            minute: picked.minute,
                          );
                          endTime.value = newEndTime;
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildDateTimeTile(
                      context,
                      'End Time',
                      endTime.value.format(context),
                      Icons.access_time_filled,
                      () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: endTime.value,
                        );
                        if (picked != null) {
                          endTime.value = picked;
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Event Properties
              _buildSectionTitle(context, 'Event Properties'),
              const SizedBox(height: AppSpacing.sm),

              // Priority
              _buildPrioritySelector(context, priority),
              const SizedBox(height: AppSpacing.md),

              // Color
              _buildColorSelector(context, selectedColor),
              const SizedBox(height: AppSpacing.md),

              // Recurring
              _buildSwitchTile(
                context,
                'Recurring Event',
                'Repeat this event',
                Icons.repeat,
                isRecurring.value,
                (value) => isRecurring.value = value,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Additional Notes
              _buildSectionTitle(context, 'Additional Notes'),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add any additional details',
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDateTimeTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.iconSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySelector(
    BuildContext context,
    ValueNotifier<int> priority,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Priority',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: List.generate(5, (index) {
              final priorityLevel = index + 1;
              final isSelected = priority.value == priorityLevel;

              return Expanded(
                child: GestureDetector(
                  onTap: () => priority.value = priorityLevel,
                  child: Container(
                    margin: EdgeInsets.only(
                      right: index < 4 ? AppSpacing.xs : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$priorityLevel',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelector(
    BuildContext context,
    ValueNotifier<Color> selectedColor,
  ) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Color',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: colors.map((color) {
              final isSelected = selectedColor.value == color;

              return GestureDetector(
                onTap: () => selectedColor.value = color,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.textPrimary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _saveEvent(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    TextEditingController titleController,
    TextEditingController subtitleController,
    TextEditingController locationController,
    TextEditingController descriptionController,
    DateTime selectedDate,
    TimeOfDay startTime,
    TimeOfDay endTime,
    Color selectedColor,
    int priority,
    bool isRecurring,
  ) {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Validate that end time is after start time
    final startDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      startTime.hour,
      startTime.minute,
    );
    final endDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      endTime.hour,
      endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime) ||
        endDateTime.isAtSameMomentAs(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Create the new event
    final newEvent = ScheduleEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text.trim(),
      subtitle: subtitleController.text.trim().isEmpty
          ? null
          : subtitleController.text.trim(),
      startTime: startDateTime,
      endTime: endDateTime,
      location: locationController.text.trim().isEmpty
          ? null
          : locationController.text.trim(),
      color: selectedColor,
      priority: priority,
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      isRecurring: isRecurring,
    );

    // Add the event to the schedule
    ref.read(scheduleProvider.notifier).addEvent(newEvent);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Event "${newEvent.title}" added successfully'),
        backgroundColor: AppColors.success,
      ),
    );

    // Navigate back
    Navigator.of(context).pop();
  }
}
