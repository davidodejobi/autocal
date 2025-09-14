import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';

/// Calendar header widget showing date selection and week view
class ScheduleCalendarHeader extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final int totalEventsToday;

  const ScheduleCalendarHeader({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.totalEventsToday = 0,
  });

  @override
  State<ScheduleCalendarHeader> createState() => _ScheduleCalendarHeaderState();
}

class _ScheduleCalendarHeaderState extends State<ScheduleCalendarHeader> {
  late PageController _pageController;
  late DateTime _currentWeekStart;

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _getWeekStart(widget.selectedDate);
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getWeekStart(DateTime date) {
    // Get Monday as the start of the week
    final daysFromMonday = (date.weekday - 1) % 7;
    return date.subtract(Duration(days: daysFromMonday));
  }

  List<DateTime> _getWeekDates(DateTime weekStart) {
    return List.generate(7, (index) => weekStart.add(Duration(days: index)));
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date and events count
          _buildDateHeader(),
          const SizedBox(height: AppSpacing.md),

          // Week view calendar
          _buildWeekView(),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    final isToday = _isToday(widget.selectedDate);
    final dateText = isToday
        ? 'Today ${_getMonthName(widget.selectedDate.month)} ${widget.selectedDate.day}'
        : '${_getMonthName(widget.selectedDate.month)} ${widget.selectedDate.day}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateText,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (widget.totalEventsToday > 0)
              Text(
                '${widget.totalEventsToday} ${_getEventWord(widget.totalEventsToday)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        // Calendar icon button
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => _showDatePicker(context),
            icon: Icon(
              Icons.calendar_today_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekView() {
    final weekDates = _getWeekDates(_currentWeekStart);

    return SizedBox(
      height: 70,
      child: Row(
        children: weekDates.map((date) {
          final isSelected = _isSameDay(date, widget.selectedDate);
          final isToday = _isToday(date);

          return Expanded(
            child: GestureDetector(
              onTap: () => widget.onDateSelected(date),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isToday
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getDayName(date.weekday),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.2)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : (isToday
                                          ? AppColors.primary
                                          : AppColors.textPrimary),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return _isSameDay(date, now);
  }

  String _getEventWord(int count) {
    if (count == 1) return 'event';
    return 'events';
  }

  void _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onDateSelected(picked);
      setState(() {
        _currentWeekStart = _getWeekStart(picked);
      });
    }
  }
}
