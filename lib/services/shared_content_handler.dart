import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:autocal/screens/event_card_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:share_handler/share_handler.dart';

import '../providers/event_provider.dart';
import '../providers/text_parsing_provider.dart';
import 'ai_leap_service.dart';

//get global context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Exception thrown when shared content cannot be processed
class SharedContentException implements Exception {
  final String message;
  final String? details;

  const SharedContentException(this.message, [this.details]);

  @override
  String toString() =>
      'SharedContentException: $message${details != null ? ' ($details)' : ''}';
}

/// Service for handling shared content from other apps
class SharedContentHandler {
  static final SharedContentHandler _instance =
      SharedContentHandler._internal();
  factory SharedContentHandler() => _instance;
  SharedContentHandler._internal();

  StreamSubscription<List<SharedMediaFile>>? _mediaStreamSubscription;
  StreamSubscription<SharedMedia>? _shareHandlerSubscription;
  WidgetRef? _ref;
  late final Dio _dio;

  // Track processed content to prevent duplicates
  final Set<String> _processedContent = <String>{};

  static const int _urlTimeoutSeconds = 10;
  static const int _maxContentLength = 1000000; // 1MB limit for URL content

  /// Initialize shared content handling
  Future<void> initialize(WidgetRef ref) async {
    _ref = ref;

    try {
      // Initialize Dio with configuration
      _initializeDio();

      // Listen for shared media (including text and images) when app is already running
      _mediaStreamSubscription = ReceiveSharingIntent.instance
          .getMediaStream()
          .listen(
            (List<SharedMediaFile> files) {
              _handleSharedMediaFiles(files);
            },
            onError: (err) {
              _logError('Error receiving shared media stream', err);
            },
          );

      // Also initialize share_handler for better compatibility
      await _initializeShareHandler();

      // Get any shared media when app is launched from sharing
      final List<SharedMediaFile> initialFiles = await ReceiveSharingIntent
          .instance
          .getInitialMedia();

      if (initialFiles.isNotEmpty) {
        await _handleSharedMediaFiles(initialFiles);
        // Reset to indicate we've consumed the initial intent
        await ReceiveSharingIntent.instance.reset();
      }

      _logInfo('SharedContentHandler initialized successfully');
    } catch (e) {
      _logError('Error initializing SharedContentHandler', e);
      rethrow;
    }
  }

  /// Initialize Dio HTTP client with proper configuration
  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: Duration(seconds: _urlTimeoutSeconds),
        receiveTimeout: Duration(seconds: _urlTimeoutSeconds),
        sendTimeout: Duration(seconds: _urlTimeoutSeconds),
        maxRedirects: 5,
        followRedirects: true,
        headers: {
          'User-Agent': 'AutoCal/1.0.0 (Mobile App)',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.5',
          'Accept-Encoding': 'gzip, deflate',
          'DNT': '1',
          'Connection': 'keep-alive',
          'Upgrade-Insecure-Requests': '1',
        },
      ),
    );

    // Add interceptors for better error handling and logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logInfo('HTTP Request: ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logInfo(
            'HTTP Response: ${response.statusCode} for ${response.requestOptions.uri}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          _logError('HTTP Error: ${error.message}', error);
          handler.next(error);
        },
      ),
    );
  }

  /// Initialize share_handler for better share menu compatibility
  Future<void> _initializeShareHandler() async {
    try {
      final handler = ShareHandlerPlatform.instance;

      // Listen for shared content via share_handler
      _shareHandlerSubscription = handler.sharedMediaStream.listen(
        (SharedMedia media) {
          _handleSharedMedia(media);
        },
        onError: (err) {
          _logError('share_handler stream error', err);
        },
      );

      // Get initial shared content
      final SharedMedia? initialMedia = await handler.getInitialSharedMedia();
      if (initialMedia != null) {
        await _handleSharedMedia(initialMedia);
      }

      _logInfo('share_handler initialized successfully');
    } catch (e) {
      _logError('Error initializing share_handler', e);
      // Don't rethrow here as this is a fallback mechanism
    }
  }

  /// Handle shared media files from receive_sharing_intent
  Future<void> _handleSharedMediaFiles(List<SharedMediaFile> files) async {
    for (final file in files) {
      try {
        switch (file.type) {
          case SharedMediaType.text:
            _logInfo(
              'Received shared text via receive_sharing_intent: ${file.path}',
            );
            await _handleSharedText(file.path);
            break;
          case SharedMediaType.image:
            _logInfo(
              'Received shared image via receive_sharing_intent: ${file.path}',
            );
            await _handleSharedImage(file);
            break;
          case SharedMediaType.video:
            _logInfo('Video sharing not supported: ${file.path}');
            break;
          case SharedMediaType.file:
            _logInfo('File sharing not supported: ${file.path}');
            break;
          case SharedMediaType.url:
            _logInfo('URL sharing via media file: ${file.path}');
            await _handleSharedText(file.path);
            break;
        }
      } catch (e) {
        _logError('Error handling shared media file: ${file.path}', e);
      }
    }
  }

  /// Handle shared media from share_handler
  Future<void> _handleSharedMedia(SharedMedia media) async {
    try {
      // Handle shared text content
      if (media.content != null && media.content!.isNotEmpty) {
        await _handleSharedText(media.content!);
        _logInfo('Received shared text via share_handler');
      }

      // Handle shared attachments (images, files, etc.)
      if (media.attachments != null && media.attachments!.isNotEmpty) {
        for (final attachment in media.attachments!) {
          if (attachment?.type == SharedAttachmentType.image &&
              attachment?.path != null) {
            _logInfo(
              'Received shared image via share_handler: ${attachment?.path}',
            );
            // Convert to SharedMediaFile format for processing
            final sharedImageFile = SharedMediaFile(
              path: attachment!.path,
              thumbnail: null,
              duration: null,
              type: SharedMediaType.image,
            );
            await _processImageWithAI(sharedImageFile);
          } else {
            _logInfo('Unsupported attachment type: ${attachment?.type}');
          }
        }
      }
    } catch (e) {
      _logError('Error handling shared media', e);
    }
  }

  /// Handle shared text content
  Future<void> _handleSharedText(String text) async {
    if (_ref == null) {
      throw const SharedContentException(
        'SharedContentHandler not initialized',
      );
    }

    // Prevent duplicate processing of the same text
    final textHash = text.trim().hashCode.toString();
    if (_processedContent.contains(textHash)) {
      _logInfo('⏭️ Skipping duplicate text processing');
      return;
    }
    _processedContent.add(textHash);

    // Set processing state to show loading overlay
    _ref!.read(eventProvider.notifier).setProcessing(true);

    try {
      // Validate input
      if (text.trim().isEmpty) {
        throw const SharedContentException('Shared text is empty');
      }

      // Check if the text is a URL
      if (_isUrl(text.trim())) {
        _logInfo('Detected URL in shared text, extracting content');
        final extractedText = await extractTextFromUrl(text.trim());
        if (extractedText.isNotEmpty) {
          await _processTextContent(extractedText);
        } else {
          // If URL extraction fails, still try to parse the URL itself
          await _processTextContent(text);
        }
      } else {
        await _processTextContent(text);
      }
    } catch (e) {
      _logError('Error handling shared text', e);
      // Still try to process the raw text if URL extraction fails
      if (e is SharedContentException && text.trim().isNotEmpty) {
        try {
          await _processTextContent(text);
        } catch (fallbackError) {
          _logError('Fallback text processing also failed', fallbackError);
          // Clear processing state on final failure
          _ref!.read(eventProvider.notifier).setProcessing(false);
        }
      } else {
        // Clear processing state on error
        _ref!.read(eventProvider.notifier).setProcessing(false);
      }
    }
  }

  /// Process text content by parsing and updating the event provider
  Future<void> _processTextContent(String text) async {
    if (_ref == null) return;

    try {
      // Parse the shared text using the enhanced text parsing provider
      final textParsingService = _ref!.read(textParsingProvider);
      final parsedEvent = await textParsingService.parseText(text);

      // Update the event provider with the parsed event
      _ref!.read(eventProvider.notifier).setParsedEvent(parsedEvent);

      _logInfo('Successfully processed shared text content');

      // Navigate to EventCardScreen using the global navigator
      if (navigatorKey.currentContext != null) {
        Navigator.of(navigatorKey.currentContext!).push(
          MaterialPageRoute(
            builder: (context) => EventCardScreen(parsedEvent: parsedEvent),
          ),
        );
      }

      // Clear processing state after successful completion
      _ref!.read(eventProvider.notifier).setProcessing(false);

      // Clean up processed content cache
      _cleanupProcessedContent();
    } catch (e) {
      _logError('Error processing text content', e);
      // Clear processing state on error
      _ref!.read(eventProvider.notifier).setProcessing(false);
      throw SharedContentException(
        'Failed to parse text content',
        e.toString(),
      );
    }
  }

  /// Handle shared image content
  Future<void> _handleSharedImage(SharedMediaFile imageFile) async {
    if (_ref == null) {
      throw const SharedContentException(
        'SharedContentHandler not initialized',
      );
    }

    try {
      _logInfo('Received shared image: ${imageFile.path}');
      _logInfo('Image type: ${imageFile.type}');
      _logInfo('Image MIME type: ${imageFile.mimeType}');

      // Validate image file
      if (imageFile.path.isEmpty) {
        throw const SharedContentException('Image path is empty');
      }

      // Check if file exists
      final file = File(imageFile.path);
      if (!await file.exists()) {
        throw SharedContentException(
          'Image file does not exist: ${imageFile.path}',
        );
      }

      // Check file size (limit to reasonable size for processing)
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        // 10MB limit
        throw SharedContentException('Image file too large: $fileSize bytes');
      }

      // Process image with AI vision models
      await _processImageWithAI(imageFile);
    } catch (e) {
      _logError('Error handling shared image: ${imageFile.path}', e);
      if (e is! SharedContentException) {
        throw SharedContentException(
          'Failed to process shared image',
          e.toString(),
        );
      }
      rethrow;
    }
  }

  /// Handle shared URL content (public method for external use)
  Future<void> handleSharedUrl(String url) async {
    try {
      if (!_isUrl(url)) {
        throw SharedContentException('Invalid URL format: $url');
      }

      final extractedText = await extractTextFromUrl(url);
      if (extractedText.isNotEmpty) {
        await _handleSharedText(extractedText);
      } else {
        // If no text extracted, still process the URL itself
        await _handleSharedText(url);
      }
    } catch (e) {
      _logError('Error handling shared URL: $url', e);
      if (e is! SharedContentException) {
        throw SharedContentException(
          'Failed to handle shared URL',
          e.toString(),
        );
      }
      rethrow;
    }
  }

  /// Process image with AI vision models
  Future<void> _processImageWithAI(SharedMediaFile imageFile) async {
    if (_ref == null) {
      throw const SharedContentException(
        'SharedContentHandler not initialized',
      );
    }

    // Prevent duplicate processing of the same image
    final imagePath = imageFile.path;
    if (_processedContent.contains(imagePath)) {
      _logInfo('⏭️ Skipping duplicate image processing: $imagePath');
      return;
    }
    _processedContent.add(imagePath);

    // Set processing state to show loading overlay
    _ref!.read(eventProvider.notifier).setProcessing(true);

    try {
      _logInfo('🔍 Processing shared image with AI: ${imageFile.path}');

      // Read image file as bytes
      final file = File(imageFile.path);
      final imageBytes = await file.readAsBytes();

      _logInfo('📷 Image loaded, size: ${imageBytes.length} bytes');

      // Get AI service
      final aiService = _ref!.read(aiLeapServiceProvider);

      // Check if AI service is ready, with proper waiting for model loading
      if (!aiService.isReady) {
        _logInfo('⏳ AI service not ready, waiting for model to load...');

        // Wait for AI service state to have a loaded model
        final aiServiceState = _ref!.read(aiServiceStateProvider);

        // If not initialized at all, wait for initialization
        if (!aiServiceState.isInitialized) {
          _logInfo('🔧 Waiting for AI service initialization...');

          // Wait up to 30 seconds for initialization (increased from 10)
          for (int i = 0; i < 60; i++) {
            await Future.delayed(const Duration(milliseconds: 500));
            final currentState = _ref!.read(aiServiceStateProvider);
            if (currentState.isInitialized) {
              _logInfo('✅ AI service initialization completed');
              break;
            }
            if (i == 59) {
              throw const SharedContentException(
                'AI service initialization timed out. Please ensure a vision model is downloaded.',
              );
            }
          }
        }

        // Now wait for a model to be loaded (more generous timeout for large models)
        _logInfo('🤖 Waiting for AI model to load...');
        for (int i = 0; i < 120; i++) {
          // Wait up to 60 seconds for model loading (increased from 30)
          await Future.delayed(const Duration(milliseconds: 500));
          final currentState = _ref!.read(aiServiceStateProvider);

          // Check if service is ready first, then verify model state
          if (aiService.isReady && currentState.currentModelId != null) {
            _logInfo(
              '🎯 AI model loaded successfully: ${currentState.currentModelId}',
            );
            break;
          }

          if (currentState.error != null) {
            _logError('❌ AI model loading failed', currentState.error);
            throw SharedContentException(
              'AI model loading failed: ${currentState.error}',
            );
          }

          if (i == 119) {
            throw const SharedContentException(
              'AI model loading timed out after 60 seconds. This may be due to insufficient memory for the current model. Consider downloading Vision Lite for better compatibility.',
            );
          }
        }
      }

      _logInfo('🚀 Starting AI image processing...');

      // Process image with AI with timeout to prevent hanging
      final parsedEvent = await Future.any([
        aiService.parseImageWithAI(
          imageBytes,
          additionalContext: 'Shared image from external app',
        ),
        Future.delayed(
          const Duration(
            seconds: 90,
          ), // Extended timeout for large models (increased from 45)
          () => throw const SharedContentException(
            'Image processing timed out after 90 seconds. This may be due to insufficient memory for the current AI model.',
          ),
        ),
      ]);

      _logInfo('📊 AI processing completed');

      if (parsedEvent != null) {
        _logInfo('✅ Successfully parsed event from image:');
        _logInfo('   📅 Title: ${parsedEvent.title}');
        _logInfo('   📅 Date: ${parsedEvent.date}');
        _logInfo('   📅 Start Time: ${parsedEvent.startTime}');
        _logInfo('   📅 End Time: ${parsedEvent.endTime}');
        _logInfo('   📍 Location: ${parsedEvent.location}');
        _logInfo('   📝 Description: ${parsedEvent.description}');
        _logInfo('   🏷️ Event Type: ${parsedEvent.eventType}');
        _logInfo('   ⚡ Importance: ${parsedEvent.importance}');

        // Log the full AI response if available
        final aiResponse = parsedEvent.metadata['response'];
        if (aiResponse != null) {
          _logInfo('🤖 Full AI Response:');
          _logInfo('$aiResponse');
        }

        // Update the event provider with the parsed event
        _ref!.read(eventProvider.notifier).setParsedEvent(parsedEvent);
        _logInfo('🎉 Successfully processed shared image with AI');

        // Navigate to EventCardScreen using the global navigator
        if (navigatorKey.currentContext != null) {
          Navigator.of(navigatorKey.currentContext!).push(
            MaterialPageRoute(
              builder: (context) => EventCardScreen(parsedEvent: parsedEvent),
            ),
          );
        }

        // Dispose AI resources to free memory (keep initialization)
        await _disposeAIResources();

        // Clear processing state after successful completion
        _ref!.read(eventProvider.notifier).setProcessing(false);

        // Clean up processed content cache
        _cleanupProcessedContent();
      } else {
        _logInfo('⚠️ AI could not extract event information from image');
        // Still try basic OCR as fallback
        final extractedText = await _extractTextFromImageFallback(
          imageFile.path,
        );
        if (extractedText.isNotEmpty) {
          await _processTextContent(extractedText);
          // Dispose AI resources after fallback processing
          // Note: _processTextContent already clears processing state
          await _disposeAIResources();
        } else {
          // Dispose AI resources before throwing error
          await _disposeAIResources();

          // Clear processing state before throwing error
          _ref!.read(eventProvider.notifier).setProcessing(false);

          // Check if user only has large models that might be causing memory issues
          final aiServiceState = _ref!.read(aiServiceStateProvider);
          final hasOnlyLargeModels =
              aiServiceState.downloadedModels.isNotEmpty &&
              aiServiceState.downloadedModels.every((modelId) {
                final modelInfo = AILeapService.availableModels[modelId];
                return modelInfo?.strength == AIModelStrength.advanced;
              });

          if (hasOnlyLargeModels) {
            throw const SharedContentException(
              'Could not process image. This may be due to insufficient memory for the current AI model. '
              'Consider downloading Vision Lite (385MB) for better compatibility with image sharing.',
            );
          } else {
            throw const SharedContentException(
              'Could not extract event information from image. Please ensure the image contains clear event details.',
            );
          }
        }
      }
    } catch (e) {
      _logError('💥 Error processing image with AI', e);

      // Clear processing state on error
      _ref!.read(eventProvider.notifier).setProcessing(false);

      // Dispose AI resources even on error to prevent memory leaks
      try {
        await _disposeAIResources();
      } catch (disposeError) {
        _logError('Error disposing AI resources', disposeError);
      }

      if (e is! SharedContentException) {
        throw SharedContentException(
          'Failed to process shared image with AI',
          e.toString(),
        );
      }
      rethrow;
    }
  }

  /// Dispose AI resources after processing to free memory
  Future<void> _disposeAIResources() async {
    try {
      _logInfo('🧹 Disposing AI resources to free memory...');

      final aiService = _ref!.read(aiLeapServiceProvider);

      // Unload the current model to free memory
      // Note: We keep the AI service initialized for future use
      if (aiService.isReady) {
        _logInfo('📤 Unloading AI model to free memory...');

        // Get the AI service state notifier to unload model
        final aiServiceNotifier = _ref!.read(aiServiceStateProvider.notifier);
        await aiServiceNotifier.unloadModel();

        _logInfo('✅ AI model unloaded successfully');
      }

      // Force garbage collection to free memory immediately
      _logInfo('🗑️ Triggering garbage collection...');
      // Note: Dart doesn't have explicit GC control, but we can suggest it

      _logInfo('✨ AI resources disposed successfully');
    } catch (e) {
      _logError('❌ Error disposing AI resources', e);
      // Don't rethrow - this is cleanup, shouldn't break the main flow
    }
  }

  /// Fallback OCR text extraction (placeholder for future implementation)
  Future<String> _extractTextFromImageFallback(String imagePath) async {
    try {
      // TODO: Implement basic OCR as fallback
      // This could use packages like:
      // - google_ml_kit for text recognition
      // - tflite_flutter for custom OCR models

      _logInfo(
        '📝 Fallback OCR text extraction not yet implemented: $imagePath',
      );
      return '';
    } catch (e) {
      _logError('Error in fallback OCR text extraction', e);
      return '';
    }
  }

  /// Extract text content from URL using Dio
  Future<String> extractTextFromUrl(String url) async {
    try {
      if (!_isUrl(url)) {
        throw SharedContentException('Invalid URL format: $url');
      }

      _logInfo('Extracting text from URL: $url');

      // Make HTTP request using Dio
      final response = await _dio.get(url);

      // Check response status (Dio automatically handles status codes)
      if (response.statusCode != 200) {
        throw SharedContentException(
          'HTTP request failed with status ${response.statusCode}',
          response.statusMessage,
        );
      }

      // Get response data as string
      final responseData = response.data.toString();

      // Check content length
      if (responseData.length > _maxContentLength) {
        throw SharedContentException(
          'Response content too large: ${responseData.length} bytes',
        );
      }

      // Check content type
      final contentType = response.headers.value('content-type') ?? '';
      if (!contentType.toLowerCase().contains('text/html') &&
          !contentType.toLowerCase().contains('text/plain')) {
        _logInfo(
          'Non-text content type: $contentType, attempting to extract anyway',
        );
      }

      // Extract text from HTML or return plain text
      final extractedText = _extractTextFromHtml(responseData);

      _logInfo(
        'Successfully extracted ${extractedText.length} characters from URL',
      );
      return extractedText;
    } on DioException catch (e) {
      // Handle Dio-specific exceptions
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw const SharedContentException('URL request timed out');
        case DioExceptionType.connectionError:
          throw const SharedContentException('Network connection failed');
        case DioExceptionType.badResponse:
          throw SharedContentException(
            'HTTP request failed with status ${e.response?.statusCode}',
            e.response?.statusMessage,
          );
        case DioExceptionType.cancel:
          throw const SharedContentException('Request was cancelled');
        case DioExceptionType.unknown:
          throw SharedContentException('Network error occurred', e.message);
        default:
          throw SharedContentException('Request failed', e.message);
      }
    } on FormatException {
      throw SharedContentException('Invalid URL format: $url');
    } catch (e) {
      if (e is SharedContentException) {
        rethrow;
      }
      _logError('Error extracting text from URL: $url', e);
      throw SharedContentException(
        'Failed to extract text from URL',
        e.toString(),
      );
    }
  }

  /// Extract text content from HTML
  String _extractTextFromHtml(String html) {
    try {
      // Simple HTML text extraction (basic implementation)
      // Remove script and style tags
      String text = html.replaceAll(
        RegExp(
          r'<script[^>]*>.*?</script>',
          caseSensitive: false,
          dotAll: true,
        ),
        '',
      );
      text = text.replaceAll(
        RegExp(r'<style[^>]*>.*?</style>', caseSensitive: false, dotAll: true),
        '',
      );

      // Remove HTML tags
      text = text.replaceAll(RegExp(r'<[^>]*>'), ' ');

      // Decode HTML entities
      text = text.replaceAll('&amp;', '&');
      text = text.replaceAll('&lt;', '<');
      text = text.replaceAll('&gt;', '>');
      text = text.replaceAll('&quot;', '"');
      text = text.replaceAll('&#39;', "'");
      text = text.replaceAll('&nbsp;', ' ');

      // Clean up whitespace
      text = text.replaceAll(RegExp(r'\s+'), ' ');
      text = text.trim();

      return text;
    } catch (e) {
      _logError('Error extracting text from HTML', e);
      return html; // Return original if extraction fails
    }
  }

  /// Check if a string is a valid URL
  bool _isUrl(String text) {
    try {
      final uri = Uri.parse(text);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // Expose methods for testing
  @visibleForTesting
  bool isUrlForTesting(String text) => _isUrl(text);

  @visibleForTesting
  String extractTextFromHtmlForTesting(String html) =>
      _extractTextFromHtml(html);

  @visibleForTesting
  Future<void> handleSharedTextForTesting(String text) =>
      _handleSharedText(text);

  @visibleForTesting
  Future<void> processTextContentForTesting(String text) =>
      _processTextContent(text);

  @visibleForTesting
  Future<void> handleSharedMediaFilesForTesting(List<SharedMediaFile> files) =>
      _handleSharedMediaFiles(files);

  @visibleForTesting
  Future<void> handleSharedImageForTesting(SharedMediaFile imageFile) =>
      _handleSharedImage(imageFile);

  /// Logging methods
  void _logInfo(String message) {
    developer.log(message, name: 'SharedContentHandler', level: 800);
  }

  void _logError(String message, dynamic error) {
    developer.log(
      message,
      name: 'SharedContentHandler',
      level: 1000,
      error: error,
      stackTrace: error is Error ? error.stackTrace : null,
    );
  }

  /// Clean up old processed content entries to prevent memory leaks
  void _cleanupProcessedContent() {
    // Keep only the most recent 50 processed items to prevent memory bloat
    if (_processedContent.length > 50) {
      final itemsToRemove = _processedContent.length - 50;
      final iterator = _processedContent.iterator;
      for (int i = 0; i < itemsToRemove && iterator.moveNext(); i++) {
        // Remove from iterator is not available, so we'll clear and rebuild
      }
      // For simplicity, just clear when it gets too big
      // In production, you might want to use a more sophisticated LRU cache
      if (_processedContent.length > 100) {
        _processedContent.clear();
        _logInfo('🧹 Cleared processed content cache to prevent memory bloat');
      }
    }
  }

  /// Dispose of resources
  void dispose() {
    _mediaStreamSubscription?.cancel();
    _mediaStreamSubscription = null;
    _shareHandlerSubscription?.cancel();
    _shareHandlerSubscription = null;
    _dio.close();
    _processedContent.clear();
    _ref = null;
    _logInfo('SharedContentHandler disposed');
  }
}

// Provider for the shared content handler
final sharedContentHandlerProvider = Provider<SharedContentHandler>((ref) {
  return SharedContentHandler();
});
