import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:share_handler/share_handler.dart';

import '../providers/event_provider.dart';
import '../providers/text_parsing_provider.dart';

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

  static const int _urlTimeoutSeconds = 10;
  static const int _maxContentLength = 1000000; // 1MB limit for URL content

  /// Initialize shared content handling
  Future<void> initialize(WidgetRef ref) async {
    _ref = ref;

    try {
      // Initialize Dio with configuration
      _initializeDio();

      // Listen for shared media (including text and images) when app is already running
      _mediaStreamSubscription =
          ReceiveSharingIntent.instance.getMediaStream().listen(
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
      final List<SharedMediaFile> initialFiles =
          await ReceiveSharingIntent.instance.getInitialMedia();

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
    _dio = Dio(BaseOptions(
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
    ));

    // Add interceptors for better error handling and logging
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        _logInfo('HTTP Request: ${options.method} ${options.uri}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        _logInfo(
            'HTTP Response: ${response.statusCode} for ${response.requestOptions.uri}');
        handler.next(response);
      },
      onError: (error, handler) {
        _logError('HTTP Error: ${error.message}', error);
        handler.next(error);
      },
    ));
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
            await _handleSharedText(file.path);
            break;
          case SharedMediaType.image:
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
          if (attachment?.type == SharedAttachmentType.image) {
            _logInfo(
                'Received shared image via share_handler: ${attachment?.path}');
            // TODO: Handle image attachments
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
          'SharedContentHandler not initialized');
    }

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
        }
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
    } catch (e) {
      _logError('Error processing text content', e);
      throw SharedContentException(
          'Failed to parse text content', e.toString());
    }
  }

  /// Handle shared image content
  Future<void> _handleSharedImage(SharedMediaFile imageFile) async {
    if (_ref == null) {
      throw const SharedContentException(
          'SharedContentHandler not initialized');
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
            'Image file does not exist: ${imageFile.path}');
      }

      // Check file size (limit to reasonable size for processing)
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        // 10MB limit
        throw SharedContentException('Image file too large: $fileSize bytes');
      }

      // Try to extract text from image if it contains text
      final extractedText = await _extractTextFromImage(imageFile.path);
      if (extractedText.isNotEmpty) {
        await _processTextContent(extractedText);
      } else {
        _logInfo('No text extracted from image or OCR not implemented');
      }
    } catch (e) {
      _logError('Error handling shared image: ${imageFile.path}', e);
      if (e is! SharedContentException) {
        throw SharedContentException(
            'Failed to process shared image', e.toString());
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
            'Failed to handle shared URL', e.toString());
      }
      rethrow;
    }
  }

  /// Extract text content from image using OCR
  Future<String> _extractTextFromImage(String imagePath) async {
    try {
      // TODO: Implement OCR text extraction from image
      // This could use packages like:
      // - google_ml_kit for text recognition
      // - tflite_flutter for custom OCR models
      // - firebase_ml_vision (deprecated, but still works)

      // For now, just return empty string
      // When OCR is implemented, extracted text can be processed like regular text
      _logInfo(
          'OCR text extraction from image not yet implemented: $imagePath');
      return '';
    } catch (e) {
      _logError('Error in OCR text extraction', e);
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
            'Non-text content type: $contentType, attempting to extract anyway');
      }

      // Extract text from HTML or return plain text
      final extractedText = _extractTextFromHtml(responseData);

      _logInfo(
          'Successfully extracted ${extractedText.length} characters from URL');
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
          'Failed to extract text from URL', e.toString());
    }
  }

  /// Extract text content from HTML
  String _extractTextFromHtml(String html) {
    try {
      // Simple HTML text extraction (basic implementation)
      // Remove script and style tags
      String text = html.replaceAll(
          RegExp(r'<script[^>]*>.*?</script>',
              caseSensitive: false, dotAll: true),
          '');
      text = text.replaceAll(
          RegExp(r'<style[^>]*>.*?</style>',
              caseSensitive: false, dotAll: true),
          '');

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

  /// Dispose of resources
  void dispose() {
    _mediaStreamSubscription?.cancel();
    _mediaStreamSubscription = null;
    _shareHandlerSubscription?.cancel();
    _shareHandlerSubscription = null;
    _dio.close();
    _ref = null;
    _logInfo('SharedContentHandler disposed');
  }
}

// Provider for the shared content handler
final sharedContentHandlerProvider = Provider<SharedContentHandler>((ref) {
  return SharedContentHandler();
});
