import 'package:flutter/material.dart';

/// App color constants and utilities
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2563EB); // Blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF3B82F6);
  
  // Background Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Confidence Score Colors
  static const Color confidenceHigh = Color(0xFF10B981); // Green
  static const Color confidenceMedium = Color(0xFFF59E0B); // Orange
  static const Color confidenceLow = Color(0xFFEF4444); // Red
  
  // Border Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  
  // Icon Colors
  static const Color iconPrimary = Color(0xFF475569);
  static const Color iconSecondary = Color(0xFF94A3B8);
  
  // Pro Feature Colors
  static const Color proGradientStart = Color(0xFF8B5CF6);
  static const Color proGradientEnd = Color(0xFF3B82F6);
  
  /// Get confidence color based on percentage
  static Color getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return confidenceHigh;
    if (confidence >= 0.6) return confidenceMedium;
    return confidenceLow;
  }
  
  /// Get confidence text based on percentage
  static String getConfidenceText(double confidence) {
    final percentage = (confidence * 100).round();
    return '$percentage% confidence';
  }
}