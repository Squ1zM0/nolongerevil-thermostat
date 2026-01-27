#!/usr/bin/env bash
# Auto-detect platform and install firmware to OMAP device

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Parse command line arguments
LOCAL_ONLY_MODE=false
FORCE_DOWNLOAD=false

for arg in "$@"; do
    case $arg in
        --local-only)
            LOCAL_ONLY_MODE=true
            ;;
        --force-download)
            FORCE_DOWNLOAD=true
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --local-only       Install in local-only/dumb mode (no cloud connectivity)"
            echo "  --force-download   Force re-download of firmware files"
            echo "  --help            Show this help message"
            echo ""
            echo "Local-Only Mode:"
            echo "  Installs firmware configured for standalone operation without cloud"
            echo "  connectivity. Device will display temperature and humidity only."
            echo "  See LOCAL_MODE.md for more information."
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Detect OS and architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

if [ "$LOCAL_ONLY_MODE" = true ]; then
    echo "========================================="
    echo "NoLongerEvil Firmware Installer"
    echo "LOCAL-ONLY MODE"
    echo "========================================="
else
    echo "========================================="
    echo "NoLongerEvil Firmware Installer"
    echo "========================================="
fi
echo "Detected OS: $OS"
echo "Detected Architecture: $ARCH"
echo ""

# Determine which binary to use
case "$OS" in
    Linux*)
        OMAP_LOADER="$SCRIPT_DIR/bin/linux-x64/omap_loader"
        USE_SUDO="sudo"
        ;;
    Darwin*)
        if [ "$ARCH" = "arm64" ]; then
            OMAP_LOADER="$SCRIPT_DIR/bin/macos-arm64/omap_loader"
        else
            OMAP_LOADER="$SCRIPT_DIR/bin/macos-x64/omap_loader"
        fi
        USE_SUDO="sudo"
        ;;
    MINGW*|MSYS*|CYGWIN*)
        OMAP_LOADER="$SCRIPT_DIR/bin/windows-x64/omap_loader.exe"
        USE_SUDO=""
        ;;
    *)
        echo "Error: Unsupported operating system: $OS"
        exit 1
        ;;
esac

# Check if binary exists
if [ ! -f "$OMAP_LOADER" ]; then
    echo "Error: omap_loader binary not found at: $OMAP_LOADER"
    echo ""
    echo "Please build it first by running:"
    echo "  ./build.sh"
    exit 1
fi

echo "Using omap_loader: $OMAP_LOADER"
echo ""

# Download and extract firmware files
FIRMWARE_DIR="$SCRIPT_DIR/bin/firmware"
FIRMWARE_URL="https://github.com/codykociemba/NoLongerEvil-Thermostat/releases/download/v1.0.0/firmware-files.zip"
FIRMWARE_ZIP="$SCRIPT_DIR/bin/firmware-files.zip"

# Create bin and firmware directories if they don't exist
mkdir -p "$SCRIPT_DIR/bin"
mkdir -p "$FIRMWARE_DIR"

# Check if firmware files were recently downloaded (within last hour), if they were we skip downloading again
SKIP_DOWNLOAD=false
if [ -f "$FIRMWARE_DIR/x-load-gen2.bin" ]; then
    REDOWNLOAD_DELAY=3600
    CURRENT_TIME=$(date +%s)
    FILE_MTIME=$(stat -c %W "$FIRMWARE_DIR/x-load-gen2.bin" 2>/dev/null || echo $(($REDOWNLOAD_DELAY + 1)))
    TIME_DIFF=$((CURRENT_TIME - FILE_MTIME))

    # Skip download if file was created within the last hour (3600 seconds)
    if [ $TIME_DIFF -lt $REDOWNLOAD_DELAY ]; then
        SKIP_DOWNLOAD=true
    fi
fi

# Force download if --force-download flag is provided
if [ "$FORCE_DOWNLOAD" = true ]; then
    SKIP_DOWNLOAD=false
fi

if [ "$SKIP_DOWNLOAD" = true ]; then
    echo "========================================="
    echo "Firmware downloaded recently! Skipping..."
    echo "(use '--force-download' to override)"
    echo "========================================="
    echo ""
else
    echo "========================================="
    echo "Downloading firmware files..."
    echo "========================================="
    echo ""

    # Rename existing firmware files with their creation times as suffix
    for fw_file in "$FIRMWARE_DIR"/{x-load-gen1,x-load-gen2,u-boot}.bin "$FIRMWARE_DIR"/uImage; do
        if [ -f "$fw_file" ]; then
            FILE_CTIME=$(stat -c %Y "$fw_file" 2>/dev/null || echo .bak)
            FILE_NAME=$(basename "$fw_file")
            mv "$fw_file" "$FIRMWARE_DIR/${FILE_NAME}.${FILE_CTIME}"
            echo "Renamed old file: $FILE_NAME → ${FILE_NAME}.${FILE_CTIME}"
        fi
    done
    echo ""

    # Download firmware archive
    if command -v curl &> /dev/null; then
        echo "Downloading from: $FIRMWARE_URL"
        if ! curl -L -o "$FIRMWARE_ZIP" "$FIRMWARE_URL"; then
            echo "Error: Failed to download firmware files"
            exit 1
        fi
    elif command -v wget &> /dev/null; then
        echo "Downloading from: $FIRMWARE_URL"
        if ! wget -O "$FIRMWARE_ZIP" "$FIRMWARE_URL"; then
            echo "Error: Failed to download firmware files"
            exit 1
        fi
    else
        echo "Error: Neither curl nor wget found. Please install one of them."
        exit 1
    fi

    echo "Download complete!"
    echo ""

    # Extract firmware files
    echo "Extracting firmware files..."
    if ! unzip -o "$FIRMWARE_ZIP" -d "$FIRMWARE_DIR"; then
        echo "Error: Failed to extract firmware files"
        echo "Make sure unzip is installed"
        exit 1
    fi

    # Clean up zip file
    rm -f "$FIRMWARE_ZIP"

    echo "Firmware files extracted successfully!"
    echo ""
fi

# Handle local-only mode configuration
if [ "$LOCAL_ONLY_MODE" = true ]; then
    echo "========================================="
    echo "Local-Only Mode Configuration"
    echo "========================================="
    echo ""
    echo "Local-only mode will configure your Nest as a simple environmental"
    echo "display showing only temperature and humidity."
    echo ""
    echo "Features in local-only mode:"
    echo "  ✓ Displays temperature (°F) and humidity (%)"
    echo "  ✓ Works completely offline (no Wi-Fi required)"
    echo "  ✓ Low power consumption"
    echo "  ✓ Minimal complexity and failure points"
    echo ""
    echo "Disabled features:"
    echo "  ✗ Cloud connectivity and remote control"
    echo "  ✗ Scheduling and learning"
    echo "  ✗ Mobile app integration"
    echo ""
    
    # Copy configuration file to firmware directory
    CONFIG_SRC="$SCRIPT_DIR/configs/local-only-mode.conf"
    CONFIG_DEST="$FIRMWARE_DIR/local-only-mode.conf"
    
    if [ -f "$CONFIG_SRC" ]; then
        cp "$CONFIG_SRC" "$CONFIG_DEST"
        echo "✓ Local-only configuration prepared"
        echo ""
    else
        echo "Warning: Configuration file not found at $CONFIG_SRC"
        echo "Proceeding with default local-only settings..."
        echo ""
    fi
fi

# Prompt for Nest generation
echo "========================================="
echo "Nest Generation Selection"
echo "========================================="
echo ""
echo "Which generation Nest Thermostat do you have?"
echo "You can check the back plate - the bubble level should be green for Gen 1/2."
echo ""
echo "Enter 1 for Generation 1"
echo "Enter 2 for Generation 2"
echo ""
read -p "Generation (1 or 2): " NEST_GEN

# Validate input
while [[ ! "$NEST_GEN" =~ ^[12]$ ]]; do
    echo "Invalid input. Please enter 1 or 2."
    read -p "Generation (1 or 2): " NEST_GEN
done

echo ""
echo "Selected: Generation $NEST_GEN"
echo ""

# Set firmware paths based on generation (use absolute paths to avoid issues with sudo)
XLOAD_BIN="$(cd "$FIRMWARE_DIR" && pwd)/x-load-gen${NEST_GEN}.bin"
UBOOT_BIN="$(cd "$FIRMWARE_DIR" && pwd)/u-boot.bin"
UIMAGE_BIN="$(cd "$FIRMWARE_DIR" && pwd)/uImage"

# Verify firmware files exist
if [ ! -f "$XLOAD_BIN" ]; then
    echo "Error: x-load-gen${NEST_GEN}.bin not found at: $XLOAD_BIN"
    exit 1
fi

if [ ! -f "$UBOOT_BIN" ]; then
    echo "Error: u-boot.bin not found at: $UBOOT_BIN"
    exit 1
fi

if [ ! -f "$UIMAGE_BIN" ]; then
    echo "Error: uImage not found at: $UIMAGE_BIN"
    exit 1
fi

echo "Firmware files verified:"
echo "  x-load: $XLOAD_BIN"
echo "  u-boot: $UBOOT_BIN"
echo "  uImage: $UIMAGE_BIN"
echo ""

echo "========================================="
echo "Waiting for device to enter DFU mode..."
echo "========================================="
echo ""
echo "Instructions:"
echo "1. Ensure your Nest is charged (50%+ recommended)"
echo "2. Remove the Nest from the wall mount"
echo "3. Connect it to your computer via micro USB"
echo "4. Press and hold the display for 10-15 seconds"
echo "5. The device will reboot and enter DFU mode"
echo ""
echo "The installer will automatically detect the device and begin flashing..."
echo ""

# Load firmware (expand all variables before sudo to prevent path issues)
if [ -n "$USE_SUDO" ]; then
    sudo "$OMAP_LOADER" \
        -f "$XLOAD_BIN" \
        -f "$UBOOT_BIN" \
        -a 0x80100000 \
        -f "$UIMAGE_BIN" \
        -a 0x80A00000 \
        -v \
        -j 0x80100000
else
    "$OMAP_LOADER" \
        -f "$XLOAD_BIN" \
        -f "$UBOOT_BIN" \
        -a 0x80100000 \
        -f "$UIMAGE_BIN" \
        -a 0x80A00000 \
        -v \
        -j 0x80100000
fi

# Check if successful
if [ $? -eq 0 ]; then
    echo ""
    echo "========================================="
    echo "Firmware installed successfully!"
    echo "========================================="
    echo ""
    
    if [ "$LOCAL_ONLY_MODE" = true ]; then
        echo "LOCAL-ONLY MODE - Next steps:"
        echo "1. Keep the device plugged in via USB"
        echo "2. Wait 2-3 minutes for the device to boot"
        echo "3. You should see the NoLongerEvil logo"
        echo "4. Device will automatically enter local-only mode"
        echo "5. Display will show: Temperature (°F) and Humidity (%)"
        echo ""
        echo "The device is now configured for standalone operation."
        echo "No internet connection or account setup is required."
        echo ""
        echo "Configuration:"
        echo "  • Cloud connectivity: DISABLED"
        echo "  • Wi-Fi: DISABLED (saves power)"
        echo "  • Display: Temperature + Humidity"
        echo "  • Refresh rate: Every 5 seconds"
        echo ""
        echo "To access settings, press and hold the display for 3 seconds."
        echo ""
        echo "For more information, see LOCAL_MODE.md"
        echo ""
    else
        echo "Next steps:"
        echo "1. Keep the device plugged in via USB"
        echo "2. Wait 2-3 minutes for the device to boot"
        echo "3. You should see the NoLongerEvil logo"
        echo "4. Visit https://nolongerevil.com to register"
        echo "5. Link your device using the entry code from:"
        echo "   Settings → Nest App → Get Entry Code"
        echo ""
    fi
else
    echo ""
    echo "========================================="
    echo "Installation failed!"
    echo "========================================="
    echo ""
    echo "Please check:"
    echo "- Device is properly connected via USB"
    echo "- Device entered DFU mode correctly"
    echo "- USB drivers are installed (Windows)"
    echo ""
    exit 1
fi

