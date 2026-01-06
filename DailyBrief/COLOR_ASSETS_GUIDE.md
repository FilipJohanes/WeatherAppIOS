# Trident App - Color Assets Setup (Optional)

This guide shows how to add color sets to your asset catalog for easier color management.

## Why Add Color Assets?

Instead of using `Color(red: 0.68, green: 0.85, blue: 0.90)` everywhere, you can use `Color("TridentBlue")` which:
- Is easier to read
- Can be changed in one place
- Supports light/dark mode variations

## Step 1: Create Color Sets in Xcode

### Method 1: Via Xcode Interface

1. Open Xcode
2. Navigate to `Assets.xcassets`
3. Right-click in the asset list
4. Select **New Color Set**
5. Name it appropriately
6. Set the color values

### Method 2: Via File Creation (Faster)

The color set configurations are already created below. Just copy them!

---

## Color Set: TridentBlue (Background)

**Create folder:** `Assets.xcassets/TridentBlue.colorset/`

**Create file:** `Assets.xcassets/TridentBlue.colorset/Contents.json`

```json
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "0.902",
          "green" : "0.847",
          "red" : "0.678"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

**Usage:**
```swift
// Instead of:
Color(red: 0.68, green: 0.85, blue: 0.90)

// Use:
Color("TridentBlue")
```

---

## Color Set: TridentDarkBlue (Buttons)

**Create folder:** `Assets.xcassets/TridentDarkBlue.colorset/`

**Create file:** `Assets.xcassets/TridentDarkBlue.colorset/Contents.json`

```json
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "0.600",
          "green" : "0.400",
          "red" : "0.200"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

**Usage:**
```swift
// Instead of:
Color(red: 0.20, green: 0.40, blue: 0.60)

// Use:
Color("TridentDarkBlue")
```

---

## Color Set: TridentGray (Text)

**Create folder:** `Assets.xcassets/TridentGray.colorset/`

**Create file:** `Assets.xcassets/TridentGray.colorset/Contents.json`

```json
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "0.329",
          "green" : "0.329",
          "red" : "0.329"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

**Usage:**
```swift
// Instead of:
Color(red: 0.33, green: 0.33, blue: 0.33)

// Use:
Color("TridentGray")
```

---

## Quick Setup Script (macOS Terminal)

Run this in your project directory:

```bash
# Navigate to Assets folder
cd DailyBrief/Assets.xcassets

# Create TridentBlue color set
mkdir -p TridentBlue.colorset
cat > TridentBlue.colorset/Contents.json << 'EOF'
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "0.902",
          "green" : "0.847",
          "red" : "0.678"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Create TridentDarkBlue color set
mkdir -p TridentDarkBlue.colorset
cat > TridentDarkBlue.colorset/Contents.json << 'EOF'
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "0.600",
          "green" : "0.400",
          "red" : "0.200"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Create TridentGray color set
mkdir -p TridentGray.colorset
cat > TridentGray.colorset/Contents.json << 'EOF'
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "0.329",
          "green" : "0.329",
          "red" : "0.329"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

echo "✅ Color sets created!"
```

---

## Update Views to Use Color Assets (Optional)

If you create the color assets, you can optionally update the views:

### LoginView.swift
Replace:
```swift
Color(red: 0.68, green: 0.85, blue: 0.90)
```
With:
```swift
Color("TridentBlue")
```

### All Views
Replace all instances of:
- `Color(red: 0.68, green: 0.85, blue: 0.90)` → `Color("TridentBlue")`
- `Color(red: 0.20, green: 0.40, blue: 0.60)` → `Color("TridentDarkBlue")`
- `Color(red: 0.33, green: 0.33, blue: 0.33)` → `Color("TridentGray")`

---

## Benefits

✅ **Easier to maintain** - Change color in one place
✅ **More readable** - `Color("TridentBlue")` vs `Color(red: 0.68, ...)`
✅ **Dark mode support** - Can add dark mode variants later
✅ **Reusable** - Use same colors across the app
✅ **Designer-friendly** - Non-coders can update colors

---

## Color Reference Table

| Name | Usage | RGB | Hex | SwiftUI (current) | Asset Name |
|------|-------|-----|-----|-------------------|------------|
| Trident Blue | Backgrounds | 173, 216, 230 | #ADD8E6 | `Color(red: 0.68, green: 0.85, blue: 0.90)` | TridentBlue |
| Dark Blue | Buttons | 51, 102, 153 | #336699 | `Color(red: 0.20, green: 0.40, blue: 0.60)` | TridentDarkBlue |
| Dark Gray | Text | 84, 84, 84 | #545454 | `Color(red: 0.33, green: 0.33, blue: 0.33)` | TridentGray |

---

## Note

This is **OPTIONAL**. The app already works with the inline color definitions. Adding color assets is a best practice for larger projects but not required for functionality.

---

*Optional Enhancement Guide*
*Version: 1.0*
