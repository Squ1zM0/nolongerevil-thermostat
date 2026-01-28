# NoLongerEvil Thermostat - Windows All-in-One Installer

This directory contains the Windows installer package for the NoLongerEvil Thermostat firmware.

## Features

The Windows installer provides:

- **Graphical User Interface**: Easy-to-use GUI for flashing your Nest Thermostat
- **Auto-Detection**: Automatically detects connected Nest devices in DFU mode
- **Driver Installation**: Includes USB driver installation tool (Zadig)
- **Firmware Management**: Automatically downloads and manages firmware files
- **Mode Selection**: Choose between Full Thermostat Mode or Display-Only Mode
- **Step-by-Step Wizard**: Guides you through the entire flashing process
- **Error Handling**: Clear error messages and troubleshooting guidance

## Contents

- `setup.iss` - Inno Setup script for building the installer
- `NestFlasher.py` - Python-based GUI application for flashing
- `build-installer.ps1` - PowerShell script to build the installer
- `build-gui.ps1` - PowerShell script to compile the GUI application
- `README.md` - This file

## Requirements for Building

To build the Windows installer, you need:

1. **Inno Setup 6.x** - Download from [https://jrsoftware.org/isinfo.php](https://jrsoftware.org/isinfo.php)
2. **Python 3.8+** - For the GUI application
3. **PyInstaller** - To compile the Python GUI into an executable
4. **omap_loader.exe** - Must be built first (see main README.md)

## Building the Installer

### Step 1: Build omap_loader

First, build the omap_loader tool:

```powershell
cd ..
.\build.ps1
```

This creates `bin\windows-x64\omap_loader.exe`

### Step 2: Build the GUI Application

Install Python dependencies and compile the GUI:

```powershell
cd windows-installer
.\build-gui.ps1
```

This creates `NestFlasher.exe` and `FlashingGUI.exe`

### Step 3: Download USB Drivers

Download Zadig for USB driver installation:

1. Create a `drivers` subdirectory
2. Download `zadig-2.8.exe` from [https://zadig.akeo.ie/](https://zadig.akeo.ie/)
3. Place it in `windows-installer\drivers\`

### Step 4: Build the Installer

Run the installer build script:

```powershell
.\build-installer.ps1
```

This will:
- Verify all required files are present
- Compile the Inno Setup script
- Create the installer in `..\bin\installer\`

The output will be: `NoLongerEvil-Thermostat-Setup.exe`

## Manual Build (Alternative)

If you prefer to build manually:

1. Open Inno Setup Compiler
2. Load `setup.iss`
3. Click Build → Compile
4. The installer will be created in `..\bin\installer\`

## Testing the Installer

1. Run `NoLongerEvil-Thermostat-Setup.exe`
2. Follow the installation wizard
3. Choose your installation mode (Full or Display-Only)
4. Complete the installation
5. Launch the NoLongerEvil Nest Flasher from the Start Menu

## Installer Features

### Installation Modes

**Full Thermostat Mode**:
- Complete thermostat functionality
- Cloud connectivity
- Remote control via web/mobile
- Requires internet and account at nolongerevil.com

**Display-Only Mode**:
- Temperature and humidity display only
- No thermostat functionality
- Works completely offline
- No account required

### Included Components

1. **Core Files** (required):
   - omap_loader.exe - Firmware flashing tool
   - Firmware files - Bootloader and kernel images
   - Configuration files
   - Documentation

2. **Graphical Flashing Tool** (optional):
   - NestFlasher.exe - User-friendly GUI
   - Auto-detection of devices
   - Progress indicators
   - Error handling

3. **USB Drivers** (optional):
   - Zadig USB driver installer
   - Required for communication with Nest in DFU mode

### Post-Installation

After installation, you can:

1. **Launch the GUI Flasher**:
   - Start Menu → NoLongerEvil Thermostat → NoLongerEvil Thermostat Flasher
   - Or desktop shortcut (if created during installation)

2. **Install USB Drivers** (if not already installed):
   - Start Menu → NoLongerEvil Thermostat → USB Driver Installation
   - Follow the Zadig instructions

3. **View Documentation**:
   - Start Menu → NoLongerEvil Thermostat → Documentation
   - Or navigate to installation directory (default: C:\Program Files\NoLongerEvil Thermostat)

## Troubleshooting

### Build Issues

**"Inno Setup not found"**:
- Install Inno Setup from https://jrsoftware.org/isinfo.php
- Ensure it's added to your PATH, or update the build script with the correct path

**"omap_loader.exe not found"**:
- Build omap_loader first using the main build.ps1 script
- Ensure it exists at `..\bin\windows-x64\omap_loader.exe`

**"Python not found"**:
- Install Python 3.8 or later from https://www.python.org/
- Ensure Python is added to your PATH during installation

### Installation Issues

**"Access Denied"**:
- Run the installer as Administrator
- Right-click → Run as Administrator

**"Firmware download failed"**:
- Check your internet connection
- Verify the firmware URLs are accessible
- You can manually download firmware and place it in the installation directory

### Flashing Issues

**"Device not detected"**:
- Ensure Nest is in DFU mode (hold display for 10-15 seconds)
- Install USB drivers using Zadig
- Try a different USB cable or port

**"USB driver not installed"**:
- Run the USB Driver Installation tool from Start Menu
- In Zadig: Options → List All Devices → Select "Texas Instruments OMAP" → Install WinUSB driver

## Architecture

```
Windows Installer Package
│
├── setup.iss (Inno Setup Script)
│   ├── Downloads firmware during installation
│   ├── Installs files to Program Files
│   ├── Creates Start Menu shortcuts
│   └── Offers to launch GUI after installation
│
├── NestFlasher.py (GUI Application)
│   ├── Firmware type selection
│   ├── Generation selection
│   ├── Device detection
│   ├── Firmware download/management
│   ├── Flashing progress tracking
│   └── Error handling/logging
│
└── Bundled Components
    ├── omap_loader.exe (compiled separately)
    ├── Firmware files (downloaded during install)
    ├── Zadig (USB drivers)
    └── Documentation (README, LICENSE, etc.)
```

## Development

### Modifying the GUI

1. Edit `NestFlasher.py`
2. Test with: `python NestFlasher.py`
3. Rebuild: `.\build-gui.ps1`

### Modifying the Installer

1. Edit `setup.iss`
2. Test compile in Inno Setup Compiler
3. Rebuild: `.\build-installer.ps1`

## Distribution

The final installer `NoLongerEvil-Thermostat-Setup.exe` is a single self-contained executable that:
- Requires no additional files to run
- Can be distributed via any method (download, USB, etc.)
- Includes all dependencies except firmware (downloaded on first use)
- Supports silent installation: `Setup.exe /SILENT`

## License

See LICENSE file in the main repository directory.

## Support

For issues, questions, or contributions:
- GitHub: https://github.com/codykociemba/NoLongerEvil-Thermostat
- Discord: https://discord.gg/hackhouse
- Documentation: https://docs.nolongerevil.com
