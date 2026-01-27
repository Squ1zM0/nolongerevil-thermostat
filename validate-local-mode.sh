#!/usr/bin/env bash
# Validation script for local-only mode setup
# This script checks that all necessary files and configurations are in place

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PASSED=0
FAILED=0

echo "========================================"
echo "Local-Only Mode Validation Script"
echo "========================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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
}

# Test 1: Check install.sh exists and is executable
echo "Checking installation script..."
if [ -f "$SCRIPT_DIR/install.sh" ]; then
    if [ -x "$SCRIPT_DIR/install.sh" ]; then
        pass "install.sh exists and is executable"
    else
        fail "install.sh exists but is not executable (run: chmod +x install.sh)"
    fi
else
    fail "install.sh not found"
fi

# Test 2: Check build.sh exists and is executable
echo "Checking build script..."
if [ -f "$SCRIPT_DIR/build.sh" ]; then
    if [ -x "$SCRIPT_DIR/build.sh" ]; then
        pass "build.sh exists and is executable"
    else
        fail "build.sh exists but is not executable (run: chmod +x build.sh)"
    fi
else
    fail "build.sh not found"
fi

# Test 3: Check configuration directory and files
echo "Checking configuration files..."
if [ -d "$SCRIPT_DIR/configs" ]; then
    pass "configs/ directory exists"
    
    if [ -f "$SCRIPT_DIR/configs/local-only-mode.conf" ]; then
        pass "local-only-mode.conf exists"
        
        # Validate config file format
        if grep -q "\[mode\]" "$SCRIPT_DIR/configs/local-only-mode.conf"; then
            pass "Configuration file has valid format"
        else
            fail "Configuration file format appears invalid"
        fi
    else
        fail "local-only-mode.conf not found"
    fi
    
    if [ -f "$SCRIPT_DIR/configs/README.md" ]; then
        pass "configs/README.md exists"
    else
        warn "configs/README.md not found (documentation)"
    fi
else
    fail "configs/ directory not found"
fi

# Test 4: Check documentation
echo "Checking documentation..."
if [ -f "$SCRIPT_DIR/LOCAL_MODE.md" ]; then
    pass "LOCAL_MODE.md exists"
else
    fail "LOCAL_MODE.md not found"
fi

if [ -f "$SCRIPT_DIR/README.md" ]; then
    pass "README.md exists"
    
    # Check if README mentions local-only mode
    if grep -q "local-only" "$SCRIPT_DIR/README.md" || grep -q "Local-Only" "$SCRIPT_DIR/README.md"; then
        pass "README.md mentions local-only mode"
    else
        warn "README.md doesn't mention local-only mode"
    fi
else
    fail "README.md not found"
fi

if [ -d "$SCRIPT_DIR/docs" ]; then
    pass "docs/ directory exists"
    
    if [ -f "$SCRIPT_DIR/docs/FAQ.md" ]; then
        pass "FAQ.md exists"
    else
        warn "docs/FAQ.md not found"
    fi
    
    if [ -f "$SCRIPT_DIR/docs/UI_MOCKUP.md" ]; then
        pass "UI_MOCKUP.md exists"
    else
        warn "docs/UI_MOCKUP.md not found"
    fi
else
    warn "docs/ directory not found"
fi

# Test 5: Check install.sh supports --local-only flag
echo "Checking install.sh features..."
if grep -q "local-only" "$SCRIPT_DIR/install.sh"; then
    pass "install.sh supports --local-only flag"
else
    fail "install.sh doesn't support --local-only flag"
fi

if grep -q "LOCAL_ONLY_MODE" "$SCRIPT_DIR/install.sh"; then
    pass "install.sh has LOCAL_ONLY_MODE variable"
else
    fail "install.sh missing LOCAL_ONLY_MODE variable"
fi

# Test 6: Verify --help works
echo "Testing install.sh --help..."
if "$SCRIPT_DIR/install.sh" --help > /dev/null 2>&1; then
    pass "install.sh --help executes successfully"
else
    fail "install.sh --help failed"
fi

# Test 7: Check bash syntax
echo "Checking script syntax..."
if bash -n "$SCRIPT_DIR/install.sh" 2>/dev/null; then
    pass "install.sh has valid bash syntax"
else
    fail "install.sh has syntax errors"
fi

if bash -n "$SCRIPT_DIR/build.sh" 2>/dev/null; then
    pass "build.sh has valid bash syntax"
else
    fail "build.sh has syntax errors"
fi

# Test 8: Check for required directories
echo "Checking directory structure..."
if [ -d "$SCRIPT_DIR/src" ]; then
    pass "src/ directory exists"
else
    fail "src/ directory not found"
fi

if [ -d "$SCRIPT_DIR/patches" ]; then
    pass "patches/ directory exists"
else
    warn "patches/ directory not found"
fi

# Test 9: Verify configuration values
echo "Validating configuration values..."
CONFIG_FILE="$SCRIPT_DIR/configs/local-only-mode.conf"
if [ -f "$CONFIG_FILE" ]; then
    # Check essential configuration values
    if grep -q "operating_mode=local-only" "$CONFIG_FILE"; then
        pass "Operating mode set to local-only"
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
    
    if grep -q "temperature_unit=fahrenheit" "$CONFIG_FILE"; then
        pass "Temperature unit set to Fahrenheit"
    else
        warn "Temperature unit not set to Fahrenheit (may be intentional)"
    fi
    
    if grep -q "show_humidity=true" "$CONFIG_FILE"; then
        pass "Humidity display enabled"
    else
        warn "Humidity display not enabled"
    fi
fi

# Test 10: Check .gitignore
echo "Checking .gitignore..."
if [ -f "$SCRIPT_DIR/.gitignore" ]; then
    pass ".gitignore exists"
    
    # Check that binary directories are ignored
    if grep -q "bin/" "$SCRIPT_DIR/.gitignore"; then
        pass "bin/ directory is gitignored"
    else
        warn "bin/ directory not in .gitignore"
    fi
else
    warn ".gitignore not found"
fi

# Summary
echo ""
echo "========================================"
echo "Validation Summary"
echo "========================================"
echo -e "${GREEN}Passed:${NC} $PASSED tests"
echo -e "${RED}Failed:${NC} $FAILED tests"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All critical tests passed!${NC}"
    echo ""
    echo "Local-only mode setup is complete and ready to use."
    echo "Run './install.sh --local-only' to install with local-only mode."
    exit 0
else
    echo -e "${RED}✗ Some tests failed!${NC}"
    echo ""
    echo "Please fix the failed tests before proceeding."
    echo "Review the errors above for details."
    exit 1
fi
