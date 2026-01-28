# Windows Installer Testing Guide

This document provides comprehensive testing procedures for the Windows all-in-one installer.

## Test Environment Setup

### Required Hardware
- Windows 10 (21H2 or later) or Windows 11 PC
- Nest Thermostat Gen 1 or Gen 2
- Micro USB cable (data cable, not charge-only)

### Test Machines
Test on multiple configurations:
1. **Clean Windows 10** - Fresh install, no dev tools
2. **Clean Windows 11** - Fresh install, no dev tools  
3. **Developer Windows 10** - With Visual Studio, Python, etc.
4. **Developer Windows 11** - With Visual Studio, Python, etc.

### User Accounts
Test with different privilege levels:
- Administrator account
- Standard user account
- User with UAC enabled
- User with UAC disabled

## Pre-Installation Testing

### Installer File Verification

```powershell
# Check installer exists
Test-Path "NoLongerEvil-Thermostat-Setup.exe"

# Check file size (should be several MB)
(Get-Item "NoLongerEvil-Thermostat-Setup.exe").Length / 1MB

# Check digital signature (if signed)
Get-AuthenticodeSignature "NoLongerEvil-Thermostat-Setup.exe"
```

### Installer Launch Test

1. **Double-click installer** - Should show UAC prompt
2. **Run as administrator** - Should launch normally
3. **Silent install test**: `NoLongerEvil-Thermostat-Setup.exe /SILENT`
4. **Cancel during install** - Should rollback cleanly

## Installation Testing

### Test Case 1: Full Thermostat Mode Installation

**Steps:**
1. Run installer as Administrator
2. Accept license
3. Choose "Full Thermostat Mode" installation type
4. Select default installation directory
5. Enable all components:
   - Core Files ✓
   - Graphical Flashing Tool ✓
   - USB Drivers ✓
6. Enable "Create desktop icon"
7. Complete installation
8. Choose to launch application

**Expected Results:**
- Installation completes without errors
- Files installed to `C:\Program Files\NoLongerEvil Thermostat\`
- Start Menu shortcuts created
- Desktop icon created (if selected)
- Application launches successfully
- Firmware files downloaded during installation

**Verification:**
```powershell
# Check installation directory
Test-Path "C:\Program Files\NoLongerEvil Thermostat\"
Test-Path "C:\Program Files\NoLongerEvil Thermostat\NestFlasher.exe"
Test-Path "C:\Program Files\NoLongerEvil Thermostat\bin\windows-x64\omap_loader.exe"

# Check Start Menu
Test-Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\NoLongerEvil Thermostat\"

# Check desktop icon (if created)
Test-Path "$env:USERPROFILE\Desktop\NoLongerEvil Thermostat.lnk"
```

### Test Case 2: Display-Only Mode Installation

**Steps:**
1. Run installer as Administrator
2. Accept license
3. Choose "Display-Only Mode" installation type
4. Select custom installation directory: `C:\Test\NLE`
5. Select components (should auto-select local-only firmware)
6. Do NOT create desktop icon
7. Complete installation
8. Do NOT launch application

**Expected Results:**
- Installation completes without errors
- Files installed to custom directory
- Local-only firmware downloaded
- No desktop icon created
- Application does not launch automatically

**Verification:**
```powershell
# Check custom directory
Test-Path "C:\Test\NLE\"
Test-Path "C:\Test\NLE\firmware\*local*"

# Verify no desktop icon
-not (Test-Path "$env:USERPROFILE\Desktop\NoLongerEvil Thermostat.lnk")
```

### Test Case 3: Custom Component Selection

**Steps:**
1. Run installer
2. Choose "Custom installation"
3. Select only:
   - Core Files ✓
   - USB Drivers ✓
   - (Deselect GUI)
4. Complete installation

**Expected Results:**
- Only selected components installed
- GUI executable NOT present
- USB drivers included
- Can still use PowerShell scripts

**Verification:**
```powershell
# GUI should NOT exist
-not (Test-Path "C:\Program Files\NoLongerEvil Thermostat\NestFlasher.exe")

# Drivers should exist
Test-Path "C:\Program Files\NoLongerEvil Thermostat\drivers\zadig-2.8.exe"

# Scripts should exist
Test-Path "C:\Program Files\NoLongerEvil Thermostat\scripts\install.ps1"
```

## GUI Application Testing

### Test Case 4: GUI Launch and Interface

**Steps:**
1. Launch NestFlasher from Start Menu
2. Verify all UI elements are present and readable
3. Check window sizing and layout
4. Try resizing window (should be fixed size)
5. Check all buttons are enabled/disabled appropriately

**Expected Results:**
- GUI launches without errors
- All labels, buttons, and controls visible
- Professional appearance
- Tooltips work (if implemented)
- Console output area visible

### Test Case 5: Firmware Type Selection

**Steps:**
1. Launch GUI
2. Select "Full Thermostat Mode" radio button
3. Observe any UI changes
4. Select "Display-Only Mode" radio button
5. Verify warning message appears

**Expected Results:**
- Radio buttons work correctly
- Only one option selectable at a time
- Warning displayed for Display-Only mode
- Selection saved for flashing process

### Test Case 6: Generation Selection

**Steps:**
1. Select Generation 1
2. Select Generation 2
3. Verify help text is visible

**Expected Results:**
- Radio buttons work correctly
- Help text about bubble level visible
- Selection saved for flashing process

### Test Case 7: USB Driver Installation

**Steps:**
1. Click "Install USB Drivers" button
2. Verify Zadig launches (if included)
3. Close Zadig
4. Check for appropriate messages in GUI

**Expected Results:**
- If Zadig included: Launches successfully with instructions
- If Zadig not included: Shows message with download link and instructions
- Instructions are clear and accurate

## Flashing Testing

### Test Case 8: Firmware Download

**Steps:**
1. Launch GUI
2. Select firmware type and generation
3. Click "Start Flashing" (without device connected)
4. Observe firmware download process

**Expected Results:**
- Firmware download starts automatically
- Progress indicator shows activity
- Download completes successfully
- Firmware extracted to correct directory
- If firmware exists and recent: Skips download

**Verification:**
```powershell
# Check firmware files exist
Test-Path "C:\Program Files\NoLongerEvil Thermostat\firmware\*.bin"
Test-Path "C:\Program Files\NoLongerEvil Thermostat\firmware\uImage"
```

### Test Case 9: Device Detection - No Device

**Steps:**
1. Ensure NO Nest device is connected
2. Select firmware type and generation
3. Click "Start Flashing"

**Expected Results:**
- Status shows "Waiting for device in DFU mode..."
- Progress indicator animates
- Console shows waiting message
- Instructions displayed
- Can click "Stop" to cancel

### Test Case 10: Device Detection - Device Connected (Non-DFU)

**Steps:**
1. Connect Nest via USB (not in DFU mode)
2. Click "Start Flashing"

**Expected Results:**
- Same as Test Case 9 (waits for DFU mode)
- Device not detected until rebooted into DFU mode

### Test Case 11: Successful Flashing - Gen 2, Full Mode

**Prerequisites:**
- USB drivers installed
- Nest Gen 2 device available
- USB cable connected

**Steps:**
1. Launch GUI
2. Select "Full Thermostat Mode"
3. Select "Generation 2"
4. Click "Start Flashing"
5. Put Nest in DFU mode (hold display 10-15 seconds)
6. Wait for flashing to complete

**Expected Results:**
- Device detected when entering DFU mode
- Console shows detailed progress:
  - "Device detected"
  - "Loading x-load..."
  - "Loading u-boot..."
  - "Loading uImage..."
  - Progress percentages
- Flashing completes successfully
- Success message displayed
- Next steps shown in console
- Progress bar stops
- Buttons return to normal state

**Verification:**
- Nest device should boot with NoLongerEvil logo
- Device should eventually boot to setup screen

### Test Case 12: Successful Flashing - Gen 1, Local-Only Mode

**Prerequisites:**
- USB drivers installed
- Nest Gen 1 device available
- USB cable connected

**Steps:**
1. Launch GUI
2. Select "Display-Only Mode"
3. Acknowledge warning
4. Select "Generation 1"
5. Click "Start Flashing"
6. Put Nest in DFU mode
7. Wait for flashing to complete

**Expected Results:**
- Warning displayed and acknowledged
- Device detected and flashed successfully
- Local-only firmware used
- Success message mentions Display-Only mode features
- Instructions appropriate for local-only mode

**Verification:**
- Device boots to temperature/humidity display
- No network configuration required

### Test Case 13: Flashing Error - Wrong Drivers

**Prerequisites:**
- USB drivers NOT installed or incorrect driver

**Steps:**
1. Select options and click "Start Flashing"
2. Put device in DFU mode

**Expected Results:**
- Device not detected OR error accessing device
- Clear error message displayed
- Troubleshooting suggestions shown
- Link to driver installation instructions

### Test Case 14: Flashing Error - Connection Lost

**Prerequisites:**
- Start flashing process

**Steps:**
1. Begin flashing
2. Wait for device detection
3. Unplug USB cable during flashing

**Expected Results:**
- Error message displayed
- Clear explanation of what happened
- Suggestions for recovery
- Application does not crash
- Can retry flashing

### Test Case 15: Stop During Flashing

**Steps:**
1. Start flashing process
2. Wait for device detection
3. Click "Stop" button during flashing

**Expected Results:**
- Flashing process stops
- Appropriate message displayed
- No device damage
- Can retry flashing

## Error Handling Testing

### Test Case 16: Missing omap_loader

**Steps:**
1. Rename or delete omap_loader.exe
2. Launch GUI

**Expected Results:**
- Error message displayed
- Clear instructions on how to fix
- "Start Flashing" button disabled

### Test Case 17: Network Error - Firmware Download

**Steps:**
1. Disconnect from internet
2. Delete firmware files
3. Click "Start Flashing"

**Expected Results:**
- Clear error message about network failure
- Suggestions to check internet connection
- Option to retry or manually download

### Test Case 18: Insufficient Permissions

**Steps:**
1. Run GUI as standard user (not Administrator)
2. Try to flash device

**Expected Results:**
- Error message about permissions
- Suggestion to run as Administrator
- Graceful handling (no crash)

## Uninstallation Testing

### Test Case 19: Standard Uninstallation

**Steps:**
1. Go to Settings → Apps → NoLongerEvil Thermostat
2. Click Uninstall
3. Confirm uninstallation

**Expected Results:**
- Uninstaller launches
- All files removed from installation directory
- Start Menu shortcuts removed
- Desktop icon removed (if created)
- Registry entries removed
- Firmware files removed

**Verification:**
```powershell
# Check installation directory removed
-not (Test-Path "C:\Program Files\NoLongerEvil Thermostat\")

# Check Start Menu cleaned
-not (Test-Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\NoLongerEvil Thermostat\")
```

### Test Case 20: Uninstall with Manual Changes

**Prerequisites:**
- Installation completed
- User has added custom files to installation directory

**Steps:**
1. Add a text file to installation directory
2. Run uninstaller

**Expected Results:**
- Uninstaller completes
- Installation directory removed (including user files)
- OR: User prompted about additional files

## Upgrade Testing

### Test Case 21: Upgrade Installation

**Prerequisites:**
- Previous version installed

**Steps:**
1. Run new installer
2. Select same installation directory

**Expected Results:**
- Detects existing installation
- Offers to upgrade or install fresh
- Preserves user settings (if applicable)
- Updates all files
- Maintains firmware files

## Silent Installation Testing

### Test Case 22: Silent Install - Full

**Steps:**
```powershell
NoLongerEvil-Thermostat-Setup.exe /SILENT /TYPE=full
```

**Expected Results:**
- Installs without user interaction
- Uses default settings
- Completes successfully
- No GUI shown during install

### Test Case 23: Silent Install - Custom Directory

**Steps:**
```powershell
NoLongerEvil-Thermostat-Setup.exe /SILENT /DIR="C:\Custom\Path" /TYPE=localonly
```

**Expected Results:**
- Installs to specified directory
- Uses local-only mode
- No user interaction required

## Performance Testing

### Test Case 24: Installation Speed

**Measurement:**
- Time to complete installation
- Time to download firmware
- Time to extract files

**Acceptable:**
- Installation: < 2 minutes
- Firmware download: < 1 minute (on reasonable connection)
- Total time: < 5 minutes

### Test Case 25: Flashing Speed

**Measurement:**
- Time from device detection to completion
- Time for each component (x-load, u-boot, uImage)

**Acceptable:**
- Total flashing time: 1-3 minutes
- No long pauses or hangs

## Compatibility Testing

### Test Case 26: Windows 10 Versions

Test on:
- Windows 10 21H2
- Windows 10 22H2
- Latest Windows 10 version

### Test Case 27: Windows 11 Versions

Test on:
- Windows 11 21H2
- Windows 11 22H2
- Latest Windows 11 version

### Test Case 28: Different USB Controllers

Test with:
- USB 2.0 ports
- USB 3.0 ports
- USB-C ports (with adapter)
- USB hub
- Front panel USB vs back panel USB

### Test Case 29: Different Cable Types

Test with:
- Standard micro USB cable
- Long cable (6ft+)
- Short cable (< 1ft)
- Different manufacturers

## Regression Testing

After any code changes, re-run:
- Test Case 1 (Full installation)
- Test Case 11 (Successful flashing Gen 2)
- Test Case 12 (Successful flashing Gen 1)
- Test Case 19 (Uninstallation)

## Bug Reporting

For each failed test, document:
1. Test case number and name
2. Steps to reproduce
3. Expected result
4. Actual result
5. Screenshots or logs
6. System information:
   - Windows version
   - Installation directory
   - User account type
   - Nest generation
   - USB driver version

## Test Results Template

```markdown
## Test Results - [Date]

**Tester:** [Name]
**Windows Version:** [Version]
**Installer Version:** [Version]

### Installation Tests
- [ ] TC1: Full Thermostat Mode Installation - PASS/FAIL
- [ ] TC2: Display-Only Mode Installation - PASS/FAIL
- [ ] TC3: Custom Component Selection - PASS/FAIL

### GUI Tests
- [ ] TC4: GUI Launch and Interface - PASS/FAIL
- [ ] TC5: Firmware Type Selection - PASS/FAIL
- [ ] TC6: Generation Selection - PASS/FAIL
- [ ] TC7: USB Driver Installation - PASS/FAIL

### Flashing Tests
- [ ] TC8: Firmware Download - PASS/FAIL
- [ ] TC11: Successful Flashing Gen 2 - PASS/FAIL
- [ ] TC12: Successful Flashing Gen 1 - PASS/FAIL

### Uninstall Tests
- [ ] TC19: Standard Uninstallation - PASS/FAIL

**Issues Found:** [List any bugs or issues]

**Notes:** [Additional observations]
```
