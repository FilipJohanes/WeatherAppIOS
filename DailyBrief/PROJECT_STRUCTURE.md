# Project Structure Overview

Complete file organization for the DailyBrief iOS application.

## 📂 Directory Tree

```
DailyBrief/
│
├── 📄 README.md                          # Main documentation
├── 📄 SETUP_GUIDE.md                     # Quick setup instructions
├── 📄 Info.plist                         # App configuration
├── 📄 .gitignore                         # Git ignore rules
│
├── 📁 App/
│   └── 📄 DailyBriefApp.swift           # Main app entry point (@main)
│       • App lifecycle management
│       • Authentication state handling
│       • Root view selection
│
├── 📁 Models/
│   ├── 📄 APIModels.swift               # API request/response wrappers
│   │   • APIResponse<T>
│   │   • AuthenticationRequest
│   │   • AuthenticationResponse
│   │
│   ├── 📄 User.swift                    # User data model
│   │   • User profile information
│   │   • Identifiable conformance
│   │
│   ├── 📄 DailyBrief.swift             # Daily brief composite model
│   │   • DailyBrief
│   │   • ModulesEnabled
│   │   • Reminder (placeholder)
│   │
│   ├── 📄 Weather.swift                 # Weather data models
│   │   • Weather
│   │   • Coordinates
│   │   • DayWeather
│   │   • String.weatherEmoji extension
│   │
│   ├── 📄 Countdown.swift               # Countdown event model
│   │   • Event tracking
│   │   • Yearly recurrence support
│   │
│   └── 📄 Nameday.swift                 # Nameday information model
│       • Daily nameday celebrations
│
├── 📁 Services/
│   ├── 📄 APIConfig.swift               # API configuration
│   │   • Base URLs (dev/prod)
│   │   • API key storage
│   │   • Environment switching
│   │
│   ├── 📄 APIService.swift              # API communication layer
│   │   • Authentication methods
│   │   • Data fetching endpoints
│   │   • Error handling
│   │   • Token management
│   │   • ObservableObject for auth state
│   │
│   └── 📄 KeychainHelper.swift          # Secure storage
│       • JWT token persistence
│       • Keychain CRUD operations
│       • Security framework integration
│
├── 📁 ViewModels/
│   ├── 📄 DailyBriefViewModel.swift    # Daily brief logic
│   │   • Data fetching
│   │   • Loading states
│   │   • Error handling
│   │
│   ├── 📄 WeatherViewModel.swift        # Weather logic
│   │   • Weather data management
│   │   • State publishing
│   │
│   └── 📄 CountdownViewModel.swift      # Countdown logic
│       • Event list management
│       • State updates
│
├── 📁 Views/
│   │
│   ├── 📁 Authentication/
│   │   └── 📄 LoginView.swift           # Login screen
│   │       • Email/password input
│   │       • Authentication handling
│   │       • Error display
│   │
│   ├── 📁 Main/
│   │   └── 📄 MainTabView.swift         # Main tab navigation
│   │       • Tab bar interface
│   │       • Navigation structure
│   │       • 4 main tabs
│   │
│   ├── 📁 DailyBrief/
│   │   ├── 📄 DailyBriefView.swift     # Home screen
│   │   │   • Main dashboard
│   │   │   • Aggregated data display
│   │   │   • Pull-to-refresh
│   │   │
│   │   └── 📁 Components/
│   │       ├── 📄 UserInfoCard.swift    # User greeting card
│   │       │   • Welcome message
│   │       │   • Timezone display
│   │       │
│   │       ├── 📄 WeatherCard.swift     # Weather summary card
│   │       │   • Current conditions
│   │       │   • High/low temps
│   │       │   • Weekly preview
│   │       │   • WeekDayView component
│   │       │
│   │       ├── 📄 CountdownsCard.swift  # Events summary card
│   │       │   • Upcoming events list
│   │       │   • Days remaining
│   │       │
│   │       └── 📄 NamedayCard.swift     # Nameday card
│   │           • Daily nameday display
│   │
│   ├── 📁 Weather/
│   │   └── 📄 WeatherView.swift         # Detailed weather screen
│   │       • Full weather card
│   │       • 7-day detailed forecast
│   │       • WeekDayDetailView component
│   │
│   ├── 📁 Countdown/
│   │   └── 📄 CountdownView.swift       # Events list screen
│   │       • Full events list
│   │       • CountdownRow component
│   │       • Empty state
│   │
│   ├── 📁 Settings/
│   │   └── 📄 SettingsView.swift        # Settings screen
│   │       • User information
│   │       • Logout functionality
│   │
│   └── 📁 Shared/
│       └── 📄 ErrorView.swift           # Reusable error component
│           • Error message display
│           • Retry action
│           • Consistent styling
│
└── 📁 Utilities/
    └── 📄 CacheManager.swift            # Local data caching
        • UserDefaults integration
        • DailyBrief caching
        • Weather caching
        • Countdown caching
        • Cache clearing

```

## 🔄 Data Flow

```
User Action
    ↓
View (SwiftUI)
    ↓
ViewModel (@MainActor)
    ↓
APIService (ObservableObject)
    ↓
API Request (URLSession)
    ↓
Backend Server
    ↓
JSON Response
    ↓
Model (Codable)
    ↓
ViewModel Update (@Published)
    ↓
View Re-render
    ↓
User Interface Update
```

## 🔐 Authentication Flow

```
1. User enters credentials → LoginView
2. LoginView calls → APIService.login()
3. APIService sends → POST /api/users/authenticate
4. Server validates → Returns JWT token
5. APIService stores → KeychainHelper.save()
6. APIService updates → isAuthenticated = true
7. App switches → MainTabView
8. Token used for → All subsequent API calls
9. On 401 error → Auto logout, return to LoginView
```

## 📊 State Management

### Global State (APIService)
- `isAuthenticated: Bool` - Authentication status
- `currentUser: User?` - Logged-in user data
- `jwtToken: String?` - JWT token (private)

### View-Specific State (ViewModels)
- `isLoading: Bool` - Loading indicator
- `errorMessage: String?` - Error display
- `data: Model?` - Fetched data (DailyBrief, Weather, etc.)

## 🎨 UI Components Hierarchy

```
DailyBriefApp (@main)
└── Authentication Check
    ├── LoginView (if not authenticated)
    │   ├── Logo & Title
    │   ├── Email TextField
    │   ├── Password SecureField
    │   ├── Error Text (conditional)
    │   └── Login Button
    │
    └── MainTabView (if authenticated)
        ├── Tab 1: DailyBriefView
        │   ├── ScrollView
        │   │   ├── UserInfoCard
        │   │   ├── WeatherCard
        │   │   │   └── WeekDayView (repeated)
        │   │   ├── CountdownsCard
        │   │   └── NamedayCard
        │   └── Pull-to-Refresh
        │
        ├── Tab 2: WeatherView
        │   ├── WeatherCard
        │   └── WeekDayDetailView (repeated)
        │
        ├── Tab 3: CountdownView
        │   └── List
        │       └── CountdownRow (repeated)
        │
        └── Tab 4: SettingsView
            └── Form
                ├── Account Section
                └── Logout Button
```

## 📦 File Size Estimates

| Directory | Files | Lines of Code |
|-----------|-------|---------------|
| App | 1 | ~20 |
| Models | 6 | ~200 |
| Services | 3 | ~250 |
| ViewModels | 3 | ~100 |
| Views | 12 | ~600 |
| Utilities | 1 | ~60 |
| **Total** | **26** | **~1,230** |

## 🎯 Key Features by File

### Core Functionality
- **DailyBriefApp.swift** - App lifecycle, auth routing
- **APIService.swift** - All network communication
- **KeychainHelper.swift** - Secure token storage

### Data Management
- **All Models/** - Type-safe data structures
- **All ViewModels/** - Business logic, state management
- **CacheManager.swift** - Offline support

### User Interface
- **LoginView.swift** - Authentication UI
- **MainTabView.swift** - Navigation structure
- **DailyBriefView.swift** - Main dashboard
- **All Components/** - Reusable UI elements

## 🔧 Dependencies

### Apple Frameworks Used
- **SwiftUI** - User interface framework
- **Foundation** - Core functionality (URLSession, Codable, etc.)
- **Security** - Keychain access

### No Third-Party Dependencies
This project is built entirely with native iOS frameworks - no CocoaPods, SPM, or Carthage packages required!

## 📱 Supported Platforms

- **iOS**: 15.0+
- **iPhone**: All models with iOS 15+
- **iPad**: Compatible (universal app)
- **Mac Catalyst**: Not configured (can be added)

## 🎨 Customization Points

Want to customize the app? Here are the key files:

1. **Colors & Styling** - Modify card components in `Views/DailyBrief/Components/`
2. **API Endpoints** - Update `Services/APIService.swift`
3. **App Icon** - Add to Assets.xcassets
4. **Launch Screen** - Configure in Info.plist
5. **Tab Icons** - Change in `Views/Main/MainTabView.swift`

## 📚 Related Documentation

- [README.md](README.md) - Complete project documentation
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Step-by-step setup
- [../SWIFT_APP_GUIDE.md](../SWIFT_APP_GUIDE.md) - Comprehensive development guide

---

*Last Updated: January 2026*
