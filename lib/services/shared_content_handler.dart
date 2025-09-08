import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../providers/event_provider.dart';
import 'text_parser_service.dart';

// Service for handling shared content from other apps
class SharedContentHandler {
  static final SharedContentHandler _instance =
      SharedContentHandler._internal();
  factory SharedContentHandler() => _instance;
  SharedContentHandler._internal();

  StreamSubscription<List<SharedMediaFile>>? _mediaStreamSubscription;
  WidgetRef? _ref;

  /// Initialize shared content handling
  Future<void> initialize(WidgetRef ref) async {
    _ref = ref;

    // Listen for shared media (including text and images) when app is already running
    _mediaStreamSubscription =
        ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> files) {
        for (final file in files) {
          if (file.type == SharedMediaType.text) {
            _handleSharedText(file.path);
          } else if (file.type == SharedMediaType.image) {
            _handleSharedImage(file);
          }
        }
      },
      onError: (err) {
        print('Error receiving shared media: $err');
      },
    );

    // Get any shared media when app is launched from sharing
    try {
      final List<SharedMediaFile> initialFiles =
          await ReceiveSharingIntent.instance.getInitialMedia();
      for (final file in initialFiles) {
        if (file.type == SharedMediaType.text) {
          _handleSharedText(file.path);
        } else if (file.type == SharedMediaType.image) {
          _handleSharedImage(file);
        }
      }
      // Reset to indicate we've consumed the initial intent
      await ReceiveSharingIntent.instance.reset();
    } catch (e) {
      print('Error getting initial shared media: $e');
    }
  }

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

  /// Handle shared image content
  void _handleSharedImage(SharedMediaFile imageFile) async {
    if (_ref == null) return;

    try {
      print('Received shared image: ${imageFile.path}');
      print('Image type: ${imageFile.type}');
      print('Image MIME type: ${imageFile.mimeType}');

      // TODO: Add OCR text extraction from image
      // For now, just log the image details
      // You could extract text from the image using OCR here

      // Optional: Try to extract text from image if it contains text
      await _extractTextFromImage(imageFile.path);
    } catch (e) {
      print('Error handling shared image: $e');
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

  /// Extract text content from image using OCR
  Future<String> _extractTextFromImage(String imagePath) async {
    // TODO: Implement OCR text extraction from image
    // This could use packages like:
    // - google_ml_kit for text recognition
    // - tflite_flutter for custom OCR models
    // - firebase_ml_vision (deprecated, but still works)

    // For now, just return empty string
    // When OCR is implemented, extracted text can be processed like regular text
    print('OCR text extraction from image not yet implemented: $imagePath');
    return '';
  }

  /// Extract text content from URL
  Future<String> extractTextFromUrl(String url) async {
    // TODO: Implement URL text extraction
    // For now, just return the URL as text
    return url;
  }

  /// Dispose of resources
  void dispose() {
    _mediaStreamSubscription?.cancel();
    _mediaStreamSubscription = null;
    _ref = null;
  }
}

// Provider for the shared content handler
final sharedContentHandlerProvider = Provider<SharedContentHandler>((ref) {
  return SharedContentHandler();
});
