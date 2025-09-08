import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/parsed_event.dart';
import '../providers/event_provider.dart';

// Screen for displaying and editing parsed event information
class EventCardScreen extends HookConsumerWidget {
  final ParsedEvent parsedEvent;

  const EventCardScreen({
    super.key,
    required this.parsedEvent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventState = ref.watch(eventProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Event Card',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Original Text: ${parsedEvent.originalText}'),
            const SizedBox(height: 8),
            Text('Confidence: ${(parsedEvent.confidence * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 16),
            if (eventState.isProcessing)
              const Center(child: CircularProgressIndicator())
            else
              const Text('TODO: Implement event card UI'),
          ],
        ),
      ),
    );
  }
}