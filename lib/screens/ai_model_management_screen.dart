import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';

// AI Model Management screen for Pro users
class AIModelManagementScreen extends HookConsumerWidget {
  const AIModelManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadProgress = useState<Map<String, double>>({});

    // Mock model data - in real implementation, this would come from a provider
    final models = [
      {
        'id': 'model_a',
        'name': 'Model A',
        'size': '1.2 GB',
        'status': 'ready',
        'description': 'Enhanced text parsing model',
      },
      {
        'id': 'model_b',
        'name': 'Model B',
        'size': '1.5 GB',
        'status': 'update_available',
        'description': 'Meeting notes analysis model',
      },
      {
        'id': 'model_c',
        'name': 'Model C',
        'size': '1.8 GB',
        'status': 'available',
        'description': 'Voice processing model',
      },
      {
        'id': 'model_d',
        'name': 'Model D',
        'size': '2.0 GB',
        'status': 'available',
        'description': 'Advanced language understanding',
      },
      {
        'id': 'model_e',
        'name': 'Model E',
        'size': '2.2 GB',
        'status': 'downloading',
        'description': 'Experimental features model',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Models'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Privacy Notice
            _buildPrivacyNotice(context),
            const SizedBox(height: AppSpacing.sectionSpacing),

            // Storage Usage
            _buildStorageUsage(context),
            const SizedBox(height: AppSpacing.sectionSpacing),

            // Available Models
            Text(
              'Available Models',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),

            // Model List
            ...models.map((model) => _buildModelItem(
              context,
              ref,
              model,
              downloadProgress,
            )),
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
          Icon(
            Icons.security,
            color: AppColors.info,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'All processing happens on your device. No data is sent to servers.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageUsage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Storage Usage',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
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
                    '12 GB / 20 GB',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '60%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(
                value: 0.6,
                backgroundColor: AppColors.borderLight,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
    ValueNotifier<Map<String, double>> downloadProgress,
  ) {
    final status = model['status'] as String;
    final modelId = model['id'] as String;
    final isDownloading = status == 'downloading';
    final progress = downloadProgress.value[modelId] ?? 0.0;

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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology_outlined,
                  size: 24,
                  color: AppColors.iconPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model['name'] as String,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      model['size'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildModelActionButton(context, status, modelId, downloadProgress),
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
                          onTap: () => _cancelDownload(modelId, downloadProgress),
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
    ValueNotifier<Map<String, double>> downloadProgress,
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
              Icon(
                Icons.check_circle,
                size: 16,
                color: AppColors.success,
              ),
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
        return ElevatedButton(
          onPressed: () => _updateModel(modelId, downloadProgress),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.info,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Update',
            style: TextStyle(fontSize: 12),
          ),
        );

      case 'available':
        return ElevatedButton.icon(
          onPressed: () => _downloadModel(modelId, downloadProgress),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const Icon(Icons.download, size: 16),
          label: const Text(
            'Download',
            style: TextStyle(fontSize: 12),
          ),
        );

      case 'downloading':
        return const SizedBox.shrink();

      default:
        return OutlinedButton(
          onPressed: () => _downloadModel(modelId, downloadProgress),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Download',
            style: TextStyle(fontSize: 12),
          ),
        );
    }
  }

  void _downloadModel(String modelId, ValueNotifier<Map<String, double>> downloadProgress) {
    // Simulate download progress
    downloadProgress.value = {...downloadProgress.value, modelId: 0.0};
    
    // Simulate download progress updates
    _simulateDownload(modelId, downloadProgress);
  }

  void _updateModel(String modelId, ValueNotifier<Map<String, double>> downloadProgress) {
    // Similar to download but for updates
    _downloadModel(modelId, downloadProgress);
  }

  void _cancelDownload(String modelId, ValueNotifier<Map<String, double>> downloadProgress) {
    final newProgress = Map<String, double>.from(downloadProgress.value);
    newProgress.remove(modelId);
    downloadProgress.value = newProgress;
  }

  void _simulateDownload(String modelId, ValueNotifier<Map<String, double>> downloadProgress) {
    // This is just for demo purposes - in real implementation, this would be handled by the AI service
    Future.delayed(const Duration(milliseconds: 100), () {
      final currentProgress = downloadProgress.value[modelId] ?? 0.0;
      if (currentProgress < 1.0) {
        downloadProgress.value = {
          ...downloadProgress.value,
          modelId: currentProgress + 0.02,
        };
        _simulateDownload(modelId, downloadProgress);
      } else {
        final newProgress = Map<String, double>.from(downloadProgress.value);
        newProgress.remove(modelId);
        downloadProgress.value = newProgress;
      }
    });
  }
}