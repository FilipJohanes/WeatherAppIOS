# Quick Setup Guide

Follow these steps to get your Trident iOS app up and running.

## Step 1: Create Xcode Project

1. Open Xcode
2. Select **File → New → Project**
3. Choose **iOS** platform
4. Select **App** template
5. Click **Next**
6. Configure your project:
   - **Product Name**: `Trident`
   - **Team**: Select your development team
   - **Organization Identifier**: `com.yourcompany` (use your own)
   - **Bundle Identifier**: Will be auto-generated (e.g., `com.yourcompany.Trident`)
   - **Interface**: **SwiftUI**
   - **Language**: **Swift**
   - **Storage**: None
   - **Tests**: Check if you want testing support
7. Click **Next** and choose a location to save the project
8. Click **Create**

## Step 2: Add Project Files

### Option A: Drag and Drop (Recommended)

1. In Finder, navigate to the `Trident/` folder you received
2. In Xcode, right-click on the project root (blue icon)
3. Select **Add Files to "Trident"...**
4. Select all folders from the Trident directory:
   - App/
   - Models/
   - Services/
   - ViewModels/
   - Views/
   - Utilities/
5. **Important**: Check these options in the dialog:
   - ✅ "Copy items if needed"
   - ✅ "Create groups"
   - ✅ Add to targets: "Trident"
6. Click **Add**

### Option B: Manual Creation

If you prefer to create files manually:
1. Right-click project in Xcode
2. Select **New Group** to create folders
3. Right-click on folder → **New File**
4. Choose **Swift File**
5. Copy content from each file in this directory

## Step 3: Delete Default Files

Xcode creates default files you don't need:

1. In Xcode project navigator, locate these files:
   - `ContentView.swift` (if it exists)
   - Any other auto-generated SwiftUI files
2. Right-click → **Delete**
3. Choose **Move to Trash**

## Step 4: Configure API Settings

1. Open `Services/APIConfig.swift`
2. Replace the placeholder values:

```swift
struct APIConfig {
    static let apiKey = "YOUR_ACTUAL_API_KEY"  // ← Update this
    
    #if DEBUG
    static let baseURL = "http://localhost:5001"  // ← Your development server
    #else
    static let baseURL = "https://api.yourdomain.com"  // ← Your production server
    #endif
}
```

3. Save the file (Cmd+S)

## Step 5: Update Keychain Service ID

1. Open `Services/KeychainHelper.swift`
2. Update the service identifier to match your bundle ID:

```swift
private let service = "com.yourcompany.trident"  // ← Update this
```

## Step 6: Configure Project Settings

1. Click on the project (blue icon) in the navigator
2. Select your app target
3. Go to **General** tab:
   - **Minimum Deployments**: Set to **iOS 15.0**
   - **Identity**: Verify Bundle Identifier matches
   - **Deployment Info**: 
     - iPhone orientation: Portrait
     - iPad: Support if desired

4. Go to **Signing & Capabilities** tab:
   - Select your **Team**
   - Enable **Automatically manage signing**
   - Click **+ Capability**
   - Add **Keychain Sharing**
   - In Keychain Groups, add: `$(AppIdentifierPrefix)com.yourcompany.trident`

## Step 7: Add Branding Assets

### 7.1 Prepare Your Images

You need three sets of images for the Trident app:

1. **App Icon** - 1024x1024 PNG (trident icon without text)
2. **Launch Images** - Three sizes: 300px, 600px, 900px (trident with text on blue background)
3. **Logo Images** - Three sizes: 200px, 400px, 600px (trident icon for in-app use)

### 7.2 Add Images to Xcode

**For App Icon:**
1. In Xcode, navigate to `Assets.xcassets` → `AppIcon`
2. Drag your 1024x1024 PNG into the 1024x1024 slot
3. iOS will automatically generate all required sizes

**For Launch Images:**
1. Navigate to `Assets.xcassets` → `LaunchImage`
2. Add three versions:
   - `LaunchImage.png` (300x300) → drag to 1x slot
   - `LaunchImage@2x.png` (600x600) → drag to 2x slot
   - `LaunchImage@3x.png` (900x900) → drag to 3x slot

**For In-App Logo:**
1. Navigate to `Assets.xcassets` → `TridentLogo`
2. Add three versions:
   - `TridentLogo.png` (200x200) → drag to 1x slot
   - `TridentLogo@2x.png` (400x400) → drag to 2x slot
   - `TridentLogo@3x.png` (600x600) → drag to 3x slot

**📖 For detailed instructions, see [ASSET_SETUP_GUIDE.md](ASSET_SETUP_GUIDE.md)**

## Step 8: Build the Project

1. Select a simulator from the device menu (e.g., iPhone 14)
2. Press **Cmd+B** to build
3. Fix any errors that appear (usually import or syntax issues)
4. Once build succeeds, press **Cmd+R** to run

## Step 9: Test the App

### First Launch:
1. App should show the login screen
2. Enter test credentials (get from backend team):
   - Email: `test@example.com`
   - Password: `testpassword`
3. Tap **Login**

### If Login Succeeds:
- You should see the main tab interface
- Daily Brief tab shows personalized overview
- Weather tab shows forecast
- Events tab shows countdowns
- Settings tab shows user info

### If Login Fails:
Check these common issues:
- ✅ Backend server is running
- ✅ API key is correct in `APIConfig.swift`
- ✅ Base URL is correct
- ✅ Network connectivity is working
- ✅ Test credentials are valid

## Step 10: Troubleshooting

### Build Errors

**"Cannot find 'APIService' in scope"**
- Ensure all files are added to the project target
- Check that Services/APIService.swift is included
- Clean build folder: Product → Clean Build Folder (Cmd+Shift+K)

**"Module not found"**
- All required frameworks are built-in iOS frameworks
- Check Minimum Deployment Target is iOS 15.0+

**Keychain errors**
- Verify Keychain Sharing capability is enabled
- Check service ID matches your bundle identifier

### Runtime Errors

**App crashes on launch**
- Check all Swift files compiled successfully
- Review console output for error messages
- Verify Info.plist is properly configured

**Login shows "Invalid URL"**
- Check APIConfig.baseURL is a valid URL
- Ensure no extra spaces or characters

**Network requests fail**
- Verify backend server is accessible
- Check Info.plist allows localhost connections
- Test API with curl or Postman first

**Images not showing**
- Verify images are in correct asset catalog folders
- Check image file names match Contents.json specifications
- Clean build folder and rebuild
- See [ERROR_DOCUMENTATION.md](ERROR_DOCUMENTATION.md) for detailed troubleshooting

**"Network Error: The data couldn't be read because it is missing"**
- This is a common error when API returns empty response
- Check backend is returning data
- Verify API endpoint is correct
- See [ERROR_DOCUMENTATION.md](ERROR_DOCUMENTATION.md) for complete solution

## Step 11: Optional Enhancements

### Add App Icon
1. Create 1024x1024 PNG icon
2. In Xcode, select Assets.xcassets
3. Click on AppIcon
4. Drag your icon to the 1024x1024 slot

### Add Launch Screen
1. In Xcode, select Assets.xcassets
2. Add color: Right-click → New Color Set → Name: "LaunchScreenBackground"
3. Set your desired color

### Enable Background Fetch (Optional)
1. Go to Signing & Capabilities
2. Add **Background Modes**
3. Check **Background fetch**

## Next Steps

- Review [README.md](README.md) for full documentation
- Check [ERROR_DOCUMENTATION.md](ERROR_DOCUMENTATION.md) for error troubleshooting
- See [ASSET_SETUP_GUIDE.md](ASSET_SETUP_GUIDE.md) for detailed image setup
- Review [CHANGE_LOG.md](CHANGE_LOG.md) for recent updates
- Check [SWIFT_APP_GUIDE.md](../SWIFT_APP_GUIDE.md) for detailed guide
- Customize the UI to match your brand
- Test all features thoroughly
- Prepare for App Store submission

## Documentation Reference

- **[README.md](README.md)** - Project overview and structure
- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - This file
- **[ERROR_DOCUMENTATION.md](ERROR_DOCUMENTATION.md)** - Complete error reference
- **[ASSET_SETUP_GUIDE.md](ASSET_SETUP_GUIDE.md)** - Image and branding setup
- **[CHANGE_LOG.md](CHANGE_LOG.md)** - Recent changes and updates
- **[SWIFT_APP_GUIDE.md](../SWIFT_APP_GUIDE.md)** - Comprehensive development guide

## Getting Help

**Build Issues**: Review Xcode error messages carefully  
**API Issues**: Contact your backend team or see [ERROR_DOCUMENTATION.md](ERROR_DOCUMENTATION.md)
**Image Issues**: See [ASSET_SETUP_GUIDE.md](ASSET_SETUP_GUIDE.md)
**SwiftUI Issues**: Check Apple's SwiftUI documentation  
**General Questions**: Refer to the comprehensive guide in SWIFT_APP_GUIDE.md

---

Happy coding! 🚀
