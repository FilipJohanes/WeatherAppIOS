# Testing Environment Setup Guide

Complete setup instructions for testing the DailyBrief iOS app using macOS, iPhone, and Raspberry Pi as backend server.

---

## 🎯 Environment Overview

**Your Setup:**
- 💻 **macOS** - Development machine running Xcode
- 📱 **iPhone** - Physical device for testing (iOS 15.0+)
- 🥧 **Raspberry Pi** - Backend API server

**Network:** All devices must be on the same WiFi/local network

---

## 📋 Prerequisites Checklist

### On macOS
- [ ] macOS 12.5 or later
- [ ] Xcode installed (from Mac App Store)
- [ ] Apple ID (free)
- [ ] USB cable for iPhone connection

### On Raspberry Pi
- [ ] Backend API server running
- [ ] Port 5001 accessible
- [ ] Known IP address
- [ ] API key available

### On iPhone
- [ ] iOS 15.0 or later
- [ ] Same WiFi network as Mac and Pi
- [ ] Developer mode enabled (iOS 16+)

---

## Part 1: Raspberry Pi Backend Setup

### Step 1.1: Verify Backend is Running

SSH into your Raspberry Pi or access it directly:

```bash
# Check if the API server is running
ps aux | grep python
# or
ps aux | grep node  # if using Node.js backend

# Check if port 5001 is listening
sudo netstat -tulpn | grep :5001
# or
sudo lsof -i :5001
```

### Step 1.2: Find Raspberry Pi IP Address

```bash
# Method 1: hostname command
hostname -I

# Method 2: ifconfig
ifconfig | grep "inet "

# Method 3: ip command
ip addr show

# Example output: 192.168.1.100
```

**Write down this IP address!** You'll need it for the iOS app.

### Step 1.3: Test API from Pi

```bash
# Test authentication endpoint
curl -X POST http://localhost:5001/api/users/authenticate \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your_api_key" \
  -d '{"email":"test@example.com","password":"testpassword"}'

# Should return JSON with success and token
```

### Step 1.4: Configure Firewall (if enabled)

```bash
# Allow port 5001 through firewall
sudo ufw allow 5001/tcp

# Check firewall status
sudo ufw status
```

### Step 1.5: Get API Credentials

You'll need:
- ✅ **API Key**: Located in your backend config
- ✅ **Test User Email**: Valid user account email
- ✅ **Test User Password**: User account password
- ✅ **Pi IP Address**: From Step 1.2

**Write these down securely!**

---

## Part 2: macOS Setup

### Step 2.1: Install Xcode

1. Open **Mac App Store**
2. Search for "Xcode"
3. Click **Get** (free, ~12-15 GB download)
4. Wait for installation (may take 30-60 minutes)
5. Open Xcode once to accept license agreement

### Step 2.2: Test Network Connection to Pi

Open **Terminal** on Mac:

```bash
# Ping the Raspberry Pi (replace with your Pi's IP)
ping 192.168.1.100

# Should see replies like:
# 64 bytes from 192.168.1.100: icmp_seq=0 ttl=64 time=2.1 ms

# Test API endpoint
curl http://192.168.1.100:5001/api/v2/daily-brief
# Should get "Unauthorized" or similar (expected without token)

# If connection fails, check:
# - Both devices on same WiFi
# - Pi firewall allows port 5001
# - Backend server is running
```

### Step 2.3: Create Xcode Project

1. **Open Xcode**
2. Select **File → New → Project**
3. Choose **iOS** platform tab
4. Select **App** template
5. Click **Next**

Configure project:
- **Product Name**: `DailyBrief`
- **Team**: Select your Apple ID team
- **Organization Identifier**: `com.yourname` (lowercase, no spaces)
- **Bundle Identifier**: Auto-generated (e.g., `com.yourname.DailyBrief`)
- **Interface**: **SwiftUI**
- **Language**: **Swift**
- **Storage**: None
- **Include Tests**: Optional

6. Click **Next**
7. Choose save location (e.g., Desktop or Documents)
8. Click **Create**

### Step 2.4: Add Project Files

**Option A: Drag and Drop (Recommended)**

1. In **Finder**, navigate to your `DailyBrief/` folder
2. In **Xcode**, right-click on the project (blue icon at top)
3. Select **Add Files to "DailyBrief"...**
4. Navigate to the `DailyBrief/` folder
5. Select all folders:
   - App/
   - Models/
   - Services/
   - ViewModels/
   - Views/
   - Utilities/
6. **Important checkboxes:**
   - ✅ Copy items if needed
   - ✅ Create groups
   - ✅ Add to targets: DailyBrief
7. Click **Add**

**Option B: Copy All at Once**

1. Select all folders in Finder
2. Drag them into Xcode project navigator
3. Ensure "Copy items if needed" is checked
4. Click **Finish**

### Step 2.5: Delete Default Files

In Xcode project navigator:
1. Find `ContentView.swift` (if exists)
2. Right-click → **Delete**
3. Choose **Move to Trash**

### Step 2.6: Configure API Settings

1. In Xcode, navigate to `Services/APIConfig.swift`
2. Update with your Raspberry Pi details:

```swift
import Foundation

struct APIConfig {
    static let apiKey = "your_actual_api_key_here"  // ← From Pi
    
    #if DEBUG
    static let baseURL = "http://192.168.1.100:5001"  // ← Your Pi's IP
    #else
    static let baseURL = "http://192.168.1.100:5001"  // ← Your Pi's IP
    #endif
}
```

3. **Save file** (Cmd+S)

### Step 2.7: Update Keychain Service ID

1. Open `Services/KeychainHelper.swift`
2. Update service ID to match your bundle identifier:

```swift
private let service = "com.yourname.dailybrief"  // ← Your bundle ID
```

3. **Save file** (Cmd+S)

### Step 2.8: Configure Project Settings

1. Click **project** (blue icon) in navigator
2. Select **DailyBrief** target
3. **General** tab:
   - **Minimum Deployments**: Set to **iOS 15.0**
   - Verify Bundle Identifier

4. **Signing & Capabilities** tab:
   - Select your **Team** (your Apple ID)
   - ✅ Enable **Automatically manage signing**
   - Click **+ Capability** button
   - Search and add **Keychain Sharing**
   - In Keychain Groups: `$(AppIdentifierPrefix)com.yourname.dailybrief`

### Step 2.9: Build the Project

1. Select simulator: **iPhone 15** (or any iOS 15+ simulator)
2. Press **Cmd+B** to build
3. Wait for build to complete
4. Check for errors (should be none if files added correctly)

**If build fails:**
- Clean build folder: Product → Clean Build Folder (Cmd+Shift+K)
- Verify all files have target membership
- Check for typos in API configuration

### Step 2.10: Test in Simulator

1. Press **Cmd+R** or click ▶️ button
2. Simulator will launch
3. App should show login screen
4. Try logging in with your test credentials

**If login succeeds:** ✅ Backend connection working!  
**If login fails:** Check network connection and API credentials

---

## Part 3: iPhone Physical Device Setup

### Step 3.1: Prepare iPhone

1. **Update iOS** (if needed)
   - Settings → General → Software Update
   - Requires iOS 15.0 or later

2. **Connect to Same WiFi**
   - Settings → WiFi
   - Connect to same network as Mac and Pi
   - Verify connection

3. **Enable Developer Mode** (iOS 16+ only)
   - Settings → Privacy & Security → Developer Mode
   - Toggle ON
   - Restart iPhone when prompted

### Step 3.2: Trust Your Mac

1. Connect iPhone to Mac with USB cable
2. On iPhone: Unlock device
3. Alert appears: **"Trust This Computer?"**
4. Tap **Trust**
5. Enter iPhone passcode
6. On Mac: Xcode should detect the device

### Step 3.3: Configure Device in Xcode

1. In Xcode, click device menu (next to scheme)
2. Your iPhone should appear in the list
3. Select your iPhone
4. Xcode will prepare device (first time only)
5. Wait for "Ready" status

**If device doesn't appear:**
- Unplug and replug USB cable
- Restart Xcode
- Check cable is data-capable (not charge-only)

### Step 3.4: Run App on iPhone

1. With iPhone selected in device menu
2. Press **Cmd+R** or click ▶️
3. Xcode will build and install app
4. **First time:** Alert on iPhone about untrusted developer

### Step 3.5: Trust Developer Certificate

On iPhone:
1. Go to **Settings → General → VPN & Device Management**
2. Under **Developer App**, tap your Apple ID
3. Tap **Trust "[Your Apple ID]"**
4. Tap **Trust** in confirmation
5. Return to home screen
6. App icon should now be visible

### Step 3.6: Launch and Test

1. Tap **DailyBrief** app icon
2. Login screen should appear
3. Enter your test credentials:
   - Email: `test@example.com` (or your user)
   - Password: Your password
4. Tap **Login**

**Expected Result:**
- Loading indicator appears
- Successfully logs in
- Main tab view displays
- Daily brief loads from Pi

---

## Part 4: Network Testing & Troubleshooting

### Test 1: Verify All Devices on Same Network

**On Raspberry Pi:**
```bash
hostname -I
# Note the IP: 192.168.1.100
```

**On macOS:**
```bash
ifconfig | grep "inet "
# Should show similar IP range: 192.168.1.xxx
```

**On iPhone:**
- Settings → WiFi → Tap (i) icon next to connected network
- Note IP address: Should be 192.168.1.xxx

**All IPs should be in same subnet (e.g., 192.168.1.x)**

### Test 2: Mac → Pi Connection

```bash
# On Mac Terminal:
curl -v http://192.168.1.100:5001/api/v2/daily-brief
# Should get response (even if 401 Unauthorized)
```

### Test 3: iPhone → Pi Connection

**Using Network Utility app** (download from App Store):
1. Ping test to Pi IP
2. Should show successful pings

**Or test via app:**
1. Run app on iPhone
2. Try to login
3. Check error messages

### Test 4: Backend API Health

```bash
# On Raspberry Pi:
curl http://localhost:5001/api/v2/daily-brief
# Should respond (even if unauthorized)

# Check logs
tail -f /path/to/your/api/logs/*.log
# Watch for incoming requests
```

---

## Part 5: Common Issues & Solutions

### Issue: "Cannot connect to backend"

**Check:**
1. Pi backend is running: `ps aux | grep python`
2. Port 5001 is listening: `sudo netstat -tulpn | grep 5001`
3. Firewall allows port 5001: `sudo ufw status`
4. All devices on same WiFi
5. Pi IP address is correct in APIConfig.swift

**Solution:**
```bash
# Restart backend on Pi
sudo systemctl restart your-api-service
# or manually restart your backend server
```

### Issue: "Build failed in Xcode"

**Check:**
1. All files added to target
2. No duplicate files
3. Minimum deployment target is iOS 15.0
4. No syntax errors in Swift files

**Solution:**
- Clean build folder: Cmd+Shift+K
- Delete DerivedData: Xcode → Preferences → Locations → DerivedData → Delete
- Restart Xcode

### Issue: "Login fails with 401 Unauthorized"

**Check:**
1. API key is correct in APIConfig.swift
2. Test credentials are valid
3. Backend user exists in database

**Solution:**
```bash
# On Pi, test authentication:
curl -X POST http://localhost:5001/api/users/authenticate \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your_key" \
  -d '{"email":"test@example.com","password":"password"}'
```

### Issue: "App crashes on launch"

**Check:**
1. Xcode console for error messages
2. All required files are present
3. No force unwrapping errors

**Solution:**
- Check Console in Xcode for crash logs
- Verify all View files are properly connected
- Ensure APIService is properly initialized

### Issue: "Device not appearing in Xcode"

**Check:**
1. USB cable is data-capable (not charge-only)
2. iPhone is unlocked
3. "Trust This Computer" accepted
4. iPhone iOS version is 15.0+

**Solution:**
1. Unplug and replug USB
2. Restart Xcode
3. Restart iPhone
4. Try different USB port
5. Update iTunes/Finder (handles device connection)

### Issue: "Network timeout on iPhone"

**Check:**
1. iPhone on WiFi (not cellular)
2. WiFi connected to same network as Pi
3. Pi IP address is correct

**Solution:**
1. Turn WiFi off/on on iPhone
2. Forget and rejoin WiFi network
3. Test with ping utility app
4. Check Pi is reachable from Mac first

### Issue: "Keychain errors"

**Check:**
1. Keychain Sharing capability enabled
2. Service ID matches bundle identifier
3. No special characters in bundle ID

**Solution:**
1. In Xcode: Signing & Capabilities → Verify Keychain Sharing
2. Update KeychainHelper.swift service ID
3. Clean and rebuild

---

## Part 6: Testing Workflow

### Daily Development Routine

1. **Start Backend on Pi**
   ```bash
   ssh pi@192.168.1.100
   cd /path/to/backend
   python app.py  # or your startup command
   ```

2. **Open Xcode on Mac**
   - Select device (simulator or iPhone)
   - Press Cmd+R to run

3. **Test Core Features**
   - Login
   - Daily brief loads
   - Weather displays
   - Countdowns appear
   - Pull-to-refresh works

4. **Monitor Backend Logs**
   ```bash
   # On Pi, watch logs
   tail -f /path/to/logs/api.log
   ```

### Testing Checklist

- [ ] Login with valid credentials
- [ ] Login with invalid credentials (error shown)
- [ ] Daily brief displays all cards
- [ ] Weather forecast shows 7 days
- [ ] Countdowns list populated
- [ ] Pull-to-refresh updates data
- [ ] Logout and login again (token persists)
- [ ] Close app and reopen (stays logged in)
- [ ] Navigate between all 4 tabs
- [ ] Settings show correct user info
- [ ] Error handling when Pi is offline
- [ ] Network error recovery

---

## Part 7: Network Security Notes

### Current Setup (Development)

Your current configuration allows:
- ✅ HTTP connections to local IP
- ✅ No certificate required for local network
- ✅ Plaintext communication (acceptable for home network)

This is **fine for testing** on your home network.

### For Production (Future)

When deploying to real users:
- ❌ Don't use HTTP
- ✅ Use HTTPS with SSL certificate
- ✅ Don't expose Pi directly to internet
- ✅ Use VPN or secure tunnel
- ✅ Update Info.plist to require HTTPS

**Production Config Example:**
```swift
static let baseURL = "https://api.yourdomain.com"  // HTTPS!
```

---

## Part 8: Quick Reference Commands

### Raspberry Pi Commands

```bash
# Find IP address
hostname -I

# Check backend running
ps aux | grep python

# Check port listening
sudo netstat -tulpn | grep 5001

# View backend logs
tail -f /path/to/logs/*.log

# Restart backend
sudo systemctl restart your-api-service
```

### macOS Commands

```bash
# Test Pi connection
ping 192.168.1.100
curl http://192.168.1.100:5001

# Find Mac IP
ifconfig | grep "inet "

# Check network route
traceroute 192.168.1.100
```

### Xcode Shortcuts

- **Build**: Cmd+B
- **Run**: Cmd+R
- **Stop**: Cmd+.
- **Clean**: Cmd+Shift+K
- **Find**: Cmd+F
- **Console**: Cmd+Shift+Y

---

## Part 9: Environment Variables Summary

Save these for easy reference:

```
# Raspberry Pi
IP Address: 192.168.1.100
API Port: 5001
API Key: your_api_key_here

# Test User
Email: test@example.com
Password: your_password_here

# macOS
Bundle ID: com.yourname.dailybrief
Development Team: Your Apple ID

# Network
WiFi Network: YourHomeWiFi
Subnet: 192.168.1.0/24
```

---

## 🎉 Success Criteria

Your environment is ready when:

✅ Raspberry Pi backend responds to API calls  
✅ Mac can curl Pi API successfully  
✅ Xcode project builds without errors  
✅ App runs in iOS Simulator  
✅ App installs on physical iPhone  
✅ Login succeeds from iPhone  
✅ Daily brief displays data from Pi  
✅ All 4 tabs work correctly  
✅ Pull-to-refresh updates data  

---

## 📞 Getting Help

**Pi Backend Issues:**
- Check backend logs on Pi
- Verify API endpoints work with curl
- Test from Pi itself first

**Network Issues:**
- Verify all devices on same WiFi
- Check firewall settings
- Test connectivity with ping/curl

**Xcode/iOS Issues:**
- Check Console for error messages
- Review device connection settings
- Verify signing certificates

**App Issues:**
- Check APIConfig.swift settings
- Review Xcode console logs
- Test API with curl first

---

**Environment Setup Complete! Ready for Development! 🚀**

*Last Updated: January 2026*
