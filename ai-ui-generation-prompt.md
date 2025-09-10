# AI UI Generation Prompt for AutoCal App

## Context
You are designing UI screens for AutoCal, a modern AI-powered Flutter calendar app that processes shared content locally using Flutter Leap SDK. The app emphasizes privacy, professional design, and intelligent automation.

## Design Requirements

### Visual Style
- **Modern & Professional**: Clean, minimalist design with subtle shadows and contemporary typography
- **Color Palette**: 
  - Primary: Deep Blue (#1E3A8A)
  - Secondary: Emerald Green (#10B981) 
  - Accent: Amber (#F59E0B)
  - AI Processing: Purple (#8B5CF6)
  - Background: Light Gray (#FAFAFA) with White (#FFFFFF) cards
- **Typography**: Inter font family, with clear hierarchy (Bold headers, Regular body text)
- **Spacing**: Generous whitespace, 16px base padding, 24px section spacing

### AI-Specific Elements
- **Confidence Indicators**: Colored dots (●●● green for high, ●●○ amber for medium, ●○○ red for low)
- **Processing States**: Purple animated indicators with descriptive text
- **Model Status**: Clear download/ready/error states with appropriate icons
- **Privacy Emphasis**: Prominent messaging about local processing

### Screen-Specific Instructions

#### 1. Home Screen
Create a welcoming home screen featuring:
- Header with app name "AutoCal" and AI status indicator (green dot when ready)
- Large primary card for "Share Content to Create Event" with subtle gradient
- Quick action buttons including voice input (marked as Pro feature)
- Recent events list with AI confidence indicators
- Subtle Pro upgrade section at bottom with feature bullets
- Modern card-based layout with soft shadows

#### 2. Event Parsing Screen  
Design an event editing interface showing:
- AI processing banner with confidence percentage (e.g., "92% confidence")
- Clean form fields for Title, Date/Time, Location with inline editing
- Reminder settings with Pro upgrade prompts for advanced options
- Meeting notes section (Pro feature) with AI analysis preview
- Expandable source text section for transparency
- Save/Cancel buttons with clear visual hierarchy

#### 3. AI Model Management Screen (Pro)
Create a technical but user-friendly interface with:
- Privacy messaging about local processing at top
- Storage usage bar with visual indicator
- Model cards showing name, description, size, and status
- Download progress indicators with cancel options
- Clear status icons (checkmark, download arrow, warning)
- Educational content about offline capabilities

#### 4. Voice Input Screen (Pro)
Design an engaging voice interface featuring:
- Large animated microphone icon with sound wave visualization
- Real-time transcription display in a clean text box
- AI processing indicator with progress bar
- Action buttons (Stop, Retry, Use) with clear iconography
- Helpful tips section for better voice recognition
- Smooth animations and visual feedback

#### 5. Settings & Subscription Screen
Create an organized settings interface with:
- Subscription status card with Pro badge and expiration date
- Grouped settings sections (AI Features, Calendar, Notifications, Privacy)
- Toggle switches with clear labels and descriptions
- Manage subscription and AI models buttons
- Privacy section emphasizing local processing

#### 6. Upgrade to Pro Screen
Design a compelling upgrade interface featuring:
- Hero section with "Unlock Pro Features" messaging
- Feature comparison with checkmarks and descriptions
- Pricing cards with "Best Value" highlighting for annual plan
- Primary CTA button for free trial
- Trust indicators (cancel anytime, restore purchases)
- Professional layout that builds confidence

### Technical Specifications
- **Platform**: Flutter/Material Design 3
- **Screen Sizes**: Design for mobile-first (375px width minimum)
- **Accessibility**: High contrast support, large touch targets (44px minimum)
- **States**: Include loading, success, error, and empty states
- **Animations**: Subtle micro-interactions, 300ms transitions

### Key Messaging
- Emphasize privacy and local processing
- Highlight AI intelligence without being overwhelming  
- Show clear value proposition for Pro features
- Build trust through transparency and professional design
- Make complex AI features feel simple and approachable

## Output Format
For each screen, provide:
1. High-fidelity mockup with proper spacing and typography
2. Component breakdown with measurements
3. Color specifications using the defined palette
4. Interaction states (hover, pressed, disabled)
5. Responsive considerations for different screen sizes

## Brand Personality
- **Intelligent**: Sophisticated AI capabilities presented simply
- **Trustworthy**: Professional design that inspires confidence
- **Efficient**: Streamlined workflows that save time
- **Private**: Strong emphasis on local processing and data protection
- **Modern**: Contemporary design that feels current and polished

Create screens that make users feel confident about trusting their important calendar events to an AI-powered system while emphasizing the privacy and intelligence benefits of local processing.