# Windows All-in-One Installer Guide

## For End Users

### Easy Installation (Recommended)

1. **Download the Installer**
   - Download `NoLongerEvil-Thermostat-Setup.exe` from the [Releases](https://github.com/codykociemba/NoLongerEvil-Thermostat/releases) page

2. **Run the Installer**
   - Right-click the installer and select "Run as Administrator"
   - Follow the installation wizard

3. **Choose Your Mode**
   - **Full Thermostat Mode**: For complete smart thermostat functionality
   - **Display-Only Mode**: For temperature/humidity monitoring only (NOT a thermostat)

4. **Complete Installation**
   - The installer will download firmware files during installation
   - Choose components to install (GUI, USB drivers, etc.)
   - Click Install

5. **Launch the Flasher**
   - After installation, the GUI flasher will launch automatically
   - Or find it in Start Menu → NoLongerEvil Thermostat

### Using the GUI Flasher

1. **Install USB Drivers (First Time Only)**
   - Click "Install USB Drivers" button
   - Or use Start Menu → NoLongerEvil Thermostat → USB Driver Installation
   - Put your Nest in DFU mode first (hold display 10-15 seconds)
   - In Zadig: Options → List All Devices → Select "Texas Instruments OMAP"
   - Choose "WinUSB" or "libusb-win32" as driver
   - Click "Install Driver"

2. **Select Firmware Type**
   - Choose between Full Thermostat Mode or Display-Only Mode
   - Display-Only Mode will NOT control heating/cooling!

3. **Select Nest Generation**
   - Choose Generation 1 or Generation 2
   - Check your device's back plate for generation info

4. **Prepare Your Device**
   - Charge your Nest (50%+ recommended)
   - Remove it from the wall mount
   - Connect it via micro USB to your computer

5. **Start Flashing**
   - Click "Start Flashing" button
   - Follow the on-screen instructions
   - Reboot your Nest by holding the display for 10-15 seconds
   - The flasher will detect the device and start flashing automatically

6. **Wait for Completion**
   - Keep the device connected via USB
   - Wait for the flashing process to complete (usually 1-2 minutes)
   - The console will show progress

7. **Next Steps**
   - Keep device plugged in via USB for 2-3 minutes
   - Device will boot and show the NoLongerEvil logo
   - For Full Thermostat Mode: Visit https://nolongerevil.com to register and link device
   - For Display-Only Mode: Device will automatically show temperature/humidity

### Troubleshooting

**"Device not detected"**
- Ensure your Nest is in DFU mode (hold display 10-15 seconds until it reboots)
- Install USB drivers using Zadig
- Try a different USB cable or port
- Make sure you're using a data cable, not just a charging cable

**"USB driver installation failed"**
- Run Zadig as Administrator
- Ensure Nest is in DFU mode before running Zadig
- Select the correct device (Texas Instruments OMAP)
- Try WinUSB first, if that doesn't work try libusb-win32

**"Firmware download failed"**
- Check your internet connection
- Temporarily disable firewall/antivirus
- You can manually download firmware from the releases page

**"Access denied" or permission errors**
- Run the flasher as Administrator (right-click → Run as Administrator)
- Ensure USB drivers are properly installed

**Flashing seems stuck**
- Wait at least 2-3 minutes before cancelling
- Make sure device is in DFU mode (screen should be blank or showing boot sequence)
- Try unplugging and replugging the device, then restart the flasher

---

## For Developers

### Building the Installer

See [windows-installer/README.md](windows-installer/README.md) for detailed build instructions.

Quick start:

```powershell
# 1. Build omap_loader
.\build.ps1

# 2. Build the GUI application
cd windows-installer
.\build-gui.ps1

# 3. Download Zadig (optional)
# Download zadig-2.8.exe from https://zadig.akeo.ie/
# Place it in windows-installer\drivers\

# 4. Build the installer
.\build-installer.ps1
```

The installer will be created at `bin\installer\NoLongerEvil-Thermostat-Setup.exe`

### Requirements for Building

- **Windows 10/11**
- **Inno Setup 6.x**: https://jrsoftware.org/isinfo.php
- **Python 3.8+**: https://www.python.org/
- **PyInstaller**: `pip install pyinstaller`
- **MSYS2** (for building omap_loader): https://www.msys2.org/

### Architecture

The Windows installer consists of:

1. **Inno Setup Script** (`setup.iss`)
   - Creates the installation wizard
   - Downloads firmware during installation
   - Installs all components
   - Creates shortcuts

2. **GUI Application** (`NestFlasher.py`)
   - Python/Tkinter-based GUI
   - Compiled to executable with PyInstaller
   - Handles device detection, firmware selection, and flashing

3. **omap_loader** (compiled from C)
   - Core flashing tool
   - Communicates with Nest in DFU mode
   - Loads bootloader and kernel to device

4. **Bundled Components**
   - Zadig USB driver installer
   - PowerShell scripts for advanced users
   - Documentation

### Testing

Test the installer on:
- Windows 10 (21H2 or later)
- Windows 11
- Both fresh installs and upgrades

Test scenarios:
- Full Thermostat Mode installation
- Display-Only Mode installation
- USB driver installation
- Flashing with Gen 1 device
- Flashing with Gen 2 device
- Error handling (no device, wrong drivers, etc.)

### Distribution

The compiled installer is a single self-contained .exe file that can be distributed via:
- GitHub Releases
- Direct download
- USB drive
- Any file sharing method

The installer supports silent installation for automated deployment:
```powershell
NoLongerEvil-Thermostat-Setup.exe /SILENT /DIR="C:\CustomPath"
```

### Customization

To customize the installer:

1. **Change branding**: Edit `setup.iss` - update AppName, AppPublisher, URLs
2. **Modify GUI**: Edit `NestFlasher.py` - change layout, colors, text
3. **Add features**: Extend the Python code with additional functionality
4. **Update firmware URLs**: Edit both `setup.iss` and `NestFlasher.py` to point to new firmware releases

### Known Limitations

- Requires internet connection for initial firmware download
- Requires Administrator privileges for driver installation
- USB driver installation requires manual user interaction (Zadig limitation)
- Only supports Windows 10/11 (x64)

### Future Improvements

Potential enhancements:
- Auto-detection of Nest generation
- Automatic USB driver installation (without Zadig)
- Firmware verification/checksums
- Multi-device flashing
- Backup/restore functionality
- Firmware rollback option
- Auto-update mechanism
