import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/parsed_event.dart';
import '../services/ai_leap_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_typography.dart';

class AITestScreen extends HookConsumerWidget {
  const AITestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiService = useMemoized(() => AILeapService());
    final aiServiceState = ref.watch(aiServiceStateProvider);
    final aiServiceNotifier = ref.read(aiServiceStateProvider.notifier);

    // Text testing state
    final textController = useTextEditingController();
    final isTextProcessing = useState(false);
    final textResult = useState<ParsedEvent?>(null);
    final textError = useState<String?>(null);

    // Image testing state
    final selectedImage = useState<File?>(null);
    final isImageProcessing = useState(false);
    final imageResult = useState<ParsedEvent?>(null);
    final imageError = useState<String?>(null);

    // Service state
    final isInitializing = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Test Page'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Service Status Section
            _buildServiceStatusSection(
              context,
              aiServiceState,
              aiServiceNotifier,
              isInitializing,
            ),

            const SizedBox(height: AppSpacing.xl),

            // AI Model Management Section
            _buildModelManagementSection(
              context,
              aiService,
              aiServiceState,
              aiServiceNotifier,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Text AI Testing Section
            _buildTextTestSection(
              context,
              textController,
              isTextProcessing,
              textResult,
              textError,
              aiService,
              aiServiceState,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Image AI Testing Section
            _buildImageTestSection(
              context,
              selectedImage,
              isImageProcessing,
              imageResult,
              imageError,
              aiService,
              aiServiceState,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceStatusSection(
    BuildContext context,
    AIServiceState aiServiceState,
    AIServiceStateNotifier aiServiceNotifier,
    ValueNotifier<bool> isInitializing,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Service Status', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.md),

            // Status indicators
            _buildStatusRow('Initialized', aiServiceState.isInitialized),
            _buildStatusRow('Loading', aiServiceState.isLoading),
            _buildStatusRow(
              'Downloaded Models',
              aiServiceState.downloadedModels.isNotEmpty,
              '${aiServiceState.downloadedModels.length} models',
            ),
            _buildStatusRow(
              'Current Model',
              aiServiceState.currentModelId != null,
              aiServiceState.currentModelId ?? 'None',
            ),

            if (aiServiceState.error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Error: ${aiServiceState.error}',
                  style: AppTypography.bodySmall.copyWith(color: Colors.red),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.lg),

            // Initialize button
            if (!aiServiceState.isInitialized && !isInitializing.value)
              ElevatedButton(
                onPressed: () =>
                    _initializeAI(aiServiceNotifier, isInitializing),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Initialize AI Service'),
              ),

            if (isInitializing.value)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool status, [String? value]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.cancel,
            color: status ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$label: ${value ?? (status ? 'Yes' : 'No')}',
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildModelManagementSection(
    BuildContext context,
    AILeapService aiService,
    AIServiceState aiServiceState,
    AIServiceStateNotifier aiServiceNotifier,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Model Management', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.md),

            // Available Models Section
            Text('Available Models', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.sm),

            // Display available models
            ...AILeapService.availableModels.entries.map((entry) {
              final modelId = entry.key;
              final modelInfo = entry.value;
              final isDownloaded = aiServiceState.downloadedModels.contains(
                modelId,
              );
              final isCurrentModel = aiServiceState.currentModelId == modelId;
              final isDownloading = aiServiceState.downloadProgress.containsKey(
                modelId,
              );
              final downloadProgress =
                  aiServiceState.downloadProgress[modelId] ?? 0.0;

              return _buildModelCard(
                context,
                modelId,
                modelInfo,
                isDownloaded,
                isCurrentModel,
                isDownloading,
                downloadProgress,
                aiService,
                aiServiceNotifier,
                aiServiceState.isInitialized,
              );
            }),

            const SizedBox(height: AppSpacing.lg),

            // Refresh Models Button
            ElevatedButton.icon(
              onPressed: aiServiceState.isInitialized
                  ? () => _refreshModels(aiServiceNotifier)
                  : null,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Model List'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelCard(
    BuildContext context,
    String modelId,
    AIModelInfo modelInfo,
    bool isDownloaded,
    bool isCurrentModel,
    bool isDownloading,
    double downloadProgress,
    AILeapService aiService,
    AIServiceStateNotifier aiServiceNotifier,
    bool isInitialized,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      elevation: isCurrentModel ? 4 : 1,
      color: isCurrentModel ? AppColors.primary.withValues(alpha: 0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        modelInfo.displayName,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: isCurrentModel
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        modelInfo.capabilityDescription,
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: modelInfo.type == AIModelType.vision
                                  ? Colors.purple.withValues(alpha: 0.2)
                                  : Colors.blue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              modelInfo.type == AIModelType.vision
                                  ? 'Vision'
                                  : 'Text',
                              style: AppTypography.bodySmall.copyWith(
                                color: modelInfo.type == AIModelType.vision
                                    ? Colors.purple.shade700
                                    : Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            modelInfo.strengthIndicator,
                            style: AppTypography.bodySmall,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            modelInfo.size,
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isCurrentModel)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Progress bar for downloading
            if (isDownloading) ...[
              LinearProgressIndicator(
                value: downloadProgress,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Downloading... ${(downloadProgress * 100).toStringAsFixed(1)}%',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

            // Action buttons
            Row(
              children: [
                if (!isDownloaded && !isDownloading)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isInitialized
                          ? () => _downloadModel(modelId, aiServiceNotifier)
                          : null,
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                if (isDownloading)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _cancelDownload(modelId, aiServiceNotifier),
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                if (isDownloaded && !isCurrentModel) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isInitialized
                          ? () => _loadModel(modelId, aiServiceNotifier)
                          : null,
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Load'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isInitialized
                          ? () => _deleteModel(modelId, aiServiceNotifier)
                          : null,
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],

                if (isCurrentModel)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isInitialized
                          ? () => _unloadModel(aiServiceNotifier)
                          : null,
                      icon: const Icon(Icons.stop, size: 18),
                      label: const Text('Unload'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextTestSection(
    BuildContext context,
    TextEditingController textController,
    ValueNotifier<bool> isTextProcessing,
    ValueNotifier<ParsedEvent?> textResult,
    ValueNotifier<String?> textError,
    AILeapService aiService,
    AIServiceState aiServiceState,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Text AI Testing', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.md),

            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Enter text to parse',
                hintText:
                    'e.g., "Meeting with John tomorrow at 2 PM in Conference Room A"',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: AppSpacing.md),

            if (textError.value != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Error: ${textError.value}',
                  style: AppTypography.bodySmall.copyWith(color: Colors.red),
                ),
              ),
            ],

            if (textResult.value != null) ...[
              const SizedBox(height: AppSpacing.md),
              _buildResultCard('Text AI Result', textResult.value!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageTestSection(
    BuildContext context,
    ValueNotifier<File?> selectedImage,
    ValueNotifier<bool> isImageProcessing,
    ValueNotifier<ParsedEvent?> imageResult,
    ValueNotifier<String?> imageError,
    AILeapService aiService,
    AIServiceState aiServiceState,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Image AI Testing', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.md),

            // Image selection
            if (selectedImage.value != null) ...[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(selectedImage.value!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _pickImage(selectedImage),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(
                      selectedImage.value == null
                          ? 'Select Image'
                          : 'Change Image',
                    ),
                  ),
                ),
                if (selectedImage.value != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          aiServiceState.isInitialized &&
                              !isImageProcessing.value
                          ? () => _testImageAI(
                              selectedImage.value!,
                              aiService,
                              isImageProcessing,
                              imageResult,
                              imageError,
                            )
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: isImageProcessing.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Test Image AI'),
                    ),
                  ),
                ],
              ],
            ),

            if (imageError.value != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Error: ${imageError.value}',
                  style: AppTypography.bodySmall.copyWith(color: Colors.red),
                ),
              ),
            ],

            if (imageResult.value != null) ...[
              const SizedBox(height: AppSpacing.md),
              _buildResultCard('Image AI Result', imageResult.value!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String title, ParsedEvent result) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          if (result.title != null) _buildResultRow('Title', result.title!),
          if (result.date != null)
            _buildResultRow('Date', result.date!.toString().split(' ')[0]),
          if (result.startTime != null)
            _buildResultRow(
              'Start Time',
              '${result.startTime!.hour}:${result.startTime!.minute.toString().padLeft(2, '0')}',
            ),
          if (result.endTime != null)
            _buildResultRow(
              'End Time',
              '${result.endTime!.hour}:${result.endTime!.minute.toString().padLeft(2, '0')}',
            ),
          if (result.location != null)
            _buildResultRow('Location', result.location!),
          if (result.description != null)
            _buildResultRow('Description', result.description!),

          _buildResultRow(
            'Confidence',
            '${(result.confidence * 100).toStringAsFixed(1)}%',
          ),

          if (result.keyPoints != null && result.keyPoints!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Key Points:',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            ...result.keyPoints!.map(
              (point) => Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.md,
                  top: AppSpacing.xs,
                ),
                child: Text('• $point', style: AppTypography.bodySmall),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }

  Future<void> _initializeAI(
    AIServiceStateNotifier aiServiceNotifier,
    ValueNotifier<bool> isInitializing,
  ) async {
    isInitializing.value = true;
    try {
      await aiServiceNotifier.initialize();
      dev.log('✅ AI service initialized successfully');
    } catch (e) {
      dev.log('❌ Failed to initialize AI service: $e');
    } finally {
      isInitializing.value = false;
    }
  }
}

Future<void> _testImageAI(
  File imageFile,
  AILeapService aiService,
  ValueNotifier<bool> isImageProcessing,
  ValueNotifier<ParsedEvent?> imageResult,
  ValueNotifier<String?> imageError,
) async {
  isImageProcessing.value = true;
  imageResult.value = null;
  imageError.value = null;

  try {
    dev.log('🧪 Testing image AI with file: ${imageFile.path}');
    final imageBytes = await imageFile.readAsBytes();
    dev.log('📷 Image size: ${imageBytes.length} bytes');

    final result = await aiService.parseImageWithAI(imageBytes);

    if (result != null) {
      imageResult.value = result;
      dev.log('✅ Image AI test successful');
    } else {
      imageError.value =
          'AI returned null result. Check that a vision model is loaded.';
    }
  } catch (e) {
    dev.log('❌ Image AI test failed: $e');
    imageError.value = 'Error: ${e.toString()}';
  } finally {
    isImageProcessing.value = false;
  }
}

Future<void> _pickImage(ValueNotifier<File?> selectedImage) async {
  try {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
      dev.log('📷 Image selected: ${pickedFile.path}');
    }
  } catch (e) {
    dev.log('❌ Failed to pick image: $e');
  }
}

// Model management methods
Future<void> _refreshModels(AIServiceStateNotifier aiServiceNotifier) async {
  try {
    dev.log('🔄 Refreshing model list...');
    // Force refresh by calling the private _initialize method
    await aiServiceNotifier.initialize();
    dev.log('✅ Model list refreshed');
  } catch (e) {
    dev.log('❌ Failed to refresh models: $e');
  }
}

Future<void> _downloadModel(
  String modelId,
  AIServiceStateNotifier aiServiceNotifier,
) async {
  try {
    dev.log('📥 Starting download for model: $modelId');
    await aiServiceNotifier.downloadModel(modelId);
    dev.log('✅ Model download completed: $modelId');
  } catch (e) {
    dev.log('❌ Failed to download model $modelId: $e');
  }
}

Future<void> _loadModel(
  String modelId,
  AIServiceStateNotifier aiServiceNotifier,
) async {
  try {
    dev.log('🚀 Loading model: $modelId');
    await aiServiceNotifier.loadModel(modelId);
    dev.log('✅ Model loaded: $modelId');
  } catch (e) {
    dev.log('❌ Failed to load model $modelId: $e');
  }
}

Future<void> _deleteModel(
  String modelId,
  AIServiceStateNotifier aiServiceNotifier,
) async {
  try {
    dev.log('🗑️ Deleting model: $modelId');
    await aiServiceNotifier.deleteModel(modelId);
    dev.log('✅ Model deleted: $modelId');
  } catch (e) {
    dev.log('❌ Failed to delete model $modelId: $e');
  }
}

Future<void> _unloadModel(AIServiceStateNotifier aiServiceNotifier) async {
  try {
    dev.log('⏹️ Unloading current model...');
    await aiServiceNotifier.unloadModel();
    dev.log('✅ Model unloaded successfully');
  } catch (e) {
    dev.log('❌ Failed to unload model: $e');
  }
}

void _cancelDownload(String modelId, AIServiceStateNotifier aiServiceNotifier) {
  try {
    dev.log('❌ Cancelling download for model: $modelId');
    aiServiceNotifier.cancelDownload(modelId);
    dev.log('✅ Download cancelled: $modelId');
  } catch (e) {
    dev.log('❌ Failed to cancel download for $modelId: $e');
  }
}
