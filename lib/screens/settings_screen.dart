import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/app_state_provider.dart';

// Settings screen for app configuration
class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Subscription Status'),
              subtitle: Text(appState.subscriptionStatus.isPro ? 'Pro' : 'Free'),
              trailing: Icon(
                appState.subscriptionStatus.isPro ? Icons.star : Icons.star_border,
                color: appState.subscriptionStatus.isPro ? Colors.amber : null,
              ),
            ),
            const Divider(),
            const Text('TODO: Implement settings UI'),
          ],
        ),
      ),
    );
  }
}