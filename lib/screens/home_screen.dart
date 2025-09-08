import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/app_state_provider.dart';
import '../providers/event_provider.dart';
import '../screens/event_card_screen.dart';

// Main home screen for AutoCal app
class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final eventState = ref.watch(eventProvider);

    // Example of using hooks - animation controller for welcome text
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1000),
    );
    final fadeAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeIn),
      ),
    );

    // Start animation when widget is first built
    useEffect(() {
      animationController.forward();
      return null;
    }, []);

    // Navigate to event card when shared content is received
    useEffect(() {
      if (eventState.currentParsedEvent != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EventCardScreen(
                parsedEvent: eventState.currentParsedEvent!,
              ),
            ),
          );
        });
      }
      return null;
    }, [eventState.currentParsedEvent]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoCal'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to AutoCal',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Share text from other apps to create calendar events',
              textAlign: TextAlign.center,
            ),
            if (eventState.currentParsedEvent != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(height: 8),
                    const Text(
                      'Shared content received!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Text: ${eventState.currentParsedEvent!.originalText}',
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (!appState.subscriptionStatus.isPro) ...[
              Text(
                'Daily events created: ${appState.dailyEventCount}/5',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              if (!appState.canCreateEvent)
                const Text(
                  'Daily limit reached. Upgrade to Pro for unlimited events.',
                  style: TextStyle(color: Colors.orange),
                  textAlign: TextAlign.center,
                ),
            ],
            if (appState.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: CircularProgressIndicator(),
              ),
            if (appState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  appState.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
