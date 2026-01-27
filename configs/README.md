# Configuration Files

This directory contains configuration files for different operating modes of the Nest Thermostat firmware.

## Available Configurations

### local-only-mode.conf

Configuration for running the thermostat in standalone local-only mode:
- No cloud connectivity
- Displays temperature and humidity only
- Minimal features for maximum stability
- Ideal for offline environmental monitoring

See [../LOCAL_MODE.md](../LOCAL_MODE.md) for complete documentation.

## Usage

These configuration files are designed to be bundled with firmware builds or applied during the installation process.

### During Installation

To install with local-only mode configuration:

```bash
./install.sh --local-only
```

### Post-Installation

Configuration files can be transferred to the device after installation using the device's settings menu or by accessing the device filesystem directly (advanced users only).

## Creating Custom Configurations

You can create custom configuration files based on the templates provided:

1. Copy an existing configuration file
2. Modify settings as needed
3. Ensure all required fields are present
4. Test with your device

## Configuration Format

Configuration files use INI format with the following sections:

- `[mode]` - Operating mode and connectivity settings
- `[display]` - Display preferences and layout
- `[sensors]` - Sensor enable/disable and calibration
- `[features]` - Feature toggles
- `[network]` - Network and API settings
- `[power]` - Power management options
- `[ui]` - User interface customization
- `[logging]` - Logging and diagnostics
- `[safety]` - Safety alerts and thresholds

## Future Configurations

Additional configuration presets may be added:

- `standard-mode.conf` - Full-featured cloud-connected operation
- `hybrid-mode.conf` - Local operation with optional cloud sync
- `minimal-power.conf` - Ultra low-power monitoring mode
- `developer-mode.conf` - Debug and development settings

## Contributing

Contributions for new configuration presets are welcome. Please ensure:

- All required fields are documented
- Configuration is tested on actual hardware
- README is updated with new configuration details
