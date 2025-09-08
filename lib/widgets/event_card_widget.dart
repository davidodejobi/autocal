import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/parsed_event.dart';
import '../providers/event_provider.dart';

// Widget for displaying parsed event information
class EventCardWidget extends HookConsumerWidget {
  final ParsedEvent parsedEvent;
  final VoidCallback? onEdit;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const EventCardWidget({
    super.key,
    required this.parsedEvent,
    this.onEdit,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventState = ref.watch(eventProvider);

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Parsed Event',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Original Text: ${parsedEvent.originalText}'),
            const SizedBox(height: 8),
            Text('Confidence: ${(parsedEvent.confidence * 100).toStringAsFixed(1)}%'),
            if (eventState.isProcessing) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ] else ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (onEdit != null)
                    ElevatedButton(
                      onPressed: onEdit,
                      child: const Text('Edit'),
                    ),
                  if (onConfirm != null)
                    ElevatedButton(
                      onPressed: onConfirm,
                      child: const Text('Confirm'),
                    ),
                  if (onCancel != null)
                    TextButton(
                      onPressed: onCancel,
                      child: const Text('Cancel'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}