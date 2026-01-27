#!/usr/bin/env bash
# Final validation script for local-only mode complete functionality
# Tests all components are ready for end-user deployment

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PASSED=0
FAILED=0

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                                                                   ║"
echo "║         Final Validation - Local-Only Mode                       ║"
echo "║                                                                   ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""

pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

# Test 1: Core Scripts Exist
echo "Test 1: Checking core installation scripts..."
for script in "install.sh" "build.sh" "quick-start.sh"; do
    if [ -f "$SCRIPT_DIR/$script" ] && [ -x "$SCRIPT_DIR/$script" ]; then
        pass "$script exists and is executable"
    else
        fail "$script missing or not executable"
    fi
done
echo ""

# Test 2: Helper Scripts Exist
echo "Test 2: Checking helper scripts..."
for script in "flash-local-mode.sh" "build-simple-firmware.sh" "verify-simple-firmware.sh" "validate-local-mode.sh"; do
    if [ -f "$SCRIPT_DIR/$script" ] && [ -x "$SCRIPT_DIR/$script" ]; then
        pass "$script exists and is executable"
    else
        fail "$script missing or not executable"
    fi
done
echo ""

# Test 3: Configuration Files
echo "Test 3: Checking configuration files..."
if [ -f "$SCRIPT_DIR/configs/local-only-mode.conf" ]; then
    pass "local-only-mode.conf exists"
    
    # Check critical settings
    if grep -q "operating_mode=local-only" "$SCRIPT_DIR/configs/local-only-mode.conf"; then
        pass "Operating mode correctly configured"
    else
        fail "Operating mode not set correctly"
    fi
else
    fail "Configuration file missing"
fi
echo ""

# Test 4: Documentation
echo "Test 4: Checking documentation..."
for doc in "README.md" "LOCAL_MODE.md" "docs/FAQ.md"; do
    if [ -f "$SCRIPT_DIR/$doc" ]; then
        pass "$doc exists"
    else
        fail "$doc missing"
    fi
done
echo ""

# Test 5: User-Friendly Language
echo "Test 5: Verifying user-friendly language..."
if grep -q "SIMPLE MODE" "$SCRIPT_DIR/install.sh"; then
    pass "install.sh uses user-friendly 'SIMPLE MODE'"
else
    fail "install.sh doesn't use user-friendly language"
fi

if grep -q "Easy Setup Wizard" "$SCRIPT_DIR/quick-start.sh"; then
    pass "quick-start.sh has user-friendly title"
else
    fail "quick-start.sh doesn't have user-friendly title"
fi
echo ""

# Test 6: Command-Line Options
echo "Test 6: Testing command-line options..."
if timeout 2 "$SCRIPT_DIR/install.sh" --help >/dev/null 2>&1; then
    pass "install.sh --help works"
else
    fail "install.sh --help doesn't work"
fi

if "$SCRIPT_DIR/install.sh" --help 2>&1 | grep -q "local-only"; then
    pass "install.sh --help mentions --local-only option"
else
    fail "install.sh --help doesn't document --local-only"
fi

if "$SCRIPT_DIR/install.sh" --help 2>&1 | grep -q "standard"; then
    pass "install.sh --help mentions --standard option"
else
    fail "install.sh --help doesn't document --standard"
fi
echo ""

# Test 7: Simple Firmware Support
echo "Test 7: Checking simple firmware support..."
if grep -q "simple" "$SCRIPT_DIR/install.sh"; then
    pass "install.sh has simple firmware support"
else
    fail "install.sh missing simple firmware support"
fi

if grep -q "x-load-gen.*-simple.bin" "$SCRIPT_DIR/install.sh"; then
    pass "install.sh looks for simple firmware variants"
else
    fail "install.sh doesn't check for simple firmware"
fi
echo ""

# Test 8: Interactive Mode Selection
echo "Test 8: Testing interactive mode selection..."
if grep -q "Which setup do you want?" "$SCRIPT_DIR/install.sh"; then
    pass "install.sh has interactive mode selection"
else
    fail "install.sh missing interactive mode selection"
fi

if echo -e "1\nn" | timeout 5 "$SCRIPT_DIR/install.sh" 2>&1 | grep -q "SIMPLE MODE"; then
    pass "Interactive mode selection works (option 1)"
else
    fail "Interactive mode selection doesn't work properly"
fi
echo ""

# Test 9: Syntax Validation
echo "Test 9: Validating script syntax..."
for script in install.sh build.sh quick-start.sh flash-local-mode.sh build-simple-firmware.sh verify-simple-firmware.sh; do
    if bash -n "$SCRIPT_DIR/$script" 2>/dev/null; then
        pass "$script has valid syntax"
    else
        fail "$script has syntax errors"
    fi
done
echo ""

# Test 10: End-User Documentation
echo "Test 10: Checking end-user documentation..."
if grep -q "Just see the temperature" "$SCRIPT_DIR/quick-start.sh"; then
    pass "quick-start.sh uses simple language"
else
    fail "quick-start.sh uses technical language"
fi

if grep -q "digital thermometer" "$SCRIPT_DIR/install.sh"; then
    pass "install.sh uses relatable analogies"
else
    fail "install.sh doesn't use helpful analogies"
fi
echo ""

# Summary
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                                                                   ║"
echo "║                     Validation Summary                            ║"
echo "║                                                                   ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}Passed:${NC} $PASSED tests"
echo -e "${RED}Failed:${NC} $FAILED tests"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                                   ║${NC}"
    echo -e "${GREEN}║  ✓✓✓  ALL TESTS PASSED - READY FOR DEPLOYMENT  ✓✓✓              ║${NC}"
    echo -e "${GREEN}║                                                                   ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Local-Only Mode is fully functional and ready for end users!"
    echo ""
    echo "End users can now:"
    echo "  1. Run ./quick-start.sh for guided setup"
    echo "  2. Run ./install.sh for direct installation with choices"
    echo "  3. Run ./install.sh --local-only for simple mode"
    echo "  4. Run ./install.sh --standard for full features"
    echo ""
    exit 0
else
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                                                                   ║${NC}"
    echo -e "${RED}║  ✗✗✗  SOME TESTS FAILED - REVIEW REQUIRED  ✗✗✗                  ║${NC}"
    echo -e "${RED}║                                                                   ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Please fix the failed tests before deployment."
    exit 1
fi
