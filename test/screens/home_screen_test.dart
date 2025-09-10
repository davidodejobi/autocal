import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autocal/screens/home_screen.dart';
import 'package:autocal/utils/app_theme.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('should display AutoCal title', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HomeScreen(),
          ),
        ),
      );

      expect(find.text('AutoCal'), findsOneWidget);
    });

    testWidgets('should display AI status card', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HomeScreen(),
          ),
        ),
      );

      expect(find.text('AI is ready'), findsOneWidget);
    });

    testWidgets('should display share to create section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HomeScreen(),
          ),
        ),
      );

      expect(find.text('Share to create an event'), findsOneWidget);
      expect(find.text('Share Content'), findsOneWidget);
    });

    testWidgets('should display quick actions', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HomeScreen(),
          ),
        ),
      );

      expect(find.text('Quick Add'), findsOneWidget);
      expect(find.text('Voice'), findsOneWidget);
    });

    testWidgets('should display recent events section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HomeScreen(),
          ),
        ),
      );

      expect(find.text('Recent Events'), findsOneWidget);
    });

    testWidgets('should display upgrade to pro section for free users', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HomeScreen(),
          ),
        ),
      );

      expect(find.text('Upgrade to Pro'), findsOneWidget);
    });

    testWidgets('should display bottom navigation bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HomeScreen(),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
