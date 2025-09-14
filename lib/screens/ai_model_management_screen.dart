import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/ai_leap_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';

// AI Model Management screen for Pro users
class AIModelManagementScreen extends HookConsumerWidget {
  const AIModelManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiServiceState = ref.watch(aiServiceStateProvider);
    final aiServiceNotifier = ref.read(aiServiceStateProvider.notifier);

    // Get model information from the AI service
    final models = AILeapService.availableModels.entries.map((entry) {
      final modelId = entry.key;
      final modelInfo = entry.value;
      final isDownloaded = aiServiceState.downloadedModels.contains(modelId);
      final isDownloading = aiServiceState.downloadProgress.containsKey(
        modelId,
      );
      final isCurrent = aiServiceState.currentModelId == modelId;

      String status;
      if (isCurrent) {
        status = 'ready';
      } else if (isDownloading) {
        status = 'downloading';
      } else if (isDownloaded) {
        status = 'update_available'; // Could check for updates
      } else {
        status = 'available';
      }

      return {
        'id': modelId,
        'name': modelInfo.displayName,
        'size': modelInfo.size,
        'status': status,
        'description': modelInfo.description,
        'progress': aiServiceState.downloadProgress[modelId] ?? 0.0,
        'strengthIndicator': modelInfo.strengthIndicator,
        'capabilities': modelInfo.capabilityDescription,
        'type': modelInfo.type.name,
      };
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Models'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => aiServiceNotifier.refreshDownloadedModels(),
            tooltip: 'Refresh Models',
          ),
        ],
      ),
      body: aiServiceState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error display
                  if (aiServiceState.error != null)
                    _buildErrorCard(
                      context,
                      aiServiceState.error!,
                      aiServiceNotifier,
                    ),

                  // Privacy Notice
                  _buildPrivacyNotice(context),
                  const SizedBox(height: AppSpacing.sectionSpacing),

                  // Storage Usage
                  _buildStorageUsage(context, aiServiceState),
                  const SizedBox(height: AppSpacing.sectionSpacing),

                  // Available Models
                  Text(
                    'Available Models',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Model List
                  ...models.map(
                    (model) =>
                        _buildModelItem(context, ref, model, aiServiceNotifier),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPrivacyNotice(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: AppColors.info, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'All processing happens on your device. No data is sent to servers.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.info),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(
    BuildContext context,
    String error,
    AIServiceStateNotifier notifier,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              error,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
            ),
          ),
          IconButton(
            onPressed: () => notifier.clearError(),
            icon: const Icon(Icons.close),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildStorageUsage(
    BuildContext context,
    AIServiceState aiServiceState,
  ) {
    // Calculate storage usage based on downloaded models
    int totalUsedBytes = 0;
    for (final modelId in aiServiceState.downloadedModels) {
      final modelInfo = AILeapService.availableModels[modelId];
      if (modelInfo != null) {
        totalUsedBytes += modelInfo.sizeBytes;
      }
    }

    const int totalAvailableBytes = 20 * 1024 * 1024 * 1024; // 20 GB
    final double usagePercentage = totalUsedBytes / totalAvailableBytes;
    final String usedGB = (totalUsedBytes / (1024 * 1024 * 1024))
        .toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Storage Usage', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$usedGB GB / 20 GB',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${(usagePercentage * 100).toInt()}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(
                value: usagePercentage,
                backgroundColor: AppColors.borderLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  usagePercentage > 0.8 ? AppColors.warning : AppColors.primary,
                ),
                minHeight: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModelItem(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> model,
    AIServiceStateNotifier aiServiceNotifier,
  ) {
    final status = model['status'] as String;
    final modelId = model['id'] as String;
    final isDownloading = status == 'downloading';
    final progress = model['progress'] as double;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                model['name'] as String,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                model['strengthIndicator'] as String,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              if (model['type'] == 'vision') ...[
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'VISION',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.info,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  model['type'] == 'vision'
                      ? Icons.visibility_outlined
                      : Icons.psychology_outlined,
                  size: 24,
                  color: model['type'] == 'vision'
                      ? AppColors.info
                      : AppColors.iconPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showModelDetails(context, model),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model['size'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        model['capabilities'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              _buildModelActionButton(
                context,
                status,
                modelId,
                aiServiceNotifier,
              ),
            ],
          ),
          if (isDownloading) ...[
            const SizedBox(height: AppSpacing.md),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Downloading...',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Row(
                      children: [
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        GestureDetector(
                          onTap: () =>
                              aiServiceNotifier.cancelDownload(modelId),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceVariant,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: AppColors.iconSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.borderLight,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 4,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModelActionButton(
    BuildContext context,
    String status,
    String modelId,
    AIServiceStateNotifier aiServiceNotifier,
  ) {
    switch (status) {
      case 'ready':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 16, color: AppColors.success),
              const SizedBox(width: 4),
              Text(
                'Ready',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );

      case 'update_available':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Show loading state and attempt to load model
                try {
                  await aiServiceNotifier.loadModel(modelId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Model $modelId loaded successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to load model: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Load', style: TextStyle(fontSize: 11)),
            ),
            const SizedBox(width: 4),
            ElevatedButton(
              onPressed: () => aiServiceNotifier.downloadModel(modelId),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Update', style: TextStyle(fontSize: 11)),
            ),
          ],
        );

      case 'available':
        return ElevatedButton.icon(
          onPressed: () => aiServiceNotifier.downloadModel(modelId),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const Icon(Icons.download, size: 16),
          label: const Text('Download', style: TextStyle(fontSize: 12)),
        );

      case 'downloading':
        return const SizedBox.shrink();

      default:
        return OutlinedButton(
          onPressed: () => aiServiceNotifier.downloadModel(modelId),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Download', style: TextStyle(fontSize: 12)),
        );
    }
  }

  void _showModelDetails(BuildContext context, Map<String, dynamic> model) {
    final modelId = model['id'] as String;
    final modelInfo = AILeapService.availableModels[modelId];

    if (modelInfo == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              model['type'] == 'vision'
                  ? Icons.visibility_outlined
                  : Icons.psychology_outlined,
              color: model['type'] == 'vision'
                  ? AppColors.info
                  : AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                model['name'] as String,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Model type and strength
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: model['type'] == 'vision'
                        ? AppColors.info.withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    model['type'] == 'vision' ? 'VISION + TEXT' : 'TEXT ONLY',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: model['type'] == 'vision'
                          ? AppColors.info
                          : AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  model['strengthIndicator'] as String,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Size
            Text(
              'Size: ${model['size']}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Description
            Text(
              modelInfo.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),

            // Capabilities
            Text(
              'Capabilities:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              model['capabilities'] as String,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            if (model['type'] == 'vision') ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 16),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Vision models can process both text and images, making them perfect for analyzing screenshots and documents.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.info),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
