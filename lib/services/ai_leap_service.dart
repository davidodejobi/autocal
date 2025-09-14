import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_leap_sdk/flutter_leap_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/parsed_event.dart';

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
  "confidence": 0.0-1.0,
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
  "confidence": 0.0-1.0,
  "keyPoints": ["important point 1", "important point 2"]
}

Be precise and only extract information that is clearly visible in the image.
Extract calendar event information from this image. Additional context: $additionalContext''';

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
      // Extract JSON from AI response (handle cases where AI adds extra text)
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(aiResponse);
      if (jsonMatch == null) {
        print('No JSON found in AI response: $aiResponse');
        return null;
      }

      final jsonString = jsonMatch.group(0)!;
      final Map<String, dynamic> json = _parseJsonSafely(jsonString);

      if (json.isEmpty) {
        print('Failed to parse JSON from AI response');
        return null;
      }

      // Parse date and time fields
      DateTime? eventDate;
      TimeOfDay? startTime;
      TimeOfDay? endTime;
      DateTime? endDate;

      // Parse start date
      if (json['startDate'] != null) {
        try {
          eventDate = DateTime.parse(json['startDate'] as String);
        } catch (e) {
          print('Failed to parse start date: ${json['startDate']}');
        }
      }

      // Parse start time
      if (json['startTime'] != null) {
        try {
          final timeParts = (json['startTime'] as String).split(':');
          if (timeParts.length >= 2) {
            startTime = TimeOfDay(
              hour: int.parse(timeParts[0]),
              minute: int.parse(timeParts[1]),
            );
          }
        } catch (e) {
          print('Failed to parse start time: ${json['startTime']}');
        }
      }

      // Parse end time
      if (json['endTime'] != null) {
        try {
          final timeParts = (json['endTime'] as String).split(':');
          if (timeParts.length >= 2) {
            endTime = TimeOfDay(
              hour: int.parse(timeParts[0]),
              minute: int.parse(timeParts[1]),
            );
          }
        } catch (e) {
          print('Failed to parse end time: ${json['endTime']}');
        }
      }

      // Parse end date
      if (json['endDate'] != null && json['endDate'] != 'null') {
        try {
          endDate = DateTime.parse(json['endDate'] as String);
        } catch (e) {
          print('Failed to parse end date: ${json['endDate']}');
        }
      }

      // Parse event type
      EventType? eventType;
      if (json['eventType'] != null) {
        try {
          eventType = EventType.values.firstWhere(
            (type) => type.name == json['eventType'],
            orElse: () => EventType.other,
          );
        } catch (e) {
          eventType = EventType.other;
        }
      }

      // Parse importance
      EventImportance? importance;
      if (json['importance'] != null) {
        try {
          importance = EventImportance.values.firstWhere(
            (imp) => imp.name == json['importance'],
            orElse: () => EventImportance.medium,
          );
        } catch (e) {
          importance = EventImportance.medium;
        }
      }

      // Parse suggested reminders
      List<SmartReminder>? suggestedReminders;
      if (json['suggestedReminders'] != null &&
          eventDate != null &&
          eventType != null) {
        try {
          final remindersList = json['suggestedReminders'] as List<dynamic>;
          suggestedReminders = remindersList
              .map((reminderJson) {
                try {
                  return SmartReminder.fromJson(
                    reminderJson as Map<String, dynamic>,
                  );
                } catch (e) {
                  print('Failed to parse reminder: $reminderJson');
                  return null;
                }
              })
              .where((reminder) => reminder != null)
              .cast<SmartReminder>()
              .toList();

          // If parsing failed or no reminders, generate smart defaults
          if (suggestedReminders.isEmpty) {
            suggestedReminders = _generateSmartReminders(eventDate, eventType);
          }
        } catch (e) {
          print('Failed to parse reminders, generating defaults: $e');
          suggestedReminders = _generateSmartReminders(eventDate, eventType);
        }
      } else if (eventDate != null && eventType != null) {
        // Generate smart reminders if not provided
        suggestedReminders = _generateSmartReminders(eventDate, eventType);
      }

      // Parse key points
      List<String>? keyPoints;
      if (json['keyPoints'] != null) {
        try {
          keyPoints = (json['keyPoints'] as List<dynamic>)
              .map((point) => point.toString())
              .toList();
        } catch (e) {
          print('Failed to parse key points: ${json['keyPoints']}');
        }
      }

      // Get confidence, default to 0.5 if not provided or invalid
      double confidence = 0.5;
      if (json['confidence'] != null) {
        try {
          confidence = (json['confidence'] as num).toDouble();
          // Ensure confidence is between 0 and 1
          confidence = confidence.clamp(0.0, 1.0);
        } catch (e) {
          print('Failed to parse confidence: ${json['confidence']}');
        }
      }

      return ParsedEvent(
        title: json['title'] as String?,
        date: eventDate,
        startTime: startTime,
        endTime: endTime,
        location: json['location'] as String?,
        originalText: originalText,
        confidence: confidence,
        metadata: {
          'aiGenerated': true,
          'response': aiResponse,
          'parsedJson': json,
        },
        // Enhanced AI fields
        summary: json['summary'] as String?,
        description: json['description'] as String?,
        endDate: endDate,
        eventType: eventType,
        importance: importance,
        suggestedReminders: suggestedReminders,
        keyPoints: keyPoints,
      );
    } catch (e) {
      print('Failed to parse enhanced AI response: $e');
      return null;
    }
  }

  /// Safely parse JSON string with error handling
  Map<String, dynamic> _parseJsonSafely(String jsonString) {
    try {
      // First try to parse as-is
      return Map<String, dynamic>.from(
        const JsonDecoder().convert(jsonString) as Map<String, dynamic>,
      );
    } catch (e) {
      try {
        // Try to clean up common JSON issues
        String cleanedJson = jsonString
            .replaceAll(
              RegExp(r'[\x00-\x1F\x7F]'),
              '',
            ) // Remove control characters
            .replaceAll(
              RegExp(r',\s*}'),
              '}',
            ) // Remove trailing commas in objects
            .replaceAll(
              RegExp(r',\s*]'),
              ']',
            ) // Remove trailing commas in arrays
            .trim();

        return Map<String, dynamic>.from(
          const JsonDecoder().convert(cleanedJson) as Map<String, dynamic>,
        );
      } catch (e2) {
        print('Failed to parse JSON even after cleaning: $e2');
        print('Original JSON: $jsonString');
        return {};
      }
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

        // Sort vision models by strength (basic first for faster loading)
        final sortedModels = [...downloadedModels];
        sortedModels.sort((a, b) {
          final aInfo = AILeapService.availableModels[a];
          final bInfo = AILeapService.availableModels[b];

          // Sort by strength (basic < intermediate < advanced)
          final aStrength = aInfo?.strength.index ?? 0;
          final bStrength = bInfo?.strength.index ?? 0;
          return aStrength.compareTo(bStrength);
        });

        log('📊 Sorted models for loading: $sortedModels');

        for (final modelId in sortedModels) {
          log('🔄 Attempting to load model: $modelId');
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
            // Continue to next model
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
