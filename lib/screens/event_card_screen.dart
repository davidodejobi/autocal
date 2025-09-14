import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/parsed_event.dart';
import '../providers/app_state_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';

// Screen for displaying and editing parsed event information
class EventCardScreen extends HookConsumerWidget {
  final ParsedEvent parsedEvent;

  const EventCardScreen({super.key, required this.parsedEvent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final titleController = useTextEditingController(
      text: parsedEvent.title ?? '',
    );
    final locationController = useTextEditingController(
      text: parsedEvent.location ?? '',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Event'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Status Badge
            _buildAIStatusBadge(context),
            const SizedBox(height: AppSpacing.sectionSpacing),

            // AI Summary (if available)
            if (parsedEvent.summary != null) _buildAISummarySection(context),
            const SizedBox(height: AppSpacing.md),

            // Event Title
            _buildEventTitleField(context, titleController),
            const SizedBox(height: AppSpacing.md),

            // Date & Time
            _buildDateTimeSection(context),
            const SizedBox(height: AppSpacing.md),

            // Location
            _buildLocationSection(context, locationController),
            const SizedBox(height: AppSpacing.md),

            // Travel Time (Pro Feature)
            if (appState.subscriptionStatus.isPro)
              _buildTravelTimeSection(context),
            const SizedBox(height: AppSpacing.md),

            // Related Resources (Pro Feature)
            if (appState.subscriptionStatus.isPro)
              _buildRelatedResourcesSection(context),
            const SizedBox(height: AppSpacing.md),

            // Smart Reminders (Pro Feature)
            if (appState.subscriptionStatus.isPro &&
                parsedEvent.suggestedReminders != null)
              _buildSmartRemindersSection(context),
            const SizedBox(height: AppSpacing.md),

            // Key Points (if available)
            if (parsedEvent.keyPoints != null &&
                parsedEvent.keyPoints!.isNotEmpty)
              _buildKeyPointsSection(context),
            const SizedBox(height: AppSpacing.md),

            // Source Text
            _buildSourceTextSection(context),
            const SizedBox(height: AppSpacing.sectionSpacing),

            // Action Buttons
            _buildActionButtons(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildAIStatusBadge(BuildContext context) {
    final confidence = parsedEvent.confidence;
    final confidenceText = '${(confidence * 100).round()}% confidence';
    final hasEnhancedFeatures =
        parsedEvent.summary != null ||
        parsedEvent.suggestedReminders != null ||
        parsedEvent.keyPoints != null;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.getConfidenceColor(
              confidence,
            ).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.getConfidenceColor(
                confidence,
              ).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.psychology,
                color: AppColors.getConfidenceColor(confidence),
                size: 16,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'AI Analysis',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.getConfidenceColor(confidence),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                confidenceText,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.getConfidenceColor(confidence),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (hasEnhancedFeatures) ...[
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'ENHANCED',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEventTitleField(
    BuildContext context,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          style: Theme.of(context).textTheme.titleLarge,
          decoration: InputDecoration(
            hintText: 'Event title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.md),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date & Time',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            _formatDateTime(parsedEvent),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(
    BuildContext context,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Event location',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.md),
          ),
        ),
      ],
    );
  }

  Widget _buildTravelTimeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Travel Time',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(Icons.directions_car, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Travel time calculation needed',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // TODO: Set alert
                },
                child: const Text('Set Alert'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedResourcesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related Resources',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Related resources would be populated dynamically based on AI analysis
      ],
    );
  }

  // Resource item widget removed - no longer used

  Widget _buildSourceTextSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Source Text',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            parsedEvent.originalText,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildAISummarySection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'AI Summary',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            parsedEvent.summary ?? '',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSmartRemindersSection(BuildContext context) {
    final reminders = parsedEvent.suggestedReminders ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Smart Reminders',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'AI',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...reminders
            .take(3)
            .map((reminder) => _buildReminderItem(context, reminder)),
        if (reminders.length > 3)
          TextButton(
            onPressed: () {
              // TODO: Show all reminders
            },
            child: Text('View all ${reminders.length} reminders'),
          ),
      ],
    );
  }

  Widget _buildReminderItem(BuildContext context, SmartReminder reminder) {
    final timeUntilEvent = reminder.reminderTime.difference(DateTime.now());
    final isUpcoming = timeUntilEvent.isNegative;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            _getReminderIcon(reminder.type),
            color: isUpcoming ? AppColors.textSecondary : AppColors.primary,
            size: 16,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatReminderTime(reminder.reminderTime),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isUpcoming
                        ? AppColors.textSecondary
                        : AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  reminder.message,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyPointsSection(BuildContext context) {
    final keyPoints = parsedEvent.keyPoints ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Points',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...keyPoints.map(
          (point) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    point,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getReminderIcon(ReminderType type) {
    switch (type) {
      case ReminderType.preparation:
        return Icons.checklist;
      case ReminderType.departure:
        return Icons.directions_walk;
      case ReminderType.followUp:
        return Icons.follow_the_signs;
      default:
        return Icons.notifications;
    }
  }

  String _formatDateTime(ParsedEvent event) {
    if (event.date == null) {
      return 'Date and time to be determined';
    }

    final date = event.date!;
    final startTime = event.startTime;
    final endTime = event.endTime;

    // Format date
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

    String dateStr = '${months[date.month - 1]} ${date.day}, ${date.year}';

    // Add time if available
    if (startTime != null) {
      String timeStr = _formatTimeOfDay(startTime);
      if (endTime != null) {
        timeStr += ' - ${_formatTimeOfDay(endTime)}';
      }
      dateStr += ', $timeStr';
    }

    return dateStr;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }

  String _formatReminderTime(DateTime reminderTime) {
    final now = DateTime.now();
    final difference = reminderTime.difference(now);

    if (difference.isNegative) {
      return 'Past reminder';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} before';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} before';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} before';
    }
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // TODO: Save event with smart reminders
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    parsedEvent.suggestedReminders != null
                        ? 'Event saved with ${parsedEvent.suggestedReminders!.length} smart reminders!'
                        : 'Event saved!',
                  ),
                ),
              );
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Save Event'),
          ),
        ),
      ],
    );
  }
}
