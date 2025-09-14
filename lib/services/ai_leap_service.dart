import 'dart:async';
import 'dart:developer' show log;
import 'dart:typed_data';

import 'package:flutter_leap_sdk/flutter_leap_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/parsed_event.dart';
import '../utils/ai_response_parser.dart';

/// Service for managing AI functionality using Flutter LEAP SDK
class AILeapService {
  bool _isInitialized = false;
  String? _currentModelPath;
  Conversation? _visionConversation;

  /// Available vision models for image processing and analysis
  static const Map<String, AIModelInfo> availableModels = {
    'LFM2-VL-450M': AIModelInfo(
      id: 'LFM2-VL-450M (Vision)',
      displayName: 'Vision Lite',
      fileName: 'LFM2-VL-450M_8da4w.bundle', // Updated to match SDK format
      size: '385 MB',
      sizeBytes: 385 * 1024 * 1024,
      description:
          'Compact vision model for image analysis and text extraction from screenshots',
      type: AIModelType.vision,
      strength: AIModelStrength.basic,
    ),
    'LFM2-VL-1.6B': AIModelInfo(
      id: 'LFM2-VL-1.6B (Vision)',
      displayName: 'Vision Pro',
      fileName: 'LFM2-VL-1_6B_8da4w.bundle', // Updated to match SDK format
      size: '1.19 GB',
      sizeBytes: 1190 * 1024 * 1024,
      description:
          'Advanced multimodal model for complex image understanding, text extraction, and visual reasoning',
      type: AIModelType.vision,
      strength: AIModelStrength.advanced,
    ),
  };

  /// Initialize the AI service
  Future<bool> initialize() async {
    try {
      // Initialize the Flutter LEAP SDK
      await FlutterLeapSdkService.initialize();
      _isInitialized = true;
      print('AI service initialized successfully');
      return true;
    } catch (e) {
      print('Failed to initialize AI service: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Check if AI service is initialized
  Future<bool> get isInitialized async => _isInitialized;

  /// Check if a model exists locally
  Future<bool> checkModelExists(String modelId) async {
    try {
      final modelInfo = availableModels[modelId];
      if (modelInfo == null) return false;

      // Get all downloaded models and check if this model ID is in the list
      final downloadedModels = await getDownloadedModels();
      return downloadedModels.contains(modelId);
    } catch (e) {
      print('Error checking model existence: $e');
      return false;
    }
  }

  /// Check if a model exists by checking the SDK directly
  Future<bool> checkModelExistsByPath(String modelPath) async {
    try {
      return await FlutterLeapSdkService.checkModelExists(modelPath);
    } catch (e) {
      print('Error checking model existence by path: $e');
      return false;
    }
  }

  /// Download a model with progress tracking
  Future<void> downloadModel(
    String modelId, {
    required Function(double progress) onProgress,
    Function(String error)? onError,
  }) async {
    try {
      final modelInfo = availableModels[modelId];
      if (modelInfo == null) {
        onError?.call('Model not found: $modelId');
        return;
      }

      await FlutterLeapSdkService.downloadModel(
        modelName: modelInfo.id,
        onProgress: (progress) {
          onProgress(progress.percentage / 100.0);
        },
      );
    } catch (e) {
      onError?.call('Download failed: $e');
    }
  }

  /// Load a model for use
  Future<bool> loadModel(String modelId) async {
    try {
      log('🔄 Loading model: $modelId');
      final modelInfo = availableModels[modelId];
      if (modelInfo == null) {
        log('❌ Model info not found for: $modelId');
        return false;
      }

      log('📋 Model info: ${modelInfo.displayName} (${modelInfo.type.name})');
      log('📁 Model file: ${modelInfo.fileName}');

      // Unload current model if any
      if (_currentModelPath != null) {
        log('🔄 Unloading current model: $_currentModelPath');
        await FlutterLeapSdkService.unloadModel();
        _visionConversation = null;
      }

      // Get the actual downloaded models to find the correct path
      final downloadedModels =
          await FlutterLeapSdkService.getDownloadedModels();
      log('📁 Available downloaded models: $downloadedModels');

      String? modelPath;

      // For vision models, prioritize the (Vision) suffix paths
      final possiblePaths = <String>[];

      // Vision models need the (Vision) suffix for image processing capabilities
      possiblePaths.addAll([
        '${modelInfo.displayName} (Vision)', // e.g., "Vision Lite (Vision)"
        '${modelInfo.id} (Vision)', // e.g., "LFM2-VL-450M (Vision)"
      ]);

      // Fallback paths (may not support image processing)
      possiblePaths.addAll([
        modelInfo.displayName, // e.g., "Vision Lite"
        modelInfo.id, // e.g., "LFM2-VL-450M"
        modelInfo.fileName, // e.g., "LFM2-VL-450M_8da4w.bundle"
        modelInfo.fileName.replaceAll(
          '.bundle',
          '',
        ), // Without .bundle extension
      ]);

      // Find the correct model path from downloaded models
      for (final possiblePath in possiblePaths) {
        if (downloadedModels.contains(possiblePath)) {
          modelPath = possiblePath;
          log('✅ Found matching model path: $modelPath');
          break;
        }
      }

      if (modelPath == null) {
        log('❌ Could not find downloaded model for $modelId');
        log('📋 Available models: $downloadedModels');
        log('🔍 Tried paths: $possiblePaths');
        return false;
      }

      log('🚀 Loading model with path: $modelPath');

      try {
        await FlutterLeapSdkService.loadModel(modelPath: modelPath);
        log('✅ Model loaded successfully with path: $modelPath');
      } catch (e) {
        log('❌ Failed to load model with path "$modelPath": $e');

        // Try alternative vision model paths
        bool loaded = false;
        log('👁️ Trying alternative vision model loading approaches...');

        // Try remaining paths from our possiblePaths list
        for (final alternativePath in possiblePaths) {
          if (alternativePath != modelPath &&
              downloadedModels.contains(alternativePath)) {
            try {
              log('🔄 Trying alternative vision model path: $alternativePath');
              await FlutterLeapSdkService.loadModel(modelPath: alternativePath);
              modelPath = alternativePath;
              loaded = true;
              log(
                '✅ Vision model loaded with alternative path: $alternativePath',
              );
              break;
            } catch (e2) {
              log('❌ Alternative path "$alternativePath" failed: $e2');
            }
          }
        }

        if (!loaded) {
          log('❌ All vision model loading attempts failed for: $modelId');
          log(
            '💡 Make sure you have downloaded the vision model with proper (Vision) suffix',
          );
          return false;
        }
      }

      _currentModelPath = modelId;

      // Warn if vision model loaded without (Vision) suffix
      if (modelPath != null && !modelPath.contains('(Vision)')) {
        log(
          '⚠️ WARNING: Vision model loaded without (Vision) suffix: $modelPath',
        );
        log(
          '⚠️ This may not support image processing. Consider redownloading the model.',
        );
      }

      // Create vision conversation
      log('🔧 Initializing vision conversation...');
      await _initializeVisionConversation();
      log('✅ Model loading complete');

      return true;
    } catch (e) {
      log('❌ Failed to load model: $e');
      log('❌ Error type: ${e.runtimeType}');
      if (e is ModelLoadingException) {
        log('❌ Model loading exception: ${e.message} (${e.code})');
      } else if (e is FlutterLeapSdkException) {
        log('❌ SDK exception: ${e.message} (${e.code})');
      }
      return false;
    }
  }

  /// Initialize vision conversation for image processing
  Future<void> _initializeVisionConversation() async {
    try {
      // Vision conversation for image analysis
      _visionConversation = await FlutterLeapSdkService.createConversation(
        systemPrompt:
            '''You are an expert at extracting calendar event information from images.
Look for text in screenshots, photos of documents, calendars, or any visual content.
Extract dates, times, locations, and event titles from the image.

Please provide a detailed JSON response with:
{
  "summary": "Brief 1-2 sentence summary of what this image contains",
  "title": "Concise, clear event title (max 50 characters)",
  "startDate": "YYYY-MM-DD",
  "startTime": "HH:MM",
  "endDate": "YYYY-MM-DD or null if same day",
  "endTime": "HH:MM or null if not specified",
  "location": "location or null",
  "description": "Detailed description extracted from the image",
  "eventType": "meeting|appointment|deadline|social|travel|other",
  "importance": "high|medium|low",
  "keyPoints": ["important point 1", "important point 2"]
}

Be precise and only extract information that is clearly visible in the image.''',
      );
    } catch (e) {
      print('Failed to initialize vision conversation: $e');
    }
  }

  /// Parse text from image using vision models
  Future<ParsedEvent?> parseImageWithAI(
    Uint8List imageBytes, {
    String? additionalContext,
  }) async {
    log('🔍 Starting image AI processing...');
    log('_isInitialized: $_isInitialized');
    log('_currentModelPath: $_currentModelPath');
    log('imageBytes length: ${imageBytes.length}');

    // Initialize AI service if not already done
    if (!_isInitialized) {
      log('🔧 AI service not initialized, initializing...');
      await initialize();
    }

    // Check if vision conversation is initialized
    if (_visionConversation == null) {
      log('🔧 Vision conversation not initialized, creating new one...');
      await _initializeVisionConversation();
      if (_visionConversation == null) {
        log('❌ Failed to create vision conversation');
        return null;
      }
    }

    try {
      final contextPrompt =
          '''You are an expert at extracting calendar event information from images.
Look for text in screenshots, photos of documents, calendars, or any visual content.
Extract dates, times, locations, and event titles from the image.

Please provide a detailed JSON response with:
{
  "summary": "Brief 1-2 sentence summary of what this image contains",
  "title": "Concise, clear event title (max 50 characters)",
  "startDate": "YYYY-MM-DD",
  "startTime": "HH:MM",
  "endDate": "YYYY-MM-DD or null if same day",
  "endTime": "HH:MM or null if not specified",
  "location": "location or null",
  "description": "Detailed description extracted from the image",
  "eventType": "meeting|appointment|deadline|social|travel|other",
  "importance": "high|medium|low",
  "keyPoints": ["important point 1", "important point 2"]
}

Be precise and only extract information that is clearly visible in the image.
Extract calendar event information from this image: $additionalContext''';

      log('🤖 Sending prompt: "$contextPrompt"');
      log('📷 Processing image with ${imageBytes.length} bytes...');

      final response = await _visionConversation!.generateResponseWithImage(
        contextPrompt,
        imageBytes,
      );

      log('🤖 Vision AI response: $response');

      final parsedResult = _parseEnhancedAIResponse('Image content', response);
      log('📋 Parsed result: $parsedResult');

      return parsedResult;
    } catch (e) {
      log('❌ AI image parsing failed: $e');
      log('❌ Error type: ${e.runtimeType}');
      if (e is ModelNotLoadedException) {
        log('❌ Model not loaded exception: ${e.message}');
      } else if (e is ModelLoadingException) {
        log('❌ Model loading exception: ${e.message} (${e.code})');
      } else if (e is FlutterLeapSdkException) {
        log('❌ SDK exception: ${e.message} (${e.code})');
      }
      return null;
    }
  }

  // /// Check if current model is a vision model
  // bool _isVisionModelLoaded() {
  //   if (_currentModelPath == null) return false;
  //   final modelInfo = availableModels[_currentModelPath];
  //   return modelInfo?.type == AIModelType.vision;
  // }

  /// Get current vision model capabilities
  List<String> getCurrentModelCapabilities() {
    if (_currentModelPath == null) return [];

    final modelInfo = availableModels[_currentModelPath];
    if (modelInfo == null) return [];

    final capabilities = <String>[];

    // All vision models have these capabilities
    capabilities.add('Image analysis');
    capabilities.add('Screenshot parsing');
    capabilities.add('Document OCR');
    capabilities.add('Event extraction from images');
    capabilities.add('Visual text recognition');

    // Advanced models have more capabilities
    if (modelInfo.strength == AIModelStrength.advanced) {
      capabilities.add('Complex visual reasoning');
      capabilities.add('Detailed image insights');
      capabilities.add('Advanced context understanding');
      capabilities.add('Multi-element recognition');
    } else {
      capabilities.add('Basic visual reasoning');
      capabilities.add('Standard image processing');
    }

    return capabilities;
  }

  /// Get list of downloaded models
  Future<List<String>> getDownloadedModels() async {
    try {
      log('🔍 Checking for downloaded models...');
      final downloadedModels =
          await FlutterLeapSdkService.getDownloadedModels();
      log('📁 Raw downloaded models from SDK: $downloadedModels');

      final mappedModels = <String>[];

      for (final model in downloadedModels) {
        log('🔍 Mapping model file: $model');

        // Try to find the model ID by matching various patterns
        String? foundModelId;

        for (final entry in availableModels.entries) {
          final modelId = entry.key;
          final modelInfo = entry.value;

          // Check multiple possible naming patterns
          final patternsToCheck = [
            modelInfo.fileName, // Full filename
            modelInfo.id, // Model ID
            modelInfo.displayName, // Display name
            '${modelInfo.displayName} (Vision)', // Vision model format
            modelInfo.fileName.replaceAll('.bundle', ''), // Without .bundle
          ];

          if (patternsToCheck.contains(model)) {
            foundModelId = modelId;
            log('✅ Found match: $model -> $modelId');
            break;
          }
        }

        if (foundModelId != null) {
          if (!mappedModels.contains(foundModelId)) {
            mappedModels.add(foundModelId);
          }
        } else {
          log('⚠️ No match found for: $model');
          // For debugging, let's check what we have and try partial matches
          for (final entry in availableModels.entries) {
            final modelId = entry.key;
            final modelInfo = entry.value;

            // Try partial matches for debugging
            if (model.contains(modelId) ||
                model.contains(modelInfo.displayName) ||
                modelInfo.fileName.contains(model)) {
              log('🔍 Possible partial match: $model might be $modelId');
              if (!mappedModels.contains(modelId)) {
                mappedModels.add(modelId);
                log('✅ Added based on partial match: $modelId');
              }
              break;
            }
          }
        }
      }

      log('📋 Final mapped models: $mappedModels');
      return mappedModels;
    } catch (e) {
      log('❌ Failed to get downloaded models: $e');
      return [];
    }
  }

  /// Delete a model
  Future<bool> deleteModel(String modelId) async {
    try {
      final modelInfo = availableModels[modelId];
      if (modelInfo == null) return false;

      await FlutterLeapSdkService.deleteModel(modelInfo.fileName);

      // If this was the current model, unload it
      if (_currentModelPath == modelId) {
        _currentModelPath = null;
        _visionConversation = null;
      }

      return true;
    } catch (e) {
      print('Failed to delete model: $e');
      return false;
    }
  }

  /// Cancel ongoing download
  Future<void> cancelDownload(String downloadId) async {
    try {
      await FlutterLeapSdkService.cancelDownload(downloadId);
    } catch (e) {
      print('Failed to cancel download: $e');
    }
  }

  /// Parse enhanced AI response into ParsedEvent
  ParsedEvent? _parseEnhancedAIResponse(
    String originalText,
    String aiResponse,
  ) {
    try {
      // Use the robust JSON extraction method
      final json = AIResponseParser.getJsonContent(aiResponse);

      if (json == null || json.isEmpty) {
        print('Failed to extract JSON from AI response: $aiResponse');
        return null;
      }

      log('Successfully extracted JSON: $json');

      // Use ParsedEvent.fromJson to handle the parsing
      final parsedEvent = ParsedEvent.fromJson(json, originalText);

      // Generate smart reminders if not provided but we have date and event type
      if (parsedEvent.suggestedReminders == null ||
          parsedEvent.suggestedReminders!.isEmpty) {
        if (parsedEvent.date != null && parsedEvent.eventType != null) {
          final updatedEvent = parsedEvent.copyWith(
            suggestedReminders: _generateSmartReminders(
              parsedEvent.date!,
              parsedEvent.eventType!,
            ),
          );
          // Update metadata to include the AI response
          return updatedEvent.copyWith(
            metadata: {...updatedEvent.metadata, 'response': aiResponse},
          );
        }
      }

      // Update metadata to include the AI response
      return parsedEvent.copyWith(
        metadata: {...parsedEvent.metadata, 'response': aiResponse},
      );
    } catch (e) {
      print('Failed to parse enhanced AI response: $e');
      return null;
    }
  }

  /// Generate smart reminders based on event type and timing
  List<SmartReminder> _generateSmartReminders(
    DateTime eventDate,
    EventType eventType,
  ) {
    final reminders = <SmartReminder>[];
    final eventDateTime = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      14, // 2 PM
      0,
    );

    switch (eventType) {
      case EventType.meeting:
        // 1 day before - preparation reminder
        reminders.add(
          SmartReminder(
            reminderTime: eventDateTime.subtract(const Duration(days: 1)),
            message:
                'Tomorrow: Project Alpha Sync Meeting. Review agenda and prepare updates.',
            type: ReminderType.preparation,
          ),
        );

        // 2 hours before - final preparation
        reminders.add(
          SmartReminder(
            reminderTime: eventDateTime.subtract(const Duration(hours: 2)),
            message:
                'Meeting in 2 hours. Gather materials and review key discussion points.',
            type: ReminderType.preparation,
          ),
        );

        // 15 minutes before - departure/join reminder
        reminders.add(
          SmartReminder(
            reminderTime: eventDateTime.subtract(const Duration(minutes: 15)),
            message:
                'Meeting starts in 15 minutes. Time to head to Conference Room A.',
            type: ReminderType.departure,
          ),
        );
        break;

      case EventType.appointment:
        reminders.add(
          SmartReminder(
            reminderTime: eventDateTime.subtract(const Duration(days: 1)),
            message:
                'Appointment tomorrow. Confirm details and prepare any required documents.',
            type: ReminderType.preparation,
          ),
        );

        reminders.add(
          SmartReminder(
            reminderTime: eventDateTime.subtract(const Duration(hours: 1)),
            message: 'Appointment in 1 hour. Time to leave soon.',
            type: ReminderType.departure,
          ),
        );
        break;

      case EventType.deadline:
        reminders.add(
          SmartReminder(
            reminderTime: eventDateTime.subtract(const Duration(days: 7)),
            message:
                'Deadline in 1 week. Start planning and organizing your work.',
            type: ReminderType.preparation,
          ),
        );

        reminders.add(
          SmartReminder(
            reminderTime: eventDateTime.subtract(const Duration(days: 3)),
            message:
                'Deadline in 3 days. Make sure you\'re on track to complete on time.',
            type: ReminderType.preparation,
          ),
        );

        reminders.add(
          SmartReminder(
            reminderTime: eventDateTime.subtract(const Duration(days: 1)),
            message:
                'Deadline tomorrow! Final review and submission preparation.',
            type: ReminderType.preparation,
          ),
        );
        break;

      case EventType.social:
        reminders.add(
          SmartReminder(
            reminderTime: eventDateTime.subtract(const Duration(days: 3)),
            message: 'Social event in 3 days. RSVP if you haven\'t already.',
            type: ReminderType.preparation,
          ),
        );

        reminders.add(
          SmartReminder(
            reminderTime: eventDateTime.subtract(const Duration(days: 1)),
            message: 'Event tomorrow. Plan your outfit and check the weather.',
            type: ReminderType.preparation,
          ),
        );
        break;

      case EventType.travel:
        reminders.add(
          SmartReminder(
            reminderTime: eventDateTime.subtract(const Duration(days: 7)),
            message:
                'Travel in 1 week. Check documents, bookings, and weather.',
            type: ReminderType.preparation,
          ),
        );

        reminders.add(
          SmartReminder(
            reminderTime: eventDateTime.subtract(const Duration(days: 2)),
            message:
                'Travel in 2 days. Pack essentials and confirm transportation.',
            type: ReminderType.preparation,
          ),
        );

        reminders.add(
          SmartReminder(
            reminderTime: eventDateTime.subtract(const Duration(hours: 4)),
            message:
                'Travel departure in 4 hours. Final preparations and check-in.',
            type: ReminderType.departure,
          ),
        );
        break;

      default:
        reminders.add(
          SmartReminder(
            reminderTime: eventDateTime.subtract(const Duration(days: 1)),
            message: 'Event tomorrow. Review details and prepare as needed.',
            type: ReminderType.general,
          ),
        );

        reminders.add(
          SmartReminder(
            reminderTime: eventDateTime.subtract(const Duration(hours: 1)),
            message: 'Event in 1 hour. Time to get ready.',
            type: ReminderType.general,
          ),
        );
        break;
    }

    return reminders;
  }

  /// Check if AI service is ready
  bool get isReady => _isInitialized && _currentModelPath != null;

  /// Get current model info
  AIModelInfo? get currentModel =>
      _currentModelPath != null ? availableModels[_currentModelPath] : null;

  /// Get diagnostic information for debugging
  Future<Map<String, dynamic>> getDiagnosticInfo() async {
    try {
      final diagnostics = <String, dynamic>{
        'isInitialized': _isInitialized,
        'currentModelPath': _currentModelPath,
        'hasVisionConversation': _visionConversation != null,
        'availableModelIds': availableModels.keys.toList(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      try {
        final sdkDownloadedModels =
            await FlutterLeapSdkService.getDownloadedModels();
        diagnostics['sdkDownloadedModels'] = sdkDownloadedModels;
      } catch (e) {
        diagnostics['sdkDownloadedModelsError'] = e.toString();
      }

      try {
        final mappedDownloadedModels = await getDownloadedModels();
        diagnostics['mappedDownloadedModels'] = mappedDownloadedModels;
      } catch (e) {
        diagnostics['mappedDownloadedModelsError'] = e.toString();
      }

      return diagnostics;
    } catch (e) {
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    try {
      if (_visionConversation != null) {
        await FlutterLeapSdkService.disposeConversation(
          _visionConversation!.id,
        );
        _visionConversation = null;
      }
      if (_currentModelPath != null) {
        await FlutterLeapSdkService.unloadModel();
        _currentModelPath = null;
      }
    } catch (e) {
      print('Error disposing AI service: $e');
    }
  }
}

/// Model information class
class AIModelInfo {
  final String id;
  final String displayName;
  final String fileName;
  final String size;
  final int sizeBytes;
  final String description;
  final AIModelType type;
  final AIModelStrength strength;

  const AIModelInfo({
    required this.id,
    required this.displayName,
    required this.fileName,
    required this.size,
    required this.sizeBytes,
    required this.description,
    required this.type,
    required this.strength,
  });

  /// Get a user-friendly capability description
  String get capabilityDescription {
    switch (strength) {
      case AIModelStrength.basic:
        return 'Image text extraction • Screenshot parsing • Basic vision processing';
      case AIModelStrength.intermediate:
        return 'Advanced image analysis • Document understanding • Enhanced OCR';
      case AIModelStrength.advanced:
        return 'Complex visual reasoning • Advanced OCR • Full multimodal capabilities';
    }
  }

  /// Get strength indicator
  String get strengthIndicator {
    switch (strength) {
      case AIModelStrength.basic:
        return '⚡ Fast';
      case AIModelStrength.intermediate:
        return '⚖️ Balanced';
      case AIModelStrength.advanced:
        return '🧠 Powerful';
    }
  }
}

/// Model types - Vision only
enum AIModelType { vision }

/// Model strength levels
enum AIModelStrength { basic, intermediate, advanced }

/// Provider for AI service
final aiLeapServiceProvider = Provider<AILeapService>((ref) {
  return AILeapService();
});

/// Provider for AI service state
final aiServiceStateProvider =
    StateNotifierProvider<AIServiceStateNotifier, AIServiceState>((ref) {
      return AIServiceStateNotifier(ref.read(aiLeapServiceProvider));
    });

/// AI service state
class AIServiceState {
  final bool isInitialized;
  final String? currentModelId;
  final List<String> downloadedModels;
  final Map<String, double> downloadProgress;
  final bool isLoading;
  final String? error;

  const AIServiceState({
    this.isInitialized = false,
    this.currentModelId,
    this.downloadedModels = const [],
    this.downloadProgress = const {},
    this.isLoading = false,
    this.error,
  });

  AIServiceState copyWith({
    bool? isInitialized,
    String? currentModelId,
    List<String>? downloadedModels,
    Map<String, double>? downloadProgress,
    bool? isLoading,
    String? error,
  }) {
    return AIServiceState(
      isInitialized: isInitialized ?? this.isInitialized,
      currentModelId: currentModelId ?? this.currentModelId,
      downloadedModels: downloadedModels ?? this.downloadedModels,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// AI service state notifier with automatic initialization
class AIServiceStateNotifier extends StateNotifier<AIServiceState> {
  final AILeapService _aiService;

  AIServiceStateNotifier(this._aiService) : super(const AIServiceState()) {
    // Automatically initialize when the notifier is created
    _initialize();
  }

  Future<void> _initialize() async {
    log('🚀 Starting AI service state initialization...');
    state = state.copyWith(isLoading: true);

    try {
      // Initialize the AI service
      log('🔧 Initializing AI service...');
      final initialized = await _aiService.initialize();
      log('✅ AI service initialized: $initialized');

      // Get downloaded models
      log('📥 Getting downloaded models...');
      final downloadedModels = await _aiService.getDownloadedModels();
      log('📋 Downloaded models: $downloadedModels');

      // Try to load a default model if available
      String? currentModelId;
      if (downloadedModels.isNotEmpty) {
        log('🔄 Attempting to load models: $downloadedModels');

        // Sort vision models by strength (basic first for faster loading and better memory usage)
        final sortedModels = [...downloadedModels];
        sortedModels.sort((a, b) {
          final aInfo = AILeapService.availableModels[a];
          final bInfo = AILeapService.availableModels[b];

          // Sort by strength (basic < intermediate < advanced)
          // This ensures we try lighter models first to avoid memory issues
          final aStrength = aInfo?.strength.index ?? 0;
          final bStrength = bInfo?.strength.index ?? 0;
          return aStrength.compareTo(bStrength);
        });

        log('📊 Sorted models for loading: $sortedModels');

        for (final modelId in sortedModels) {
          log('🔄 Attempting to load model: $modelId');
          final modelInfo = AILeapService.availableModels[modelId];

          // Log model size information
          if (modelInfo != null) {
            log(
              '📊 Model info: ${modelInfo.displayName} - ${modelInfo.size} (${modelInfo.strength.name})',
            );
          }

          try {
            final success = await _aiService.loadModel(modelId);
            log('✅ Model loading result for $modelId: $success');
            if (success) {
              currentModelId = modelId;
              log(
                '✅ Successfully loaded and set current model to: $currentModelId',
              );
              break;
            }
          } catch (e) {
            log('❌ Failed to load model $modelId: $e');

            // Check if this is a memory-related error
            final errorString = e.toString().toLowerCase();
            if (errorString.contains('memory') ||
                errorString.contains('allocation') ||
                errorString.contains('lost connection') ||
                errorString.contains('out of memory')) {
              log(
                '⚠️ Memory-related error detected. Skipping large models and trying smaller ones.',
              );
              // Continue to next (smaller) model
            }
          }
        }

        if (currentModelId == null) {
          log('⚠️ Could not load any of the downloaded models');
        }
      } else {
        log('⚠️ No downloaded models found');
      }

      state = state.copyWith(
        isInitialized: initialized,
        downloadedModels: downloadedModels,
        currentModelId: currentModelId,
        isLoading: false,
      );
      log('✅ AI service state initialization complete');
      log(
        '📊 Final state: initialized=$initialized, currentModel=$currentModelId, models=${downloadedModels.length}',
      );
    } catch (e) {
      log('❌ AI service state initialization failed: $e');
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> downloadModel(String modelId) async {
    state = state.copyWith(
      downloadProgress: {...state.downloadProgress, modelId: 0.0},
    );

    await _aiService.downloadModel(
      modelId,
      onProgress: (progress) {
        state = state.copyWith(
          downloadProgress: {...state.downloadProgress, modelId: progress},
        );
      },
      onError: (error) {
        final newProgress = Map<String, double>.from(state.downloadProgress);
        newProgress.remove(modelId);
        state = state.copyWith(downloadProgress: newProgress, error: error);
      },
    );

    // Update downloaded models list
    final downloadedModels = await _aiService.getDownloadedModels();
    final newProgress = Map<String, double>.from(state.downloadProgress);
    newProgress.remove(modelId);

    state = state.copyWith(
      downloadedModels: downloadedModels,
      downloadProgress: newProgress,
    );
  }

  Future<void> loadModel(String modelId) async {
    log('🔄 State notifier loading model: $modelId');
    state = state.copyWith(isLoading: true);

    try {
      final success = await _aiService.loadModel(modelId);
      log('✅ State notifier model loading result: $success');
      state = state.copyWith(
        currentModelId: success ? modelId : null,
        isLoading: false,
      );
      log('📊 Updated state: currentModel=${state.currentModelId}');
    } catch (e) {
      log('❌ State notifier model loading error: $e');
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> deleteModel(String modelId) async {
    try {
      await _aiService.deleteModel(modelId);
      final downloadedModels = await _aiService.getDownloadedModels();

      state = state.copyWith(
        downloadedModels: downloadedModels,
        currentModelId: state.currentModelId == modelId
            ? null
            : state.currentModelId,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void cancelDownload(String modelId) {
    final newProgress = Map<String, double>.from(state.downloadProgress);
    newProgress.remove(modelId);
    state = state.copyWith(downloadProgress: newProgress);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Manually initialize the AI service (for test page)
  Future<void> initialize() async {
    await _initialize();
  }

  /// Unload the current model
  Future<void> unloadModel() async {
    try {
      await FlutterLeapSdkService.unloadModel();
      state = state.copyWith(currentModelId: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Refresh the downloaded models list
  Future<void> refreshDownloadedModels() async {
    try {
      log('🔄 Refreshing downloaded models list...');
      final downloadedModels = await _aiService.getDownloadedModels();
      log('📋 Refreshed downloaded models: $downloadedModels');

      state = state.copyWith(downloadedModels: downloadedModels);
    } catch (e) {
      log('❌ Failed to refresh downloaded models: $e');
      state = state.copyWith(error: 'Failed to refresh models: $e');
    }
  }
}
