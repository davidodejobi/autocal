import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_typography.dart';

/// Custom floating bottom navigation bar widget
/// Features:
/// - Pill-shaped design with rounded corners
/// - Floating above content with shadow
/// - Smooth animations between tabs
/// - Custom styling with green accent for active state
class CustomFloatingNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<FloatingNavItem> items;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? elevation;
  final EdgeInsets? margin;
  final double? borderRadius;
  final Duration? animationDuration;

  const CustomFloatingNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.elevation,
    this.margin,
    this.borderRadius,
    this.animationDuration,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth =
        (screenWidth - (margin?.horizontal ?? 32) - 32) / items.length;

    return Container(
      margin: margin ?? const EdgeInsets.all(AppSpacing.md),
      child: Material(
        elevation: elevation ?? 8.0,
        borderRadius: BorderRadius.circular(borderRadius ?? 28.0),
        color:
            backgroundColor ??
            const Color(0xFF2A2A2A), // Dark background like in image
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return Expanded(
                child: _buildNavigationItem(
                  context,
                  item,
                  isSelected,
                  index,
                  itemWidth,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    FloatingNavItem item,
    bool isSelected,
    int index,
    double itemWidth,
  ) {
    final activeColorValue =
        activeColor ?? const Color(0xFF9AFF7A); // Green from image
    final inactiveColorValue = inactiveColor ?? Colors.white.withOpacity(0.6);

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: animationDuration ?? const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? activeColorValue : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              AnimatedContainer(
                duration:
                    animationDuration ?? const Duration(milliseconds: 300),
                child: Icon(
                  isSelected ? item.activeIcon ?? item.icon : item.icon,
                  color: isSelected ? Colors.black : inactiveColorValue,
                  size: 20,
                ),
              ),

              // Label (only show when selected)
              if (isSelected && item.label != null) ...[
                const SizedBox(width: 8),
                AnimatedOpacity(
                  duration:
                      animationDuration ?? const Duration(milliseconds: 300),
                  opacity: isSelected ? 1.0 : 0.0,
                  child: Text(
                    item.label!,
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigation item model for the floating navigation bar
class FloatingNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String? label;
  final Color? color;

  const FloatingNavItem({
    required this.icon,
    this.activeIcon,
    this.label,
    this.color,
  });
}

/// Enhanced version with more customization options and scroll-based visibility
class CustomFloatingNavigationBarEnhanced extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<FloatingNavItem> items;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? elevation;
  final EdgeInsets? margin;
  final double? borderRadius;
  final Duration? animationDuration;
  final bool showLabels;
  final bool enableHapticFeedback;
  final BoxShadow? customShadow;
  final bool isVisible;

  const CustomFloatingNavigationBarEnhanced({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.elevation,
    this.margin,
    this.borderRadius,
    this.animationDuration,
    this.showLabels = true,
    this.enableHapticFeedback = true,
    this.customShadow,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: animationDuration ?? const Duration(milliseconds: 300),
      offset: isVisible
          ? Offset.zero
          : const Offset(0, 2), // Slide down when hidden
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        duration: animationDuration ?? const Duration(milliseconds: 300),
        opacity: isVisible ? 1.0 : 0.0,
        curve: Curves.easeInOut,
        child: Container(
          margin: margin ?? const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius ?? 24.0),
            boxShadow: [
              customShadow ??
                  BoxShadow(
                    color: AppColors.primary.withOpacity(
                      isVisible ? 0.08 : 0.03,
                    ),
                    blurRadius: isVisible ? 16 : 8,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius ?? 24.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: (backgroundColor ?? AppColors.surface).withOpacity(
                    0.95,
                  ),
                  borderRadius: BorderRadius.circular(borderRadius ?? 24.0),
                  border: Border.all(
                    color: AppColors.border.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  child: Row(
                    children: items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isSelected = index == currentIndex;

                      return Expanded(
                        child: _buildEnhancedNavigationItem(
                          context,
                          item,
                          isSelected,
                          index,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedNavigationItem(
    BuildContext context,
    FloatingNavItem item,
    bool isSelected,
    int index,
  ) {
    final activeColorValue = activeColor ?? AppColors.primary;
    final inactiveColorValue = inactiveColor ?? AppColors.iconSecondary;

    return GestureDetector(
      onTap: () {
        if (enableHapticFeedback) {
          // Add haptic feedback
          // HapticFeedback.selectionClick();
        }
        onTap(index);
      },
      child: AnimatedContainer(
        duration: animationDuration ?? const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected
              ? activeColorValue.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with scale animation
              AnimatedScale(
                duration:
                    animationDuration ?? const Duration(milliseconds: 300),
                scale: isSelected ? 1.0 : 0.9,
                child: Icon(
                  isSelected ? item.activeIcon ?? item.icon : item.icon,
                  color: isSelected ? activeColorValue : inactiveColorValue,
                  size: 22,
                ),
              ),

              // Label with slide animation
              if (isSelected && item.label != null && showLabels) ...[
                const SizedBox(width: 8),
                AnimatedSlide(
                  duration:
                      animationDuration ?? const Duration(milliseconds: 300),
                  offset: isSelected ? Offset.zero : const Offset(0.5, 0),
                  child: AnimatedOpacity(
                    duration:
                        animationDuration ?? const Duration(milliseconds: 300),
                    opacity: isSelected ? 1.0 : 0.0,
                    child: Text(
                      item.label!,
                      style: AppTypography.labelMedium.copyWith(
                        color: activeColorValue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Utility class for creating common navigation items
class FloatingNavItems {
  static FloatingNavItem home({String? label}) => FloatingNavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    label: label ?? 'Home',
  );

  static FloatingNavItem events({String? label}) => FloatingNavItem(
    icon: Icons.calendar_today_outlined,
    activeIcon: Icons.calendar_today,
    label: label ?? 'Events',
  );

  // static FloatingNavItem analytics({String? label}) => FloatingNavItem(
  //   icon: Icons.bar_chart_outlined,
  //   activeIcon: Icons.bar_chart,
  //   label: label ?? 'Analytics',
  // );

  static FloatingNavItem profile({String? label}) => FloatingNavItem(
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    label: label ?? 'Profile',
  );

  static FloatingNavItem settings({String? label}) => FloatingNavItem(
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings,
    label: label ?? 'Settings',
  );
}
