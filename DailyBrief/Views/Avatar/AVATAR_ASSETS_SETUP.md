# Avatar Assets Setup

## Required Assets

Until you have custom art assets, you'll need to add placeholder images to `Assets.xcassets/Avatar/`.

### Asset Structure:

```
Assets.xcassets/
└── Avatar/
    ├── Base/
    │   ├── character_body.imageset/
    │   └── character_head.imageset/
    ├── Outfits/
    │   ├── outfit_sunny.imageset/
    │   ├── outfit_rainy.imageset/
    │   ├── outfit_snowy.imageset/
    │   ├── outfit_cold.imageset/
    │   ├── outfit_hot.imageset/
    │   ├── outfit_windy.imageset/
    │   └── outfit_cloudy.imageset/
    └── Accessories/
        ├── accessory_sunglasses.imageset/
        ├── accessory_umbrella.imageset/
        ├── accessory_hat.imageset/
        └── accessory_scarf.imageset/
```

## Placeholder Options

### Option 1: SF Symbols (Quickest)
Use system icons temporarily:
- `figure.stand` for character body
- `person.circle` for head
- Weather-specific SF Symbols for outfits

### Option 2: Simple Colored Shapes
Create simple geometric placeholder shapes in any image editor:
- Circle for head
- Rectangle for body
- Different colored rectangles for different outfits

### Option 3: Free Asset Packs
Download from:
- [Kenney.nl](https://kenney.nl/assets?q=2d) - Free game assets
- [OpenGameArt.org](https://opengameart.org/art-search?keys=character)
- [itch.io](https://itch.io/game-assets/free/tag-character)

## Image Requirements

- **Format**: PNG with transparency
- **Resolution**: 512x512px minimum (1024x1024px recommended)
- **Color Mode**: RGBA
- **Naming**: Must match the names in code exactly

## Next Steps

1. **Create Avatar folder** in Assets.xcassets
2. **Add placeholder images** (can use SF Symbols initially)
3. **Test in preview** to verify images load
4. **Replace with real art** when ready

---

*Note: The code is ready and will work once assets are added. The app will crash if it can't find these images, so add placeholders first.*
