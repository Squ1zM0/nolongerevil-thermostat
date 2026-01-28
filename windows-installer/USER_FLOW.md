# Windows Installer User Flow

## Installation Flow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Download NoLongerEvil-Thermostat-Setup.exe from GitHub  │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Run Installer as Administrator                           │
│    Right-click → Run as Administrator                       │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Accept License Agreement                                 │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. Choose Installation Mode                                 │
│    ┌───────────────────────┬───────────────────────────┐   │
│    │ Full Thermostat Mode  │ Display-Only Mode         │   │
│    │ • Cloud-connected     │ • Temperature monitor     │   │
│    │ • Smart features      │ • NO thermostat control   │   │
│    │ • Remote control      │ • Offline operation       │   │
│    └───────────────────────┴───────────────────────────┘   │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. Select Components to Install                             │
│    ☑ Core Files (required)                                  │
│    ☑ Graphical Flashing Tool                                │
│    ☑ USB Drivers (Zadig)                                    │
│    ☑ Firmware Files (auto-selected)                         │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. Choose Installation Directory                            │
│    Default: C:\Program Files\NoLongerEvil Thermostat\      │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 7. Installer Downloads Firmware from GitHub                 │
│    [████████████████████░░░░] 75%                           │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 8. Files Installed & Shortcuts Created                      │
│    • Program Files copied                                   │
│    • Start Menu shortcuts created                           │
│    • Desktop icon (optional)                                │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 9. Installation Complete!                                   │
│    ☐ Launch NoLongerEvil Thermostat Flasher                │
└─────────────────────────────────────────────────────────────┘
```

## First-Time Setup Flow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Launch GUI from Start Menu                               │
│    Start → NoLongerEvil Thermostat → NLE Thermostat Flasher│
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Install USB Drivers (FIRST TIME ONLY)                    │
│    ┌─────────────────────────────────────────────────┐     │
│    │ Click "Install USB Drivers" button              │     │
│    └─────────────┬───────────────────────────────────┘     │
└──────────────────┼─────────────────────────────────────────┘
                   │
                   ▼
          ┌────────────────────┐
          │ Connect Nest & put │
          │ in DFU mode        │
          │ (hold 10-15 sec)   │
          └────────┬───────────┘
                   │
                   ▼
          ┌────────────────────────┐
          │ Zadig Opens            │
          │ 1. Options → List All  │
          │ 2. Select "TI OMAP"    │
          │ 3. Choose WinUSB       │
          │ 4. Install Driver      │
          └────────┬───────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Driver Installed ✓                                       │
│    (Only needed once per computer)                          │
└─────────────────────────────────────────────────────────────┘
```

## Flashing Flow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Open NoLongerEvil Thermostat Flasher                     │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Select Firmware Type                                     │
│    ⦿ Full Thermostat Mode    ○ Display-Only Mode           │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Select Nest Generation                                   │
│    ⦿ Generation 1            ○ Generation 2                │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. Prepare Device                                           │
│    • Ensure Nest is charged (50%+)                          │
│    • Remove from wall mount                                 │
│    • Connect via micro USB to computer                      │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. Click "Start Flashing"                                   │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. Put Nest in DFU Mode                                     │
│    Hold display for 10-15 seconds until device reboots      │
│    [Waiting for device...]                                  │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 7. Device Detected - Flashing Begins!                       │
│    [████████████████████░░░░] 75%                           │
│    Loading x-load...                                        │
│    Loading u-boot...                                        │
│    Loading uImage...                                        │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 8. Flashing Complete! ✓                                     │
│    Keep device plugged in via USB                           │
│    Wait 2-3 minutes for device to boot                      │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
          ┌───────┴────────┐
          │                │
          ▼                ▼
┌──────────────────┐  ┌─────────────────┐
│ Full Mode:       │  │ Display-Only:   │
│ 1. Visit         │  │ 1. Device boots │
│    nolongerevil  │  │ 2. Shows temp & │
│    .com          │  │    humidity     │
│ 2. Register      │  │ 3. Ready to use!│
│ 3. Get entry     │  │    (no setup)   │
│    code from     │  │                 │
│    device        │  │                 │
│ 4. Link device   │  │                 │
└──────────────────┘  └─────────────────┘
```

## Architecture Diagram

```
┌────────────────────────────────────────────────────────────────┐
│                    Windows Installer Package                   │
│                 (NoLongerEvil-Thermostat-Setup.exe)            │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────┐     │
│  │ Inno Setup Installer (setup.iss)                     │     │
│  │ • Installation wizard                                 │     │
│  │ • Downloads firmware from GitHub                      │     │
│  │ • Extracts files to Program Files                     │     │
│  │ • Creates shortcuts                                   │     │
│  └──────────────────┬───────────────────────────────────┘     │
│                     │                                          │
│                     │ Installs                                 │
│                     ▼                                          │
│  ┌──────────────────────────────────────────────────────┐     │
│  │ Installed Components                                  │     │
│  ├──────────────────────────────────────────────────────┤     │
│  │                                                       │     │
│  │  ┌────────────────────────────────────────────┐      │     │
│  │  │ NestFlasher.exe (GUI Application)          │      │     │
│  │  │ • Firmware type selection                  │      │     │
│  │  │ • Generation selection                     │      │     │
│  │  │ • Firmware download/management             │      │     │
│  │  │ • Device detection                         │      │     │
│  │  │ • Flashing coordination                    │      │     │
│  │  │ • Error handling                           │      │     │
│  │  └─────────────┬──────────────────────────────┘      │     │
│  │                │                                      │     │
│  │                │ Calls                                │     │
│  │                ▼                                      │     │
│  │  ┌────────────────────────────────────────────┐      │     │
│  │  │ omap_loader.exe (Flashing Utility)         │      │     │
│  │  │ • Communicates with Nest in DFU mode       │      │     │
│  │  │ • Loads x-load, u-boot, uImage             │      │     │
│  │  │ • Handles USB protocol                     │      │     │
│  │  └────────────────────────────────────────────┘      │     │
│  │                                                       │     │
│  │  ┌────────────────────────────────────────────┐      │     │
│  │  │ Firmware Files (firmware/)                 │      │     │
│  │  │ • x-load-gen1.bin / x-load-gen2.bin        │      │     │
│  │  │ • u-boot.bin                               │      │     │
│  │  │ • uImage                                   │      │     │
│  │  │ (Downloaded from GitHub releases)          │      │     │
│  │  └────────────────────────────────────────────┘      │     │
│  │                                                       │     │
│  │  ┌────────────────────────────────────────────┐      │     │
│  │  │ Zadig (drivers/zadig-2.8.exe)              │      │     │
│  │  │ • USB driver installation tool             │      │     │
│  │  │ • Installs WinUSB/libusb-win32             │      │     │
│  │  └────────────────────────────────────────────┘      │     │
│  │                                                       │     │
│  │  ┌────────────────────────────────────────────┐      │     │
│  │  │ Documentation                              │      │     │
│  │  │ • README.md                                │      │     │
│  │  │ • WINDOWS_INSTALLER_GUIDE.md               │      │     │
│  │  │ • LOCAL_MODE.md                            │      │     │
│  │  └────────────────────────────────────────────┘      │     │
│  │                                                       │     │
│  └───────────────────────────────────────────────────────┘     │
│                                                                 │
└────────────────────────────────────────────────────────────────┘

                           │
                           │ USB Connection
                           ▼
                    ┌──────────────┐
                    │ Nest Gen 1/2 │
                    │ (DFU Mode)   │
                    └──────────────┘
```

## Component Interaction

```
User                GUI                omap_loader         Nest Device
 │                   │                     │                    │
 │   Launch GUI      │                     │                    │
 ├──────────────────>│                     │                    │
 │                   │                     │                    │
 │  Select options   │                     │                    │
 ├──────────────────>│                     │                    │
 │                   │                     │                    │
 │ Click "Flash"     │                     │                    │
 ├──────────────────>│ Check firmware      │                    │
 │                   ├─────────────────────┐                    │
 │                   │ Download if needed  │                    │
 │                   │<────────────────────┘                    │
 │                   │                     │                    │
 │   Connect Nest    │                     │                    │
 ├────────────────────────────────────────────────────────────>│
 │                   │                     │                    │
 │  Reboot to DFU    │                     │                    │
 ├────────────────────────────────────────────────────────────>│
 │                   │                     │                    │
 │                   │ Execute omap_loader │                    │
 │                   ├────────────────────>│                    │
 │                   │                     │  Wait for device   │
 │                   │                     ├───────────────────>│
 │                   │                     │  Device detected   │
 │                   │                     │<───────────────────┤
 │                   │                     │  Load x-load       │
 │                   │                     ├───────────────────>│
 │                   │                     │  Load u-boot       │
 │                   │                     ├───────────────────>│
 │                   │                     │  Load uImage       │
 │                   │                     ├───────────────────>│
 │                   │                     │  Jump to code      │
 │                   │                     ├───────────────────>│
 │                   │     Success!        │                    │
 │                   │<────────────────────┤                    │
 │  Flash complete   │                     │                    │
 │<──────────────────┤                     │                    │
 │                   │                     │      Boot          │
 │                   │                     │<───────────────────┤
 │                   │                     │                    │
```

## File Structure After Installation

```
C:\Program Files\NoLongerEvil Thermostat\
│
├── NestFlasher.exe                    (GUI Application)
│
├── bin\
│   └── windows-x64\
│       └── omap_loader.exe            (Flashing tool)
│
├── firmware\
│   ├── x-load-gen1.bin                (Gen 1 bootloader)
│   ├── x-load-gen2.bin                (Gen 2 bootloader)
│   ├── u-boot.bin                     (U-Boot)
│   └── uImage                         (Kernel)
│
├── drivers\
│   └── zadig-2.8.exe                  (USB driver installer)
│
├── scripts\
│   ├── install.ps1                    (PowerShell installer)
│   └── build.ps1                      (Build script)
│
├── configs\
│   └── local-only-mode.conf           (Config files)
│
├── README.md                          (Documentation)
├── LOCAL_MODE.md
└── LICENSE

Start Menu:
└── NoLongerEvil Thermostat\
    ├── NoLongerEvil Thermostat Flasher
    ├── USB Driver Installation
    ├── Documentation
    └── Uninstall NoLongerEvil Thermostat

Desktop (optional):
└── NoLongerEvil Thermostat.lnk
```
