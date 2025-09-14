import 'package:flutter/material.dart';

import '../models/schedule_event.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';

/// Widget for displaying a single schedule event
class ScheduleEventCard extends StatelessWidget {
  final ScheduleEvent event;
  final VoidCallback? onTap;
  final bool showTimeSlot;
  final bool isCompact;

  const ScheduleEventCard({
    super.key,
    required this.event,
    this.onTap,
    this.showTimeSlot = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time slot
            if (showTimeSlot) _buildTimeSlot(context),

            // Event card
            Expanded(child: _buildEventCard(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlot(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.only(right: AppSpacing.md, top: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: event.isActive ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          Text(
            '${event.endTime.hour}:${event.endTime.minute.toString().padLeft(2, '0')}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context) {
    final cardColor = event.color ?? _getPriorityColor(event.priority);

    return Container(
      padding: EdgeInsets.all(isCompact ? AppSpacing.sm : AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: event.isActive
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.border,
          width: event.isActive ? 2 : 1,
        ),
        boxShadow: event.isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with priority indicator and status
          Row(
            children: [
              // Priority/Subject indicator
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Event number/position
              if (!isCompact)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${event.priority}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cardColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              const Spacer(),

              // Location/Room
              if (event.location != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    event.location!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: isCompact ? AppSpacing.xs : AppSpacing.sm),

          // Event title
          Text(
            event.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: event.isCompleted
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
              decoration: event.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),

          // Subtitle/Description
          if (event.subtitle != null && !isCompact) ...[
            const SizedBox(height: 4),
            Text(
              event.subtitle!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Status indicators
          if (!isCompact &&
              (event.isActive || event.isUpcoming || event.isCompleted)) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildStatusIndicators(context),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIndicators(BuildContext context) {
    return Row(
      children: [
        if (event.isActive)
          _buildStatusChip(
            context,
            'Now',
            AppColors.success,
            Icons.play_circle_outline,
          ),
        if (event.isUpcoming && !event.isActive)
          _buildStatusChip(context, 'Soon', AppColors.warning, Icons.schedule),
        if (event.isCompleted)
          _buildStatusChip(
            context,
            'Completed',
            AppColors.textSecondary,
            Icons.check_circle_outline,
          ),
      ],
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    String label,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return AppColors.success;
      case 2:
        return AppColors.info;
      case 3:
        return AppColors.warning;
      case 4:
        return AppColors.error;
      case 5:
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }
}

/// Compact version for list views
class CompactScheduleEventCard extends StatelessWidget {
  final ScheduleEvent event;
  final VoidCallback? onTap;

  const CompactScheduleEventCard({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ScheduleEventCard(
      event: event,
      onTap: onTap,
      showTimeSlot: false,
      isCompact: true,
    );
  }
}
