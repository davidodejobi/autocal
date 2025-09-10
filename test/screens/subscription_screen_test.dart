import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autocal/screens/subscription_screen.dart';
import 'package:autocal/utils/app_theme.dart';

void main() {
  group('SubscriptionScreen Widget Tests', () {
    testWidgets('should display subscription title', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SubscriptionScreen(),
          ),
        ),
      );

      expect(find.text('Subscription'), findsOneWidget);
    });

    testWidgets('should display upgrade content for free users', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SubscriptionScreen(),
          ),
        ),
      );

      expect(find.text('Upgrade to Pro'), findsOneWidget);
      expect(find.text('Unlimited Events'), findsOneWidget);
      expect(find.text('Enhanced AI Parsing'), findsOneWidget);
      expect(find.text('Voice Input'), findsOneWidget);
      expect(find.text('Meeting Notes Analysis'), findsOneWidget);
      expect(find.text('Start Free Trial'), findsOneWidget);
    });

    testWidgets('should display pricing information', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SubscriptionScreen(),
          ),
        ),
      );

      expect(find.text('\$4.99'), findsOneWidget);
      expect(find.text('/month'), findsOneWidget);
      expect(find.text('Cancel anytime'), findsOneWidget);
    });

    testWidgets('should display feature list with check marks', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SubscriptionScreen(),
          ),
        ),
      );

      // Should find check circle icons for each feature
      expect(find.byIcon(Icons.check_circle), findsWidgets);
    });

    testWidgets('should have upgrade button that shows snackbar', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SubscriptionScreen(),
          ),
        ),
      );

      // Tap the upgrade button
      await tester.tap(find.text('Start Free Trial'));
      await tester.pump();

      // Should show snackbar with coming soon message
      expect(find.text('Subscription purchase coming soon!'), findsOneWidget);
    });
  });
}