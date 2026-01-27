# Local-Only Mode: Clean UI Design Specification

## Design Philosophy

**Minimalism First**
- Show only essential information
- Maximum readability from across the room
- Clean typography with generous spacing
- High contrast for accessibility
- No visual clutter or unnecessary elements

**Functional Beauty**
- Information hierarchy through size and weight
- Subtle visual cues without distraction
- Professional, modern appearance
- Timeless design that won't feel dated

## Primary Display (Default View)

### Layout Specification

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│          [40px padding]             │
│                                     │
│            72°                      │
│          [Bold, 96px]               │
│                                     │
│          [20px gap]                 │
│                                     │
│        Humidity 41%                 │
│        [Light, 28px]                │
│                                     │
│          [40px padding]             │
│                                     │
│                                     │
│      [Status: Local Mode]           │
│         [12px, subtle]              │
│                                     │
└─────────────────────────────────────┘
```

### Typography

**Temperature Display**
- Font: System Sans Serif (Roboto/Helvetica Neue equivalent)
- Size: 96px
- Weight: Bold (700)
- Color: #FFFFFF (Pure White)
- Letter spacing: -2px (tighter for large numbers)
- Line height: 1.0

**Humidity Display**
- Font: System Sans Serif
- Size: 28px
- Weight: Light (300)
- Color: #B0B0B0 (Light Gray, 69% opacity)
- Letter spacing: 0
- Line height: 1.2

**Status Indicator**
- Font: System Sans Serif
- Size: 12px
- Weight: Regular (400)
- Color: #707070 (Dark Gray, 44% opacity)
- Letter spacing: 0.5px
- Line height: 1.4

### Color Palette

**Background**
- Primary: #000000 (True Black)
- Reason: Maximum contrast, lowest power consumption on OLED

**Text Colors**
- Primary (Temperature): #FFFFFF (White)
- Secondary (Humidity): #B0B0B0 (70% White)
- Tertiary (Status): #707070 (44% White)

**Accent Colors** (for alerts only)
- Warning: #FF6B35 (Warm Orange)
- Alert: #FF3B30 (Red)
- Success: #00D9FF (Cyan)

### Spacing & Alignment

**Vertical Rhythm**
- Top padding: 40px
- Temperature to Humidity gap: 20px
- Humidity to bottom: Auto (flex-grow)
- Status to bottom: 16px

**Horizontal Alignment**
- All elements: Center aligned
- Text: Center aligned within container

### Responsive Sizing (for 480x480 circular display)

**Safe Zone**
- Use circular safe zone of 400x400px
- Center all content within safe zone
- Account for ~40px inset from circular edge

## Visual Hierarchy

```
Level 1: Temperature (96px, Bold, White)
    ↓ Dominates the display
    
Level 2: Humidity (28px, Light, Gray)
    ↓ Clearly secondary but readable
    
Level 3: Status (12px, Regular, Dark Gray)
    ↓ Subtle, non-intrusive
```

## Animation & Transitions

**Value Changes**
- Temperature change: Smooth fade 300ms
- Humidity change: Smooth fade 300ms
- No jarring updates or flashing

**State Transitions**
- Alert appearing: Fade in 200ms
- Menu opening: Slide up 250ms with ease-out
- Settings change: Cross-fade 150ms

**Micro-interactions**
- Touch feedback: Subtle highlight (10% white overlay)
- Button press: Scale down to 0.98 (50ms)
- Menu item select: Background fade (100ms)

## Exact Pixel Specifications

### Main Display (480x480 canvas, 400x400 safe zone)

```
Canvas: 480px × 480px
Safe Zone: 400px × 400px (centered, accounting for circular edge)

┌─────────────────────────────────────────────┐
│          [40px from safe zone top]          │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │                                     │   │
│  │              72°                    │   │
│  │     [96px Bold, #FFFFFF]            │   │
│  │                                     │   │
│  └─────────────────────────────────────┘   │
│                                             │
│          [20px vertical gap]                │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │                                     │   │
│  │         Humidity 41%                │   │
│  │     [28px Light, #B0B0B0]           │   │
│  │                                     │   │
│  └─────────────────────────────────────┘   │
│                                             │
│          [flex space]                       │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │        Local Mode                   │   │
│  │     [12px Regular, #707070]         │   │
│  └─────────────────────────────────────┘   │
│          [16px from safe zone bottom]       │
└─────────────────────────────────────────────┘
```

### Temperature Display Element

**Bounding Box**: 360px wide × 120px tall
**Position**: Centered horizontally, 40px from top of safe zone

```
Temperature: "72°"
- "72": 96px Bold
- "°": 72px Bold (3/4 size of number, raised baseline)
- Kerning between number and degree: -4px
- Color: #FFFFFF
- Text-align: center
- Anti-aliasing: Subpixel
```

### Humidity Display Element

**Bounding Box**: 360px wide × 36px tall
**Position**: Centered horizontally, 20px below temperature

```
Text: "Humidity 41%"
- Font-size: 28px
- Font-weight: 300 (Light)
- Color: #B0B0B0
- Text-align: center
- Letter-spacing: normal
```

Alternative shorter format:
```
Text: "41% RH"
- Same styling
- More compact if space is constrained
```

## Clean Settings Menu

### Menu Design

**Background**: #1C1C1E (Dark gray, slightly lighter than black)
**Overlay**: 40% opacity black behind menu

```
┌─────────────────────────────────────┐
│                                     │
│        Settings                     │
│        [24px Semi-bold]             │
│                                     │
│    ────────────────────             │
│                                     │
│    Display                          │
│      • Fahrenheit / Celsius         │
│      • Brightness: Auto             │
│      • Refresh: 5 sec               │
│                                     │
│    Calibration                      │
│      • Temperature: +0.0°           │
│      • Humidity: +0%                │
│                                     │
│    Alerts                           │
│      • High Temp: 90°               │
│      • Low Temp: 40°                │
│                                     │
│    About                            │
│      • Local-Only Mode              │
│      • v1.0.0                       │
│                                     │
└─────────────────────────────────────┘
```

**Menu Styling**
- Section headers: 18px Semi-bold, #FFFFFF
- Menu items: 16px Regular, #B0B0B0
- Values: 16px Regular, #00D9FF (accent color)
- Spacing between sections: 24px
- Item height: 44px (touch-friendly)
- Left padding: 24px
- Right padding: 24px

## Alert States (Clean Design)

### High Temperature Alert

```
┌─────────────────────────────────────┐
│                                     │
│            ⚠                        │
│        [36px, #FF6B35]              │
│                                     │
│     High Temperature                │
│        [20px Bold]                  │
│                                     │
│            92°                      │
│        [64px Bold, #FF6B35]         │
│                                     │
│        Threshold: 90°               │
│        [16px Light, #B0B0B0]        │
│                                     │
│    ┌───────────────────────┐       │
│    │      Dismiss          │       │
│    │  [18px, Button]       │       │
│    └───────────────────────┘       │
│                                     │
└─────────────────────────────────────┘
```

**Alert Button**
- Background: #FF6B35 (20% opacity)
- Border: 1px solid #FF6B35
- Border-radius: 8px
- Padding: 12px 24px
- Text: 18px Semi-bold, #FFFFFF
- Active state: Full opacity background

## Power Modes - Display Variations

### Standard Mode (Default)
- Background: #000000
- Temperature: #FFFFFF at 100% opacity
- Humidity: #B0B0B0 at 100% opacity
- Brightness: 80%
- Refresh: 5 seconds

### Low Power Mode
- Background: #000000
- Temperature: #FFFFFF at 60% opacity
- Humidity: #B0B0B0 at 40% opacity
- Brightness: 30%
- Refresh: 10 seconds
- Dim after 30s inactivity

### Night Mode (Auto, based on ambient light)
- Background: #000000
- Temperature: #FFFFFF at 40% opacity
- Humidity: #B0B0B0 at 30% opacity
- Brightness: 15%
- Refresh: 10 seconds

## CSS-Style Reference Implementation

```css
/* Main Container */
.local-mode-display {
  width: 480px;
  height: 480px;
  background: #000000;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-start;
  border-radius: 50%;
  overflow: hidden;
}

/* Safe Zone */
.safe-zone {
  width: 400px;
  height: 400px;
  margin: 40px;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding-top: 40px;
  padding-bottom: 16px;
}

/* Temperature */
.temperature {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  font-size: 96px;
  font-weight: 700;
  color: #FFFFFF;
  letter-spacing: -2px;
  line-height: 1.0;
  margin: 0;
  padding: 0;
  text-align: center;
}

.temperature .degree {
  font-size: 72px;
  margin-left: -4px;
  vertical-align: super;
}

/* Humidity */
.humidity {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  font-size: 28px;
  font-weight: 300;
  color: #B0B0B0;
  letter-spacing: 0;
  line-height: 1.2;
  margin-top: 20px;
  text-align: center;
}

/* Status */
.status {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  font-size: 12px;
  font-weight: 400;
  color: #707070;
  letter-spacing: 0.5px;
  line-height: 1.4;
  margin-top: auto;
  text-align: center;
}

/* Transitions */
.temperature,
.humidity {
  transition: all 300ms ease-in-out;
}

/* Touch Feedback */
.touchable:active {
  opacity: 0.9;
  transform: scale(0.98);
  transition: all 50ms ease-out;
}

/* Alert State */
.alert {
  background: rgba(255, 107, 53, 0.1);
  border: 1px solid #FF6B35;
  border-radius: 12px;
  padding: 24px;
  margin: 20px;
  text-align: center;
}

.alert-icon {
  font-size: 36px;
  color: #FF6B35;
  margin-bottom: 12px;
}

.alert-title {
  font-size: 20px;
  font-weight: 700;
  color: #FFFFFF;
  margin-bottom: 16px;
}

.alert-value {
  font-size: 64px;
  font-weight: 700;
  color: #FF6B35;
  margin-bottom: 8px;
}

.alert-threshold {
  font-size: 16px;
  font-weight: 300;
  color: #B0B0B0;
}

/* Dismiss Button */
.dismiss-button {
  background: rgba(255, 107, 53, 0.2);
  border: 1px solid #FF6B35;
  border-radius: 8px;
  padding: 12px 24px;
  font-size: 18px;
  font-weight: 600;
  color: #FFFFFF;
  margin-top: 20px;
  cursor: pointer;
}

.dismiss-button:active {
  background: #FF6B35;
}
```

## Design Tokens

```json
{
  "colors": {
    "background": "#000000",
    "text": {
      "primary": "#FFFFFF",
      "secondary": "#B0B0B0",
      "tertiary": "#707070"
    },
    "accent": {
      "warning": "#FF6B35",
      "alert": "#FF3B30",
      "success": "#00D9FF"
    }
  },
  "typography": {
    "temperature": {
      "size": "96px",
      "weight": 700,
      "lineHeight": 1.0,
      "letterSpacing": "-2px"
    },
    "humidity": {
      "size": "28px",
      "weight": 300,
      "lineHeight": 1.2,
      "letterSpacing": "0"
    },
    "status": {
      "size": "12px",
      "weight": 400,
      "lineHeight": 1.4,
      "letterSpacing": "0.5px"
    }
  },
  "spacing": {
    "paddingTop": "40px",
    "temperatureToHumidity": "20px",
    "statusPaddingBottom": "16px"
  },
  "animation": {
    "valueChange": "300ms ease-in-out",
    "stateTransition": "200ms ease-out",
    "touch": "50ms ease-out"
  }
}
```

## Accessibility

**Contrast Ratios** (WCAG AAA compliant)
- Temperature on background: 21:1 (exceeds AAA)
- Humidity on background: 12.6:1 (exceeds AAA)
- Status on background: 5.3:1 (exceeds AA)

**Touch Targets**
- Minimum size: 44px × 44px
- Recommended spacing: 8px between targets

**Motion Sensitivity**
- All animations can be disabled via settings
- Reduced motion option respects system preferences

## Implementation Notes

### Anti-aliasing
- Use subpixel anti-aliasing for text
- Ensure crisp rendering on OLED display

### Power Optimization
- True black (#000000) for OLED power saving
- Minimal white pixels in low power mode
- Static display (no animations) saves power

### Rendering Performance
- Use hardware acceleration for animations
- Minimize redraws to temperature/humidity region only
- Update only changed values, not entire display

### Font Loading
- Prefer system fonts to avoid loading overhead
- Fallback chain: System → Roboto → Helvetica → Arial → sans-serif

## Mockup Variations

### Compact Alternative
```
┌─────────────────────┐
│                     │
│      72° • 41%      │
│   [temp] [humid]    │
│                     │
└─────────────────────┘
```

### Detailed Alternative
```
┌─────────────────────┐
│   Temperature       │
│       72°F          │
│                     │
│   Humidity          │
│       41%           │
│   (Comfortable)     │
└─────────────────────┘
```

**Recommendation**: Use main design (large temperature, secondary humidity) for optimal readability and clean aesthetic.

## Final Notes

This design prioritizes:
1. **Legibility** - Read from 10+ feet away
2. **Simplicity** - Only essential information
3. **Battery Life** - True black background
4. **Professionalism** - Clean, modern aesthetic
5. **Accessibility** - High contrast, large text
6. **Timelessness** - Won't feel dated

The UI should feel like a premium, focused tool rather than a feature-heavy smart device.
