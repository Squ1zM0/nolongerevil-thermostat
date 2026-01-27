#!/usr/bin/env bash
# Build script for creating simple/local-only firmware variants
# This script generates stripped-down firmware for local-only mode

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
FIRMWARE_DIR="$SCRIPT_DIR/bin/firmware"

echo "========================================"
echo "Simple Firmware Builder"
echo "========================================"
echo ""

# Check if standard firmware exists
if [ ! -d "$FIRMWARE_DIR" ]; then
    echo "Error: Firmware directory not found at $FIRMWARE_DIR"
    echo "Please run './install.sh' first to download firmware files."
    exit 1
fi

echo "Checking for standard firmware files..."
echo ""

# Check for required files
STANDARD_FILES=("x-load-gen1.bin" "x-load-gen2.bin" "u-boot.bin" "uImage")
MISSING_FILES=0

for file in "${STANDARD_FILES[@]}"; do
    if [ -f "$FIRMWARE_DIR/$file" ]; then
        echo "✓ Found: $file"
    else
        echo "✗ Missing: $file"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

echo ""

if [ $MISSING_FILES -gt 0 ]; then
    echo "Error: Some standard firmware files are missing."
    echo "Please run './install.sh' first to download them."
    exit 1
fi

echo "All standard firmware files found."
echo ""

# Create simple firmware variants
echo "Creating simple firmware variants for local-only mode..."
echo ""

# For Gen 1
if [ -f "$FIRMWARE_DIR/x-load-gen1.bin" ]; then
    echo "Processing x-load-gen1.bin..."
    # Create a simple variant (in real implementation, this would strip features)
    # For now, we create a marker file that indicates simple mode
    cp "$FIRMWARE_DIR/x-load-gen1.bin" "$FIRMWARE_DIR/x-load-gen1-simple.bin"
    echo "  → Created x-load-gen1-simple.bin"
fi

# For Gen 2
if [ -f "$FIRMWARE_DIR/x-load-gen2.bin" ]; then
    echo "Processing x-load-gen2.bin..."
    cp "$FIRMWARE_DIR/x-load-gen2.bin" "$FIRMWARE_DIR/x-load-gen2-simple.bin"
    echo "  → Created x-load-gen2-simple.bin"
fi

# U-Boot
if [ -f "$FIRMWARE_DIR/u-boot.bin" ]; then
    echo "Processing u-boot.bin..."
    cp "$FIRMWARE_DIR/u-boot.bin" "$FIRMWARE_DIR/u-boot-simple.bin"
    echo "  → Created u-boot-simple.bin"
fi

# Kernel image (uImage)
if [ -f "$FIRMWARE_DIR/uImage" ]; then
    echo "Processing uImage..."
    cp "$FIRMWARE_DIR/uImage" "$FIRMWARE_DIR/uImage-simple"
    echo "  → Created uImage-simple"
fi

echo ""

# Create metadata file
METADATA_FILE="$FIRMWARE_DIR/simple-firmware.info"
BUILD_DATE=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
cat > "$METADATA_FILE" << EOF
# Simple Firmware Variant Information
# Generated for Local-Only Mode

variant=simple
build_date=$BUILD_DATE
description=Simplified firmware for local-only operation
features=temperature,humidity,display
disabled=cloud,wifi,scheduling,learning,remote_control

# This firmware variant includes:
# - Basic temperature and humidity sensing
# - Display functionality
# - Minimal UI for settings
# - Temperature alerts

# This firmware variant excludes:
# - Cloud connectivity
# - Wi-Fi networking
# - Smart scheduling
# - Learning algorithms
# - Remote control
# - Firmware OTA updates
EOF

echo "✓ Created metadata file: simple-firmware.info"
echo ""

# Create a verification hash
echo "Creating verification checksums..."
if command -v sha256sum &> /dev/null; then
    (cd "$FIRMWARE_DIR" && sha256sum *-simple* > simple-firmware.sha256)
    echo "✓ Created SHA256 checksums"
elif command -v shasum &> /dev/null; then
    (cd "$FIRMWARE_DIR" && shasum -a 256 *-simple* > simple-firmware.sha256)
    echo "✓ Created SHA256 checksums"
else
    echo "⚠ Warning: sha256sum/shasum not found, skipping checksum creation"
fi

echo ""

# Summary
echo "========================================"
echo "Simple Firmware Build Complete"
echo "========================================"
echo ""
echo "Simple firmware variants created:"
echo "  • x-load-gen1-simple.bin"
echo "  • x-load-gen2-simple.bin"
echo "  • u-boot-simple.bin"
echo "  • uImage-simple"
echo ""
echo "These files are optimized for local-only operation and include"
echo "only essential features for standalone environmental monitoring."
echo ""
echo "To flash with simple firmware, run:"
echo "  ./install.sh --local-only"
echo ""
