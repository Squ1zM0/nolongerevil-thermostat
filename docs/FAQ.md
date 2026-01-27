# Local-Only Mode FAQ & Troubleshooting

## Frequently Asked Questions

### General Questions

**Q: What is Local-Only Mode?**
A: Local-Only Mode converts your Nest thermostat into a simple environmental display showing temperature and humidity without any cloud connectivity, smart features, or internet dependency.

**Q: Do I need an internet connection?**
A: No! Local-Only Mode works completely offline. Wi-Fi is disabled by default to save power.

**Q: Do I need to create an account at nolongerevil.com?**
A: No. Unlike standard mode, local-only mode does not require account registration or device linking.

**Q: Can I switch back to standard mode later?**
A: Yes. You can reflash the device using the standard `./install.sh` command (without `--local-only` flag), or use the device settings menu to disable local-only mode.

**Q: Will this work with Generation 3+ Nest thermostats?**
A: Currently, the project only supports Nest Generation 1 and 2 hardware. Gen 3+ uses different architecture.

**Q: Can I still control my HVAC system?**
A: No. Local-only mode disables all thermostat control features. It becomes a display-only environmental sensor. This is intended for repurposing unsupported devices.

### Installation Questions

**Q: How do I install local-only mode?**
A: Follow the standard installation steps, but use `./install.sh --local-only` instead of `./install.sh`.

**Q: Can I install local-only mode if I've already installed standard mode?**
A: Yes. Just run `./install.sh --local-only` again. The device will be reflashed with local-only configuration.

**Q: Does the installation process differ from standard mode?**
A: The flashing process is identical. The difference is in the configuration applied during setup.

**Q: How long does installation take?**
A: Same as standard installation: 5-10 minutes for flashing, plus 2-3 minutes for the device to boot.

### Display & UI Questions

**Q: Can I change from Fahrenheit to Celsius?**
A: Yes. Press and hold the display for 3 seconds, then navigate to Settings → Display Settings → Temperature Unit.

**Q: How often does the display update?**
A: Default is every 5 seconds. You can change this in Settings → Display Settings → Refresh Rate (1s, 5s, 10s, or 30s).

**Q: Can I adjust the brightness?**
A: Yes. Settings → Display Settings → Brightness. Options: Low, Medium, High, or Auto (uses ambient light sensor).

**Q: The display is too bright at night. What can I do?**
A: Set brightness to "Auto" and the device will adjust based on ambient light, or manually set it to "Low".

**Q: Can I change the layout?**
A: Yes. Settings → Display Settings → Layout. Choose from Simple, Compact, or Detailed layouts.

### Sensor Questions

**Q: How accurate are the sensors?**
A: The onboard sensors have the following specifications (typical accuracy at room temperature, 20-25°C):
- Temperature accuracy: ±1°F (±0.5°C) typical
- Humidity accuracy: ±5% RH typical
Accuracy may vary outside normal indoor temperature ranges or in extreme humidity conditions.

**Q: The temperature seems off. How do I calibrate?**
A: Settings → Sensor Calibration → Temperature Offset. Adjust by -5°F to +5°F based on a reference thermometer.

**Q: Why is my humidity reading different from another device?**
A: Sensor placement matters. Ensure your Nest is not in direct sunlight, near vents, or exposed to drafts. You can also calibrate in Settings → Sensor Calibration → Humidity Offset.

**Q: How long does it take for sensors to stabilize after power-on?**
A: Allow 15 minutes for sensors to calibrate and provide accurate readings.

### Power & Battery Questions

**Q: How is local-only mode powered?**
A: The device can be powered via micro USB or, if installed on a wall plate with HVAC wiring, through the C-wire (common wire).

**Q: Does local-only mode use less power than standard mode?**
A: Yes! Wi-Fi is disabled, cloud polling is eliminated, and the display can be optimized for low power. Battery life is extended significantly.

**Q: How long will the battery last?**
A: On battery power alone (no wall power), expect 30+ days in low power mode, or 10-15 days in standard display mode.

**Q: Can I leave it plugged into USB permanently?**
A: Yes. The device can run indefinitely from USB power.

### Features & Limitations

**Q: Can I view historical temperature data?**
A: Not in the current version. Local-only mode is designed to be minimal. Future updates may add logging or graphing features.

**Q: Does it track temperature trends?**
A: No. The current version shows real-time data only. This may be added in future updates.

**Q: Can I set up temperature alerts?**
A: Yes! Settings → Safety Alerts. You can configure high and low temperature thresholds (e.g., alert if temperature goes above 90°F or below 40°F).

**Q: Will it alert me if temperature is dangerous?**
A: Yes, if you enable safety alerts. The device will beep and show an alert message when thresholds are exceeded.

**Q: Can multiple devices display on my phone?**
A: No. Local-only mode has no network connectivity, so remote viewing is not possible. Each device operates independently.

## Troubleshooting

### Display Issues

**Problem: Display is blank or not turning on**
- Check power connection (USB cable or wall plate)
- Press the display to wake it from sleep
- Try rebooting: Hold display for 10 seconds
- Verify installation completed successfully

**Problem: Display shows "Calibrating..." indefinitely**
- Allow up to 5 minutes for initial calibration
- Ensure device is not in direct sunlight or extreme temperature
- Try rebooting the device
- If persists, reflash with `./install.sh --local-only --force-download`

**Problem: Display is dim or hard to read**
- Adjust brightness: Settings → Display Settings → Brightness
- Try "Auto" mode for automatic adjustment
- Check if power save mode is enabled
- Clean the display surface

**Problem: Touch screen not responding**
- Clean the display surface
- Reboot device (hold for 10 seconds)
- Check for firmware issues in Settings → Diagnostics

### Sensor Issues

**Problem: Temperature reading seems inaccurate**
- Wait 15 minutes after power-on for calibration
- Move device away from heat sources (sunlight, vents, electronics)
- Compare with a reference thermometer
- Calibrate: Settings → Sensor Calibration → Temperature Offset
- Typical offset: -3°F to +3°F

**Problem: Humidity reading is stuck or not changing**
- Allow 15-20 minutes for humidity sensor to stabilize
- Humidity changes slowly - wait for actual changes in environment
- Verify sensor is working: Settings → Diagnostics → Sensor Test
- If stuck at 0% or 100%, may indicate sensor failure

**Problem: Readings fluctuate wildly**
- Ensure stable power supply
- Check for drafts or air movement
- Increase refresh rate: Settings → Display → Refresh Rate → 10s or 30s
- Verify device is securely mounted

**Problem: "Sensor Error" message appears**
- Reboot the device
- Run sensor test: Settings → Diagnostics → Sensor Test
- Check firmware version: Settings → About
- May require reflashing if persists

### Installation Issues

**Problem: Installation failed / "omap_loader binary not found"**
- Run `./build.sh` first to compile the loader
- Check that you have the required dependencies installed
- See main README.md for platform-specific prerequisites

**Problem: Device not entering DFU mode**
- Ensure device is at least 50% charged
- Hold display for full 10-15 seconds
- Try using a different USB cable
- Disconnect and reconnect, then try again

**Problem: "Firmware files not found" error**
- Run `./install.sh --force-download` to re-download firmware
- Check internet connection during download
- Verify firmware files in `bin/firmware/` directory

**Problem: Device boots but shows standard mode, not local-only**
- Configuration may not have been applied
- Try reflashing: `./install.sh --local-only --force-download`
- Verify local-only-mode.conf exists in configs/ directory
- Check Settings → About → Operating Mode

### Configuration Issues

**Problem: Settings menu not accessible**
- Press and hold for full 3 seconds
- Ensure you're pressing the center of the display
- Try different pressure/location
- Reboot device if issue persists

**Problem: Changes to settings not saved**
- Settings should save automatically
- Wait a few seconds after making changes
- Don't power off immediately after changes
- Check Settings → Diagnostics → View Logs for errors

**Problem: Temperature unit won't change from °F to °C**
- Change in Settings → Display Settings → Temperature Unit
- Select the desired unit and press confirm/OK
- Changes should apply immediately
- If not, try rebooting device

### Power Issues

**Problem: Device keeps rebooting**
- Check power supply (USB cable and adapter)
- Try different USB power source
- Battery may be depleted - charge for 30+ minutes
- May indicate firmware corruption - reflash device

**Problem: Battery drains quickly**
- Enable power save mode: Settings → Power Settings
- Reduce display brightness
- Increase refresh rate (less frequent = less power)
- Ensure Wi-Fi is disabled (should be default in local-only mode)

**Problem: Device won't charge**
- Try different USB cable
- Try different USB power adapter (2A recommended)
- Check USB port on device for debris
- Battery may be at end of life (device is 10+ years old)

### Error Messages

**Error: "Cloud Connection Failed"**
- This is expected in local-only mode
- If message persists on screen, reflash with `--local-only` flag
- Ensure you're running local-only firmware variant

**Error: "Wi-Fi Error"**
- Wi-Fi is disabled in local-only mode - this is normal
- Message should not appear - if it does, reflash device

**Error: "Configuration Error"**
- Configuration file may be corrupted
- Reflash: `./install.sh --local-only --force-download`
- Check config file at configs/local-only-mode.conf

**Error: "Memory Error" or "System Error"**
- Reboot device
- If persists, reflash firmware
- May indicate hardware failure if frequent

## Advanced Troubleshooting

### Accessing Logs

To view system logs:
1. Settings → Diagnostics → View Logs
2. Logs show sensor readings, errors, and system events
3. Logs are stored locally on device (up to 1MB)

### Sensor Test

To verify sensors are working:
1. Settings → Diagnostics → Sensor Test
2. Device will show real-time sensor readings
3. Temperature should change if you warm/cool the device
4. Humidity should change if you breathe on the sensor

### Factory Reset

To reset to defaults (keeps local-only mode):
1. Settings → Advanced → Factory Reset
2. This clears user settings but keeps firmware
3. Display settings, calibration, and alerts will reset
4. Does NOT reflash the device

### Complete Reflash

If device is unresponsive or corrupted:
1. Connect device via USB
2. Run `./install.sh --local-only --force-download`
3. Follow on-screen instructions to enter DFU mode
4. Wait for complete installation

## Getting Help

### Community Support

- **Discord:** [discord.gg/hackhouse](https://discord.gg/hackhouse)
- **Documentation:** [docs.nolongerevil.com](https://docs.nolongerevil.com)
- **GitHub Issues:** Report bugs or request features

### What to Include When Asking for Help

1. Nest generation (1 or 2)
2. Operating system (Linux/Mac/Windows)
3. Installation method used
4. Exact error message or issue description
5. Steps you've already tried
6. Firmware version (Settings → About)

### Known Limitations

- No historical data or trends
- No remote access or mobile app
- No automatic firmware updates
- No cloud backup of settings
- Temperature control features disabled
- Gen 3+ devices not supported

## Best Practices

### Optimal Placement

- Mount at typical thermostat height (4-5 feet from floor)
- Avoid direct sunlight
- Keep away from heat sources (vents, appliances, windows)
- Avoid drafty areas
- Mount on interior wall if possible
- Keep away from doors and windows

### Maintenance

- Clean display monthly with soft, dry cloth
- Check power connections periodically
- Verify battery health if using battery power
- Update firmware when available (community releases)

### Maximizing Battery Life

- Use power save mode
- Reduce refresh rate to 10-30 seconds
- Lower display brightness
- Enable display timeout
- Consider USB power for permanent installations

## Frequently Requested Features

These may be added in future community releases:

- Temperature history graphs
- Min/max temperature tracking
- Configurable display themes
- Additional sensor data (dew point, heat index)
- Data export/logging to file
- Local API for home automation integration
- Multiple display pages (swipe to switch)
- Custom alert sounds
- Screen saver modes

To contribute or vote on features, visit the GitHub repository!
