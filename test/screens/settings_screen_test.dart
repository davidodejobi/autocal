import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autocal/screens/settings_screen.dart';
import 'package:autocal/utils/app_theme.dart';

void main() {
  group('SettingsScreen Widget Tests', () {
    testWidgets('should display Settings title', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('should display account section', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      expect(find.text('ACCOUNT'), findsOneWidget);
      expect(find.text('AutoCal Free'), findsOneWidget);
      expect(find.text('Upgrade to Pro'), findsOneWidget);
    });

    testWidgets('should display AI features section', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      expect(find.text('AI FEATURES'), findsOneWidget);
      expect(find.text('Enhanced Text Parsing'), findsOneWidget);
      expect(find.text('Meeting Notes Analysis'), findsOneWidget);
      expect(find.text('Voice Input'), findsOneWidget);
      expect(find.text('Manage AI Models'), findsOneWidget);
    });

    testWidgets('should display calendar section', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      expect(find.text('CALENDAR'), findsOneWidget);
      expect(find.text('Default Calendar'), findsOneWidget);
      expect(find.text('Default Reminders'), findsOneWidget);
      expect(find.text('Time Zone'), findsOneWidget);
    });

    testWidgets('should display notifications section', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      expect(find.text('NOTIFICATIONS'), findsOneWidget);
      expect(find.text('Event Reminders'), findsOneWidget);
      expect(find.text('AI Processing Updates'), findsOneWidget);
      expect(find.text('Model Download Alerts'), findsOneWidget);
    });

    testWidgets('should display privacy section', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      expect(find.text('PRIVACY'), findsOneWidget);
      expect(find.text('On-Device Processing'), findsOneWidget);
      expect(find.text('Learn more in our Privacy Policy'), findsOneWidget);
    });

    testWidgets('should have toggle switches for notification settings', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      // Should find multiple switches for various toggle settings
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('should have navigation arrows for settings with submenus', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      // Should find chevron right icons for navigation items
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });
  });
}