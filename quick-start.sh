#!/usr/bin/env bash
# Quick-start script for easy firmware installation
# Helps users choose the right firmware for their needs

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

clear

echo ""
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                                                                   ║"
echo "║         NoLongerEvil Thermostat - Easy Setup Wizard              ║"
echo "║                                                                   ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Welcome and info
echo -e "${CYAN}Welcome!${NC} This wizard will help you set up your Nest Thermostat."
echo ""
echo "We'll ask you a few simple questions to find the best setup for you."
echo ""

# Step 2: Ask about use case
echo "========================================="
echo "Question 1: What do you want to do?"
echo "========================================="
echo ""
echo "A) Just see the temperature and humidity on the display"
echo "B) Control my heating/cooling and access from my phone"
echo ""
read -p "Choose A or B: " USE_CASE

USE_CASE=$(echo "$USE_CASE" | tr '[:lower:]' '[:upper:]')

while [[ ! "$USE_CASE" =~ ^[AB]$ ]]; do
    echo "Invalid input. Please enter A or B."
    read -p "Enter A or B: " USE_CASE
    USE_CASE=$(echo "$USE_CASE" | tr '[:lower:]' '[:upper:]')
done

echo ""

# Step 3: Ask about connectivity
if [ "$USE_CASE" = "B" ]; then
    INSTALL_MODE="standard"
else
    echo "========================================="
    echo "Question 2: Do you have Wi-Fi at home?"
    echo "========================================="
    echo ""
    read -p "Choose Y or N: " HAS_WIFI
    
    HAS_WIFI=$(echo "$HAS_WIFI" | tr '[:lower:]' '[:upper:]')
    
    while [[ ! "$HAS_WIFI" =~ ^[YN]$ ]]; do
        echo "Invalid input. Please enter Y or N."
        read -p "Enter Y or N: " HAS_WIFI
        HAS_WIFI=$(echo "$HAS_WIFI" | tr '[:lower:]' '[:upper:]')
    done
    
    echo ""
    
    if [ "$HAS_WIFI" = "N" ]; then
        INSTALL_MODE="local-only"
    else
        echo "========================================="
        echo "Question 3: How do you feel about privacy?"
        echo "========================================="
        echo ""
        echo "A) I want maximum privacy (no internet connection, stays offline)"
        echo "B) I'm comfortable connecting to get extra features"
        echo ""
        read -p "Choose A or B: " PRIVACY
        
        PRIVACY=$(echo "$PRIVACY" | tr '[:lower:]' '[:upper:]')
        
        while [[ ! "$PRIVACY" =~ ^[AB]$ ]]; do
            echo "Invalid input. Please enter A or B."
            read -p "Enter A or B: " PRIVACY
            PRIVACY=$(echo "$PRIVACY" | tr '[:lower:]' '[:upper:]')
        done
        
        if [ "$PRIVACY" = "A" ]; then
            INSTALL_MODE="local-only"
        else
            INSTALL_MODE="standard"
        fi
    fi
fi

echo ""
echo "========================================="
echo "Recommendation"
echo "========================================="
echo ""

if [ "$INSTALL_MODE" = "local-only" ]; then
    echo -e "${GREEN}► SIMPLE MODE${NC} is perfect for you!"
    echo ""
    echo "Based on your answers, you'll get:"
    echo "  ✓ Easy-to-read temperature & humidity display"
    echo "  ✓ Works without Wi-Fi or internet"
    echo "  ✓ Completely private (no data sent anywhere)"
    echo "  ✓ Uses less battery power"
    echo "  ✓ Super simple - just works!"
    echo ""
    echo "What you won't get:"
    echo "  ✗ Can't control heating/cooling"
    echo "  ✗ No phone app or remote access"
    echo "  ✗ No schedules or timers"
    echo ""
    echo "Think of it like a digital thermometer that sits on your wall."
    echo ""
    
    read -p "Install SIMPLE MODE? (Y/n): " CONFIRM
else
    echo -e "${BLUE}► FULL FEATURES MODE${NC} is perfect for you!"
    echo ""
    echo "Based on your answers, you'll get:"
    echo "  ✓ Control your heating and cooling"
    echo "  ✓ Access from your phone or computer"
    echo "  ✓ Set schedules and timers"
    echo "  ✓ Save energy with smart features"
    echo "  ✓ Works from anywhere with internet"
    echo ""
    echo "What you'll need:"
    echo "  • Wi-Fi network at home"
    echo "  • Internet connection"
    echo "  • Free account at nolongerevil.com"
    echo ""
    echo "Think of it like making your old Nest smart again!"
    echo ""
    
    read -p "Install FULL FEATURES MODE? (Y/n): " CONFIRM
fi

CONFIRM=$(echo "$CONFIRM" | tr '[:lower:]' '[:upper:]')

if [[ "$CONFIRM" =~ ^N ]]; then
    echo ""
    echo "No problem! Setup cancelled."
    echo ""
    echo "You can start over anytime by running:"
    echo "  ./quick-start.sh"
    echo ""
    echo "Or if you know what you want:"
    echo "  ./install.sh --local-only    (for Simple Mode)"
    echo "  ./install.sh --standard      (for Full Features Mode)"
    exit 0
fi

echo ""
echo "========================================="
echo "Great! Let's get started..."
echo "========================================="
echo ""

# Make sure install.sh is executable
chmod +x "$SCRIPT_DIR/install.sh"

# Run the appropriate installation
if [ "$INSTALL_MODE" = "local-only" ]; then
    echo "Setting up SIMPLE MODE..."
    echo ""
    "$SCRIPT_DIR/install.sh" --local-only
else
    echo "Setting up FULL FEATURES MODE..."
    echo ""
    "$SCRIPT_DIR/install.sh" --standard
fi
