# Weather Avatar Implementation Guide

## Overview
The Weather Avatar is a layered 2D sprite system that changes appearance (clothing, accessories) based on weather conditions. The avatar uses a "skin" system where different PNG layers stack to create the complete character.

---

## Animation Options

### Option A: Light Animations (CURRENT IMPLEMENTATION)
**Ideal for MVP - Fast, smooth, professional**

#### Features:
- **Smooth Clothing Transitions**: Crossfade between outfits (0.5-0.8s)
- **Idle Breathing Motion**: Gentle scale pulse (1.0 → 1.02 → 1.0 over 3-4 seconds)
- **Weather-Reactive Accessories**: 
  - Umbrella bounces in rain
  - Scarf sways in wind
  - Sunglasses shine in sun

#### Animation Complexity: Low
- CPU Impact: Minimal
- Battery Impact: Negligible
- Asset Requirements: Simple PNGs

#### Code Requirements:
```swift
.animation(.easeInOut, value: outfit)
.scaleEffect(breathing)
.offset(accessoryOffset)
```

---

### Option B: Enhanced Animations
**For polished production app**

#### Everything from Option A, PLUS:
- **Weather Particles**: Rain drops, snow, sun rays
- **Background Mood**: Sky color shifts (sunny yellow → rainy gray)
- **Multiple Idle Animations**: 
  - Occasional blinks
  - Random hand gestures
  - Head turns
- **Wind Effects**: Hair/clothing movement in wind

#### Animation Complexity: Medium
- CPU Impact: Low-Medium
- Battery Impact: Low
- Asset Requirements: More PNG variations + particle system

#### Additional Code:
```swift
ParticleEmitter(type: .rain)
.background(weatherGradient)
TimelineView(.animation) { ... }
```

---

### Option C: Premium Animations
**For flagship feature / avatar-focused app**

#### Everything from Option A + B, PLUS:
- **Interactive Gestures**: 
  - Tap avatar → waves
  - Swipe → spins around
  - Long press → special animation
- **Physics-Based Motion**: Spring animations, realistic cloth movement
- **Advanced Particles**: Complex weather effects
- **Transition Animations**: Full outfit change sequences
- **Avatar Customization**: User-selectable base character appearance

#### Animation Complexity: High
- CPU Impact: Medium
- Battery Impact: Medium
- Asset Requirements: Extensive PNG library + custom animations

#### Additional Code:
```swift
.gesture(TapGesture().onEnded { triggerWave() })
.gesture(DragGesture().onChanged { spin() })
PhysicsSimulation(clothLayers)
```

---

## Skin System Architecture

### Layer Structure
The avatar is built using a **Z-stack layering system** where each layer is a PNG image:

```
ZStack {
    1. Background Layer (optional)
    2. Base Character Body
    3. Base Character Head
    4. Clothing Layer (changes with weather)
    5. Accessories Layer (changes with weather)
    6. Foreground Effects (rain/snow particles)
}
```

### Asset Naming Convention
```
base_character_body.png
base_character_head.png

outfit_sunny_shirt.png
outfit_sunny_shorts.png
outfit_rainy_raincoat.png
outfit_rainy_boots.png
outfit_snowy_jacket.png
outfit_snowy_pants.png
outfit_cold_sweater.png
outfit_cold_scarf.png

accessory_sunny_sunglasses.png
accessory_rainy_umbrella.png
accessory_snowy_hat.png
accessory_windy_scarf.png
```

### Weather-to-Outfit Mapping
```swift
enum WeatherOutfit {
    case sunny       // Light clothing, sunglasses
    case rainy       // Raincoat, umbrella
    case snowy       // Heavy jacket, warm hat
    case cold        // Sweater, scarf
    case hot         // Minimal clothing, sun hat
    case windy       // Jacket, scarf blowing
    case cloudy      // Casual outfit
}

func getOutfit(for weather: Weather) -> WeatherOutfit {
    // Temperature + weather code logic
}
```

---

## Implementation Process

### Phase 1: Core Structure (Day 1)
1. **Create WeatherAvatarModel.swift**
   - Define `WeatherOutfit` enum
   - Weather condition → outfit mapping logic
   - Asset name generator

2. **Create WeatherAvatarView.swift**
   - Basic ZStack with layers
   - Image loading from assets
   - Simple crossfade transitions

3. **Add Assets to Assets.xcassets**
   - Base character (body, head)
   - 5-7 outfit variations
   - 3-5 accessories

### Phase 2: Option A Animations (Day 1-2)
4. **Implement Breathing Animation**
   - `.onAppear` timer for scale effect
   - Gentle 1.0 → 1.02 pulse

5. **Add Weather-Reactive Accessories**
   - Umbrella bounce in rain
   - Scarf sway in wind
   - Conditional rendering based on weather

6. **Smooth Transitions**
   - `.animation(.easeInOut(duration: 0.6))` on outfit changes

### Phase 3: Integration (Day 2)
7. **Connect to WeatherViewModel**
   - Pass current weather data
   - Update outfit when weather changes

8. **Add to DailyBriefView**
   - Position above WeatherCard
   - Size appropriately (200-300pt)

### Phase 4: Testing (Day 2)
9. **Test All Weather Conditions**
   - Sunny, rainy, snowy, cold, hot
   - Verify outfit changes
   - Check animation smoothness

10. **Performance Check**
    - Memory usage
    - Animation frame rate
    - Battery impact

---

## Migration Path: Option A → B → C

### A to B (Add Later):
```swift
// Add to WeatherAvatarView
@State private var showParticles = true

var body: some View {
    ZStack {
        // Existing avatar layers
        avatarLayers
        
        // NEW: Weather particles
        if showParticles {
            WeatherParticleView(weather: weather)
        }
    }
    // NEW: Background mood
    .background(weatherMoodGradient)
}
```

### B to C (Add When Ready):
```swift
// Add to WeatherAvatarView
@State private var isInteractive = true
@State private var gestureAnimation: GestureType?

var body: some View {
    avatarWithParticles
        // NEW: Gesture handling
        .gesture(TapGesture().onEnded { wave() })
        .gesture(DragGesture().onChanged { spin(value: $0) })
}
```

**No breaking changes** - each option extends the previous one.

---

## Asset Creation Guide

### Option 1: Create Your Own (Free)
**Tools:**
- Procreate (iPad) / Krita (Free Desktop)
- Export as PNG with transparency
- Resolution: 512x512 to 1024x1024

**Style Suggestions:**
- Simple cartoon style (easier to animate)
- Clear outlines
- Flat colors or minimal shading

### Option 2: Commission an Artist
**Cost:** $50-200 for full character + 7 outfits
**Platforms:** Fiverr, Upwork, r/HungryArtists

### Option 3: Use AI Generation
**Tools:**
- Midjourney / DALL-E for concept
- Remove backgrounds with remove.bg
- Create layers manually in image editor

### Option 4: Asset Stores
**Resources:**
- itch.io (game assets, many free)
- OpenGameArt.org
- Kenney.nl (free game assets)

---

## File Structure

```
DailyBrief/
├── Models/
│   └── WeatherAvatar.swift          # Outfit enum, mapping logic
├── Views/
│   └── Avatar/
│       ├── WeatherAvatarView.swift  # Main avatar component
│       └── Components/
│           ├── AvatarBaseLayer.swift
│           ├── AvatarOutfitLayer.swift
│           └── AvatarAccessoryLayer.swift (if needed)
├── Assets.xcassets/
│   └── Avatar/
│       ├── Base/
│       │   ├── character_body.imageset/
│       │   └── character_head.imageset/
│       ├── Outfits/
│       │   ├── outfit_sunny.imageset/
│       │   ├── outfit_rainy.imageset/
│       │   └── outfit_snowy.imageset/
│       └── Accessories/
│           ├── accessory_umbrella.imageset/
│           └── accessory_sunglasses.imageset/
```

---

## Performance Considerations

### Optimization Tips:
1. **Lazy Loading**: Only load visible outfit assets
2. **Asset Compression**: Use compressed PNGs
3. **Caching**: Cache loaded images in memory
4. **Animation Throttling**: Limit updates to 60fps
5. **Conditional Rendering**: Hide particles on low battery

### Memory Targets:
- **Option A**: ~5-10MB (5-7 PNG assets)
- **Option B**: ~10-20MB (more assets + particles)
- **Option C**: ~20-30MB (extensive asset library)

---

## Testing Checklist

### Visual Testing:
- [ ] All weather conditions show correct outfit
- [ ] Transitions are smooth (no flickering)
- [ ] Animations run at 60fps
- [ ] Assets align properly (no gaps/overlaps)
- [ ] Works on all device sizes (iPhone SE to Pro Max)

### Performance Testing:
- [ ] Memory usage under 30MB
- [ ] No memory leaks during outfit changes
- [ ] Battery drain < 5% over 30min of active use
- [ ] CPU usage < 20% during animations

### Integration Testing:
- [ ] Updates when weather data refreshes
- [ ] Works with all weather presets (minimal/standard/complete)
- [ ] Doesn't block weather card loading
- [ ] Handles missing/loading weather data gracefully

---

## Current Status

**Phase:** Starting Implementation  
**Option:** A (Light Animations)  
**Branch:** phase-2-weather-avatar  
**Next Steps:** 
1. Create WeatherAvatar.swift model
2. Create WeatherAvatarView.swift
3. Add placeholder assets (will need real art assets later)
4. Implement Option A animations
5. Integrate into DailyBriefView

---

## Future Enhancements (Post-Option C)

- **Multiple Avatar Characters**: Let users choose different base characters
- **Avatar Customization**: Hair color, skin tone, accessories
- **Avatar Moods**: Happy in good weather, grumpy in bad weather
- **Time-of-Day Variations**: Different outfits for morning/evening
- **Seasonal Themes**: Holiday outfits, special events
- **Avatar Shop**: In-app purchases for premium outfits
- **Social Features**: Share your avatar's outfit

---

## Resources

### SwiftUI Animation Documentation:
- [Apple - Animating Views and Transitions](https://developer.apple.com/tutorials/swiftui/animating-views-and-transitions)
- [Hacking with Swift - Advanced SwiftUI Animations](https://www.hackingwithswift.com/books/ios-swiftui)

### Particle Systems:
- [SwiftUI Particle Effects Tutorial](https://www.hackingwithswift.com/plus/intermediate-swiftui/how-to-create-a-particle-system)

### Asset Design:
- [2D Character Design Best Practices](https://www.gamedeveloper.com/design/2d-character-design-guide)

---

*Last Updated: January 18, 2026*  
*Current Implementation: Starting Option A*
