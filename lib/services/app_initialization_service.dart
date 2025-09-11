import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_leap_service.dart';

/// Service for initializing app services
class AppInitializationService {
  static final AppInitializationService _instance = AppInitializationService._internal();
  factory AppInitializationService() => _instance;
  AppInitializationService._internal();

  bool _isInitialized = false;

  /// Initialize all app services
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize AI service
      final aiService = AILeapService();
      await aiService.initialize();

      _isInitialized = true;
      return true;
    } catch (e) {
      print('Failed to initialize app services: $e');
      return false;
    }
  }

  bool get isInitialized => _isInitialized;
}

/// Provider for app initialization service
final appInitializationServiceProvider = Provider<AppInitializationService>((ref) {
  return AppInitializationService();
});

/// Provider for initialization state
final appInitializationProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(appInitializationServiceProvider);
  return await service.initialize();
});