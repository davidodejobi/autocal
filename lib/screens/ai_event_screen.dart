import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:flutter_leap_sdk/flutter_leap_sdk.dart'; // Removed - not needed after cleanup
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/parsed_event.dart';
import '../providers/event_provider.dart';
import '../services/ai_leap_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_typography.dart';
import 'ai_model_management_screen.dart';
import 'event_card_screen.dart';

/// Screen for AI-powered event creation using text or images
class AIEventScreen extends HookConsumerWidget {
  final DateTime? selectedDate;

  const AIEventScreen({super.key, this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController();
    final selectedImage = useState<File?>(null);
    final isProcessing = useState(false);
    final processingType = useState<String?>(null);
    final parsedEvent = useState<ParsedEvent?>(null);
    final errorMessage = useState<String?>(null);

    final aiService = useMemoized(() => AILeapService());
    final aiServiceState = ref.watch(aiServiceStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Event Creation'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Create events with AI',
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Use AI to extract calendar events from text or images',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // AI Status Card
              _buildAIStatusCard(context, aiServiceState, ref),
              const SizedBox(height: 16),

              // Debug buttons removed for production

              // Option Cards
              _buildOptionCard(
                context: context,
                title: 'Text Input',
                subtitle: 'Describe your event in natural language',
                icon: Icons.text_fields,
                enabled:
                    aiServiceState.isInitialized &&
                    aiServiceState.currentModelId != null &&
                    !_isVisionModelLoaded(aiServiceState.currentModelId),
                onTap: () => _showTextInputDialog(
                  context,
                  textController,
                  isProcessing,
                  processingType,
                  parsedEvent,
                  errorMessage,
                  aiService,
                  ref,
                ),
              ),
              const SizedBox(height: 16),

              _buildOptionCard(
                context: context,
                title: 'Image Vision',
                subtitle: 'Upload an image containing event information',
                icon: Icons.image,
                enabled:
                    aiServiceState.isInitialized &&
                    aiServiceState.currentModelId != null &&
                    _isVisionModelLoaded(aiServiceState.currentModelId),
                onTap: () => _selectAndProcessImage(
                  context,
                  selectedImage,
                  isProcessing,
                  processingType,
                  parsedEvent,
                  errorMessage,
                  aiService,
                  ref,
                ),
              ),
              const SizedBox(height: 16),

              _buildOptionCard(
                context: context,
                title: 'Camera Capture',
                subtitle: 'Take a photo of event details',
                icon: Icons.camera_alt,
                enabled:
                    aiServiceState.isInitialized &&
                    aiServiceState.currentModelId != null &&
                    _isVisionModelLoaded(aiServiceState.currentModelId),
                onTap: () => _captureAndProcessImage(
                  context,
                  selectedImage,
                  isProcessing,
                  processingType,
                  parsedEvent,
                  errorMessage,
                  aiService,
                  ref,
                ),
              ),

              const SizedBox(height: 32),

              // Processing Status
              if (isProcessing.value) ...[
                _buildProcessingIndicator(processingType.value),
                const SizedBox(height: 24),
              ],

              // Error Message
              if (errorMessage.value != null) ...[
                _buildErrorCard(errorMessage.value!),
                const SizedBox(height: 24),
              ],

              // Selected Image Preview
              if (selectedImage.value != null) ...[
                _buildImagePreview(selectedImage.value!),
                const SizedBox(height: 24),
              ],

              // Parsed Event Preview
              if (parsedEvent.value != null) ...[
                _buildEventPreview(context, parsedEvent.value!, ref),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Card(
      elevation: 2,
      color: enabled ? AppColors.surface : AppColors.surface.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: enabled
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: enabled ? AppColors.primary : AppColors.textSecondary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleLarge.copyWith(
                        color: enabled
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.bodyMedium.copyWith(
                        color: enabled
                            ? AppColors.textSecondary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.iconSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator(String? type) {
    return Card(
      elevation: 1,
      color: AppColors.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                type != null
                    ? 'Processing $type with AI...'
                    : 'Processing with AI...',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      elevation: 1,
      color: Colors.red.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                error,
                style: AppTypography.bodyLarge.copyWith(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(File image) {
    return Card(
      elevation: 2,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Image',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                image,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventPreview(
    BuildContext context,
    ParsedEvent event,
    WidgetRef ref,
  ) {
    return Card(
      elevation: 2,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Extracted Event',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(
                      event.confidence,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(event.confidence * 100).toInt()}% confident',
                    style: AppTypography.labelSmall.copyWith(
                      color: _getConfidenceColor(event.confidence),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Event details preview
            _buildEventDetail('Title', event.title ?? 'No title'),
            if (event.date != null)
              _buildEventDetail('Date', event.date!.toString().split(' ')[0]),
            if (event.startTime != null)
              _buildEventDetail(
                'Time',
                '${event.startTime!.hour.toString().padLeft(2, '0')}:${event.startTime!.minute.toString().padLeft(2, '0')}',
              ),
            if (event.location != null && event.location!.isNotEmpty)
              _buildEventDetail('Location', event.location!),
            if (event.description != null && event.description!.isNotEmpty)
              _buildEventDetail('Description', event.description!),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _navigateToEventCard(context, event, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Review & Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  void _showTextInputDialog(
    BuildContext context,
    TextEditingController textController,
    ValueNotifier<bool> isProcessing,
    ValueNotifier<String?> processingType,
    ValueNotifier<ParsedEvent?> parsedEvent,
    ValueNotifier<String?> errorMessage,
    AILeapService aiService,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Describe Your Event'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: textController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText:
                  'e.g., "Meeting with John tomorrow at 2 PM in the conference room about project planning"',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          // ElevatedButton(
          //   onPressed: () {
          //     Navigator.pop(context);
          //     _processTextWithAI(
          //       textController.text,
          //       isProcessing,
          //       processingType,
          //       parsedEvent,
          //       errorMessage,
          //       aiService,
          //       ref,
          //     );
          //   },
          //   child: const Text('Process'),
          // ),
        ],
      ),
    );
  }

  Future<void> _selectAndProcessImage(
    BuildContext context,
    ValueNotifier<File?> selectedImage,
    ValueNotifier<bool> isProcessing,
    ValueNotifier<String?> processingType,
    ValueNotifier<ParsedEvent?> parsedEvent,
    ValueNotifier<String?> errorMessage,
    AILeapService aiService,
    WidgetRef ref,
  ) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
        await _processImageWithAI(
          selectedImage.value!,
          isProcessing,
          processingType,
          parsedEvent,
          errorMessage,
          aiService,
          ref,
        );
      }
    } catch (e) {
      errorMessage.value = 'Failed to select image: $e';
    }
  }

  Future<void> _captureAndProcessImage(
    BuildContext context,
    ValueNotifier<File?> selectedImage,
    ValueNotifier<bool> isProcessing,
    ValueNotifier<String?> processingType,
    ValueNotifier<ParsedEvent?> parsedEvent,
    ValueNotifier<String?> errorMessage,
    AILeapService aiService,
    WidgetRef ref,
  ) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
        await _processImageWithAI(
          selectedImage.value!,
          isProcessing,
          processingType,
          parsedEvent,
          errorMessage,
          aiService,
          ref,
        );
      }
    } catch (e) {
      errorMessage.value = 'Failed to capture image: $e';
    }
  }

  Future<void> _processImageWithAI(
    File imageFile,
    ValueNotifier<bool> isProcessing,
    ValueNotifier<String?> processingType,
    ValueNotifier<ParsedEvent?> parsedEvent,
    ValueNotifier<String?> errorMessage,
    AILeapService aiService,
    WidgetRef ref,
  ) async {
    // Check AI readiness for vision
    final aiServiceState = ref.read(aiServiceStateProvider);
    if (!aiServiceState.isInitialized ||
        aiServiceState.currentModelId == null ||
        !_isVisionModelLoaded(aiServiceState.currentModelId)) {
      errorMessage.value =
          'Vision AI is not ready. Please download and load a vision model first.';
      return;
    }

    isProcessing.value = true;
    processingType.value = 'image';
    errorMessage.value = null;
    parsedEvent.value = null;

    try {
      final imageBytes = await imageFile.readAsBytes();
      log('Processing image with AI, size: ${imageBytes.length} bytes');
      final result = await aiService.parseImageWithAI(imageBytes);
      log('AI image processing result: $result');

      if (result != null) {
        parsedEvent.value = result;
      } else {
        errorMessage.value =
            'Failed to extract event information from image. Please ensure the image contains clear event details (text, dates, times) or try a different image.';
      }
    } catch (e) {
      log('Error processing image with AI: $e');

      // Provide more helpful error messages based on the specific error
      String userFriendlyError;
      if (e.toString().contains('model supports only string content') ||
          e.toString().contains('InvalidArgumentException')) {
        userFriendlyError =
            'Vision model error: The loaded model doesn\'t support image processing. '
            'Please ensure a vision model (like Vision Pro or Vision Lite) is downloaded and loaded, '
            'then try again.';
      } else if (e.toString().contains('Vision model') &&
          e.toString().contains('not found')) {
        userFriendlyError =
            'Vision model not available. Please download a vision model '
            '(Vision Pro or Vision Lite) from the AI Model Management screen first.';
      } else if (e.toString().contains('Failed to load')) {
        userFriendlyError =
            'Failed to load vision model. Please check that you have enough '
            'storage space and try restarting the app.';
      } else {
        userFriendlyError = 'Error processing image: ${e.toString()}';
      }

      errorMessage.value = userFriendlyError;
    } finally {
      isProcessing.value = false;
      processingType.value = null;
    }
  }

  void _navigateToEventCard(
    BuildContext context,
    ParsedEvent event,
    WidgetRef ref,
  ) {
    // Update the event provider with the parsed event
    ref.read(eventProvider.notifier).setParsedEvent(event);

    // Navigate to event card screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => EventCardScreen(parsedEvent: event),
      ),
    );
  }

  Widget _buildAIStatusCard(
    BuildContext context,
    AIServiceState aiServiceState,
    WidgetRef ref,
  ) {
    String statusText;
    IconData statusIcon;
    Color statusColor;
    Widget? actionWidget;

    if (aiServiceState.isLoading) {
      statusText = 'Initializing AI service...';
      statusIcon = Icons.sync;
      statusColor = AppColors.primary;
    } else if (aiServiceState.error != null) {
      statusText = 'AI service error: ${aiServiceState.error}';
      statusIcon = Icons.error;
      statusColor = Colors.red;
    } else if (!aiServiceState.isInitialized) {
      statusText = 'AI service not initialized';
      statusIcon = Icons.warning;
      statusColor = Colors.orange;
    } else if (aiServiceState.downloadedModels.isEmpty) {
      statusText = 'No AI models downloaded. Download a model to get started.';
      statusIcon = Icons.download;
      statusColor = Colors.orange;
      actionWidget = ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AIModelManagementScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        child: const Text('Download Models'),
      );
    } else if (aiServiceState.currentModelId == null) {
      statusText =
          'AI models available but none loaded. Load a model to continue.';
      statusIcon = Icons.play_arrow;
      statusColor = Colors.blue;
      actionWidget = ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AIModelManagementScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        child: const Text('Load Model'),
      );
    } else {
      final modelInfo =
          AILeapService.availableModels[aiServiceState.currentModelId];
      statusText =
          'AI ready with ${modelInfo?.displayName ?? aiServiceState.currentModelId}';
      statusIcon = Icons.check_circle;
      statusColor = Colors.green;
    }

    return Card(
      elevation: 1,
      color: statusColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Status',
                    style: AppTypography.labelMedium.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (actionWidget != null) ...[
              const SizedBox(width: 12),
              actionWidget,
            ],
          ],
        ),
      ),
    );
  }

  bool _isVisionModelLoaded(String? modelId) {
    if (modelId == null) return false;
    final modelInfo = AILeapService.availableModels[modelId];
    return modelInfo?.type == AIModelType.vision;
  }

  // Debug method removed for production

  // Test methods removed for production

  // Fallback event creation method removed - handled elsewhere
}
