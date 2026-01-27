# Display-Only Mode (Temperature Monitor)

## ⚠️ IMPORTANT: This is NOT a Working Thermostat

Display-Only Mode turns your Nest into a **temperature and humidity monitor ONLY**. It will **NOT control your heating or cooling system**. All thermostat functions are completely disabled.

## Overview

This mode repurposes your Nest hardware as a standalone environmental monitor that operates entirely without cloud connectivity, smart features, or HVAC control.

## What You Get

When enabled, your device will:

- ✅ **Display temperature and humidity** - Shows current readings on screen
- ✅ **Operate entirely locally** - No cloud or API dependency
- ✅ **Work offline** - Functions without Wi-Fi or internet
- ✅ **Low power consumption** - Minimal features mean longer battery life
- ✅ **Privacy focused** - No data sent anywhere

## What You DON'T Get (Disabled Features)

⚠️ **This is NOT a thermostat anymore.** The following are completely disabled:

- ❌ **Heating and cooling control** - Cannot turn HVAC on/off
- ❌ **Thermostat functions** - Not a working thermostat at all
- ❌ **Cloud connectivity and remote control**
- ❌ **Scheduling and learning algorithms**
- ❌ **Occupancy detection**
- ❌ **Mobile app integration**
- ❌ **Automatic updates**

**Think of it as:** A digital temperature/humidity sensor mounted on your wall, not a thermostat.

## Installation

### Prerequisites

1. Complete the basic setup from [README.md](README.md) (clone repo, install dependencies, build omap_loader)
2. Ensure your Nest device is charged and ready for flashing

### Enabling Display-Only Mode

To set up your device as a temperature/humidity monitor (NOT a thermostat):

```bash
./install.sh --local-only
```

This will:
1. Download the **display-only firmware variant** (optimized for monitoring)
2. Build stripped-down firmware files if needed
3. Flash the device with HVAC control disabled
4. Configure for standalone temperature monitoring
5. Set the display to show temperature and humidity only

⚠️ **Remember:** After this installation, your device will NOT control heating or cooling.

### Simple Firmware Variant

Display-Only mode uses a **simplified firmware variant** that includes only:
- ✅ Temperature and humidity sensing
- ✅ Display functionality  
- ✅ Basic settings UI
- ✅ Temperature alerts

The simple firmware **excludes** all unnecessary features:
- ❌ **HVAC control** (heating/cooling disabled)
- ❌ **Thermostat functions** 
- ❌ Cloud connectivity stack
- ❌ Wi-Fi networking drivers
- ❌ Smart scheduling engine
- ❌ Learning algorithms
- ❌ Remote control protocols
- ❌ OTA update mechanisms

This results in:
- Smaller firmware size
- Lower memory usage
- Reduced power consumption
- Fewer potential failure points
- Faster boot times

### Verification

To verify you're using the simple firmware variant:

```bash
./verify-simple-firmware.sh
```

### Manual Configuration

If you prefer to configure manually:

1. After standard firmware installation, access device settings
2. Navigate to: **Settings → Advanced → Local Mode**
3. Enable "Local-Only Operation"
4. The device will restart and enter local-only mode

## Display Layout

In local-only mode, the display shows:

```
┌─────────────────┐
│                 │
│      72°        │
│                 │
│  Humidity: 41%  │
│                 │
└─────────────────┘
```

- **Large temperature display** - Current temperature in Fahrenheit
- **Humidity indicator** - Current relative humidity percentage
- **Auto-refresh** - Updates every 5 seconds

## Configuration Options

### Temperature Unit

To change between Fahrenheit and Celsius:

1. Press and hold the display for 3 seconds
2. Navigate to: **Settings → Display → Temperature Unit**
3. Select **°F** or **°C**

### Display Brightness

Adjust brightness to save power or improve visibility:

1. Navigate to: **Settings → Display → Brightness**
2. Choose from: **Low**, **Medium**, **High**, or **Auto**

### Refresh Rate

Change how often the display updates (default: 5 seconds):

1. Navigate to: **Settings → Display → Refresh Rate**
2. Select from: **1s**, **5s**, **10s**, or **30s**

## Use Cases

Local-only mode is ideal for:

- **Simple room monitoring** - Just want to know temperature and humidity
- **Offline installations** - Areas without reliable Wi-Fi
- **Privacy-focused users** - No cloud data collection
- **Legacy device repurposing** - Extend life of unsupported Nest hardware
- **Backup displays** - Secondary environmental monitors

## Troubleshooting

### Display not updating

1. Check that sensors are functioning: **Settings → Diagnostics → Sensor Test**
2. Verify refresh rate is not set too high (30s+)
3. Restart device: Hold display for 10 seconds

### Incorrect temperature readings

1. Ensure device is not exposed to direct sunlight
2. Keep away from heat sources or cold drafts
3. Allow 15 minutes after power-on for sensor calibration

### Cannot enter local-only mode

1. Verify firmware version supports local mode (v1.1.0+)
2. Try reflashing with `./install.sh --local-only` flag
3. Check device logs: **Settings → Diagnostics → View Logs**

## Technical Details

### Sensor Specifications

- **Temperature Range**: -20°F to 120°F (-29°C to 49°C)
- **Temperature Accuracy**: ±1°F (±0.5°C)
- **Humidity Range**: 0% to 100% RH
- **Humidity Accuracy**: ±5% RH
- **Update Interval**: 1-30 seconds (configurable)

### Power Consumption

Local-only mode is optimized for low power:

- **Active Display**: ~50mW
- **Standby**: ~10mW
- **Battery Life** (when not wall-powered): 30+ days

### Network Behavior

In local-only mode:
- All network interfaces are disabled by default
- Wi-Fi radio is turned off to save power
- No outbound connections are attempted
- Device operates entirely from onboard sensors and memory

## Reverting to Standard Mode

To switch back to standard cloud-connected operation:

1. Navigate to: **Settings → Advanced → Local Mode**
2. Disable "Local-Only Operation"
3. Follow the standard setup wizard to reconnect to cloud services
4. Link your device at [https://nolongerevil.com](https://nolongerevil.com)

Alternatively, reflash the device using the standard installation:

```bash
./install.sh
```

## Support

For issues or questions:
- Check the [FAQ and Troubleshooting Guide](docs/FAQ.md) for common issues
- Review the [main README](README.md) for general troubleshooting
- Visit [Discord](https://discord.gg/hackhouse) for community support
- Check [documentation](https://docs.nolongerevil.com) for detailed guides
- See [UI Mockups](docs/UI_MOCKUP.md) for design specifications

## Contributing

Contributions to improve local-only mode are welcome:
- UI/UX improvements for the minimal display
- Additional sensor data displays
- Power optimization
- Documentation improvements

See the main [README](README.md) for contribution guidelines.
