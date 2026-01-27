# UI Mockups and Design Specifications

## Local-Only Mode Display

### Main Display (Default View)

```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│              ╔══════════╗               │
│              ║          ║               │
│              ║   72°    ║               │
│              ║          ║               │
│              ╚══════════╝               │
│                                         │
│            Humidity: 41%                │
│                                         │
└─────────────────────────────────────────┘
```

**Example Layout:**
```
      72°
Humidity: 41%
```

### Display Variations

#### Minimal Layout (Default)
- Large temperature display (72pt font)
- Smaller humidity percentage below (24pt font)
- Maximum readability from distance
- Low power consumption

#### Compact Layout
- Temperature and humidity side-by-side
- More condensed display
- Useful for detailed monitoring

#### Detailed Layout  
- Temperature with "feels like" calculation
- Humidity with comfort indicator
- Additional contextual information

### Font Specifications

- **Temperature:** 72pt Bold
- **Temperature Unit (°F/°C):** 36pt Regular
- **Humidity:** 24pt Regular
- **Labels:** 16pt Regular
- **Settings Menu:** 14pt Regular

### Color Scheme

**Default (Power Saving):**
- Background: Black (#000000)
- Temperature: White (#FFFFFF)
- Humidity: Light Gray (#A0A0A0)
- Alerts: Orange-Red (#FF6B35)
- Indicators: Cyan (#00D9FF)

**Temperature-based Color Coding (Optional):**
- Blue tint: < 60°F (Cold)
- White: 60-75°F (Comfortable)
- Orange tint: > 75°F (Warm)
- Red tint: > 85°F (Hot)

### Settings Menu

**Access:** Press and hold display for 3 seconds

**Menu Structure:**
```
⚙ SETTINGS MENU
├── Display Settings
│   ├── Temperature Unit (°F / °C)
│   ├── Brightness (Low/Med/High/Auto)
│   ├── Refresh Rate (1s/5s/10s/30s)
│   └── Layout (Simple/Compact/Detailed)
├── Sensor Calibration
│   ├── Temperature Offset (-5.0 to +5.0°F)
│   └── Humidity Offset (-10 to +10%)
├── Safety Alerts
│   ├── High Temp Alert (default: 90°F)
│   └── Low Temp Alert (default: 40°F)
├── Power Settings
│   ├── Power Save Mode
│   └── Display Timeout
├── Diagnostics
│   ├── Sensor Test
│   ├── View Logs
│   └── System Info
└── About
    ├── Firmware Version
    └── Operating Mode: Local-Only
```

### Startup Sequence

1. **Boot Logo** (5 seconds)
   - NoLongerEvil logo
   - Loading indicator

2. **Mode Indicator** (2 seconds)
   - "LOCAL-ONLY MODE"
   - "No cloud • Offline"

3. **Sensor Calibration** (3-5 seconds)
   - "Calibrating sensors..."
   - Progress indicators

4. **Main Display**
   - Shows temperature and humidity

### Alert States

**High Temperature Alert:**
```
┌─────────────────────────────────────────┐
│  ⚠ HIGH TEMPERATURE ALERT ⚠            │
│              92°F                       │
│          Humidity: 38%                  │
│  Alert threshold: 90°F                  │
│  [Dismiss]                              │
└─────────────────────────────────────────┘
```

**Low Temperature Alert:**
```
┌─────────────────────────────────────────┐
│  ⚠ LOW TEMPERATURE ALERT ⚠             │
│              38°F                       │
│          Humidity: 75%                  │
│  Alert threshold: 40°F                  │
│  [Dismiss]                              │
└─────────────────────────────────────────┘
```

### Power Saving Modes

**Low Power Mode:**
- Reduced brightness (30%)
- Refresh rate: 10 seconds
- Display dims after 30s inactivity
- Wi-Fi disabled

**Medium Power Mode (Default):**
- Auto brightness based on ambient light
- Refresh rate: 5 seconds
- Always-on display
- Wi-Fi disabled

**High Performance Mode:**
- Maximum brightness (100%)
- Refresh rate: 1 second
- Always-on with smooth animations
- Wi-Fi disabled

### Display Specifications

**Nest Thermostat Display:**
- Size: 3.2 inch diameter
- Resolution: 480 x 480 pixels (circular)
- Aspect Ratio: 1:1
- Usable Area: ~400 x 400 pixels (safe zone)
- Touch-enabled: Capacitive touchscreen

### Visual Indicators

**Humidity Comfort Levels (Optional):**
- 💧 Low: < 30% (Too Dry)
- 💧💧 Good: 30-60% (Comfortable)
- 💧💧💧 High: > 60% (Too Humid)

**Status Icons:**
- ● Local Mode Active (bottom corner)
- 🔋 Battery Status (if on battery power)
- ⚠ Alert Active
- ⚙ Settings Mode

## Implementation Notes

### Minimal Changes Philosophy

The UI design follows the "minimal changes" principle:
- Reuses existing display rendering engine
- Uses standard fonts available on the device
- Leverages existing touch input handlers
- Minimal new code for maximum stability

### Accessibility

- High contrast display (white on black)
- Large, readable fonts
- Simple, uncluttered interface
- Clear visual hierarchy
- Touch-friendly targets (minimum 44x44 pixels)

### Localization Support

While initially supporting Fahrenheit:
- Temperature unit is configurable (°F/°C)
- Simple conversion formula: C = (F - 32) × 5/9
- Configuration file supports both units
- Easy to extend for other units

### Future Enhancements (Optional)

Ideas for community contributions:
- Graph view showing temperature trends
- Min/max temperature tracking
- Dew point calculation and display
- Air quality monitoring (if sensor available)
- Custom color themes
- Screen saver modes
