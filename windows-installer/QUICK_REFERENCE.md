# Windows Installer Quick Reference

## For End Users

### Installation Steps
1. Download `NoLongerEvil-Thermostat-Setup.exe` from [Releases](https://github.com/codykociemba/NoLongerEvil-Thermostat/releases)
2. Run as Administrator
3. Follow wizard, select mode (Full Thermostat or Display-Only)
4. Launch GUI from Start Menu after installation

### Flashing Steps
1. Open NoLongerEvil Thermostat Flasher (from Start Menu)
2. Click "Install USB Drivers" (first time only)
3. Select firmware type and Nest generation
4. Connect Nest via USB
5. Click "Start Flashing"
6. Hold Nest display for 10-15 seconds to reboot
7. Wait for flashing to complete

### Troubleshooting
- **Device not detected**: Install USB drivers, ensure DFU mode, try different USB cable/port
- **Driver install failed**: Run Zadig as Admin, select "Texas Instruments OMAP", choose WinUSB
- **Permission errors**: Run flasher as Administrator

## For Developers

### Building Installer
```powershell
# Build omap_loader
.\build.ps1

# Build GUI
cd windows-installer
.\build-gui.ps1

# Build installer
.\build-installer.ps1
```

### Requirements
- Inno Setup 6.x
- Python 3.8+
- PyInstaller
- MSYS2 (for omap_loader)

### Output
Installer: `bin\installer\NoLongerEvil-Thermostat-Setup.exe`

### Testing
Test on Windows 10 and 11 with both Gen 1 and Gen 2 devices.

For more details, see:
- [WINDOWS_INSTALLER_GUIDE.md](WINDOWS_INSTALLER_GUIDE.md) - Complete guide
- [README.md](README.md) - Technical documentation
