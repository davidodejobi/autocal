import 'package:flutter/foundation.dart';

/// Model for productivity analytics and insights
@immutable
class ProductivityInsights {
  final String id;
  final String userId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final Map<EventCategory, Duration> timeByCategory;
  final List<ProductivityRecommendation> recommendations;
  final WorkLifeBalance workLifeBalance;
  final List<TimePattern> patterns;
  final double productivityScore;
  final DateTime generatedAt;

  const ProductivityInsights({
    required this.id,
    required this.userId,
    required this.periodStart,
    required this.periodEnd,
    required this.timeByCategory,
    required this.recommendations,
    required this.workLifeBalance,
    required this.patterns,
    required this.productivityScore,
    required this.generatedAt,
  });

  ProductivityInsights copyWith({
    String? id,
    String? userId,
    DateTime? periodStart,
    DateTime? periodEnd,
    Map<EventCategory, Duration>? timeByCategory,
    List<ProductivityRecommendation>? recommendations,
    WorkLifeBalance? workLifeBalance,
    List<TimePattern>? patterns,
    double? productivityScore,
    DateTime? generatedAt,
  }) {
    return ProductivityInsights(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      timeByCategory: timeByCategory ?? this.timeByCategory,
      recommendations: recommendations ?? this.recommendations,
      workLifeBalance: workLifeBalance ?? this.workLifeBalance,
      patterns: patterns ?? this.patterns,
      productivityScore: productivityScore ?? this.productivityScore,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'timeByCategory': timeByCategory.map(
        (key, value) => MapEntry(key.name, value.inMinutes),
      ),
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
      'workLifeBalance': workLifeBalance.toJson(),
      'patterns': patterns.map((p) => p.toJson()).toList(),
      'productivityScore': productivityScore,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory ProductivityInsights.fromJson(Map<String, dynamic> json) {
    return ProductivityInsights(
      id: json['id'] as String,
      userId: json['userId'] as String,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      timeByCategory: (json['timeByCategory'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          EventCategory.values.byName(key),
          Duration(minutes: value as int),
        ),
      ),
      recommendations: (json['recommendations'] as List)
          .map((r) => ProductivityRecommendation.fromJson(r as Map<String, dynamic>))
          .toList(),
      workLifeBalance: WorkLifeBalance.fromJson(json['workLifeBalance'] as Map<String, dynamic>),
      patterns: (json['patterns'] as List)
          .map((p) => TimePattern.fromJson(p as Map<String, dynamic>))
          .toList(),
      productivityScore: (json['productivityScore'] as num).toDouble(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductivityInsights &&
        other.id == id &&
        other.userId == userId &&
        other.periodStart == periodStart &&
        other.periodEnd == periodEnd &&
        mapEquals(other.timeByCategory, timeByCategory) &&
        listEquals(other.recommendations, recommendations) &&
        other.workLifeBalance == workLifeBalance &&
        listEquals(other.patterns, patterns) &&
        other.productivityScore == productivityScore &&
        other.generatedAt == generatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      periodStart,
      periodEnd,
      timeByCategory,
      recommendations,
      workLifeBalance,
      patterns,
      productivityScore,
      generatedAt,
    );
  }

  @override
  String toString() {
    return 'ProductivityInsights(id: $id, productivityScore: $productivityScore, period: $periodStart - $periodEnd)';
  }
}

/// Event categories for time tracking
enum EventCategory {
  work,
  personal,
  health,
  education,
  social,
  travel,
  meetings,
  focusTime,
  breaks,
  other,
}

/// Model for productivity recommendations
@immutable
class ProductivityRecommendation {
  final String id;
  final RecommendationType type;
  final String title;
  final String description;
  final String actionText;
  final double impact;
  final int priority;

  const ProductivityRecommendation({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.actionText,
    required this.impact,
    required this.priority,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'actionText': actionText,
      'impact': impact,
      'priority': priority,
    };
  }

  factory ProductivityRecommendation.fromJson(Map<String, dynamic> json) {
    return ProductivityRecommendation(
      id: json['id'] as String,
      type: RecommendationType.values.byName(json['type'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      actionText: json['actionText'] as String,
      impact: (json['impact'] as num).toDouble(),
      priority: json['priority'] as int,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductivityRecommendation &&
        other.id == id &&
        other.type == type &&
        other.title == title &&
        other.description == description &&
        other.actionText == actionText &&
        other.impact == impact &&
        other.priority == priority;
  }

  @override
  int get hashCode {
    return Object.hash(id, type, title, description, actionText, impact, priority);
  }
}

/// Types of productivity recommendations
enum RecommendationType {
  scheduleFocusTime,
  reduceMeetings,
  improveWorkLifeBalance,
  optimizeLocation,
  addBreaks,
  batchSimilarTasks,
}

/// Model for work-life balance analysis
@immutable
class WorkLifeBalance {
  final double workPercentage;
  final double personalPercentage;
  final Duration averageWorkDay;
  final int workDaysPerWeek;
  final BalanceRating rating;
  final List<String> suggestions;

  const WorkLifeBalance({
    required this.workPercentage,
    required this.personalPercentage,
    required this.averageWorkDay,
    required this.workDaysPerWeek,
    required this.rating,
    required this.suggestions,
  });

  Map<String, dynamic> toJson() {
    return {
      'workPercentage': workPercentage,
      'personalPercentage': personalPercentage,
      'averageWorkDay': averageWorkDay.inMinutes,
      'workDaysPerWeek': workDaysPerWeek,
      'rating': rating.name,
      'suggestions': suggestions,
    };
  }

  factory WorkLifeBalance.fromJson(Map<String, dynamic> json) {
    return WorkLifeBalance(
      workPercentage: (json['workPercentage'] as num).toDouble(),
      personalPercentage: (json['personalPercentage'] as num).toDouble(),
      averageWorkDay: Duration(minutes: json['averageWorkDay'] as int),
      workDaysPerWeek: json['workDaysPerWeek'] as int,
      rating: BalanceRating.values.byName(json['rating'] as String),
      suggestions: List<String>.from(json['suggestions'] as List),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkLifeBalance &&
        other.workPercentage == workPercentage &&
        other.personalPercentage == personalPercentage &&
        other.averageWorkDay == averageWorkDay &&
        other.workDaysPerWeek == workDaysPerWeek &&
        other.rating == rating &&
        listEquals(other.suggestions, suggestions);
  }

  @override
  int get hashCode {
    return Object.hash(
      workPercentage,
      personalPercentage,
      averageWorkDay,
      workDaysPerWeek,
      rating,
      suggestions,
    );
  }
}

/// Work-life balance rating
enum BalanceRating {
  excellent,
  good,
  fair,
  poor,
  critical,
}

/// Model for time usage patterns
@immutable
class TimePattern {
  final String id;
  final PatternType type;
  final String description;
  final double frequency;
  final Duration averageDuration;
  final List<int> commonDaysOfWeek;
  final List<int> commonHours;

  const TimePattern({
    required this.id,
    required this.type,
    required this.description,
    required this.frequency,
    required this.averageDuration,
    required this.commonDaysOfWeek,
    required this.commonHours,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'description': description,
      'frequency': frequency,
      'averageDuration': averageDuration.inMinutes,
      'commonDaysOfWeek': commonDaysOfWeek,
      'commonHours': commonHours,
    };
  }

  factory TimePattern.fromJson(Map<String, dynamic> json) {
    return TimePattern(
      id: json['id'] as String,
      type: PatternType.values.byName(json['type'] as String),
      description: json['description'] as String,
      frequency: (json['frequency'] as num).toDouble(),
      averageDuration: Duration(minutes: json['averageDuration'] as int),
      commonDaysOfWeek: List<int>.from(json['commonDaysOfWeek'] as List),
      commonHours: List<int>.from(json['commonHours'] as List),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimePattern &&
        other.id == id &&
        other.type == type &&
        other.description == description &&
        other.frequency == frequency &&
        other.averageDuration == averageDuration &&
        listEquals(other.commonDaysOfWeek, commonDaysOfWeek) &&
        listEquals(other.commonHours, commonHours);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      type,
      description,
      frequency,
      averageDuration,
      commonDaysOfWeek,
      commonHours,
    );
  }
}

/// Types of time patterns
enum PatternType {
  recurringMeeting,
  focusBlock,
  breakPattern,
  travelTime,
  personalTime,
  overwork,
}