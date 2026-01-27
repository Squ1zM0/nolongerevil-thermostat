#!/usr/bin/env bash
# Comprehensive integration test for local-only mode
# Tests all components without requiring actual hardware

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PASSED=0
FAILED=0
WARNINGS=0

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "========================================"
echo "Local-Only Mode Integration Test Suite"
echo "========================================"
echo ""

pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Test 1: Script Permissions
echo "Test 1: Checking script permissions..."
if [ -x "$SCRIPT_DIR/install.sh" ]; then
    pass "install.sh is executable"
else
    fail "install.sh is not executable"
fi

if [ -x "$SCRIPT_DIR/build.sh" ]; then
    pass "build.sh is executable"
else
    fail "build.sh is not executable"
fi

if [ -x "$SCRIPT_DIR/validate-local-mode.sh" ]; then
    pass "validate-local-mode.sh is executable"
else
    fail "validate-local-mode.sh is not executable"
fi

echo ""

# Test 2: Configuration File Validation
echo "Test 2: Validating configuration file..."
CONFIG_FILE="$SCRIPT_DIR/configs/local-only-mode.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    fail "Configuration file not found"
else
    pass "Configuration file exists"
    
    # Test critical settings
    if grep -q "operating_mode=local-only" "$CONFIG_FILE"; then
        pass "Operating mode correctly set to local-only"
    else
        fail "Operating mode not set to local-only"
    fi
    
    if grep -q "cloud_enabled=false" "$CONFIG_FILE"; then
        pass "Cloud connectivity disabled"
    else
        fail "Cloud connectivity not disabled"
    fi
    
    if grep -q "wifi_enabled=false" "$CONFIG_FILE"; then
        pass "Wi-Fi disabled"
    else
        fail "Wi-Fi not disabled"
    fi
    
    # Check display settings
    if grep -q "show_humidity=true" "$CONFIG_FILE"; then
        pass "Humidity display enabled"
    else
        warn "Humidity display not enabled"
    fi
    
    if grep -q "temperature_sensor=true" "$CONFIG_FILE"; then
        pass "Temperature sensor enabled"
    else
        fail "Temperature sensor not enabled"
    fi
    
    # Check safety features
    if grep -q "temp_alerts_enabled=true" "$CONFIG_FILE"; then
        pass "Temperature alerts enabled (safety feature)"
    else
        fail "Temperature alerts not enabled - SAFETY ISSUE"
    fi
fi

echo ""

# Test 3: Script Syntax Validation
echo "Test 3: Validating script syntax..."

validate_bash_syntax() {
    local script=$1
    local name=$2
    if bash -n "$script" 2>/dev/null; then
        pass "$name has valid syntax"
        return 0
    else
        fail "$name has syntax errors"
        return 1
    fi
}

validate_bash_syntax "$SCRIPT_DIR/install.sh" "install.sh"
validate_bash_syntax "$SCRIPT_DIR/build.sh" "build.sh"
validate_bash_syntax "$SCRIPT_DIR/validate-local-mode.sh" "validate-local-mode.sh"

echo ""

# Test 4: Command Line Argument Parsing
echo "Test 4: Testing command line argument parsing..."

# Test --help
if timeout 2 "$SCRIPT_DIR/install.sh" --help > /dev/null 2>&1; then
    pass "install.sh --help works"
else
    fail "install.sh --help failed"
fi

# Test that --local-only flag is recognized (will fail without deps, but should parse)
OUTPUT=$(timeout 5 "$SCRIPT_DIR/install.sh" --local-only 2>&1 <<< "1" || true)
if echo "$OUTPUT" | grep -q "LOCAL-ONLY" || echo "$OUTPUT" | grep -q "SIMPLE MODE"; then
    pass "install.sh --local-only flag recognized"
else
    fail "install.sh --local-only flag not recognized"
fi

# Test invalid argument handling
OUTPUT=$(timeout 2 "$SCRIPT_DIR/install.sh" --invalid-flag 2>&1 || true)
if echo "$OUTPUT" | grep -q "Unknown option"; then
    pass "Unknown options are properly rejected"
else
    fail "Unknown options not properly handled"
fi

echo ""

# Test 5: Documentation Completeness
echo "Test 5: Checking documentation..."

docs=("README.md" "LOCAL_MODE.md" "docs/FAQ.md" "configs/README.md")
for doc in "${docs[@]}"; do
    if [ -f "$SCRIPT_DIR/$doc" ]; then
        pass "$doc exists"
    else
        fail "$doc not found"
    fi
done

# Check for local-only references in README
if grep -q "local-only" "$SCRIPT_DIR/README.md" || grep -q "Local-Only" "$SCRIPT_DIR/README.md"; then
    pass "README.md documents local-only mode"
else
    fail "README.md doesn't document local-only mode"
fi

# Check LOCAL_MODE.md has essential sections
if grep -q "Installation" "$SCRIPT_DIR/LOCAL_MODE.md"; then
    pass "LOCAL_MODE.md has Installation section"
else
    warn "LOCAL_MODE.md missing Installation section"
fi

if grep -q "Configuration" "$SCRIPT_DIR/LOCAL_MODE.md"; then
    pass "LOCAL_MODE.md has Configuration section"
else
    warn "LOCAL_MODE.md missing Configuration section"
fi

echo ""

# Test 6: Directory Structure
echo "Test 6: Validating directory structure..."

required_dirs=("src" "configs" "docs" "patches")
for dir in "${required_dirs[@]}"; do
    if [ -d "$SCRIPT_DIR/$dir" ]; then
        pass "$dir/ directory exists"
    else
        fail "$dir/ directory missing"
    fi
done

echo ""

# Test 7: Source Code Integrity
echo "Test 7: Checking source code..."

if [ -d "$SCRIPT_DIR/src/omap_loader" ]; then
    pass "omap_loader source directory exists"
    
    if [ -f "$SCRIPT_DIR/src/omap_loader/omap_loader.c" ]; then
        pass "omap_loader.c exists"
    else
        fail "omap_loader.c not found"
    fi
    
    if [ -f "$SCRIPT_DIR/src/omap_loader/Makefile" ]; then
        pass "Makefile exists"
    else
        fail "Makefile not found"
    fi
else
    fail "omap_loader source directory not found"
fi

echo ""

# Test 8: Patch Files
echo "Test 8: Checking patch files..."

if [ -d "$SCRIPT_DIR/patches" ]; then
    pass "patches/ directory exists"
    
    if [ -f "$SCRIPT_DIR/patches/omap_loader_mac.patch" ]; then
        pass "macOS patch file exists"
        
        # Validate patch format
        if head -1 "$SCRIPT_DIR/patches/omap_loader_mac.patch" | grep -q "---"; then
            pass "Patch file has valid unified diff format"
        else
            warn "Patch file format may be invalid"
        fi
    else
        warn "macOS patch file not found"
    fi
else
    fail "patches/ directory not found"
fi

echo ""

# Test 9: .gitignore Configuration
echo "Test 9: Checking .gitignore..."

if [ -f "$SCRIPT_DIR/.gitignore" ]; then
    pass ".gitignore exists"
    
    # Check essential entries
    if grep -q "bin/" "$SCRIPT_DIR/.gitignore"; then
        pass "bin/ is ignored"
    else
        warn "bin/ not in .gitignore"
    fi
    
    if grep -q "*.bin" "$SCRIPT_DIR/.gitignore"; then
        pass "Binary files are ignored"
    else
        warn "Binary files not ignored"
    fi
    
    if grep -q "*.zip" "$SCRIPT_DIR/.gitignore"; then
        pass "Archive files are ignored"
    else
        warn "Archive files not ignored"
    fi
else
    fail ".gitignore not found"
fi

echo ""

# Test 10: Build System
echo "Test 10: Testing build system (dry-run)..."

# Check if build.sh properly detects OS
BUILD_OUTPUT=$("$SCRIPT_DIR/build.sh" 2>&1 || true)
if echo "$BUILD_OUTPUT" | grep -q "Detected OS:"; then
    pass "build.sh detects operating system"
else
    fail "build.sh doesn't detect OS"
fi

if echo "$BUILD_OUTPUT" | grep -q "Detected Architecture:"; then
    pass "build.sh detects architecture"
else
    fail "build.sh doesn't detect architecture"
fi

echo ""

# Test 11: Error Handling
echo "Test 11: Testing error handling..."

# Test install.sh behavior when omap_loader is missing
INSTALL_OUTPUT=$("$SCRIPT_DIR/install.sh" --local-only 2>&1 || true)
if echo "$INSTALL_OUTPUT" | grep -q "omap_loader binary not found" || echo "$INSTALL_OUTPUT" | grep -q "build.sh"; then
    pass "install.sh properly handles missing binary"
else
    warn "Missing binary error handling may need improvement"
fi

echo ""

# Test 12: Configuration Validation
echo "Test 12: Advanced configuration validation..."

# Validate all sections exist
sections=("[mode]" "[display]" "[sensors]" "[features]" "[network]" "[power]" "[ui]" "[logging]" "[safety]")
for section in "${sections[@]}"; do
    if grep -q "$section" "$CONFIG_FILE"; then
        pass "Configuration has $section section"
    else
        fail "Configuration missing $section section"
    fi
done

echo ""

# Test 13: Safety Settings
echo "Test 13: Validating safety settings..."

# Check temperature alert thresholds
if grep -q "high_temp_alert=90" "$CONFIG_FILE"; then
    pass "High temperature alert set (90°F)"
else
    warn "High temperature alert threshold not configured"
fi

if grep -q "low_temp_alert=40" "$CONFIG_FILE"; then
    pass "Low temperature alert set (40°F)"
else
    warn "Low temperature alert threshold not configured"
fi

echo ""

# Test 14: Feature Flags
echo "Test 14: Verifying feature flags..."

# Ensure smart features are disabled
disabled_features=("scheduling=false" "learning=false" "auto_away=false" "remote_control=false" "firmware_updates=false")
for feature in "${disabled_features[@]}"; do
    if grep -q "$feature" "$CONFIG_FILE"; then
        pass "Feature disabled: $feature"
    else
        warn "Feature flag not set: $feature"
    fi
done

echo ""

# Test 15: Logging Configuration
echo "Test 15: Checking logging configuration..."

if grep -q "logging_enabled=true" "$CONFIG_FILE"; then
    pass "Logging enabled"
else
    warn "Logging not enabled"
fi

if grep -q "log_level=info" "$CONFIG_FILE"; then
    pass "Log level set to info"
else
    warn "Log level not configured"
fi

echo ""

# Summary
echo "========================================"
echo "Test Summary"
echo "========================================"
echo -e "${GREEN}Passed:${NC}   $PASSED tests"
echo -e "${RED}Failed:${NC}   $FAILED tests"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS issues"
echo ""

# Calculate success rate
TOTAL=$((PASSED + FAILED))
if [ $TOTAL -gt 0 ]; then
    SUCCESS_RATE=$((PASSED * 100 / TOTAL))
    echo "Success Rate: $SUCCESS_RATE%"
    echo ""
fi

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All critical tests passed!${NC}"
    echo ""
    echo "Local-only mode is ready for use."
    echo "Run './install.sh --local-only' to flash your device."
    echo ""
    exit 0
else
    echo -e "${RED}✗ Some tests failed!${NC}"
    echo ""
    echo "Please review and fix the failed tests before deploying."
    echo ""
    exit 1
fi
