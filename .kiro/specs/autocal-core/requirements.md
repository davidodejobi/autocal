# Requirements Document

## Introduction

AutoCal is a Flutter-based mobile application (Android-first) that automatically parses dates, times, and locations from shared text content and converts them into calendar events with offline reminder capabilities. The app features a freemium model with basic functionality available for free and advanced features through a Pro subscription.

## Requirements

### Requirement 1

**User Story:** As a mobile user, I want to share text or links from other apps (WhatsApp, email, browser) into AutoCal, so that I can quickly capture event information without manual typing.

#### Acceptance Criteria

1. WHEN a user shares text content from WhatsApp THEN the app SHALL receive and process the shared text
2. WHEN a user shares text content from email applications THEN the app SHALL receive and process the shared text
3. WHEN a user shares links from browser applications THEN the app SHALL receive and process the shared content
4. WHEN the app receives shared content THEN it SHALL be available for immediate parsing

### Requirement 2

**User Story:** As a user, I want AutoCal to automatically parse dates, times, and locations from shared text, so that I don't have to manually extract event details.

#### Acceptance Criteria

1. WHEN shared text contains date information THEN the app SHALL automatically identify and extract the date
2. WHEN shared text contains time information THEN the app SHALL automatically identify and extract the time
3. WHEN shared text contains location information THEN the app SHALL automatically identify and extract the location
4. WHEN parsing is complete THEN the app SHALL display a clean event card with extracted information
5. IF parsing fails to identify key information THEN the app SHALL highlight missing fields for manual input

### Requirement 3

**User Story:** As a user, I want to review and edit parsed event details before saving, so that I can ensure accuracy and completeness.

#### Acceptance Criteria

1. WHEN an event card is displayed THEN the user SHALL be able to edit the title
2. WHEN an event card is displayed THEN the user SHALL be able to edit the date and time
3. WHEN an event card is displayed THEN the user SHALL be able to edit the location
4. WHEN the user confirms the event details THEN the app SHALL proceed to save the event
5. WHEN the user cancels the event THEN the app SHALL discard the parsed information

### Requirement 4

**User Story:** As a user, I want to save confirmed events to my device calendar, so that they appear in my standard calendar application.

#### Acceptance Criteria

1. WHEN a user confirms an event THEN the app SHALL save it to the device's default calendar
2. WHEN saving to calendar THEN the app SHALL include title, date, time, and location information
3. IF calendar permission is not granted THEN the app SHALL request calendar access permission
4. WHEN calendar save is successful THEN the app SHALL provide confirmation feedback

### Requirement 5

**User Story:** As a user, I want to set offline reminders for my events, so that I receive notifications even when I don't have internet connectivity.

#### Acceptance Criteria

1. WHEN creating an event THEN the user SHALL be able to set reminder times
2. WHEN a reminder is set THEN the app SHALL schedule local notifications
3. WHEN reminder time arrives THEN the app SHALL display notification even in airplane mode
4. WHEN user taps notification THEN the app SHALL open to event details

### Requirement 6

**User Story:** As a free tier user, I want to create up to 5 events per day, so that I can use basic functionality without payment.

#### Acceptance Criteria

1. WHEN a free user creates events THEN the app SHALL track daily event count
2. WHEN daily limit is reached THEN the app SHALL prevent creation of additional events
3. WHEN daily limit is reached THEN the app SHALL display upgrade prompt
4. WHEN a new day begins THEN the daily event counter SHALL reset to zero

### Requirement 7

**User Story:** As a Pro subscriber, I want unlimited event creation, so that I can use the app without daily restrictions.

#### Acceptance Criteria

1. WHEN a user has active Pro subscription THEN daily event limits SHALL be disabled
2. WHEN Pro subscription expires THEN the app SHALL revert to free tier limitations
3. WHEN Pro user creates events THEN no daily counter SHALL be displayed

### Requirement 8

**User Story:** As a Pro subscriber, I want voice quick-add functionality, so that I can create events using speech input.

#### Acceptance Criteria

1. WHEN Pro user accesses voice feature THEN the app SHALL activate speech recognition
2. WHEN user speaks event details THEN the app SHALL convert speech to text
3. WHEN speech conversion is complete THEN the app SHALL parse the text for event details
4. IF voice recognition fails THEN the app SHALL provide fallback text input option

### Requirement 9

**User Story:** As a Pro subscriber, I want custom reminder options, so that I can set personalized notification schedules.

#### Acceptance Criteria

1. WHEN Pro user sets reminders THEN advanced timing options SHALL be available
2. WHEN Pro user sets reminders THEN custom reminder messages SHALL be supported
3. WHEN Pro user sets reminders THEN multiple reminder times SHALL be supported
4. WHEN custom reminders are set THEN they SHALL function offline like standard reminders

### Requirement 10

**User Story:** As a Pro subscriber, I want to add meeting notes to my events with offline AI processing using flutter_leap_sdk, so that I can capture and organize meeting details without internet connectivity.

#### Acceptance Criteria

1. WHEN Pro user creates an event THEN meeting notes option SHALL be available
2. WHEN user adds meeting notes THEN flutter_leap_sdk SHALL process the text locally using on-device AI models
3. WHEN AI processes notes THEN it SHALL identify action items, participants, and key decisions using local language models
4. WHEN notes are processed THEN extracted information SHALL be saved with the event
5. IF AI processing fails THEN raw notes SHALL still be saved with the event
6. WHEN app starts THEN flutter_leap_sdk models SHALL be initialized for offline processing
7. WHEN processing meeting notes THEN no data SHALL be sent to external servers

### Requirement 11

**User Story:** As a Pro subscriber, I want enhanced text parsing using flutter_leap_sdk's local AI models, so that I can get more accurate event extraction from complex text without relying on internet connectivity.

#### Acceptance Criteria

1. WHEN Pro user shares complex text THEN flutter_leap_sdk SHALL enhance parsing accuracy using local language models
2. WHEN AI-enhanced parsing is complete THEN results SHALL show higher confidence scores than basic regex parsing
3. WHEN flutter_leap_sdk models are unavailable THEN the app SHALL fallback to basic text parsing
4. WHEN processing text with AI THEN all processing SHALL happen locally on device
5. IF AI model loading fails THEN the app SHALL continue with standard parsing and log the error
6. WHEN user first accesses Pro features THEN the app SHALL prompt to download required AI models
7. WHEN downloading models THEN the app SHALL show download progress and storage requirements
8. WHEN models are downloaded THEN they SHALL be stored locally for offline use

### Requirement 12

**User Story:** As a Pro subscriber, I want to manage AI model downloads and storage, so that I can control which models are available for offline processing and manage device storage.

#### Acceptance Criteria

1. WHEN user accesses AI model settings THEN available models SHALL be displayed with download status
2. WHEN user selects a model to download THEN the app SHALL show model size and download progress
3. WHEN model download completes THEN the model SHALL be available for immediate use
4. WHEN user wants to remove a model THEN the app SHALL allow deletion to free storage space
5. WHEN models are outdated THEN the app SHALL offer updates while maintaining offline functionality
6. IF model download fails THEN the app SHALL provide retry options and error details

### Requirement 13

**User Story:** As a user, I want to manage my subscription through RevenueCat, so that I can upgrade, downgrade, or cancel my Pro subscription.

#### Acceptance Criteria

1. WHEN user accesses subscription settings THEN RevenueCat interface SHALL be displayed
2. WHEN user purchases Pro subscription THEN features SHALL be immediately unlocked
3. WHEN subscription status changes THEN the app SHALL update feature availability accordingly
4. WHEN subscription expires THEN the app SHALL gracefully handle feature restrictions