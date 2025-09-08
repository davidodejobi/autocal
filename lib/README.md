# AutoCal Project Structure

This document outlines the basic architecture and directory structure set up for the AutoCal Flutter application.

## Dependencies Added

The following packages have been added to `pubspec.yaml`:

- `receive_sharing_intent`: Handle shared content from other apps
- `device_calendar`: Calendar integration for reading/writing events
- `flutter_local_notifications`: Offline notification system
- `purchases_flutter`: RevenueCat integration for subscriptions
- `speech_to_text`: Voice input for Pro users
- `shared_preferences`: Local data persistence
- `intl`: Date/time parsing and formatting
- `flutter_riverpod`: State management with Riverpod
- `flutter_hooks`: React-like hooks for Flutter
- `hooks_riverpod`: Integration between Riverpod and Flutter Hooks
- `permission_handler`: Managing device permissions
- `tflite_flutter`: Offline AI model for meeting notes processing
- `path_provider`: Local file storage for AI models

## Directory Structure

### Models (`lib/models/`)
- `parsed_event.dart`: Core data model for parsed event information
- `event.dart`: Main event model for calendar events
- `reminder.dart`: Reminder model for event notifications
- `meeting_notes.dart`: Meeting notes model for Pro feature
- `processed_notes.dart`: Processed notes model for AI-extracted information
- `action_item.dart`: Action item model for meeting notes
- `subscription_status.dart`: Subscription status model for Pro features

### Services (`lib/services/`)
- `text_parser_service.dart`: Extract dates, times, and locations from text
- `event_manager.dart`: Manage event creation and calendar integration
- `subscription_manager.dart`: Handle Pro subscriptions via RevenueCat
- `notification_manager.dart`: Manage offline notifications and reminders
- `shared_content_handler.dart`: Process incoming shared content from other apps
- `meeting_notes_ai_service.dart`: Offline AI processing of meeting notes (Pro feature)

### Screens (`lib/screens/`)
- `home_screen.dart`: Main home screen for AutoCal app
- `event_card_screen.dart`: Screen for displaying and editing parsed event information
- `settings_screen.dart`: Settings screen for app configuration
- `subscription_screen.dart`: Screen for subscription management and Pro upgrade

### Widgets (`lib/widgets/`)
- `event_card_widget.dart`: Widget for displaying parsed event information
- `subscription_upgrade_widget.dart`: Widget for displaying subscription upgrade prompts

### Providers (`lib/providers/`)
- `app_state_provider.dart`: Main app state notifier for global state management using Riverpod
- `event_provider.dart`: Event-specific state notifier using Riverpod

## State Management

The app uses Riverpod with Flutter Hooks for state management with two main notifiers:

1. **AppStateNotifier**: Manages global app state including:
   - Subscription status
   - Daily event count for free users
   - Recent events list
   - Loading and error states
   - Immutable state with copyWith pattern

2. **EventNotifier**: Manages event-specific state including:
   - Current parsed event
   - Current event being created
   - Editing mode state
   - Processing state
   - Immutable state with copyWith pattern

## Architecture Benefits

- **Riverpod**: Provides compile-time safe dependency injection and state management
- **Flutter Hooks**: Enables React-like hooks for managing widget lifecycle and animations
- **HookConsumerWidget**: Combines Riverpod's reactive state management with hooks functionality
- **Immutable State**: All state objects use copyWith pattern for predictable state updates
- **Notifier Pattern**: Follows Riverpod's recommended Notifier pattern for state management

## Main Application

The main application (`lib/main.dart`) is set up with:
- ProviderScope for Riverpod state management
- Material Design 3 theme
- HomeScreen as the initial route
- All screens use HookConsumerWidget for reactive UI updates
- Example hooks integration for animations and lifecycle management

## Testing

Basic widget tests are included in `test/widget_test.dart` to verify the app loads correctly.

## Shared Content Integration

The `receive_sharing_intent` package has been properly configured:

### Android Configuration
- Added intent filters in `AndroidManifest.xml` for:
  - `android.intent.action.SEND` with `text/plain` MIME type
  - `android.intent.action.SEND` with `text/*` MIME type  
  - `android.intent.action.SEND_MULTIPLE` for multiple shared items

### iOS Configuration
- Added `CFBundleDocumentTypes` in `Info.plist` for handling text documents
- Added `CFBundleURLTypes` for custom URL scheme support
- Configured to handle `public.text` and `public.plain-text` content types

### Implementation
- `SharedContentHandler` service listens for shared content
- Automatically parses shared text using `TextParserService`
- Updates `EventProvider` state when content is received
- `HomeScreen` automatically navigates to `EventCardScreen` when shared content is detected

### Usage
Users can now share text from any app (Messages, Safari, Notes, etc.) and select AutoCal to automatically parse and create calendar events.

## Next Steps

All service classes contain TODO comments indicating where the actual implementation logic needs to be added. The basic architecture is now in place and ready for feature implementation according to the tasks outlined in the implementation plan.