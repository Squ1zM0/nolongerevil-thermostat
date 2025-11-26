#!/usr/bin/env bash
# Auto-detect platform and install firmware to OMAP device

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Detect OS and architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

echo "========================================="
echo "NoLongerEvil Firmware Installer"
echo "========================================="
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

# Check if firmware files already exist
if [ -f "$FIRMWARE_DIR/x-load-gen1.bin" ] && [ -f "$FIRMWARE_DIR/x-load-gen2.bin" ] && [ -f "$FIRMWARE_DIR/u-boot.bin" ] && [ -f "$FIRMWARE_DIR/uImage" ]; then
    echo "========================================="
    echo "Firmware files already exist, skipping download"
    echo "========================================="
    echo ""
else
    echo "========================================="
    echo "Downloading firmware files..."
    echo "========================================="
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
    echo "Next steps:"
    echo "1. Keep the device plugged in via USB"
    echo "2. Wait 2-3 minutes for the device to boot"
    echo "3. You should see the NoLongerEvil logo"
    echo "4. Visit https://nolongerevil.com to register"
    echo "5. Link your device using the entry code from:"
    echo "   Settings → Nest App → Get Entry Code"
    echo ""
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

