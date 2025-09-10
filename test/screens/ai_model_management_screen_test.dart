import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autocal/screens/ai_model_management_screen.dart';
import 'package:autocal/utils/app_theme.dart';

void main() {
  group('AIModelManagementScreen Widget Tests', () {
    testWidgets('should display AI Models title', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const AIModelManagementScreen(),
          ),
        ),
      );

      expect(find.text('AI Models'), findsOneWidget);
    });

    testWidgets('should display privacy notice', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const AIModelManagementScreen(),
          ),
        ),
      );

      expect(find.text('All processing happens on your device. No data is sent to servers.'), findsOneWidget);
      expect(find.byIcon(Icons.security), findsOneWidget);
    });

    testWidgets('should display storage usage section', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const AIModelManagementScreen(),
          ),
        ),
      );

      expect(find.text('Storage Usage'), findsOneWidget);
      expect(find.text('12 GB / 20 GB'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsWidgets);
    });

    testWidgets('should display available models section', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const AIModelManagementScreen(),
          ),
        ),
      );

      expect(find.text('Available Models'), findsOneWidget);
      expect(find.text('Model A'), findsOneWidget);
      expect(find.text('Model B'), findsOneWidget);
      expect(find.text('Model C'), findsOneWidget);
      expect(find.text('Model D'), findsOneWidget);
      expect(find.text('Model E'), findsOneWidget);
    });

    testWidgets('should display different model statuses', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const AIModelManagementScreen(),
          ),
        ),
      );

      // Should find Ready status
      expect(find.text('Ready'), findsOneWidget);
      
      // Should find Update button
      expect(find.text('Update'), findsOneWidget);
      
      // Should find Download buttons
      expect(find.text('Download'), findsWidgets);
      
      // Should find downloading progress
      expect(find.text('Downloading...'), findsOneWidget);
    });

    testWidgets('should have download buttons that trigger download simulation', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const AIModelManagementScreen(),
          ),
        ),
      );

      // Find and tap a download button
      final downloadButtons = find.text('Download');
      if (downloadButtons.evaluate().isNotEmpty) {
        await tester.tap(downloadButtons.first);
        await tester.pump();
        
        // The download simulation should start (this is a basic test)
        // In a real test, we'd mock the download service
      }
    });

    testWidgets('should display model icons and sizes', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const AIModelManagementScreen(),
          ),
        ),
      );

      // Should find psychology icons for models
      expect(find.byIcon(Icons.psychology_outlined), findsWidgets);
      
      // Should find model sizes
      expect(find.text('1.2 GB'), findsOneWidget);
      expect(find.text('1.5 GB'), findsOneWidget);
      expect(find.text('1.8 GB'), findsOneWidget);
      expect(find.text('2.0 GB'), findsOneWidget);
      expect(find.text('2.2 GB'), findsOneWidget);
    });

    testWidgets('should have back button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const AIModelManagementScreen(),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}