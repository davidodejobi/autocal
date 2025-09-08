// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autocal/main.dart';

void main() {
  testWidgets('AutoCal app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: AutoCalApp(),
      ),
    );

    // Verify that our app loads with the welcome message.
    expect(find.text('Welcome to AutoCal'), findsOneWidget);
    expect(find.text('Share text from other apps to create calendar events'),
        findsOneWidget);
    expect(find.text('Daily events created: 0/5'), findsOneWidget);
  });
}
