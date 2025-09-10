import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/app_state_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';

// Screen for subscription management and Pro upgrade
class SubscriptionScreen extends HookConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Subscription'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (appState.subscriptionStatus.isPro) ...[
              _buildProStatusCard(context),
              const SizedBox(height: AppSpacing.sectionSpacing),
              _buildManageSubscriptionSection(context),
            ] else ...[
              _buildUpgradeHeader(context),
              const SizedBox(height: AppSpacing.sectionSpacing),
              _buildFeaturesList(context),
              const SizedBox(height: AppSpacing.sectionSpacing),
              _buildPricingCard(context),
              const SizedBox(height: AppSpacing.sectionSpacing),
              _buildUpgradeButton(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProStatusCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.proGradientStart, AppColors.proGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.star,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'AutoCal Pro',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'You have access to all premium features',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildManageSubscriptionSection(BuildContext context) {
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
          Text(
            'Manage Subscription',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildManagementOption(
            context,
            'View Subscription Details',
            'See your current plan and billing info',
            Icons.info_outline,
            () {
              // TODO: Show subscription details
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildManagementOption(
            context,
            'Restore Purchases',
            'Restore your subscription on this device',
            Icons.refresh,
            () {
              // TODO: Restore purchases
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildManagementOption(
            context,
            'Cancel Subscription',
            'Manage your subscription in the App Store',
            Icons.cancel_outlined,
            () {
              // TODO: Open App Store subscription management
            },
          ),
        ],
      ),
    );
  }

  Widget _buildManagementOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, color: AppColors.iconPrimary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.iconSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upgrade to Pro and\nUnlock AI Superpowers',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Experience the future of scheduling with\nAutoCal\'s intelligent features.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      {'icon': Icons.schedule, 'title': 'Smart Scheduling & Optimization', 'subtitle': 'Let our AI find the perfect time for your meetings, considering availability and preferences.'},
      {'icon': Icons.insights, 'title': 'Proactive Meeting Insights & Follow-ups', 'subtitle': 'Get intelligent briefings before meetings and automated follow-up suggestions for every meeting.'},
      {'icon': Icons.link, 'title': 'Contextual Event Enrichment & Resource Linking', 'subtitle': 'Automatically enrich your events with relevant documents, contacts, and locations from your shared content.'},
      {'icon': Icons.location_on, 'title': 'Intelligent Travel Time Calculation & Alerts', 'subtitle': 'Get smart travel time estimates and receive alerts to ensure you\'re always on time for your appointments.'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: features.asMap().entries.map((entry) {
          final index = entry.key;
          final feature = entry.value;
          final isLast = index == features.length - 1;
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        feature['icon'] as IconData,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature['title'] as String,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            feature['subtitle'] as String,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 20,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.borderLight,
                  indent: AppSpacing.md,
                  endIndent: AppSpacing.md,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPricingCard(BuildContext context) {
    return Column(
      children: [
        // Monthly Option
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Text(
                'Monthly',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '\$9.99',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '/month',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Annual Option with Badge
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Annual',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'BEST VALUE',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '\$79.99',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '/year',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement subscription purchase
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription purchase coming soon!'),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
        child: const Text(
          'Start Free Trial',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}