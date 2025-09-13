import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/app_state_provider.dart';
import '../providers/event_provider.dart';
import '../screens/event_card_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/shared_content_test_screen.dart';
import '../screens/subscription_screen.dart';
import '../services/ai_leap_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../widgets/custom_floating_navigation_bar.dart';

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
        child: IndexedStack(
          index: selectedIndex.value,
          children: [
            _buildHomeContent(context, ref, appState, eventState),
            _buildEventsContent(context, ref),
            _buildAnalyticsContent(context, ref),
            _buildSettingsContent(context, ref),
          ],
        ),
      ),
      floatingActionButton: CustomFloatingNavigationBarEnhanced(
        currentIndex: selectedIndex.value,
        onTap: (index) => selectedIndex.value = index,
        items: [
          FloatingNavItems.home(),
          FloatingNavItems.events(),
          FloatingNavItems.profile(),
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: AppSpacing.screenPadding,
          right: AppSpacing.screenPadding,
          top: AppSpacing.screenPadding,
          bottom: 100, // Extra bottom padding for floating navigation
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context, ref, appState),
            const SizedBox(height: AppSpacing.sectionSpacing),

            // AI Status Card
            _buildAIStatusCard(context, appState),
            const SizedBox(height: AppSpacing.sectionSpacing),

            // Share to Create Section
            _buildShareToCreateSection(context, ref),
            const SizedBox(height: AppSpacing.sectionSpacing),

            // Quick Actions
            _buildQuickActions(context, ref, appState),
            const SizedBox(height: AppSpacing.sectionSpacing),

            // AI Suggested Actions
            _buildAISuggestedActionsSection(context, ref, appState),
            const SizedBox(height: AppSpacing.sectionSpacing),

            // Recent Events
            _buildRecentEventsSection(context, ref, eventState),
            const SizedBox(height: AppSpacing.sectionSpacing),

            // Upgrade to Pro (if not pro)
            if (!appState.subscriptionStatus.isPro)
              _buildUpgradeToProSection(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, AppState appState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('AutoCal', style: Theme.of(context).textTheme.headlineLarge),
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
          icon: const Icon(Icons.settings_outlined),
          iconSize: 28,
        ),
      ],
    );
  }

  Widget _buildAIStatusCard(BuildContext context, AppState appState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.psychology_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final aiServiceState = ref.watch(aiServiceStateProvider);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aiServiceState.isInitialized
                          ? (appState.subscriptionStatus.isPro
                                ? 'AI is optimizing your schedule...'
                                : 'AI is ready')
                          : 'AI is initializing...',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      aiServiceState.currentModelId != null
                          ? 'Using ${AILeapService.availableModels[aiServiceState.currentModelId]?.displayName ?? 'AI model'}'
                          : (aiServiceState.isLoading
                                ? 'Loading AI models...'
                                : 'No AI model loaded'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareToCreateSection(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share to create an event',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Paste text, upload a screenshot, or share from another app.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SharedContentTestScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.share),
              label: const Text('Share Content'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    WidgetRef ref,
    AppState appState,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            context: context,
            icon: Icons.add_circle_outline,
            label: 'Quick Add',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SharedContentTestScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildQuickActionButton(
            context: context,
            icon: Icons.mic_outlined,
            label: 'Voice',
            isPro: true,
            isEnabled: appState.subscriptionStatus.isPro,
            onTap: appState.subscriptionStatus.isPro
                ? () {
                    // TODO: Implement voice functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Voice feature coming soon!'),
                      ),
                    );
                  }
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SubscriptionScreen(),
                      ),
                    );
                  },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPro = false,
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.surface : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled ? AppColors.border : AppColors.borderLight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isEnabled
                  ? AppColors.iconPrimary
                  : AppColors.iconSecondary,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isEnabled
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            if (isPro && !isEnabled) ...[
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'PRO',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 8,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAISuggestedActionsSection(
    BuildContext context,
    WidgetRef ref,
    AppState appState,
  ) {
    if (!appState.subscriptionStatus.isPro) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Suggested Actions',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
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
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.schedule,
                      color: AppColors.info,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Reschedule "Meeting with Alex"?',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Conflict detected with another event today that avoids conflict.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      // TODO: Dismiss suggestion
                    },
                    child: const Text('Dismiss'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Reschedule event
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Reschedule'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentEventsSection(
    BuildContext context,
    WidgetRef ref,
    EventState eventState,
  ) {
    final appState = ref.watch(appStateProvider);
    final recentEvents = appState.recentEvents;

    // Show mock data if no recent events exist
    final displayEvents = recentEvents.isEmpty
        ? [
            {'title': 'Meeting with Alex', 'confidence': 0.98, 'isReal': false},
            {'title': 'Dinner at 7 PM', 'confidence': 0.85, 'isReal': false},
            {'title': 'Project Review', 'confidence': 0.95, 'isReal': false},
          ]
        : recentEvents
              .map(
                (event) => {
                  'title': event.title,
                  'confidence': 0.9, // Default confidence for real events
                  'isReal': true,
                },
              )
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Events', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        if (displayEvents.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 48,
                  color: AppColors.iconSecondary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No events yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Share content from other apps to create your first event',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...displayEvents
              .take(3)
              .map(
                (event) => _buildRecentEventItem(
                  context,
                  event['title'] as String,
                  event['confidence'] as double,
                ),
              ),
      ],
    );
  }

  Widget _buildRecentEventItem(
    BuildContext context,
    String title,
    double confidence,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: AppColors.iconPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.getConfidenceColor(confidence),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppColors.getConfidenceText(confidence),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.getConfidenceColor(confidence),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.iconSecondary),
        ],
      ),
    );
  }

  Widget _buildUpgradeToProSection(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upgrade to Pro', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Unlock unlimited events and advanced features.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionScreen(),
                  ),
                );
              },
              child: const Text('Upgrade'),
            ),
          ),
        ],
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
