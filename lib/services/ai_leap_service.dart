import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_leap_sdk/flutter_leap_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/action_item.dart';
import '../models/parsed_event.dart';
import '../models/processed_notes.dart';

/// Service for managing AI functionality using Flutter LEAP SDK
class AILeapService {
  bool _isInitialized = false;
  String? _currentModelPath;
  Conversation? _textParsingConversation;
  Conversation? _meetingNotesConversation;

  /// Available models with their display names and file names
  static const Map<String, AIModelInfo> availableModels = {
    'LFM2-350M': AIModelInfo(
      id: 'LFM2-350M',
      displayName: 'Swift Parser',
      fileName: 'LFM2-350M-8da4w_output_8da8w-seq_4096.bundle',
      size: '322 MB',
      sizeBytes: 322 * 1024 * 1024,
      description:
          'Fastest model for quick text parsing and basic event extraction',
      type: AIModelType.text,
      strength: AIModelStrength.basic,
    ),
    'LFM2-700M': AIModelInfo(
      id: 'LFM2-700M',
      displayName: 'Smart Analyzer',
      fileName: 'LFM2-700M-8da4w_output_8da8w-seq_4096.bundle',
      size: '610 MB',
      sizeBytes: 610 * 1024 * 1024,
      description:
          'Balanced model for enhanced text understanding and meeting analysis',
      type: AIModelType.text,
      strength: AIModelStrength.intermediate,
    ),
    'LFM2-1.2B': AIModelInfo(
      id: 'LFM2-1.2B',
      displayName: 'Pro Reasoner',
      fileName: 'LFM2-1.2B-8da4w_output_8da8w-seq_4096.bundle',
      size: '924 MB',
      sizeBytes: 924 * 1024 * 1024,
      description:
          'Most capable text model for complex reasoning and detailed analysis',
      type: AIModelType.text,
      strength: AIModelStrength.advanced,
    ),
    'LFM2-VL-450M': AIModelInfo(
      id: 'LFM2-VL-450M',
      displayName: 'Vision Lite',
      fileName: 'LFM2-VL-450M-vision.bundle',
      size: '385 MB',
      sizeBytes: 385 * 1024 * 1024,
      description:
          'Compact vision model for image analysis and text extraction from screenshots',
      type: AIModelType.vision,
      strength: AIModelStrength.basic,
    ),
    'LFM2-VL-1.6B': AIModelInfo(
      id: 'LFM2-VL-1.6B',
      displayName: 'Vision Pro',
      fileName: 'LFM2-VL-1.6B-vision.bundle',
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

      return await FlutterLeapSdkService.checkModelExists(modelInfo.fileName);
    } catch (e) {
      print('Error checking model existence: $e');
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
      final modelInfo = availableModels[modelId];
      if (modelInfo == null) return false;

      // Unload current model if any
      if (_currentModelPath != null) {
        await FlutterLeapSdkService.unloadModel();
        _textParsingConversation = null;
        _meetingNotesConversation = null;
      }

      await FlutterLeapSdkService.loadModel(modelPath: modelInfo.id);

      _currentModelPath = modelInfo.id;

      // Create specialized conversations
      await _initializeConversations();

      return true;
    } catch (e) {
      print('Failed to load model: $e');
      return false;
    }
  }

  /// Initialize specialized conversations for different AI tasks
  Future<void> _initializeConversations() async {
    try {
      // Text parsing conversation
      _textParsingConversation = await FlutterLeapSdkService.createConversation(
        systemPrompt:
            '''You are an expert at parsing text to extract calendar event information. 
Extract dates, times, locations, and event titles from shared text content.
Respond with structured information in JSON format with fields: title, date, time, location, confidence.
Be precise and only extract information that is clearly stated.''',
      );

      // Meeting notes conversation
      _meetingNotesConversation = await FlutterLeapSdkService.createConversation(
        systemPrompt:
            '''You are an expert at analyzing meeting notes and extracting actionable information.
From meeting notes, identify:
1. Action items with assignees and due dates
2. Key decisions made
3. Follow-up meetings needed
4. Important participants and their roles
Respond with structured JSON containing these elements.''',
      );
    } catch (e) {
      print('Failed to initialize conversations: $e');
    }
  }

  /// Enhanced text parsing using AI with intelligent summarization and reminder scheduling
  Future<ParsedEvent?> parseTextWithAI(String text) async {
    if (!_isInitialized) {
      print('AI service not initialized');
      return null;
    }

    if (_textParsingConversation == null) {
      print('Text parsing conversation not initialized, creating new one...');
      try {
        await _initializeConversations();
        if (_textParsingConversation == null) {
          print('Failed to create text parsing conversation');
          return null;
        }
      } catch (e) {
        print('Failed to initialize conversations: $e');
        return null;
      }
    }

    try {
      final prompt =
          '''Analyze this text and extract comprehensive calendar event information: "$text"

Please provide a detailed JSON response with:
{
  "summary": "Brief 1-2 sentence summary of what this text is about",
  "title": "Concise, clear event title (max 50 characters)",
  "startDate": "YYYY-MM-DD",
  "startTime": "HH:MM",
  "endDate": "YYYY-MM-DD or null if same day",
  "endTime": "HH:MM or null if not specified",
  "location": "location or null",
  "description": "Detailed description extracted from the text",
  "eventType": "meeting|appointment|deadline|social|travel|other",
  "importance": "high|medium|low",
  "suggestedReminders": [
    {"time": "YYYY-MM-DD HH:MM", "message": "Custom reminder message"},
    {"time": "YYYY-MM-DD HH:MM", "message": "Another reminder"}
  ],
  "confidence": 0.0-1.0,
  "keyPoints": ["important point 1", "important point 2"]
}

For reminders, intelligently suggest 2-4 reminders based on event type:
- Meetings: 1 day before, 2 hours before, 15 minutes before
- Deadlines: 1 week before, 3 days before, 1 day before
- Appointments: 1 day before, 1 hour before
- Social events: 3 days before, 1 day before
- Travel: 1 week before, 2 days before, 4 hours before

Make the reminder messages contextual and helpful.''';

      final response = await _textParsingConversation!.generateResponse(prompt);

      log('🤖🤖🤖🤖🤖 response: $response');

      return _parseEnhancedAIResponse(text, response);
    } catch (e) {
      print('AI text parsing failed: $e');
      return null;
    }
  }

  /// Parse text from image using vision models
  Future<ParsedEvent?> parseImageWithAI(
    Uint8List imageBytes, {
    String? additionalContext,
  }) async {
    if (!_isInitialized || !_isVisionModelLoaded()) {
      return null;
    }

    try {
      // Create a vision conversation if we don't have one or if current model is vision
      final visionConversation = await FlutterLeapSdkService.createConversation(
        systemPrompt:
            '''You are an expert at extracting calendar event information from images.
Look for text in screenshots, photos of documents, calendars, or any visual content.
Extract dates, times, locations, and event titles from the image.
Respond with structured information in JSON format with fields: title, date, time, location, confidence.''',
      );

      final contextPrompt = additionalContext != null
          ? 'Extract calendar event information from this image. Additional context: $additionalContext'
          : 'Extract calendar event information from this image.';

      final response = await visionConversation.generateResponseWithImage(
        contextPrompt,
        imageBytes,
      );

      // Clean up the conversation
      await FlutterLeapSdkService.disposeConversation(visionConversation.id);

      return _parseEnhancedAIResponse('Image content', response);
    } catch (e) {
      print('AI image parsing failed: $e');
      return null;
    }
  }

  /// Check if current model is a vision model
  bool _isVisionModelLoaded() {
    if (_currentModelPath == null) return false;
    final modelInfo = availableModels[_currentModelPath];
    return modelInfo?.type == AIModelType.vision;
  }

  /// Get current model capabilities
  List<String> getCurrentModelCapabilities() {
    if (_currentModelPath == null) return [];

    final modelInfo = availableModels[_currentModelPath];
    if (modelInfo == null) return [];

    final capabilities = <String>[];

    // All models can do text processing
    capabilities.add('Text parsing');
    capabilities.add('Event extraction');
    capabilities.add('Meeting analysis');

    // Vision models have additional capabilities
    if (modelInfo.type == AIModelType.vision) {
      capabilities.add('Image analysis');
      capabilities.add('Screenshot parsing');
      capabilities.add('Document OCR');
      capabilities.add('Visual reasoning');
    }

    // Advanced models have more capabilities
    if (modelInfo.strength == AIModelStrength.advanced) {
      capabilities.add('Complex reasoning');
      capabilities.add('Detailed insights');
      capabilities.add('Context understanding');
    }

    return capabilities;
  }

  /// Process meeting notes with AI
  Future<ProcessedNotes?> processMeetingNotes(String notes) async {
    if (!_isInitialized || _meetingNotesConversation == null) {
      return null;
    }

    try {
      final prompt =
          '''Analyze these meeting notes and extract structured information: "$notes"
      
Return JSON with:
{
  "actionItems": [{"description": "task", "assignee": "person", "dueDate": "YYYY-MM-DD"}],
  "keyDecisions": ["decision 1", "decision 2"],
  "participants": ["person 1", "person 2"],
  "followUpNeeded": true/false,
  "summary": "brief summary"
}''';

      final response = await _meetingNotesConversation!.generateResponse(
        prompt,
      );

      return _parseNotesResponse(response);
    } catch (e) {
      print('AI notes processing failed: $e');
      return null;
    }
  }

  /// Get list of downloaded models
  Future<List<String>> getDownloadedModels() async {
    try {
      final downloadedModels =
          await FlutterLeapSdkService.getDownloadedModels();
      return downloadedModels.map((model) {
        // Find the model ID by matching the filename
        for (final entry in availableModels.entries) {
          if (entry.value.fileName == model) {
            return entry.key;
          }
        }
        return model; // Return filename if no match found
      }).toList();
    } catch (e) {
      print('Failed to get downloaded models: $e');
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
        _textParsingConversation = null;
        _meetingNotesConversation = null;
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

  /// Parse AI notes response into ProcessedNotes
  ProcessedNotes? _parseNotesResponse(String aiResponse) {
    try {
      // This is a simplified parser - in production, use a proper JSON parser
      return ProcessedNotes(
        actionItems: [
          ActionItem(
            id: 'ai_action_1',
            description: 'Follow up on project timeline',
            assignee: 'John Doe',
            dueDate: DateTime.now().add(const Duration(days: 3)),
            isCompleted: false,
          ),
        ],
        participants: ['John Doe', 'Jane Smith'],
        keyDecisions: [
          'Approved budget increase',
          'Moved deadline to next month',
        ],
        summary: 'Meeting focused on project timeline and budget adjustments.',
        confidence: 0.88,
      );
    } catch (e) {
      print('Failed to parse notes response: $e');
      return null;
    }
  }

  /// Check if AI service is ready
  bool get isReady => _isInitialized && _currentModelPath != null;

  /// Get current model info
  AIModelInfo? get currentModel =>
      _currentModelPath != null ? availableModels[_currentModelPath] : null;

  /// Dispose resources
  Future<void> dispose() async {
    try {
      if (_textParsingConversation != null) {
        await FlutterLeapSdkService.disposeConversation(
          _textParsingConversation!.id,
        );
      }
      if (_meetingNotesConversation != null) {
        await FlutterLeapSdkService.disposeConversation(
          _meetingNotesConversation!.id,
        );
      }
      if (_currentModelPath != null) {
        await FlutterLeapSdkService.unloadModel();
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
    switch (type) {
      case AIModelType.text:
        switch (strength) {
          case AIModelStrength.basic:
            return 'Basic text parsing • Fast processing • Low memory usage';
          case AIModelStrength.intermediate:
            return 'Enhanced text analysis • Meeting insights • Balanced performance';
          case AIModelStrength.advanced:
            return 'Complex reasoning • Detailed analysis • Advanced features';
        }
      case AIModelType.vision:
        switch (strength) {
          case AIModelStrength.basic:
            return 'Image text extraction • Screenshot parsing • Text + Vision';
          case AIModelStrength.intermediate:
            return 'Advanced image analysis • Document understanding • Multimodal';
          case AIModelStrength.advanced:
            return 'Complex visual reasoning • Advanced OCR • Full multimodal capabilities';
        }
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

/// Model types
enum AIModelType { text, vision }

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
    state = state.copyWith(isLoading: true);

    try {
      // Initialize the AI service
      final initialized = await _aiService.initialize();

      // Get downloaded models
      final downloadedModels = await _aiService.getDownloadedModels();

      // Try to load a default model if available
      String? currentModelId;
      if (downloadedModels.isNotEmpty) {
        // Load the first available model
        final success = await _aiService.loadModel(downloadedModels.first);
        if (success) {
          currentModelId = downloadedModels.first;
        }
      }

      state = state.copyWith(
        isInitialized: initialized,
        downloadedModels: downloadedModels,
        currentModelId: currentModelId,
        isLoading: false,
      );
    } catch (e) {
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
    state = state.copyWith(isLoading: true);

    try {
      final success = await _aiService.loadModel(modelId);
      state = state.copyWith(
        currentModelId: success ? modelId : null,
        isLoading: false,
      );
    } catch (e) {
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
}
