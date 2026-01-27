# Local-Only / Dumb Mode

## Overview

Local-Only Mode turns your Nest Thermostat into a simple, standalone environmental display that operates entirely without cloud connectivity or smart features.

## Features

When enabled, your thermostat will:

- ✅ **Operate entirely locally** - No cloud or API dependency
- ✅ **Display environmental data** - Temperature (°F) and Humidity (%)
- ✅ **Work offline** - Functions without Wi-Fi or internet
- ✅ **Low complexity** - Minimal failure points
- ✅ **Always-on display** - Continuous monitoring

### Disabled Features

To ensure stability and local operation, the following features are disabled:

- ❌ Cloud connectivity and remote control
- ❌ Scheduling and learning algorithms
- ❌ Occupancy detection
- ❌ Mobile app integration
- ❌ Automatic updates

## Installation

### Prerequisites

1. Follow the standard installation guide in [README.md](README.md) to flash the base firmware
2. Ensure your Nest device is successfully flashed and booting

### Enabling Local-Only Mode

After flashing your device with the standard firmware, you can enable local-only mode:

```bash
./install.sh --local-only
```

This will:
1. Download the local-only firmware variant
2. Configure the device for standalone operation
3. Set the display to show temperature and humidity only

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
- Check the [main README](README.md) for general troubleshooting
- Visit [Discord](https://discord.gg/hackhouse) for community support
- Review [documentation](https://docs.nolongerevil.com) for detailed guides

## Contributing

Contributions to improve local-only mode are welcome:
- UI/UX improvements for the minimal display
- Additional sensor data displays
- Power optimization
- Documentation improvements

See the main [README](README.md) for contribution guidelines.
