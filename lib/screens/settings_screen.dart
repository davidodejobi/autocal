import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/app_state_provider.dart';
import '../screens/ai_model_management_screen.dart';
import '../screens/subscription_screen.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';

// Settings screen for app configuration
class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            // _buildSectionHeader(context, 'ACCOUNT'),
            // const SizedBox(height: AppSpacing.md),
            // _buildAccountCard(context, ref, appState),
            // const SizedBox(height: AppSpacing.sectionSpacing),

            // AI Features Section
            _buildSectionHeader(context, 'AI FEATURES'),
            const SizedBox(height: AppSpacing.md),
            _buildAIFeaturesSection(context, ref, appState),
            const SizedBox(height: AppSpacing.sectionSpacing),

            // Calendar Section
            _buildSectionHeader(context, 'CALENDAR'),
            const SizedBox(height: AppSpacing.md),
            _buildCalendarSection(context, ref),
            const SizedBox(height: AppSpacing.sectionSpacing),

            // Notifications Section
            _buildSectionHeader(context, 'NOTIFICATIONS'),
            const SizedBox(height: AppSpacing.md),
            _buildNotificationsSection(context, ref),
            const SizedBox(height: AppSpacing.sectionSpacing),

            // Privacy Section
            _buildSectionHeader(context, 'PRIVACY'),
            const SizedBox(height: AppSpacing.md),
            _buildPrivacySection(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: AppColors.textTertiary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildAccountCard(
    BuildContext context,
    WidgetRef ref,
    AppState appState,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: appState.subscriptionStatus.isPro
                      ? AppColors.warning
                      : AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  appState.subscriptionStatus.isPro
                      ? Icons.star
                      : Icons.person_outline,
                  color: appState.subscriptionStatus.isPro
                      ? Colors.white
                      : AppColors.iconPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appState.subscriptionStatus.isPro
                          ? 'AutoCal Pro'
                          : 'AutoCal Free',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appState.subscriptionStatus.isPro
                          ? 'You have access to all features.'
                          : 'Upgrade to unlock all features.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
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
              child: Text(
                appState.subscriptionStatus.isPro
                    ? 'Manage Subscription'
                    : 'Upgrade to Pro',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIFeaturesSection(
    BuildContext context,
    WidgetRef ref,
    AppState appState,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildToggleSettingItem(
            context: context,
            title: 'Smart Scheduling',
            subtitle: 'Find the best time for your events.',
            value: appState.subscriptionStatus.isPro,
            onChanged: appState.subscriptionStatus.isPro
                ? (value) {
                    // TODO: Implement smart scheduling toggle
                  }
                : null,
            isFirst: true,
          ),
          _buildDivider(),
          _buildToggleSettingItem(
            context: context,
            title: 'Proactive Meeting Insights',
            subtitle: 'Get insights before meetings.',
            value: appState.subscriptionStatus.isPro,
            onChanged: appState.subscriptionStatus.isPro
                ? (value) {
                    // TODO: Implement meeting insights toggle
                  }
                : null,
          ),
          _buildDivider(),
          _buildToggleSettingItem(
            context: context,
            title: 'Contextual Enrichment',
            subtitle: 'Automatically add event details.',
            value: appState.subscriptionStatus.isPro,
            onChanged: appState.subscriptionStatus.isPro
                ? (value) {
                    // TODO: Implement contextual enrichment toggle
                  }
                : null,
          ),
          _buildDivider(),
          _buildToggleSettingItem(
            context: context,
            title: 'Travel Time Alerts',
            subtitle: 'Intelligent travel time calculation.',
            value: appState.subscriptionStatus.isPro,
            onChanged: appState.subscriptionStatus.isPro
                ? (value) {
                    // TODO: Implement travel time alerts toggle
                  }
                : null,
          ),
          _buildDivider(),
          _buildNavigationSettingItem(
            context: context,
            title: 'Voice Input',
            subtitle: 'Create events using your voice.',
            onTap: appState.subscriptionStatus.isPro
                ? () {
                    // TODO: Navigate to voice settings
                  }
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SubscriptionScreen(),
                      ),
                    );
                  },
          ),
          _buildDivider(),
          _buildNavigationSettingItem(
            context: context,
            title: 'Manage AI Models',
            subtitle: '',
            onTap: !appState.subscriptionStatus.isPro
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AIModelManagementScreen(),
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
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildNavigationSettingItem(
            context: context,
            title: 'Calendar Integrations',
            subtitle: '',
            onTap: () {
              // TODO: Show calendar integrations
            },
            isFirst: true,
          ),
          _buildDivider(),
          _buildNavigationSettingItem(
            context: context,
            title: 'Default Calendar',
            subtitle: 'Personal',
            onTap: () {
              // TODO: Show calendar selection
            },
          ),
          _buildDivider(),
          _buildNavigationSettingItem(
            context: context,
            title: 'Default Reminders',
            subtitle: '15 minutes before',
            onTap: () {
              // TODO: Show reminder time selection
            },
          ),
          _buildDivider(),
          _buildNavigationSettingItem(
            context: context,
            title: 'Time Zone',
            subtitle: 'Pacific Time',
            onTap: () {
              // TODO: Show timezone selection
            },
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildToggleSettingItem(
            context: context,
            title: 'Event Reminders',
            subtitle: '',
            value: true,
            onChanged: (value) {
              // TODO: Implement event reminders toggle
            },
            isFirst: true,
          ),
          _buildDivider(),
          _buildToggleSettingItem(
            context: context,
            title: 'AI Processing Updates',
            subtitle: '',
            value: false,
            onChanged: (value) {
              // TODO: Implement AI updates toggle
            },
          ),
          _buildDivider(),
          _buildToggleSettingItem(
            context: context,
            title: 'Model Download Alerts',
            subtitle: '',
            value: true,
            onChanged: (value) {
              // TODO: Implement download alerts toggle
            },
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(BuildContext context, WidgetRef ref) {
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
          Row(
            children: [
              const Icon(
                Icons.security,
                color: AppColors.iconPrimary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'On-Device Processing',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'All AI processing is done locally on your device. Your data never leaves your device, ensuring maximum privacy.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () {
              // TODO: Show privacy policy
            },
            child: const Text('Learn more in our Privacy Policy'),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSettingItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: isFirst ? AppSpacing.md : AppSpacing.sm,
        bottom: isLast ? AppSpacing.md : AppSpacing.sm,
        left: AppSpacing.md,
        right: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
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

  Widget _buildNavigationSettingItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(12) : Radius.zero,
        bottom: isLast ? const Radius.circular(12) : Radius.zero,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: isFirst ? AppSpacing.md : AppSpacing.sm,
          bottom: isLast ? AppSpacing.md : AppSpacing.sm,
          left: AppSpacing.md,
          right: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.iconSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.borderLight,
      indent: AppSpacing.md,
      endIndent: AppSpacing.md,
    );
  }
}
