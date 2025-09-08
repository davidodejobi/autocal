import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription_status.dart';
import '../models/event.dart';

// App state data class
class AppState {
  final SubscriptionStatus subscriptionStatus;
  final int dailyEventCount;
  final DateTime lastResetDate;
  final List<Event> recentEvents;
  final bool isLoading;
  final String? errorMessage;

  const AppState({
    required this.subscriptionStatus,
    required this.dailyEventCount,
    required this.lastResetDate,
    required this.recentEvents,
    required this.isLoading,
    this.errorMessage,
  });

  bool get canCreateEvent => subscriptionStatus.isPro || dailyEventCount < 5;

  AppState copyWith({
    SubscriptionStatus? subscriptionStatus,
    int? dailyEventCount,
    DateTime? lastResetDate,
    List<Event>? recentEvents,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AppState(
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      dailyEventCount: dailyEventCount ?? this.dailyEventCount,
      lastResetDate: lastResetDate ?? this.lastResetDate,
      recentEvents: recentEvents ?? this.recentEvents,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Main app state notifier for global state management
class AppStateNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    return AppState(
      subscriptionStatus: const SubscriptionStatus(
        isPro: false,
        isActive: false,
      ),
      dailyEventCount: 0,
      lastResetDate: DateTime.now(),
      recentEvents: const [],
      isLoading: false,
    );
  }

  // Subscription methods
  void updateSubscriptionStatus(SubscriptionStatus status) {
    state = state.copyWith(subscriptionStatus: status);
  }

  // Event count methods
  void incrementEventCount() {
    _checkDailyReset();
    if (!state.subscriptionStatus.isPro) {
      state = state.copyWith(dailyEventCount: state.dailyEventCount + 1);
    }
  }

  void _checkDailyReset() {
    final now = DateTime.now();
    if (now.day != state.lastResetDate.day ||
        now.month != state.lastResetDate.month ||
        now.year != state.lastResetDate.year) {
      state = state.copyWith(
        dailyEventCount: 0,
        lastResetDate: now,
      );
    }
  }

  // Event management
  void addRecentEvent(Event event) {
    final updatedEvents = [event, ...state.recentEvents];
    final limitedEvents = updatedEvents.length > 10 
        ? updatedEvents.take(10).toList() 
        : updatedEvents;
    
    state = state.copyWith(recentEvents: limitedEvents);
  }

  // Loading and error states
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Provider for the app state
final appStateProvider = NotifierProvider<AppStateNotifier, AppState>(() {
  return AppStateNotifier();
});