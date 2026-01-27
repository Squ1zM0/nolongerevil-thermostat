# NoLongerEvil Quick-Start Script for Windows
# Helps users choose the right firmware for their needs

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Clear-Host

Write-Host ""
Write-Host "+===================================================================+"
Write-Host "|                                                                   |"
Write-Host "|         NoLongerEvil Thermostat - Easy Setup Wizard              |"
Write-Host "|                                                                   |"
Write-Host "+===================================================================+"
Write-Host ""

# Step 1: Welcome and info
Write-Host "Welcome! This wizard will help you set up your Nest Thermostat."
Write-Host ""
Write-Host "We'll ask you a few simple questions to find the best setup for you."
Write-Host ""

# Step 2: Ask about use case
Write-Host "========================================="
Write-Host "Question 1: What do you want to do?"
Write-Host "========================================="
Write-Host ""
Write-Host "A) Just display temperature and humidity (NOT a working thermostat)"
Write-Host "B) Actually control my heating and cooling (working thermostat)"
Write-Host ""

do {
    $UseCase = (Read-Host "Choose A or B").ToUpper()
} while ($UseCase -notmatch '^[AB]$')

Write-Host ""

# Step 3: Ask about connectivity
$InstallMode = "standard"

if ($UseCase -eq "B") {
    $InstallMode = "standard"
} else {
    Write-Host "========================================="
    Write-Host "Question 2: Do you have Wi-Fi at home?"
    Write-Host "========================================="
    Write-Host ""
    
    do {
        $HasWifi = (Read-Host "Choose Y or N").ToUpper()
    } while ($HasWifi -notmatch '^[YN]$')
    
    Write-Host ""
    
    if ($HasWifi -eq "N") {
        $InstallMode = "local-only"
    } else {
        Write-Host "========================================="
        Write-Host "Question 3: How do you feel about privacy?"
        Write-Host "========================================="
        Write-Host ""
        Write-Host "A) I want maximum privacy (no internet connection, stays offline)"
        Write-Host "B) I'm comfortable connecting to get extra features"
        Write-Host ""
        
        do {
            $Privacy = (Read-Host "Choose A or B").ToUpper()
        } while ($Privacy -notmatch '^[AB]$')
        
        if ($Privacy -eq "A") {
            $InstallMode = "local-only"
        } else {
            $InstallMode = "standard"
        }
    }
}

Write-Host ""
Write-Host "========================================="
Write-Host "Recommendation"
Write-Host "========================================="
Write-Host ""

if ($InstallMode -eq "local-only") {
    Write-Host "[*] DISPLAY-ONLY MODE is perfect for you!"
    Write-Host ""
    Write-Host "WARNING: This is NOT a working thermostat!"
    Write-Host ""
    Write-Host "What you'll get:"
    Write-Host "  [+] Temperature & humidity display"
    Write-Host "  [+] Works without Wi-Fi or internet"
    Write-Host "  [+] Completely private (no data sent anywhere)"
    Write-Host "  [+] Uses less battery power"
    Write-Host ""
    Write-Host "What you WON'T get:"
    Write-Host "  [-] NO heating/cooling control"
    Write-Host "  [-] NO thermostat functions at all"
    Write-Host "  [-] NO phone app or remote access"
    Write-Host "  [-] NO schedules or timers"
    Write-Host ""
    Write-Host "Think of it as a wall-mounted temperature sensor, not a thermostat."
    Write-Host ""
    
    $Confirm = Read-Host "Install DISPLAY-ONLY MODE (monitor only, NOT a thermostat)? (Y/n)"
} else {
    Write-Host "[*] FULL THERMOSTAT MODE is perfect for you!"
    Write-Host ""
    Write-Host "What you'll get:"
    Write-Host "  [+] Full heating and cooling control"
    Write-Host "  [+] Access from your phone or computer"
    Write-Host "  [+] Set schedules and timers"
    Write-Host "  [+] Save energy with smart features"
    Write-Host "  [+] Works from anywhere with internet"
    Write-Host ""
    Write-Host "What you'll need:"
    Write-Host "  * Wi-Fi network at home"
    Write-Host "  * Internet connection"
    Write-Host "  * Free account at nolongerevil.com"
    Write-Host ""
    Write-Host "This is a fully working smart thermostat!"
    Write-Host ""
    
    $Confirm = Read-Host "Install FULL THERMOSTAT MODE? (Y/n)"
}

$Confirm = $Confirm.ToUpper()

if ($Confirm -notmatch '^[Yy]?$') {
    Write-Host ""
    Write-Host "No problem! Setup cancelled."
    Write-Host ""
    Write-Host "You can start over anytime by running:"
    Write-Host "  .\quick-start.ps1"
    Write-Host ""
    Write-Host "Or if you know what you want:"
    Write-Host "  .\install.ps1 -LocalOnly    (for Display-Only Mode - monitor only)"
    Write-Host "  .\install.ps1 -Standard     (for Full Thermostat Mode)"
    exit 0
}

Write-Host ""
Write-Host "========================================="
Write-Host "Great! Let's get started..."
Write-Host "========================================="
Write-Host ""

# Run the appropriate installation
$InstallScript = Join-Path $ScriptDir "install.ps1"

if ($InstallMode -eq "local-only") {
    Write-Host "Setting up DISPLAY-ONLY MODE (temperature monitor)..."
    Write-Host ""
    & $InstallScript -LocalOnly
} else {
    Write-Host "Setting up FULL THERMOSTAT MODE..."
    Write-Host ""
    & $InstallScript -Standard
}
