import 'dart:async';
// import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/event_provider.dart';
import '../models/parsed_event.dart';
import 'text_parser_service.dart';

// Service for handling shared content from other apps
class SharedContentHandler {
  static final SharedContentHandler _instance =
      SharedContentHandler._internal();
  factory SharedContentHandler() => _instance;
  SharedContentHandler._internal();

  StreamSubscription<String>? _textStreamSubscription;
  WidgetRef? _ref;

  // /// Initialize shared content handling
  // Future<void> initialize(WidgetRef ref) async {
  //   _ref = ref;

  //   // Listen for shared text when app is already running
  //   _textStreamSubscription =
  //       ReceiveSharingIntent.instance.getTextStream().listen(
  //     (String value) {
  //       _handleSharedText(value);
  //     },
  //     onError: (err) {
  //       print('Error receiving shared text: $err');
  //     },
  //   );

  //   // Get any shared text when app is launched from sharing
  //   try {
  //     final String? initialText =
  //         await ReceiveSharingIntent.instance.getInitialText();
  //     if (initialText != null && initialText.isNotEmpty) {
  //       _handleSharedText(initialText);
  //     }
  //   } catch (e) {
  //     print('Error getting initial shared text: $e');
  //   }
  // }

  /// Handle shared text content
  void _handleSharedText(String text) async {
    if (_ref == null) return;

    try {
      // Parse the shared text
      final textParser = TextParserService();
      final parsedEvent = await textParser.parseEventFromText(text);

      // Update the event provider with the parsed event
      _ref!.read(eventProvider.notifier).setParsedEvent(parsedEvent);

      print('Received shared text: $text');
    } catch (e) {
      print('Error handling shared text: $e');
    }
  }

  /// Handle shared URL content
  void handleSharedUrl(String url) async {
    try {
      final extractedText = await extractTextFromUrl(url);
      if (extractedText.isNotEmpty) {
        _handleSharedText(extractedText);
      }
    } catch (e) {
      print('Error handling shared URL: $e');
    }
  }

  /// Extract text content from URL
  Future<String> extractTextFromUrl(String url) async {
    // TODO: Implement URL text extraction
    // For now, just return the URL as text
    return url;
  }

  /// Dispose of resources
  void dispose() {
    _textStreamSubscription?.cancel();
    _textStreamSubscription = null;
    _ref = null;
  }
}

// Provider for the shared content handler
final sharedContentHandlerProvider = Provider<SharedContentHandler>((ref) {
  return SharedContentHandler();
});
