import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/app_state_provider.dart';
import '../providers/event_provider.dart';
import '../providers/schedule_provider.dart';
import '../screens/add_event_screen.dart';
import '../screens/event_card_screen.dart';
import '../screens/settings_screen.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../widgets/custom_floating_navigation_bar.dart';
import '../widgets/schedule_view.dart';

// Main home screen for AutoCal app
class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final eventState = ref.watch(eventProvider);
    final selectedIndex = useState(0);
    final isNavBarVisible = useState(true);
    final lastScrollPosition = useRef(0.0);
    final scrollVelocity = useRef(0.0);

    // Navigate to event card when shared content is received
    useEffect(() {
      if (eventState.currentParsedEvent != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  EventCardScreen(parsedEvent: eventState.currentParsedEvent!),
            ),
          );
        });
      }
      return null;
    }, [eventState.currentParsedEvent]);

    // Handle scroll notification for navigation bar visibility
    bool handleScrollNotification(ScrollNotification notification) {
      if (notification is ScrollUpdateNotification) {
        final currentPosition = notification.metrics.pixels;
        final scrollDelta = currentPosition - lastScrollPosition.value;

        // Update scroll velocity for smoother detection
        scrollVelocity.value = scrollDelta;

        // Show navigation bar when at the very top
        if (currentPosition <= 50) {
          if (!isNavBarVisible.value) {
            isNavBarVisible.value = true;
          }
        }
        // Only trigger hide/show if we've scrolled enough distance and not at the top
        else if (scrollDelta.abs() > 3.0) {
          if (scrollDelta > 0) {
            // Scrolling down - hide navigation bar
            if (isNavBarVisible.value) {
              isNavBarVisible.value = false;
            }
          } else if (scrollDelta < -3.0) {
            // Scrolling up - show navigation bar
            if (!isNavBarVisible.value) {
              isNavBarVisible.value = true;
            }
          }
        }

        lastScrollPosition.value = currentPosition;
      }

      // Also handle scroll end to ensure nav bar shows when scrolling stops
      if (notification is ScrollEndNotification) {
        if (notification.metrics.pixels <= 100 && !isNavBarVisible.value) {
          isNavBarVisible.value = true;
        }
      }

      return false; // Allow the notification to continue
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NotificationListener<ScrollNotification>(
        onNotification: handleScrollNotification,
        child: Stack(
          children: [
            IndexedStack(
              index: selectedIndex.value,
              children: [
                _buildHomeContent(context, ref, appState, eventState),
                _buildEventsContent(context, ref),
                _buildAnalyticsContent(context, ref),
                _buildSettingsContent(context, ref),
              ],
            ),
            // Add Event FAB - only show on home tab
            if (selectedIndex.value == 0 && isNavBarVisible.value)
              Positioned(
                right: 20,
                bottom: 120, // Position above the navigation bar
                child: FloatingActionButton(
                  onPressed: () {
                    final scheduleState = ref.read(scheduleProvider);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddEventScreen(
                          selectedDate: scheduleState.selectedDate,
                        ),
                      ),
                    );
                  },
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: CustomFloatingNavigationBarEnhanced(
        currentIndex: selectedIndex.value,
        onTap: (index) => selectedIndex.value = index,
        items: [
          FloatingNavItems.home(),
          FloatingNavItems.events(),
          FloatingNavItems.settings(),
        ],
        backgroundColor: AppColors.surface,
        activeColor: AppColors.primary,
        inactiveColor: AppColors.iconSecondary,
        borderRadius: 24,
        animationDuration: const Duration(milliseconds: 300),
        showLabels: true,
        enableHapticFeedback: true,
        isVisible: isNavBarVisible.value,
        customShadow: BoxShadow(
          color: AppColors.primary.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHomeContent(
    BuildContext context,
    WidgetRef ref,
    AppState appState,
    EventState eventState,
  ) {
    final scheduleState = ref.watch(scheduleProvider);

    return SafeArea(
      child: ScheduleView(
        daySchedule: scheduleState.currentDaySchedule,
        onDateChanged: (date) {
          ref.read(scheduleProvider.notifier).selectDate(date);
        },
        onEventTap: (event) {
          // TODO: Navigate to event details or edit
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tapped on: ${event.title}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventsContent(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: AppSpacing.screenPadding,
          right: AppSpacing.screenPadding,
          top: AppSpacing.screenPadding,
          bottom: 100, // Extra bottom padding for floating navigation
        ),
        child: Column(
          children: [
            const Center(child: Text('Events screen coming soon!')),
            // Add some extra content to make it scrollable for testing
            ...List.generate(
              20,
              (index) => Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Event item ${index + 1}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsContent(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: AppSpacing.screenPadding,
          right: AppSpacing.screenPadding,
          top: AppSpacing.screenPadding,
          bottom: 100, // Extra bottom padding for floating navigation
        ),
        child: Column(
          children: [
            const Center(child: Text('Analytics screen coming soon!')),
            // Add some extra content to make it scrollable for testing
            ...List.generate(
              15,
              (index) => Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Analytics item ${index + 1}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          bottom: 100, // Extra bottom padding for floating navigation
        ),
        child: const SettingsScreen(),
      ),
    );
  }
}
