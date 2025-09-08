import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/app_state_provider.dart';

// Widget for displaying subscription upgrade prompts
class SubscriptionUpgradeWidget extends HookConsumerWidget {
  final String message;
  final VoidCallback? onUpgrade;
  final VoidCallback? onDismiss;

  const SubscriptionUpgradeWidget({
    super.key,
    required this.message,
    this.onUpgrade,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    // Don't show upgrade widget if user is already Pro
    if (appState.subscriptionStatus.isPro) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Upgrade to Pro',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onDismiss != null)
                  TextButton(
                    onPressed: onDismiss,
                    child: const Text('Not Now'),
                  ),
                const SizedBox(width: 8),
                if (onUpgrade != null)
                  ElevatedButton(
                    onPressed: onUpgrade,
                    child: const Text('Upgrade'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}