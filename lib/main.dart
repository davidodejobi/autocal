import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/home_screen.dart';
import 'services/shared_content_handler.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: AutoCalApp()));
}

class AutoCalApp extends ConsumerStatefulWidget {
  const AutoCalApp({super.key});

  @override
  ConsumerState<AutoCalApp> createState() => _AutoCalAppState();
}

class _AutoCalAppState extends ConsumerState<AutoCalApp> {
  @override
  void initState() {
    super.initState();
    // Initialize services after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sharedContentHandlerProvider).initialize(ref);
      // AI service initialization removed - will be done manually in test page
    });
  }

  @override
  void dispose() {
    ref.read(sharedContentHandlerProvider).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoCal',
      theme: AppTheme.lightTheme,

      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
