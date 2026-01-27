#!/usr/bin/env bash
# Verify that simple firmware variant is being used for local-only mode
# This script checks firmware integrity and variant type

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
FIRMWARE_DIR="$SCRIPT_DIR/bin/firmware"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "========================================"
echo "Simple Firmware Verification"
echo "========================================"
echo ""

# Check if firmware directory exists
if [ ! -d "$FIRMWARE_DIR" ]; then
    echo -e "${RED}✗ Firmware directory not found${NC}"
    echo ""
    echo "Run './install.sh --local-only' to download and prepare firmware."
    exit 1
fi

# Check for simple firmware variants
echo "Checking for simple firmware variants..."
echo ""

SIMPLE_FILES=(
    "x-load-gen1-simple.bin"
    "x-load-gen2-simple.bin"
    "u-boot-simple.bin"
    "uImage-simple"
)

FOUND=0
MISSING=0

for file in "${SIMPLE_FILES[@]}"; do
    if [ -f "$FIRMWARE_DIR/$file" ]; then
        echo -e "${GREEN}✓${NC} Found: $file"
        FOUND=$((FOUND + 1))
    else
        echo -e "${RED}✗${NC} Missing: $file"
        MISSING=$((MISSING + 1))
    fi
done

echo ""

# Check for metadata
if [ -f "$FIRMWARE_DIR/simple-firmware.info" ]; then
    echo -e "${GREEN}✓${NC} Found: simple-firmware.info"
    echo ""
    echo "Firmware variant information:"
    grep "^variant=" "$FIRMWARE_DIR/simple-firmware.info" || true
    grep "^description=" "$FIRMWARE_DIR/simple-firmware.info" || true
    grep "^features=" "$FIRMWARE_DIR/simple-firmware.info" || true
    grep "^disabled=" "$FIRMWARE_DIR/simple-firmware.info" || true
    echo ""
else
    echo -e "${YELLOW}⚠${NC} Metadata file not found"
    echo ""
fi

# Verify checksums if available
if [ -f "$FIRMWARE_DIR/simple-firmware.sha256" ]; then
    echo "Verifying checksums..."
    if command -v sha256sum &> /dev/null; then
        if (cd "$FIRMWARE_DIR" && sha256sum -c simple-firmware.sha256 2>/dev/null); then
            echo -e "${GREEN}✓${NC} All checksums verified"
        else
            echo -e "${RED}✗${NC} Checksum verification failed"
            echo "Firmware files may be corrupted. Run './build-simple-firmware.sh' to rebuild."
        fi
    elif command -v shasum &> /dev/null; then
        if (cd "$FIRMWARE_DIR" && shasum -a 256 -c simple-firmware.sha256 2>/dev/null); then
            echo -e "${GREEN}✓${NC} All checksums verified"
        else
            echo -e "${RED}✗${NC} Checksum verification failed"
            echo "Firmware files may be corrupted. Run './build-simple-firmware.sh' to rebuild."
        fi
    else
        echo -e "${YELLOW}⚠${NC} Cannot verify checksums (sha256sum/shasum not found)"
    fi
    echo ""
fi

# Compare with standard firmware
echo "Comparing with standard firmware..."
echo ""

STANDARD_FILES=(
    "x-load-gen1.bin"
    "x-load-gen2.bin"
    "u-boot.bin"
    "uImage"
)

STD_FOUND=0
for file in "${STANDARD_FILES[@]}"; do
    if [ -f "$FIRMWARE_DIR/$file" ]; then
        STD_FOUND=$((STD_FOUND + 1))
    fi
done

if [ $STD_FOUND -eq ${#STANDARD_FILES[@]} ]; then
    echo -e "${GREEN}✓${NC} Standard firmware files also present"
    echo ""
    
    # Show size comparison
    echo "Size comparison (Standard vs Simple):"
    echo ""
    
    for i in "${!STANDARD_FILES[@]}"; do
        std_file="${STANDARD_FILES[$i]}"
        simple_file="${SIMPLE_FILES[$i]}"
        
        if [ -f "$FIRMWARE_DIR/$std_file" ] && [ -f "$FIRMWARE_DIR/$simple_file" ]; then
            std_size=$(stat -c%s "$FIRMWARE_DIR/$std_file" 2>/dev/null || stat -f%z "$FIRMWARE_DIR/$std_file" 2>/dev/null || echo "0")
            simple_size=$(stat -c%s "$FIRMWARE_DIR/$simple_file" 2>/dev/null || stat -f%z "$FIRMWARE_DIR/$simple_file" 2>/dev/null || echo "0")
            
            printf "  %-30s %10d bytes → %10d bytes\n" "$std_file:" "$std_size" "$simple_size"
        fi
    done
    echo ""
else
    echo -e "${YELLOW}⚠${NC} Standard firmware files not found"
    echo ""
fi

# Summary
echo "========================================"
echo "Verification Summary"
echo "========================================"
echo ""

if [ $MISSING -eq 0 ]; then
    echo -e "${GREEN}✓ All simple firmware files present${NC}"
    echo ""
    echo "Simple firmware variant is ready for local-only mode."
    echo "These firmware files are optimized for standalone operation."
    echo ""
    echo "To flash your device, run:"
    echo "  ./install.sh --local-only"
    echo ""
    exit 0
else
    echo -e "${YELLOW}⚠ Some simple firmware files are missing${NC}"
    echo ""
    echo "Found: $FOUND / ${#SIMPLE_FILES[@]} files"
    echo ""
    echo "To build simple firmware, run:"
    echo "  ./build-simple-firmware.sh"
    echo ""
    exit 1
fi
