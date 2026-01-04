# DailyBrief iOS App

A SwiftUI-based iOS application that provides daily weather forecasts, countdowns to important events, and nameday information.

## 📁 Project Structure

```
DailyBrief/
├── App/
│   └── DailyBriefApp.swift          # App entry point
│
├── Models/
│   ├── APIModels.swift              # API request/response models
│   ├── User.swift                   # User model
│   ├── DailyBrief.swift            # Daily brief model
│   ├── Weather.swift                # Weather models with emoji extension
│   ├── Countdown.swift              # Countdown event model
│   └── Nameday.swift                # Nameday model
│
├── Services/
│   ├── APIConfig.swift              # API configuration
│   ├── APIService.swift             # API communication layer
│   └── KeychainHelper.swift         # Secure token storage
│
├── ViewModels/
│   ├── DailyBriefViewModel.swift   # Daily brief business logic
│   ├── WeatherViewModel.swift       # Weather business logic
│   └── CountdownViewModel.swift     # Countdown business logic
│
├── Views/
│   ├── Authentication/
│   │   └── LoginView.swift          # Login screen
│   ├── Main/
│   │   └── MainTabView.swift        # Main tab navigation
│   ├── DailyBrief/
│   │   ├── DailyBriefView.swift    # Home screen
│   │   └── Components/
│   │       ├── UserInfoCard.swift   # User info display
│   │       ├── WeatherCard.swift    # Weather card component
│   │       ├── CountdownsCard.swift # Countdowns card component
│   │       └── NamedayCard.swift    # Nameday card component
│   ├── Weather/
│   │   └── WeatherView.swift        # Detailed weather view
│   ├── Countdown/
│   │   └── CountdownView.swift      # Events list view
│   ├── Settings/
│   │   └── SettingsView.swift       # Settings and logout
│   └── Shared/
│       └── ErrorView.swift          # Error display component
│
└── Utilities/
    └── CacheManager.swift           # Local data caching
```

## 🚀 Getting Started

### Prerequisites

- **Xcode 13.0+**
- **iOS 15.0+**
- **Swift 5.5+**
- Active DailyBrief API backend

### Setup Instructions

1. **Create Xcode Project**
   ```
   File → New → Project
   Choose: iOS → App
   Product Name: DailyBrief
   Interface: SwiftUI
   Language: Swift
   ```

2. **Copy Project Files**
   - Copy all files from the `DailyBrief/` folder into your Xcode project
   - Maintain the folder structure when adding files

3. **Configure API**
   - Open `Services/APIConfig.swift`
   - Replace `your_api_key_here` with your actual API key
   - Update `baseURL` for production environment

4. **Enable Required Capabilities**
   - Select your project in Xcode
   - Go to "Signing & Capabilities"
   - Add "Keychain Sharing" capability

5. **Set Minimum iOS Version**
   - In project settings, set Deployment Target to iOS 15.0+

6. **Build and Run**
   - Select a simulator or device
   - Press Cmd+R to build and run

## 🔑 Configuration

### API Configuration

Edit [Services/APIConfig.swift](DailyBrief/Services/APIConfig.swift):

```swift
struct APIConfig {
    static let apiKey = "your_actual_api_key"  // Get from backend team
    
    #if DEBUG
    static let baseURL = "http://localhost:5001"  // Development
    #else
    static let baseURL = "https://api.yourdomain.com"  // Production
    #endif
}
```

### Keychain Service ID

Edit [Services/KeychainHelper.swift](DailyBrief/Services/KeychainHelper.swift):

```swift
private let service = "com.yourcompany.dailybrief"  // Update with your bundle ID
```

## 📱 Features

### ✅ Implemented

- **JWT Authentication** - Secure login with token storage
- **Daily Brief** - Personalized daily overview
- **Weather Forecast** - Current weather + 7-day forecast
- **Event Countdowns** - Track important dates
- **Nameday Information** - Daily nameday celebrations
- **Pull-to-Refresh** - Update data with swipe gesture
- **Offline Caching** - View cached data when offline
- **Error Handling** - User-friendly error messages

### 🔮 Future Enhancements

- Push notifications
- Widget support
- Apple Watch companion app
- Siri shortcuts
- Multiple location support
- Custom themes
- Calendar integration

## 🔐 Authentication

The app uses JWT (JSON Web Token) authentication:

1. User logs in with email/password
2. Server returns JWT token (valid for 7 days)
3. Token stored securely in Keychain
4. Token included in all API requests
5. Auto-logout on token expiration

## 🌐 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/users/authenticate` | POST | Login and get JWT token |
| `/api/v2/daily-brief` | GET | Get complete daily brief |
| `/api/v2/weather` | GET | Get weather forecast |
| `/api/v2/countdowns` | GET | Get event countdowns |
| `/api/v2/nameday` | GET | Get nameday information |

## 📦 Dependencies

This project uses only native iOS frameworks:

- **SwiftUI** - User interface
- **Foundation** - Core functionality
- **Security** - Keychain access

No third-party dependencies required!

## 🧪 Testing

### Manual Testing

Test the API connection:

```swift
Task {
    do {
        let user = try await APIService.shared.login(
            email: "test@example.com",
            password: "testpassword"
        )
        print("✅ Login successful: \(user.email)")
        
        let brief = try await APIService.shared.getDailyBrief()
        print("✅ Daily brief fetched")
    } catch {
        print("❌ Error: \(error)")
    }
}
```

### Test Checklist

- [ ] Login with valid credentials
- [ ] Login with invalid credentials (error handling)
- [ ] Fetch daily brief
- [ ] Pull-to-refresh functionality
- [ ] View weather forecast
- [ ] View event countdowns
- [ ] View settings
- [ ] Logout functionality
- [ ] Token persistence (close and reopen app)
- [ ] Network error handling
- [ ] Rate limit handling

## 🚢 Deployment

### Pre-Release Checklist

- [ ] Update `APIConfig.baseURL` to production URL
- [ ] Remove debug logging
- [ ] Test on multiple iOS versions (15.0+)
- [ ] Test on different screen sizes
- [ ] Add app icons (1024x1024 required)
- [ ] Add launch screen
- [ ] Test error scenarios
- [ ] Test token expiration
- [ ] Add privacy policy
- [ ] Prepare App Store screenshots

### App Store Information

- **Category**: Weather or Productivity
- **Age Rating**: 4+
- **Privacy Policy**: Required
- **Keywords**: weather, daily, brief, countdown, events

## 📖 Documentation

For detailed API documentation, see [SWIFT_APP_GUIDE.md](../SWIFT_APP_GUIDE.md)

## 🐛 Troubleshooting

### Common Issues

**Login fails with "Invalid URL"**
- Check `APIConfig.baseURL` is correct
- Ensure backend server is running

**App crashes on launch**
- Verify all files are properly added to Xcode project
- Check minimum iOS version is set to 15.0+

**Token not persisting**
- Enable Keychain Sharing capability
- Check bundle identifier matches keychain service ID

**Weather/Events not loading**
- Verify user has enabled these modules in backend
- Check network connectivity
- Review error messages in ErrorView

## 📄 License

Copyright © 2026 DailyBrief. All rights reserved.

## 👥 Support

For backend API issues:
- Contact backend team
- Check API documentation

For iOS app issues:
- Review this README
- Check Apple's SwiftUI documentation
- Refer to SWIFT_APP_GUIDE.md

---

**Built with ❤️ using SwiftUI**
