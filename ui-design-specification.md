# AutoCal AI App - UI Design Specification

## Overview
This document outlines the screen designs for AutoCal, a modern AI-powered calendar app that processes shared content locally using Flutter Leap SDK. The design emphasizes a clean, professional aesthetic with intuitive AI-powered features.

## Design Principles
- **Modern & Professional**: Clean lines, subtle shadows, contemporary typography
- **AI-First**: Visual indicators for AI processing, confidence scores, smart suggestions
- **Local Processing**: Emphasize privacy and offline capabilities
- **Accessibility**: High contrast options, large touch targets, screen reader support
- **Freemium UX**: Clear value proposition for Pro features without being pushy

## Color Palette
- **Primary**: Deep Blue (#1E3A8A) - Trust, intelligence, professionalism
- **Secondary**: Emerald Green (#10B981) - Success, AI processing, growth
- **Accent**: Amber (#F59E0B) - Attention, warnings, premium features
- **Neutral**: 
  - Background: #FAFAFA (light), #1F2937 (dark)
  - Surface: #FFFFFF (light), #374151 (dark)
  - Text Primary: #111827 (light), #F9FAFB (dark)
  - Text Secondary: #6B7280 (light), #D1D5DB (dark)
- **AI Indicators**: 
  - Processing: #8B5CF6 (Purple)
  - High Confidence: #10B981 (Green)
  - Medium Confidence: #F59E0B (Amber)
  - Low Confidence: #EF4444 (Red)

## Typography
- **Headers**: Inter Bold, 24-32px
- **Subheaders**: Inter SemiBold, 18-20px
- **Body**: Inter Regular, 16px
- **Captions**: Inter Medium, 14px
- **AI Labels**: Inter Medium, 12px (with colored backgrounds)

---

## Screen Designs

### 1. Home Screen
**Purpose**: Main entry point showing recent events, quick actions, and AI status

**Layout**:
```
┌─────────────────────────────────────┐
│ ☰  AutoCal              🤖 AI ●    │ ← Header with AI status indicator
├─────────────────────────────────────┤
│                                     │
│   📤 Share Content to Create Event  │ ← Primary CTA card
│   ┌─────────────────────────────┐   │
│   │  Share from any app or      │   │
│   │  paste text/links here      │   │
│   │                             │   │
│   │  [+ Quick Add]  [🎤 Voice]  │   │ ← Voice button for Pro users
│   └─────────────────────────────┘   │
│                                     │
│   📅 Recent Events                  │
│   ┌─────────────────────────────┐   │
│   │ 🤖 Team Meeting             │   │ ← AI confidence indicator
│   │ Today, 2:00 PM              │   │
│   │ Conference Room A           │   │
│   │ Confidence: High ●●●        │   │
│   └─────────────────────────────┘   │
│                                     │
│   ┌─────────────────────────────┐   │
│   │ 📝 Doctor Appointment       │   │
│   │ Tomorrow, 10:30 AM          │   │
│   │ Medical Center              │   │
│   │ Confidence: Medium ●●○      │   │
│   └─────────────────────────────┘   │
│                                     │
│   💎 Upgrade to Pro                 │ ← Subtle upgrade prompt
│   • Unlimited events               │
│   • Voice input                    │
│   • Advanced AI processing         │
│   • Meeting notes analysis         │
│                                     │
└─────────────────────────────────────┘
```

**Key Features**:
- AI status indicator (green dot = models loaded, amber = downloading, red = offline)
- Confidence visualization with colored dots
- Pro feature teasing without being intrusive
- Quick access to voice input for Pro users

### 2. Event Parsing Screen
**Purpose**: Display AI-parsed event details with editing capabilities

**Layout**:
```
┌─────────────────────────────────────┐
│ ← Back    Event Details    ✓ Save   │
├─────────────────────────────────────┤
│                                     │
│ 🤖 AI Processing Complete           │ ← AI status banner
│ Confidence: High (92%)              │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📝 Title                        │ │
│ │ Team Sprint Planning Meeting    │ │ ← Editable fields
│ │                                 │ │
│ │ 📅 Date & Time                  │ │
│ │ March 15, 2024 at 2:00 PM      │ │
│ │                                 │ │
│ │ 📍 Location                     │ │
│ │ Conference Room A, 2nd Floor    │ │
│ │                                 │ │
│ │ 🔔 Reminders                    │ │
│ │ 15 minutes before               │ │
│ │ [+ Add Reminder] (Pro)          │ │ ← Pro feature indicator
│ │                                 │ │
│ │ 📋 Meeting Notes (Pro)          │ │
│ │ ┌─────────────────────────────┐ │ │
│ │ │ Add notes for AI analysis   │ │ │
│ │ │ • Action items              │ │ │
│ │ │ • Key decisions             │ │ │
│ │ │ • Participants              │ │ │
│ │ └─────────────────────────────┘ │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 🔍 Source Text                      │ ← Expandable section
│ "Hey team, let's meet tomorrow..."  │
│                                     │
│ [Cancel]              [Save Event]  │
│                                     │
└─────────────────────────────────────┘
```

**Key Features**:
- Real-time confidence scoring
- Inline editing with validation
- Pro features clearly marked but accessible
- Source text reference for transparency

### 3. AI Model Management Screen (Pro)
**Purpose**: Manage local AI models for offline processing

**Layout**:
```
┌─────────────────────────────────────┐
│ ← Back    AI Models         ⚙️      │
├─────────────────────────────────────┤
│                                     │
│ 🤖 Local AI Processing              │
│ All processing happens on your      │
│ device. No data sent to servers.    │
│                                     │
│ 📊 Storage Usage: 2.1GB / 5GB       │
│ ████████░░ 42%                      │
│                                     │
│ Available Models                    │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📝 Text Parser Pro              │ │
│ │ Enhanced event extraction       │ │
│ │ Size: 450MB    Status: ✓ Ready │ │
│ │ [Update Available]              │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🧠 Meeting Notes Analyzer       │ │
│ │ Action items & key decisions    │ │
│ │ Size: 680MB    Status: ⬇️ 45%   │ │
│ │ [Cancel Download]               │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🌍 Multi-language Support       │ │
│ │ Spanish, French, German         │ │
│ │ Size: 1.2GB    Status: ○ Not   │ │
│ │ [Download]                      │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ⚠️ Models require WiFi to download  │
│ 📱 Downloaded models work offline   │
│                                     │
└─────────────────────────────────────┘
```

**Key Features**:
- Clear privacy messaging about local processing
- Storage management with visual indicators
- Download progress and status
- Model descriptions and benefits

### 4. Voice Input Screen (Pro)
**Purpose**: Voice-to-text event creation with AI processing

**Layout**:
```
┌─────────────────────────────────────┐
│ ← Back    Voice Input       🎤      │
├─────────────────────────────────────┤
│                                     │
│                                     │
│        🎤                           │
│    ┌─────────┐                      │
│    │         │                      │ ← Animated microphone
│    │    🎵    │                      │   with sound waves
│    │  ∿∿∿∿∿   │                      │
│    └─────────┘                      │
│                                     │
│    "Listening..."                   │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Recognized Text:                │ │
│ │                                 │ │
│ │ "Schedule a team meeting for    │ │
│ │ tomorrow at 2 PM in the         │ │
│ │ conference room"                │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 🤖 AI Processing...                 │ ← Processing indicator
│ ████████░░ Analyzing text           │
│                                     │
│ [🛑 Stop]    [🔄 Retry]    [✓ Use]  │
│                                     │
│ 💡 Tips:                            │
│ • Speak clearly and slowly          │
│ • Include date, time, and location  │
│ • Say "meeting" or "appointment"    │
│                                     │
└─────────────────────────────────────┘
```

**Key Features**:
- Visual feedback during recording
- Real-time transcription display
- AI processing status
- Helpful usage tips

### 5. Settings & Subscription Screen
**Purpose**: Manage app settings and subscription status

**Layout**:
```
┌─────────────────────────────────────┐
│ ← Back    Settings          ⚙️      │
├─────────────────────────────────────┤
│                                     │
│ 👤 Account                          │
│ ┌─────────────────────────────────┐ │
│ │ 💎 AutoCal Pro                  │ │
│ │ Active until March 15, 2025     │ │
│ │ [Manage Subscription]           │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 🤖 AI Features                      │
│ ┌─────────────────────────────────┐ │
│ │ Enhanced Text Parsing      ✓ On │ │
│ │ Meeting Notes Analysis     ✓ On │ │
│ │ Voice Input               ✓ On │ │
│ │ [Manage AI Models]              │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 📅 Calendar                         │
│ ┌─────────────────────────────────┐ │
│ │ Default Calendar    📱 Personal │ │
│ │ Default Reminders   🔔 15 min   │ │
│ │ Time Zone          🌍 Auto      │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 🔔 Notifications                    │
│ ┌─────────────────────────────────┐ │
│ │ Event Reminders        ✓ On     │ │
│ │ AI Processing Updates  ✓ On     │ │
│ │ Model Download Alerts  ✓ On     │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 🛡️ Privacy                          │
│ ┌─────────────────────────────────┐ │
│ │ Local AI Processing    ✓ On     │ │
│ │ Data never leaves device        │ │
│ │ [Privacy Policy]                │ │
│ └─────────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

**Key Features**:
- Clear subscription status
- AI feature toggles
- Privacy emphasis
- Organized sections

### 6. Upgrade to Pro Screen
**Purpose**: Showcase Pro features and handle subscription

**Layout**:
```
┌─────────────────────────────────────┐
│ ✕ Close   Upgrade to Pro    💎      │
├─────────────────────────────────────┤
│                                     │
│        🚀 Unlock Pro Features       │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ✓ Unlimited Events              │ │
│ │   No daily limits               │ │
│ │                                 │ │
│ │ ✓ Voice Quick-Add               │ │
│ │   Speak to create events        │ │
│ │                                 │ │
│ │ ✓ Advanced AI Processing        │ │
│ │   Higher accuracy parsing       │ │
│ │                                 │ │
│ │ ✓ Meeting Notes Analysis        │ │
│ │   Extract action items & more   │ │
│ │                                 │ │
│ │ ✓ Custom Reminders              │ │
│ │   Multiple alerts per event     │ │
│ │                                 │ │
│ │ ✓ Offline AI Models             │ │
│ │   Complete privacy protection   │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 💰 Pricing                          │
│ ┌─────────────────────────────────┐ │
│ │ Monthly: $4.99/month            │ │
│ │ ┌─────────────────────────────┐ │ │
│ │ │ 🏆 BEST VALUE               │ │ │
│ │ │ Annual: $39.99/year         │ │ │
│ │ │ Save 33% • $3.33/month      │ │ │
│ │ └─────────────────────────────┘ │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [Start Free Trial - 7 Days]         │ ← Primary CTA
│                                     │
│ 🔒 Cancel anytime • No commitment   │
│ 📱 Restore purchases                │
│                                     │
└─────────────────────────────────────┘
```

**Key Features**:
- Clear value proposition
- Pricing comparison
- Free trial offer
- Trust indicators

---

## AI-Specific UI Elements

### Confidence Indicators
- **High (80-100%)**: Green dot ●●● + "High confidence"
- **Medium (60-79%)**: Amber dot ●●○ + "Medium confidence"  
- **Low (0-59%)**: Red dot ●○○ + "Low confidence"

### Processing States
- **Loading**: Purple animated spinner + "AI processing..."
- **Success**: Green checkmark + "Processing complete"
- **Error**: Red warning + "Processing failed, using basic parsing"

### Model Status Icons
- **Downloaded**: ✓ Green checkmark
- **Downloading**: ⬇️ Blue arrow with percentage
- **Available**: ○ Gray circle
- **Error**: ⚠️ Red warning triangle

---

## Accessibility Features
- High contrast mode support
- Large text scaling (up to 200%)
- Screen reader labels for all AI indicators
- Voice control compatibility
- Keyboard navigation support
- Color-blind friendly indicators (shapes + colors)

---

## Animation Guidelines
- **AI Processing**: Subtle pulse animation on processing indicators
- **Voice Input**: Sound wave animation during recording
- **Model Downloads**: Smooth progress bar animations
- **Confidence Scores**: Gentle fade-in when results appear
- **Transitions**: 300ms ease-in-out for screen transitions
- **Micro-interactions**: 150ms for button presses and toggles

This design specification emphasizes the AI-powered nature of your app while maintaining a professional, trustworthy appearance that users will feel confident using for their important calendar events.