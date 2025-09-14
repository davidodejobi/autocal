import 'package:flutter/material.dart';

import '../models/schedule_event.dart';
// import '../screens/add_event_screen.dart'; // No longer needed
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import 'schedule_calendar_header.dart';
import 'schedule_event_card.dart';

/// Main schedule view widget that displays the daily timetable
class ScheduleView extends StatefulWidget {
  final DaySchedule daySchedule;
  final Function(DateTime) onDateChanged;
  final Function(ScheduleEvent)? onEventTap;

  const ScheduleView({
    super.key,
    required this.daySchedule,
    required this.onDateChanged,
    this.onEventTap,
  });

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calendar header
        ScheduleCalendarHeader(
          selectedDate: widget.daySchedule.date,
          onDateSelected: widget.onDateChanged,
          totalEventsToday: widget.daySchedule.totalEvents,
        ),

        // Schedule content
        Expanded(child: _buildScheduleContent()),
      ],
    );
  }

  Widget _buildScheduleContent() {
    final events = widget.daySchedule.sortedEvents;

    if (events.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current time indicator if today
          // if (widget.daySchedule.isToday) _buildCurrentTimeIndicator(),

          // Events list
          ...events.map((event) {
            return ScheduleEventCard(
              event: event,
              onTap: () => widget.onEventTap?.call(event),
            );
          }),

          // Bottom padding for scroll
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 48,
                color: AppColors.iconSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Events',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No events scheduled for this day',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            // Events will be added through AI processing or manual entry
          ],
        ),
      ),
    );
  }

  // Current time indicator method removed - no longer used
}

/// Quick schedule overview widget for home screen
class ScheduleOverview extends StatelessWidget {
  final DaySchedule daySchedule;
  final VoidCallback? onViewAll;

  const ScheduleOverview({
    super.key,
    required this.daySchedule,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final nextEvents = daySchedule.sortedEvents.take(3).toList();
    final activeEvent = daySchedule.activeEvents.isNotEmpty
        ? daySchedule.activeEvents.first
        : null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Schedule',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (onViewAll != null)
                TextButton(onPressed: onViewAll, child: const Text('All')),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Current/Next event highlight
          if (activeEvent != null) ...[
            _buildHighlightedEvent(context, activeEvent, isActive: true),
            const SizedBox(height: AppSpacing.md),
          ] else if (daySchedule.nextEvent != null) ...[
            _buildHighlightedEvent(
              context,
              daySchedule.nextEvent!,
              isActive: false,
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Upcoming events
          if (nextEvents.isNotEmpty) ...[
            Text(
              'Upcoming Events',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...nextEvents.map(
              (event) => CompactScheduleEventCard(
                event: event,
                onTap: () {
                  // TODO: Navigate to event details
                },
              ),
            ),
          ] else
            _buildNoEventsMessage(context),
        ],
      ),
    );
  }

  Widget _buildHighlightedEvent(
    BuildContext context,
    ScheduleEvent event, {
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.timeRange,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isActive ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (event.location != null)
                Text(
                  event.location!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),

          const SizedBox(width: AppSpacing.md),

          // Event details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (event.subtitle != null)
                  Text(
                    event.subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Status indicator
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Now',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoEventsMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 32,
            color: AppColors.iconSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No events today',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
