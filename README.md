# Nest Thermostat Firmware Setup

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-donate-yellow.svg)](https://buymeacoffee.com/codykociemba)
[![Discord](https://img.shields.io/badge/Discord-Join%20Us-5865F2?logo=discord&logoColor=white)](https://discord.gg/hackhouse)
[![Release](https://img.shields.io/badge/Release-v1.0.0-blue)](https://github.com/codykociemba/NoLongerEvil-Thermostat/releases/tag/v1.0.0)

<div align="center">
  <a href="https://bounties.fulu.org/bounties/nest-learning-thermostat-gen-1-2">
    <img src="assets/fulu-bounties.png" alt="FULU Bounties Winner" width="500">
  </a>
  <h2>🏆 FULU Bounty Winner 🏆</h2>
  <p><strong><a href="https://hackhouse.io">Hack House</a></strong> and this project are the official winners of the <strong><a href="https://bounties.fulu.org/bounties/nest-learning-thermostat-gen-1-2">FULU Bounty for Nest Learning Thermostat Gen 1/2</a></strong></p>
</div>

**Hardware Alternative:** If you're interested in the hardware side of things, check out [https://sett.homes](https://sett.homes) for a drop-in PCB replacement option.

---

## Installation Options

Choose the installation method that works best for you:

### Option 1: Hosted (GUI Installer) - **Recommended**

The easiest way to get started. Download our GUI installer that handles everything automatically.

📖 **[View Installation Guide](https://docs.nolongerevil.com/hosted/installation)**

### Option 2: Hosted (Manual)

If the GUI installer doesn't work for you, follow the manual installation steps below. This method uses command-line tools to flash the firmware.

### Option 3: Self-Hosted - **Advanced Users Only**

Host your own No Longer Evil server infrastructure. Requires technical expertise.

📖 **[View Self-Hosted Guide](https://docs.nolongerevil.com/self-hosted/overview)**

⚠️ **Warning:** This option is still a work in progress and may or may not function properly. Check out the [discussion here](https://github.com/codykociemba/NoLongerEvil-Thermostat/discussions/34) for more details.

### Option 4: Display-Only Mode - **Temperature Monitor (NOT a Thermostat)**

⚠️ **IMPORTANT:** This mode turns your Nest into a temperature/humidity display ONLY. It will NOT control heating or cooling.

📖 **[View Display-Only Mode Guide](LOCAL_MODE.md)**

**Perfect for you if:**
- You just want to monitor temperature and humidity (NOT control HVAC)
- You don't need thermostat functions at all
- You don't have Wi-Fi or prefer to stay offline
- You care about privacy (nothing gets sent to the internet)
- You want to repurpose your old Nest as a sensor/monitor

**Super Easy Setup:**
```bash
./quick-start.sh
```

Or if you know you want Display-Only Mode:
```bash
./install.sh --local-only
```

**What you get:** Temperature and humidity display  
**What you DON'T get:** NO heating/cooling control, NO thermostat functions

---

## Manual Installation (Option 2)

This directory contains the tools and firmware needed to flash custom firmware to Nest Thermostat devices using the OMAP DFU (Device Firmware Update) interface.

### Prerequisites

You will need a computer running **Linux**, **macOS**, or **Windows**.

⚠️ Please verify your Nest is compatible at **[https://docs.nolongerevil.com/compatibility](https://docs.nolongerevil.com/compatibility)** - we currently only support Nest Generation 1 and 2 at the moment.

### How it Works

The custom firmware flashes the device with modified bootloader and kernel components that redirect all network traffic from the original Nest/Google servers to a server we specify. This server hosts a reverse-engineered replica of their API, allowing the thermostat to function independently while giving you complete control over your device data and settings.

By intercepting the communication layer, the thermostat believes it's communicating with the official Nest infrastructure, but instead connects to the No Longer Evil platform. This approach ensures full compatibility with the device's existing software while breaking free from Google's cloud dependency.

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/codykociemba/NoLongerEvil-Thermostat.git
cd NoLongerEvil-Thermostat
```

### 2. Install Prerequisites

Before building, you'll need to install some required packages:

#### Linux (Debian/Ubuntu)

```bash
sudo apt-get update
sudo apt-get install build-essential libusb-1.0-0-dev gcc pkg-config
```

#### macOS

First, install Xcode Command Line Tools:

```bash
xcode-select --install
```

Then install libusb using Homebrew (the build script will attempt to install this automatically if missing):

```bash
# Install Homebrew if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install libusb
brew install libusb pkg-config
```

#### Windows

**Option A: Using MSYS2/MinGW (Recommended)**

1. Download and install MSYS2 from [https://www.msys2.org/](https://www.msys2.org/)
2. Open "MSYS2 MINGW64" terminal (not the regular MSYS2 terminal)
3. Install required packages:
   ```bash
   pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-libusb mingw-w64-x86_64-pkg-config make
   ```

**Option B: Pre-built Binary**

If you don't want to build from source, pre-built Windows binaries are available in the [Releases](https://github.com/codykociemba/NoLongerEvil-Thermostat/releases) section.

**USB Driver Installation (Required for Windows)**

Windows requires a USB driver to communicate with the Nest in DFU mode:

1. Download [Zadig](https://zadig.akeo.ie/)
2. Put your Nest in DFU mode (see Step 5 below)
3. In Zadig, select "List All Devices" from the Options menu
4. Find "Texas Instruments OMAP" or similar device
5. Select "WinUSB" or "libusb-win32" as the driver
6. Click "Install Driver" or "Replace Driver"

### 3. Build the omap_loader tool

**Linux/macOS:**
```bash
chmod +x build.sh
./build.sh
```

**Windows (MSYS2 MINGW64 terminal):**
```bash
./build.sh
```

**Windows (PowerShell - requires MSYS2 installed):**
```powershell
.\build.ps1
```

The build script will automatically detect your operating system and build the appropriate binary.

### 4. Start the firmware installer

**IMPORTANT: You must start the installer script BEFORE rebooting the device.**

**Linux/macOS:**
```bash
chmod +x install.sh
./install.sh
```

**Windows (MSYS2 MINGW64 terminal):**
```bash
./install.sh
```

**Windows (PowerShell):**
```powershell
.\install.ps1
```

**Note for macOS:** You may need to grant USB permissions. If you encounter permission issues, check System Preferences → Security & Privacy.

**Note for Windows:** Run PowerShell as Administrator if you encounter permission issues.

The script will wait for the device to enter DFU mode.

### 5. Put your Nest device in DFU mode

Follow these steps carefully:

1. **Charge the device** - Ensure your Nest Thermostat is properly charged (at least 50% battery recommended)
2. **Remove from wall** - Remove the Nest from its back plate/wall mount
3. **Connect via USB** - Plug the Nest into your computer using a micro USB cable
4. **Wait for the installer** - Make sure the `install.sh` script is running and waiting
5. **Reboot the device** - Press and hold down on the display for 10-15 seconds until the device reboots
6. **DFU mode active** - Once it reboots, the device will enter DFU mode and the installer script will recognize it and begin flashing

The firmware installer will automatically detect the device and flash the custom bootloader (x-load, u-boot) and kernel (uImage).

### 6. Wait for the device to boot

After the firmware is flashed successfully, you should see our NLE logo on the device screen.

**Important:**
- Keep the device plugged in via USB
- Wait for the device to complete its boot sequence (this may take 3-4 minutes)
- Do not disconnect or power off the device during this time

### 7. Register your account

Once the device has fully rebooted:

1. Visit **[https://nolongerevil.com](https://nolongerevil.com)** in your web browser
2. **Register an account** (or sign in if you already have one)
3. Navigate to your **Dashboard**

You will see a "No devices" screen that prompts you for an entry code.

### 8. Link your device

To link your Nest device to your No Longer Evil account:

1. On your Nest device, navigate to: **Settings → Nest App → Get Entry Code**
2. The device will display a unique entry code
3. Enter this code on the No Longer Evil dashboard
4. Your device is now linked and ready to use!

---

## Local-Only Mode Installation

Want to use your Nest as a simple temperature and humidity display without cloud connectivity? Follow these alternative steps:

### Prerequisites

Complete steps 1-3 from the standard installation above (clone repository, install prerequisites, build omap_loader).

### Install with Local-Only Mode

Instead of running the standard `./install.sh`, use the local-only flag:

```bash
chmod +x install.sh
./install.sh --local-only
```

This will:
- Flash the device with modified firmware
- Configure for standalone operation (no cloud)
- Set up the display to show temperature and humidity only
- Disable Wi-Fi to save power

### What You Get

After installation, your Nest will:
- ✅ Display large temperature reading (°F)
- ✅ Show humidity percentage below temperature
- ✅ Update every 5 seconds
- ✅ Work completely offline
- ✅ Operate with minimal power consumption

### No Account Setup Required

Unlike the standard installation, local-only mode does **not** require:
- Creating an account at nolongerevil.com
- Linking the device with an entry code
- Any internet connection
- Wi-Fi network access

The device will boot and immediately start displaying sensor data.

### Customization

After installation, you can customize settings by pressing and holding the display for 3 seconds:
- Change temperature unit (°F / °C)
- Adjust display brightness
- Configure refresh rate
- Set temperature alerts

For complete documentation, see **[LOCAL_MODE.md](LOCAL_MODE.md)**.

---

## Security Considerations

This tool provides low-level access to the device's boot process. Use responsibly:

- Only use on devices you own
- Improper firmware can brick your device (Don't sue me bro)

## Credits & Acknowledgments

This project builds upon the excellent work of several security researchers and developers:

- **[grant-h](https://github.com/grant-h) / [ajb142](https://github.com/ajb142)** - [omap_loader](https://github.com/ajb142/omap_loader), the USB bootloader tool used to flash OMAP devices
- **[exploiteers (GTVHacker)](https://github.com/exploiteers)** - Original research and development of the [Nest DFU attack](https://github.com/exploiteers/NestDFUAttack), which demonstrated the ability to flash custom firmware to Nest devices gen 1 & gen 2
- **[FULU](https://bounties.fulu.org/)** and all bounty backers - For funding the [Nest Learning Thermostat Gen 1/2 bounty](https://bounties.fulu.org/bounties/nest-learning-thermostat-gen-1-2) and supporting the right-to-repair movement

Without their groundbreaking research, open-source contributions, and advocacy for device ownership rights, this work would not be possible. Thank you!

### Open Source Commitment

We are committed to transparency and the right-to-repair movement. The firmware images and backend API server code will be open sourced soon, allowing the community to audit, improve, and self-host their own infrastructure.

## References

- [OMAP Loader by ajb142](https://github.com/ajb142/omap_loader)
- [Nest DFU Attack by exploiteers](https://github.com/exploiteers/NestDFUAttack)
