#!/usr/bin/env bash
# Dedicated flashing script for local-only mode
# This script provides a streamlined workflow for flashing local-only mode

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "========================================"
echo "Local-Only Mode Flash Helper"
echo "========================================"
echo ""

# Step 1: Pre-flight checks
echo -e "${BLUE}Step 1: Running pre-flight checks...${NC}"
echo ""

if [ ! -f "$SCRIPT_DIR/build.sh" ]; then
    echo -e "${RED}✗ Error: build.sh not found${NC}"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/install.sh" ]; then
    echo -e "${RED}✗ Error: install.sh not found${NC}"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/configs/local-only-mode.conf" ]; then
    echo -e "${RED}✗ Error: local-only-mode.conf not found${NC}"
    exit 1
fi

echo -e "${GREEN}✓ All required files present${NC}"
echo ""

# Step 2: Check for omap_loader binary
echo -e "${BLUE}Step 2: Checking for omap_loader binary...${NC}"
echo ""

OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
    Linux*)
        OMAP_LOADER="$SCRIPT_DIR/bin/linux-x64/omap_loader"
        ;;
    Darwin*)
        if [ "$ARCH" = "arm64" ]; then
            OMAP_LOADER="$SCRIPT_DIR/bin/macos-arm64/omap_loader"
        else
            OMAP_LOADER="$SCRIPT_DIR/bin/macos-x64/omap_loader"
        fi
        ;;
    *)
        echo -e "${RED}✗ Unsupported OS: $OS${NC}"
        exit 1
        ;;
esac

if [ ! -f "$OMAP_LOADER" ]; then
    echo -e "${YELLOW}⚠ omap_loader binary not found${NC}"
    echo ""
    echo "Would you like to build it now? (y/n)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${BLUE}Building omap_loader...${NC}"
        echo ""
        chmod +x "$SCRIPT_DIR/build.sh"
        "$SCRIPT_DIR/build.sh"
        echo ""
        
        if [ -f "$OMAP_LOADER" ]; then
            echo -e "${GREEN}✓ Build successful${NC}"
        else
            echo -e "${RED}✗ Build failed${NC}"
            exit 1
        fi
    else
        echo ""
        echo "Please run './build.sh' first, then try again."
        exit 1
    fi
else
    echo -e "${GREEN}✓ Binary found: $OMAP_LOADER${NC}"
fi

echo ""

# Step 3: Display configuration summary
echo -e "${BLUE}Step 3: Configuration Summary${NC}"
echo ""
echo "Local-Only Mode will configure your device with:"
echo ""
echo "  • Operating Mode: Local-Only (no cloud)"
echo "  • Cloud Connectivity: DISABLED"
echo "  • Wi-Fi: DISABLED"
echo "  • Display: Temperature + Humidity"
echo "  • Temperature Unit: Fahrenheit (configurable)"
echo "  • Refresh Rate: 5 seconds (configurable)"
echo "  • Smart Features: DISABLED"
echo "  • Temperature Alerts: ENABLED"
echo ""

# Step 4: Compatibility check
echo -e "${BLUE}Step 4: Compatibility Check${NC}"
echo ""
echo "This firmware supports:"
echo "  ✓ Nest Thermostat Generation 1"
echo "  ✓ Nest Thermostat Generation 2"
echo ""
echo "  ✗ NOT compatible with Generation 3 or newer"
echo ""
echo "Is your device a Generation 1 or 2 Nest Thermostat? (y/n)"
read -r compat_response

if [[ ! "$compat_response" =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${RED}✗ Incompatible device${NC}"
    echo ""
    echo "Please verify your device is Generation 1 or 2."
    echo "See: https://docs.nolongerevil.com/compatibility"
    exit 1
fi

echo ""

# Step 5: Safety warning
echo -e "${YELLOW}Step 5: Important Safety Information${NC}"
echo ""
echo "Before proceeding:"
echo ""
echo "  ⚠ This will flash custom firmware to your device"
echo "  ⚠ Ensure your device is charged (50%+ recommended)"
echo "  ⚠ Keep the device connected throughout the process"
echo "  ⚠ Do not disconnect during flashing"
echo "  ⚠ Improper flashing may brick your device"
echo ""
echo "Do you understand and accept these risks? (y/n)"
read -r safety_response

if [[ ! "$safety_response" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Flash process cancelled."
    exit 0
fi

echo ""

# Step 6: Final confirmation
echo -e "${BLUE}Step 6: Final Confirmation${NC}"
echo ""
echo "Ready to flash Local-Only Mode firmware."
echo ""
echo "This will:"
echo "  1. Download firmware files (if needed)"
echo "  2. Wait for device to enter DFU mode"
echo "  3. Flash bootloader and kernel"
echo "  4. Apply local-only configuration"
echo ""
echo "Proceed with flashing? (y/n)"
read -r final_response

if [[ ! "$final_response" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Flash process cancelled."
    exit 0
fi

echo ""

# Step 7: Execute flash
echo -e "${GREEN}Step 7: Starting Flash Process${NC}"
echo ""
echo "========================================"
echo ""

chmod +x "$SCRIPT_DIR/install.sh"
"$SCRIPT_DIR/install.sh" --local-only

# Check exit code
if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo -e "${GREEN}✓ Flash Completed Successfully!${NC}"
    echo "========================================"
    echo ""
    echo "Next Steps:"
    echo "  1. Keep device connected via USB"
    echo "  2. Wait 2-3 minutes for boot"
    echo "  3. Device will show temperature and humidity"
    echo "  4. Press and hold display for settings (optional)"
    echo ""
    echo "For troubleshooting, see LOCAL_MODE.md"
    echo ""
else
    echo ""
    echo "========================================"
    echo -e "${RED}✗ Flash Failed${NC}"
    echo "========================================"
    echo ""
    echo "Troubleshooting steps:"
    echo "  1. Ensure device is in DFU mode"
    echo "  2. Check USB connection"
    echo "  3. Try a different USB cable/port"
    echo "  4. Restart the flash process"
    echo ""
    echo "See docs/FAQ.md for more help"
    echo ""
    exit 1
fi
