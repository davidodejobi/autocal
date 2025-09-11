import 'package:flutter/material.dart';

/// Extension on [BuildContext] to provide easy access to text styles
/// and other theme-related properties.
extension ContextExtension on BuildContext {
  // Theme accessors
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  // Screen size utilities
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  // Padding and margin utilities
  EdgeInsets get padding => MediaQuery.of(this).padding;
  double get horizontalPadding => padding.left + padding.right;
  double get verticalPadding => padding.top + padding.bottom;
}

/// Extension for text styling with predefined styles and modifiers
extension TextStyleExtension on BuildContext {
  // Display styles
  TextStyle get displayLarge => Theme.of(this).textTheme.displayLarge!;
  TextStyle get displayMedium => Theme.of(this).textTheme.displayMedium!;
  TextStyle get displaySmall => Theme.of(this).textTheme.displaySmall!;

  // Headline styles
  TextStyle get headlineLarge => Theme.of(this).textTheme.headlineLarge!;
  TextStyle get headlineMedium => Theme.of(this).textTheme.headlineMedium!;
  TextStyle get headlineSmall => Theme.of(this).textTheme.headlineSmall!;

  // Title styles
  TextStyle get titleLarge => Theme.of(this).textTheme.titleLarge!;
  TextStyle get titleMedium => Theme.of(this).textTheme.titleMedium!;
  TextStyle get titleSmall => Theme.of(this).textTheme.titleSmall!;

  // Body styles
  TextStyle get bodyLarge => Theme.of(this).textTheme.bodyLarge!;
  TextStyle get bodyMedium => Theme.of(this).textTheme.bodyMedium!;
  TextStyle get bodySmall => Theme.of(this).textTheme.bodySmall!;

  // Label styles
  TextStyle get labelLarge => Theme.of(this).textTheme.labelLarge!;
  TextStyle get labelMedium => Theme.of(this).textTheme.labelMedium!;
  TextStyle get labelSmall => Theme.of(this).textTheme.labelSmall!;

  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;

  // Common text style modifiers
  TextStyle withBold([TextStyle? style]) =>
      (style ?? bodyMedium).copyWith(fontWeight: FontWeight.bold);

  TextStyle withSemiBold([TextStyle? style]) =>
      (style ?? bodyMedium).copyWith(fontWeight: FontWeight.w600);

  TextStyle withColor(Color color, [TextStyle? style]) =>
      (style ?? bodyMedium).copyWith(color: color);

  TextStyle withSize(double size, [TextStyle? style]) =>
      (style ?? bodyMedium).copyWith(fontSize: size);

  TextStyle withHeight(double height, [TextStyle? style]) =>
      (style ?? bodyMedium).copyWith(height: height);

  TextStyle withLetterSpacing(double spacing, [TextStyle? style]) =>
      (style ?? bodyMedium).copyWith(letterSpacing: spacing);
}

/// Extension for color utilities
extension ColorExtension on BuildContext {
  Color get primary => colorScheme.primary;
  Color get secondary => colorScheme.secondary;
  Color get surface => colorScheme.surface;
  Color get background => colorScheme.surface;
  Color get error => colorScheme.error;

  Color get onPrimary => colorScheme.onPrimary;
  Color get onSecondary => colorScheme.onSecondary;
  Color get onSurface => colorScheme.onSurface;
  Color get onBackground => colorScheme.onSurface;
  Color get onError => colorScheme.onError;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // Additional colors with opacity
  Color primaryWithOpacity(double opacity) => primary.withOpacity(opacity);
  Color secondaryWithOpacity(double opacity) => secondary.withOpacity(opacity);
}
