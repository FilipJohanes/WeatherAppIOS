# Asset Setup Instructions for Trident App

This document provides step-by-step instructions for implementing the Trident branding images in your iOS app.

## 📱 Overview

The Trident app uses two key images:
1. **Trident Icon** - Used as the app icon (appears on home screen)
2. **Trident Launch Image** - Used on the launch screen and in-app branding

---

## 🎨 Step 1: Add Images to Xcode

### 1.1 Open Assets Catalog

The project has been pre-configured with an `Assets.xcassets` folder containing three image sets:

```
Assets.xcassets/
├── AppIcon.appiconset/           # For app icon
├── LaunchImage.imageset/          # For launch screen
└── TridentLogo.imageset/          # For in-app use
```

### 1.2 Add the App Icon

1. **Locate** the first image (trident icon without text)
2. **In Xcode**, navigate to `Assets.xcassets` → `AppIcon`
3. **Drag and drop** your icon image into the **1024x1024** slot
   - iOS will automatically generate all required sizes
   - Image should be:
     - 1024x1024 pixels
     - PNG format
     - No transparency (opaque background)
     - No rounded corners (iOS adds these automatically)

**Note:** If you don't see the slot:
- Right-click `AppIcon.appiconset` in Finder
- Delete the existing `Contents.json`
- In Xcode: Right-click `AppIcon` → Show in Finder
- Drag your 1024x1024 PNG into this folder
- Rename it to match iOS conventions if needed

### 1.3 Add the Launch Image

1. **Locate** the second image (trident with "TROJZUBEC" text on blue background)
2. **In Xcode**, navigate to `Assets.xcassets` → `LaunchImage`
3. **Prepare three sizes** of the image:
   - `LaunchImage.png` (1x) - 300x300 pixels
   - `LaunchImage@2x.png` (2x) - 600x600 pixels  
   - `LaunchImage@3x.png` (3x) - 900x900 pixels

4. **Drag and drop** each image into the corresponding slot:
   - 1x → Standard resolution
   - 2x → Retina displays
   - 3x → iPhone Plus/Pro Max displays

**Quick Resize Method (macOS):**
```bash
# If you only have one image, resize it using sips command:
sips -Z 300 original.png --out LaunchImage.png
sips -Z 600 original.png --out LaunchImage@2x.png
sips -Z 900 original.png --out LaunchImage@3x.png
```

### 1.4 Add the In-App Logo

1. **Use the first image** (trident icon without text)
2. **In Xcode**, navigate to `Assets.xcassets` → `TridentLogo`
3. **Prepare three sizes**:
   - `TridentLogo.png` (1x) - 200x200 pixels
   - `TridentLogo@2x.png` (2x) - 400x400 pixels
   - `TridentLogo@3x.png` (3x) - 600x600 pixels
4. **Drag and drop** into corresponding slots

---

## 🔧 Step 2: Configure Info.plist

The `Info.plist` has already been configured with:

```xml
<key>CFBundleDisplayName</key>
<string>Trident</string>

<key>UILaunchScreen</key>
<dict>
    <key>UIColorName</key>
    <string>LaunchScreenBackground</string>
    <key>UIImageName</key>
    <string>LaunchImage</string>
</dict>
```

### Verify Configuration:

1. Open `Info.plist`
2. Confirm `CFBundleDisplayName` is set to **Trident**
3. Confirm `UILaunchScreen` references **LaunchImage**

---

## 🎨 Step 3: Configure Colors (Optional)

To ensure consistent branding, add a color set for the background:

### 3.1 Add Color Set

1. In Xcode, navigate to `Assets.xcassets`
2. Right-click → **New Color Set**
3. Name it: `LaunchScreenBackground`
4. Set the color to: **RGB (173, 216, 230)** or **Hex #ADD8E6**
   - This matches the light blue in your images

### 3.2 Alternative: Use Code-Based Color

The app already uses this color in views:
```swift
Color(red: 0.68, green: 0.85, blue: 0.90)
```

---

## 📱 Step 4: Test the Implementation

### 4.1 Test App Icon

1. **Build and run** the app on a simulator or device
2. **Close the app** (press Home button or swipe up)
3. **Check the Home screen** - you should see the Trident icon

**Troubleshooting:**
- If icon doesn't appear: Clean build folder (Cmd+Shift+K), then rebuild
- If wrong icon shows: Delete app from device, clean build, reinstall
- Simulator cache: Reset Simulator → Device → Erase All Content and Settings

### 4.2 Test Launch Screen

1. **Build and run** the app
2. **Watch carefully** when app launches
3. You should see:
   - Blue background (light blue #ADD8E6)
   - Trident logo centered
   - "TRIDENT" text below logo

**Troubleshooting:**
- If launch screen doesn't show: 
  - Check `Info.plist` has correct image name
  - Verify images are in correct asset catalog
  - Clean build folder and rebuild

### 4.3 Test Login Screen

1. **Launch the app**
2. The login screen should display:
   - Light blue background
   - Trident logo at top
   - "Trident" title text
   - Login form fields

---

## 🎯 Step 5: Advanced Configuration (Optional)

### 5.1 Custom Launch Screen View (Already Implemented)

A custom launch screen has been created at:
- `Views/Shared/LaunchScreenView.swift`

This provides a SwiftUI-based launch experience with:
- Matching blue background color
- Trident logo
- "TRIDENT" text

### 5.2 Enable Custom Launch Screen

If you want to use the SwiftUI launch screen instead of the static image:

1. Open `DailyBriefApp.swift`
2. Add a state variable:
```swift
@State private var showLaunchScreen = true
```

3. Wrap the body content:
```swift
var body: some Scene {
    WindowGroup {
        if showLaunchScreen {
            LaunchScreenView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showLaunchScreen = false
                        }
                    }
                }
        } else {
            // Regular app content
            if apiService.isAuthenticated {
                MainTabView()
                    .environmentObject(apiService)
            } else {
                LoginView()
                    .environmentObject(apiService)
            }
        }
    }
}
```

---

## 📋 File Checklist

Ensure these files exist and are properly configured:

- [ ] `Assets.xcassets/Contents.json` ✓ Created
- [ ] `Assets.xcassets/AppIcon.appiconset/Contents.json` ✓ Created  
- [ ] `Assets.xcassets/LaunchImage.imageset/Contents.json` ✓ Created
- [ ] `Assets.xcassets/TridentLogo.imageset/Contents.json` ✓ Created
- [ ] **Your trident icon image** → AppIcon folder (1024x1024 PNG)
- [ ] **Your launch images** → LaunchImage folder (3 sizes)
- [ ] **Your logo images** → TridentLogo folder (3 sizes)
- [ ] `Info.plist` configured with app name "Trident" ✓ Done
- [ ] `Views/Shared/LaunchScreenView.swift` ✓ Created
- [ ] All views updated with blue background ✓ Done

---

## 🚨 Common Issues and Solutions

### Issue: App icon not showing

**Solution:**
1. Verify image is exactly 1024x1024 pixels
2. Verify it's PNG format (not JPEG or HEIC)
3. Clean build folder: **Product → Clean Build Folder** (Cmd+Shift+K)
4. Delete app from device/simulator
5. Rebuild and reinstall

### Issue: Launch screen shows old content

**Solution:**
1. Delete app from device/simulator
2. Clean build folder
3. Reset simulator (if using simulator)
4. Rebuild and reinstall

### Issue: Images appear blurry

**Solution:**
1. Ensure you have @2x and @3x versions
2. Verify pixel dimensions are correct (not scaled)
3. Use PNG format (best for icons)
4. Don't use JPG (causes compression artifacts)

### Issue: Wrong colors on screen

**Solution:**
1. Verify color values in code:
   - Blue background: `Color(red: 0.68, green: 0.85, blue: 0.90)`
   - Dark blue button: `Color(red: 0.20, green: 0.40, blue: 0.60)`
2. Check that images have transparent backgrounds (for TridentLogo)
3. Verify LaunchImage has the correct blue background

### Issue: Can't find Assets.xcassets in Xcode

**Solution:**
1. In Xcode project navigator, look for `Assets.xcassets`
2. If missing, create it:
   - Right-click project root
   - New File → iOS → Resource → Asset Catalog
   - Name it `Assets` (Xcode adds .xcassets)
3. Copy the Contents.json files from the project folder

---

## 🎨 Design Specifications

For reference, here are the design specifications used:

### Colors
- **Light Blue Background**: RGB(173, 216, 230) / #ADD8E6 / SwiftUI: Color(red: 0.68, green: 0.85, blue: 0.90)
- **Dark Gray Text**: RGB(84, 84, 84) / #545454 / SwiftUI: Color(red: 0.33, green: 0.33, blue: 0.33)
- **Button Blue**: RGB(51, 102, 153) / #336699 / SwiftUI: Color(red: 0.20, green: 0.40, blue: 0.60)

### Sizes
- **App Icon**: 1024x1024px (Xcode generates other sizes)
- **Launch Image**: 300/600/900px (1x/2x/3x)
- **In-App Logo**: 200/400/600px (1x/2x/3x)
- **Login Logo Display**: 120x120 points
- **Launch Screen Logo**: 200x200 points

---

## 🎓 Best Practices

1. **Always use PNG for icons** - Better quality, transparency support
2. **Provide all resolution variants** - Ensures crisp display on all devices
3. **Use vector graphics when possible** - Though iOS requires raster for app icon
4. **Test on multiple devices** - Different screen sizes may show images differently
5. **Keep file sizes reasonable** - Large images increase app download size

---

## 📱 Quick Reference: Image Locations

Once properly set up, your images will be used in:

| Location | Asset Name | Display Size | Usage |
|----------|-----------|--------------|--------|
| Home Screen | AppIcon | System-defined | App icon on device |
| App Launch | LaunchImage | Full screen | Splash screen |
| Login Screen | TridentLogo | 120x120 | Branding |
| Launch Screen View | TridentLogo | 200x200 | SwiftUI splash |

---

## 🆘 Getting Help

If you encounter issues:

1. **Check Console**: View → Debug Area → Activate Console (Cmd+Shift+C)
2. **Check Build Logs**: View → Navigators → Show Report Navigator (Cmd+9)
3. **Verify File Paths**: Ensure images are actually in the .xcassets folder
4. **Check Target Membership**: Select image → File Inspector → Target Membership

---

*Last Updated: January 6, 2026*
*Version: 1.0*
