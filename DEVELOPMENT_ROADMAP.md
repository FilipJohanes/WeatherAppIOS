# Trident App - Development Roadmap

## 🎯 Project Overview

A weather app with countdown features and an avatar that changes clothes based on weather conditions. Progressive development in 4 stages.

---

## 📋 Stage 1: MVP (Minimum Viable Product)

### Goals
- Simple weather app showing current weather and forecast
- Countdown feature (limit: 20 per user)
- No login/authentication
- Local storage only
- Direct weather API integration

### Features
✅ Weather display (current + 7-day forecast)
✅ Location-based weather
✅ Add/edit/delete countdowns
✅ 20 countdown limit per user
✅ Clean Trident blue UI
✅ Offline support (cached data)

### Technical Stack
- SwiftUI
- No backend
- OpenWeatherMap API (or similar)
- UserDefaults for local storage
- CoreLocation for GPS

### Architecture
```
Trident App
├── Weather (API → Display)
├── Countdowns (Local Storage)
└── Settings (Basic)
```

### Copy-Paste Prompt for Stage 1:
```
Start Stage 1 of Trident app development:

Create MVP with:
1. Weather display (current + 7-day forecast) using direct API calls
2. Countdown feature with 20 item limit
3. Local storage (no backend)
4. Trident blue branding (#ADD8E6)
5. No authentication required
6. Simple, clean UI

Remove all authentication/login code.
Implement direct weather API integration.
Add countdown CRUD operations with 20 limit.
Store everything locally.
```

---

## 📋 Stage 2: Weather Avatar

### Goals
- Add character/avatar to main screen
- Avatar changes clothes based on weather conditions
- Visual guide for how to dress

### Features
✅ Character display on main screen
✅ Dynamic clothing based on:
  - Temperature (cold/mild/hot)
  - Rain (umbrella, raincoat)
  - Snow (winter coat, boots)
  - Sun (sunglasses, light clothes)
  - Wind (jacket)
✅ Smooth animations between states
✅ Character positioned prominently

### Technical Requirements
- SF Symbols or custom illustrations
- Weather condition mapping
- Animation system
- Asset management

### Weather → Clothing Logic
```
Cold (<10°C): Winter coat, hat, gloves
Mild (10-20°C): Jacket, long pants
Warm (20-30°C): T-shirt, shorts
Hot (>30°C): Light clothes, sunglasses
Rain: Umbrella, raincoat
Snow: Heavy coat, boots, scarf
Sunny: Sunglasses
Windy: Windbreaker
```

### Copy-Paste Prompt for Stage 2:
```
Start Stage 2 of Trident app development:

Build on Stage 1 MVP and add weather avatar:

1. Create character/avatar component for main screen
2. Implement clothing system based on weather:
   - Temperature ranges (cold/mild/warm/hot)
   - Precipitation (rain/snow)
   - Special conditions (sun/wind)
3. Design or use SF Symbols for clothing items:
   - Winter coat, jacket, t-shirt
   - Umbrella, sunglasses, hat
   - Boots, regular shoes
4. Add smooth transitions when weather changes
5. Position character prominently on DailyBrief view
6. Make it visually appealing and helpful

Reference image provided for character style.
Character should be simple and iconic.
```

---

## 📋 Stage 3: Subscription Model

### Goals
- Implement freemium model
- Add StoreKit 2 for IAP
- Enforce feature limits
- Premium features

### Features

**Free Tier:**
- 1 location only
- 1 countdown only
- Basic avatar (default clothes)
- Standard theme

**Premium Tier (€1/month):**
- Unlimited locations
- Unlimited countdowns
- All avatar clothes
- Premium themes
- Extended forecast (14 days)
- Weather widgets

### Technical Requirements
- StoreKit 2 integration
- Subscription management
- Receipt validation
- Feature gating
- Paywall UI
- Restore purchases

### Backend Decision
- Option A: Continue serverless (iCloud for sync)
- Option B: Add lightweight backend for receipt verification

### Copy-Paste Prompt for Stage 3:
```
Start Stage 3 of Trident app development:

Build on Stages 1-2 and implement subscription model:

1. Integrate StoreKit 2 for in-app purchases
2. Create subscription product: €1/month
3. Implement feature gating:
   
   FREE TIER:
   - 1 location only
   - 1 countdown only
   - Basic avatar clothes
   - 7-day forecast
   
   PREMIUM TIER (€1/month):
   - Unlimited locations
   - Unlimited countdowns (still max 20 active)
   - All avatar clothes unlocked
   - 14-day forecast
   - Premium themes

4. Create paywall/upgrade UI
5. Add "Restore Purchases" functionality
6. Store subscription status locally + verify with Apple
7. Show premium badge/indicator
8. Handle subscription lifecycle (trial, active, expired)

Keep serverless architecture unless absolutely needed.
Use iCloud for syncing subscription status across devices.
```

---

## 📋 Stage 4: Wardrobe & Custom Skins

### Goals
- Custom clothing system
- Wardrobe management
- Unlock/purchase clothes
- Gamification elements

### Features

**Wardrobe System:**
✅ Browse available clothes
✅ Try on clothes
✅ Save outfits per weather condition
✅ Organize by category (tops, bottoms, accessories)

**Unlocking Clothes:**
- Some free (default)
- Some earned (achievements)
- Some purchased (IAP €0.99 per item or bundle)
- Seasonal collections

**Categories:**
- Tops (t-shirt, sweater, jacket, coat)
- Bottoms (shorts, pants, jeans)
- Accessories (hat, sunglasses, umbrella, scarf)
- Shoes (sandals, sneakers, boots)
- Special (holiday themes, fun costumes)

**Weather Rules:**
- User can override automatic selection
- Set preferences: "Always wear sunglasses in sun"
- Default fallbacks if user hasn't chosen

### Monetization

**Free Clothes:**
- 3 basic outfits
- Starter pack

**Earned Clothes:**
- Login streaks
- Location milestones
- Weather achievements

**Purchased Clothes:**
- €0.99 per item
- €2.99 for themed bundle
- Seasonal packs

### Technical Requirements
- Asset management system
- Wardrobe database (local)
- Purchase tracking
- Achievement system
- UI for browsing/trying clothes

### Copy-Paste Prompt for Stage 4:
```
Start Stage 4 of Trident app development:

Build on Stages 1-3 and add wardrobe/custom skins system:

1. Create Wardrobe feature:
   - Browse all clothes (owned + locked)
   - Try on clothes with preview
   - Save outfits per weather condition
   - Organize by category

2. Implement clothing categories:
   - Tops (5+ options)
   - Bottoms (5+ options)
   - Accessories (hat, sunglasses, umbrella, scarf)
   - Shoes (3+ options)
   - Special items (seasonal/fun)

3. Add unlock system:
   - Free: 3 basic outfits (always available)
   - Earned: Achievements (login streaks, milestones)
   - Purchased: IAP for individual items or bundles

4. Create wardrobe UI:
   - Grid view of all clothes
   - Filter by category
   - Show locked/unlocked status
   - Try before buy
   - Purchase flow

5. Implement weather-outfit mapping:
   - User can customize per condition
   - Default smart selection
   - Override system ("always wear this")

6. Add IAP products:
   - Individual clothes: €0.99
   - Themed bundles: €2.99
   - Seasonal collections

7. Achievement system:
   - Track app usage
   - Reward with clothes
   - Show progress

Keep data local with iCloud sync for premium users.
Make wardrobe fun and engaging!
```

---

## 🚀 Development Workflow

### Starting a New Stage

1. **Copy the prompt** from this document
2. **Paste into chat** with GitHub Copilot
3. **Review** existing code first
4. **Implement** features incrementally
5. **Test** thoroughly before moving on
6. **Update documentation** as needed

### Between Stages

- ✅ Test all features thoroughly
- ✅ Fix any bugs
- ✅ Optimize performance
- ✅ Update documentation
- ✅ Get user feedback (if possible)
- ✅ Plan next stage refinements

---

## 📊 Feature Comparison Matrix

| Feature | Stage 1 | Stage 2 | Stage 3 Free | Stage 3 Premium | Stage 4 |
|---------|---------|---------|--------------|-----------------|---------|
| Weather (locations) | 1 | 1 | 1 | Unlimited | Unlimited |
| Countdowns | 20 | 20 | 1 | 20 | 20 |
| Avatar | ❌ | ✅ Basic | ✅ Basic | ✅ All clothes | ✅ Custom |
| Forecast days | 7 | 7 | 7 | 14 | 14 |
| Themes | Basic | Basic | Basic | Premium | Premium |
| Wardrobe | ❌ | ❌ | ❌ | ❌ | ✅ |
| Custom clothes | ❌ | ❌ | ❌ | ✅ | ✅ Purchase |
| Cost | Free | Free | Free | €1/mo | €1/mo + items |

---

## 🎯 Success Metrics

### Stage 1 (MVP)
- App launches successfully
- Weather displays accurately
- Can add/edit/delete countdowns
- No crashes
- Smooth performance

### Stage 2 (Avatar)
- Character displays correctly
- Clothes change based on weather
- Animations are smooth
- User finds it helpful/fun

### Stage 3 (Subscription)
- Purchase flow works
- Feature limits enforced
- Premium features unlock correctly
- No payment issues

### Stage 4 (Wardrobe)
- Wardrobe is intuitive
- Clothes display correctly on avatar
- Purchase flow smooth
- Users engage with customization

---

## 🛠️ Technical Debt & Refactoring

### After Each Stage

**Code Quality:**
- Refactor repeated code
- Optimize performance
- Clean up unused code
- Update comments

**Testing:**
- Add unit tests
- Test edge cases
- Memory leak checks
- Performance profiling

**Documentation:**
- Update README
- Document new features
- Update architecture diagrams

---

## 📱 Platform & Requirements

### iOS Requirements
- iOS 16.0+ (for StoreKit 2)
- Xcode 14+
- Swift 5.9+
- SwiftUI

### APIs Needed

**Stage 1:**
- OpenWeatherMap API (free tier)
  - 1,000 calls/day
  - Current weather + forecast

**Stage 2:**
- Same as Stage 1

**Stage 3:**
- Weather API
- StoreKit 2 (Apple)

**Stage 4:**
- Weather API
- StoreKit 2 (Apple)
- Optional: Cloud storage for purchased items

---

## 💰 Monetization Summary

### Stage 1-2
- **Free** - Build audience

### Stage 3
- **Freemium** - €1/month subscription
- Revenue: Recurring

### Stage 4
- **Freemium + IAP** - €1/month + items
- Additional: €0.99-€2.99 per item/bundle
- Revenue: Recurring + one-time

---

## 🗓️ Estimated Timeline

**Stage 1 (MVP):** 
- Implementation: 4-6 hours
- Testing: 2 hours
- Total: 1 day

**Stage 2 (Avatar):**
- Design/Assets: 2-3 hours
- Implementation: 3-4 hours
- Testing: 2 hours
- Total: 1-2 days

**Stage 3 (Subscription):**
- StoreKit setup: 2 hours
- Feature gating: 2 hours
- UI/UX: 2 hours
- Testing: 2 hours
- Total: 1 day

**Stage 4 (Wardrobe):**
- Design system: 3-4 hours
- Wardrobe UI: 4-5 hours
- Purchase flow: 2-3 hours
- Achievements: 2 hours
- Testing: 3 hours
- Total: 2-3 days

**Total Project:** 5-7 days of development

---

## 🎨 Design System

### Colors (Trident Branding)
```swift
Light Blue: #ADD8E6 (RGB 173, 216, 230)
Dark Blue: #336699 (RGB 51, 102, 153)
Dark Gray: #545454 (RGB 84, 84, 84)
White: #FFFFFF
Green: #4CAF50 (accents)
```

### Typography
- Title: System Bold 28pt
- Headline: System Semibold 20pt
- Body: System Regular 16pt
- Caption: System Regular 12pt

### Spacing
- Tiny: 4pt
- Small: 8pt
- Medium: 16pt
- Large: 24pt
- XLarge: 32pt

---

## 📦 Deliverables Per Stage

### Stage 1
- ✅ Working weather app
- ✅ Countdown feature
- ✅ Basic settings
- ✅ Documentation

### Stage 2
- ✅ Avatar component
- ✅ Weather-based clothing logic
- ✅ Animation system
- ✅ Updated UI

### Stage 3
- ✅ Subscription system
- ✅ Feature gating
- ✅ Paywall UI
- ✅ Premium features

### Stage 4
- ✅ Wardrobe system
- ✅ Custom clothes
- ✅ Purchase flow
- ✅ Achievement system
- ✅ Complete app

---

## 🔄 Version Control

### Git Workflow

**Branching:**
- `main` - Production ready
- `stage-1-mvp` - Stage 1 development
- `stage-2-avatar` - Stage 2 development
- `stage-3-subscription` - Stage 3 development
- `stage-4-wardrobe` - Stage 4 development

**Commits:**
- Small, focused commits
- Clear commit messages
- Reference stage in message

---

## ✅ Current Status

**Status:** Ready to start Stage 1
**Branch:** main
**Next Action:** Begin Stage 1 MVP implementation

---

*Last Updated: January 6, 2026*
*Project: Trident Weather App*
*Repository: FilipJohanes/WeatherAppIOS*
