# NoLongerEvil Firmware Installer for Windows
# Auto-detect platform and install firmware to OMAP device

param(
    [switch]$LocalOnly,
    [switch]$Standard,
    [switch]$ForceDownload,
    [switch]$Help
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Show help
if ($Help) {
    Write-Host "Usage: .\install.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -LocalOnly       Install Display-Only Mode (monitor only, NOT a thermostat)"
    Write-Host "  -Standard        Install Full Thermostat Mode (working thermostat)"
    Write-Host "  -ForceDownload   Force re-download of firmware files"
    Write-Host "  -Help            Show this help message"
    Write-Host ""
    Write-Host "If no mode is specified, you will be prompted to choose interactively."
    Write-Host ""
    Write-Host "Display-Only Mode:"
    Write-Host "  Warning: NOT A THERMOSTAT - Temperature/humidity monitor ONLY"
    Write-Host "  Shows temperature and humidity on display. Does NOT control heating/cooling."
    Write-Host "  No cloud, Wi-Fi, or smart features. Perfect for offline monitoring."
    Write-Host ""
    Write-Host "Full Thermostat Mode:"
    Write-Host "  Full working thermostat with cloud connectivity, remote control, scheduling,"
    Write-Host "  and integration with nolongerevil.com platform."
    Write-Host ""
    Write-Host "See LOCAL_MODE.md for detailed comparison."
    exit 0
}

# Detect architecture
$Arch = if ([Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }

Write-Host "========================================="
Write-Host "NoLongerEvil Firmware Installer"
Write-Host "========================================="
Write-Host "Detected OS: Windows"
Write-Host "Detected Architecture: $Arch"
Write-Host ""

# Interactive mode selection if not specified via command line
$LocalOnlyMode = $LocalOnly
$StandardMode = $Standard

if (-not $LocalOnlyMode -and -not $StandardMode) {
    Write-Host "========================================="
    Write-Host "Which setup do you want?"
    Write-Host "========================================="
    Write-Host ""
    Write-Host "+---------------------------------------------------------------------+"
    Write-Host "| 1. DISPLAY-ONLY MODE (Temperature Monitor)                         |"
    Write-Host "|    [+] Shows temperature & humidity on the display                 |"
    Write-Host "|    [+] Works without Wi-Fi or internet                             |"
    Write-Host "|    [+] Completely private (no data sent anywhere)                  |"
    Write-Host "|    [+] Uses less battery                                           |"
    Write-Host "|    [-] DOES NOT control heating or cooling                         |"
    Write-Host "|    [-] No thermostat functions at all                              |"
    Write-Host "|                                                                     |"
    Write-Host "|    Just a display - NOT a working thermostat                       |"
    Write-Host "+---------------------------------------------------------------------+"
    Write-Host ""
    Write-Host "+---------------------------------------------------------------------+"
    Write-Host "| 2. FULL THERMOSTAT MODE (Smart Control)                            |"
    Write-Host "|    [+] Control your heating and cooling                            |"
    Write-Host "|    [+] Access from your phone or computer                          |"
    Write-Host "|    [+] Set schedules to save energy                                |"
    Write-Host "|    [+] Works from anywhere with internet                           |"
    Write-Host "|    [-] Needs Wi-Fi and internet                                    |"
    Write-Host "|    [-] Needs free account at nolongerevil.com                      |"
    Write-Host "|                                                                     |"
    Write-Host "|    Full working thermostat with smart features                     |"
    Write-Host "+---------------------------------------------------------------------+"
    Write-Host ""
    
    do {
        $ModeChoice = Read-Host "Choose 1 or 2"
    } while ($ModeChoice -notmatch '^[12]$')
    
    Write-Host ""
    
    if ($ModeChoice -eq "1") {
        $LocalOnlyMode = $true
        Write-Host "[+] You chose: DISPLAY-ONLY MODE"
    } else {
        $StandardMode = $true
        Write-Host "[+] You chose: FULL THERMOSTAT MODE"
    }
    
    Write-Host ""
    
    # Confirmation
    if ($LocalOnlyMode) {
        Write-Host "WARNING: Your device will ONLY show temperature/humidity."
        Write-Host "         It will NOT control heating or cooling at all."
        Write-Host ""
        $Confirm = Read-Host "Do you understand this is display-only, not a thermostat? (y/n)"
    } else {
        Write-Host "Your device will work as a full thermostat with smart features."
        Write-Host ""
        $Confirm = Read-Host "Ready to continue? (y/n)"
    }
    
    if ($Confirm -notmatch '^[Yy]$') {
        Write-Host ""
        Write-Host "Setup cancelled. You can run .\install.ps1 again anytime!"
        exit 0
    }
    
    Write-Host ""
    Write-Host "========================================="
    Write-Host ""
}

# Set mode flags based on command line
if ($StandardMode) {
    $LocalOnlyMode = $false
}

# Display selected mode
if ($LocalOnlyMode) {
    Write-Host "Installing in DISPLAY-ONLY MODE"
    Write-Host "(Temperature/Humidity Monitor - NOT a thermostat)"
    Write-Host ""
} elseif ($StandardMode -or (-not $LocalOnlyMode)) {
    Write-Host "Installing in FULL THERMOSTAT MODE"
    Write-Host ""
}

# Determine which binary to use
$OmapLoader = Join-Path $ScriptDir "bin\windows-x64\omap_loader.exe"

# Check if binary exists
if (-not (Test-Path $OmapLoader)) {
    Write-Host "Error: omap_loader.exe not found at: $OmapLoader"
    Write-Host ""
    Write-Host "Please build it first by running:"
    Write-Host "  .\build.ps1"
    Write-Host ""
    Write-Host "Or for MSYS2/MinGW users:"
    Write-Host "  ./build.sh"
    exit 1
}

Write-Host "Using omap_loader: $OmapLoader"
Write-Host ""

# Download and extract firmware files
$FirmwareDir = Join-Path $ScriptDir "bin\firmware"

# Use the same firmware for both modes - firmware-files.zip is the only available release asset
$FirmwareUrl = "https://github.com/codykociemba/NoLongerEvil-Thermostat/releases/download/v1.0.0/firmware-files.zip"
$FirmwareZip = Join-Path $ScriptDir "bin\firmware-files.zip"

# Create bin and firmware directories if they don't exist
if (-not (Test-Path (Join-Path $ScriptDir "bin"))) {
    New-Item -ItemType Directory -Path (Join-Path $ScriptDir "bin") | Out-Null
}
if (-not (Test-Path $FirmwareDir)) {
    New-Item -ItemType Directory -Path $FirmwareDir | Out-Null
}

# Check if firmware files were recently downloaded (within last hour)
$SkipDownload = $false
$XLoadFile = Join-Path $FirmwareDir "x-load-gen2.bin"
if (Test-Path $XLoadFile) {
    $RedownloadDelay = 3600
    $CurrentTime = [int][double]::Parse((Get-Date -UFormat %s))
    $FileCreationTime = [int][double]::Parse((Get-Date (Get-Item $XLoadFile).CreationTime -UFormat %s))
    $TimeDiff = $CurrentTime - $FileCreationTime
    
    if ($TimeDiff -lt $RedownloadDelay) {
        $SkipDownload = $true
    }
}

# Force download if -ForceDownload flag is provided
if ($ForceDownload) {
    $SkipDownload = $false
}

if ($SkipDownload) {
    Write-Host "========================================="
    Write-Host "Firmware downloaded recently! Skipping..."
    Write-Host "(use '-ForceDownload' to override)"
    Write-Host "========================================="
    Write-Host ""
} else {
    Write-Host "========================================="
    Write-Host "Downloading firmware files..."
    Write-Host "========================================="
    Write-Host ""

    # Backup existing firmware files
    $FwFiles = @("x-load-gen1.bin", "x-load-gen2.bin", "u-boot.bin", "uImage")
    foreach ($FwFile in $FwFiles) {
        $FwPath = Join-Path $FirmwareDir $FwFile
        if (Test-Path $FwPath) {
            $FileTime = (Get-Item $FwPath).LastWriteTime.ToString("yyyyMMddHHmmss")
            $BackupPath = Join-Path $FirmwareDir "$FwFile.$FileTime"
            Move-Item $FwPath $BackupPath -Force
            Write-Host "Renamed old file: $FwFile -> $FwFile.$FileTime"
        }
    }
    Write-Host ""

    # Download firmware archive
    Write-Host "Downloading from: $FirmwareUrl"
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $FirmwareUrl -OutFile $FirmwareZip -UseBasicParsing
    } catch {
        Write-Host "Error: Failed to download firmware files"
        Write-Host $_.Exception.Message
        exit 1
    }

    Write-Host "Download complete!"
    Write-Host ""

    # Extract firmware files
    Write-Host "Extracting firmware files..."
    try {
        Expand-Archive -Path $FirmwareZip -DestinationPath $FirmwareDir -Force
    } catch {
        Write-Host "Error: Failed to extract firmware files"
        Write-Host $_.Exception.Message
        exit 1
    }

    # Clean up zip file
    Remove-Item $FirmwareZip -Force -ErrorAction SilentlyContinue

    Write-Host "Firmware files extracted successfully!"
    Write-Host ""
}

# Handle local-only mode configuration
if ($LocalOnlyMode) {
    Write-Host "========================================="
    Write-Host "Local-Only Mode Configuration"
    Write-Host "========================================="
    Write-Host ""
    Write-Host "Local-only mode will configure your Nest as a simple environmental"
    Write-Host "display showing only temperature and humidity."
    Write-Host ""
    Write-Host "Features in local-only mode:"
    Write-Host "  [+] Displays temperature (F) and humidity (%)"
    Write-Host "  [+] Works completely offline (no Wi-Fi required)"
    Write-Host "  [+] Low power consumption"
    Write-Host "  [+] Minimal complexity and failure points"
    Write-Host ""
    Write-Host "Disabled features:"
    Write-Host "  [-] Cloud connectivity and remote control"
    Write-Host "  [-] Scheduling and learning"
    Write-Host "  [-] Mobile app integration"
    Write-Host ""
    
    # Copy configuration file to firmware directory
    $ConfigSrc = Join-Path $ScriptDir "configs\local-only-mode.conf"
    $ConfigDest = Join-Path $FirmwareDir "local-only-mode.conf"
    
    if (Test-Path $ConfigSrc) {
        Copy-Item $ConfigSrc $ConfigDest -Force
        Write-Host "[+] Local-only configuration prepared"
        Write-Host ""
    } else {
        Write-Host "Warning: Configuration file not found at $ConfigSrc"
        Write-Host "Proceeding with default local-only settings..."
        Write-Host ""
    }
    
    # Check if simple firmware variants exist
    Write-Host "Checking for simple firmware variants..."
    $SimpleFirmwareExists = $false
    
    $UImageSimple = Join-Path $FirmwareDir "uImage-simple"
    $UBootSimple = Join-Path $FirmwareDir "u-boot-simple.bin"
    
    if ((Test-Path $UImageSimple) -and (Test-Path $UBootSimple)) {
        $SimpleFirmwareExists = $true
        Write-Host "[+] Simple firmware variants found"
    } else {
        Write-Host "[!] Simple firmware variants not found"
        Write-Host "    Will use standard firmware with local-only configuration"
    }
    Write-Host ""
}

# Prompt for Nest generation
Write-Host "========================================="
Write-Host "Nest Generation Selection"
Write-Host "========================================="
Write-Host ""
Write-Host "Which generation Nest Thermostat do you have?"
Write-Host "You can check the back plate - the bubble level should be green for Gen 1/2."
Write-Host ""
Write-Host "Enter 1 for Generation 1"
Write-Host "Enter 2 for Generation 2"
Write-Host ""

do {
    $NestGen = Read-Host "Generation (1 or 2)"
} while ($NestGen -notmatch '^[12]$')

Write-Host ""
Write-Host "Selected: Generation $NestGen"
Write-Host ""

# Set firmware paths based on generation and mode
if ($LocalOnlyMode) {
    # Use simple/local-only firmware variants
    $XLoadBin = Join-Path $FirmwareDir "x-load-gen$NestGen-simple.bin"
    $UBootBin = Join-Path $FirmwareDir "u-boot-simple.bin"
    $UImageBin = Join-Path $FirmwareDir "uImage-simple"
    
    # Fall back to standard names if simple variants not found
    if (-not (Test-Path $XLoadBin)) {
        $XLoadBin = Join-Path $FirmwareDir "x-load-gen$NestGen.bin"
    }
    if (-not (Test-Path $UBootBin)) {
        $UBootBin = Join-Path $FirmwareDir "u-boot.bin"
    }
    if (-not (Test-Path $UImageBin)) {
        $UImageBin = Join-Path $FirmwareDir "uImage"
    }
} else {
    # Use standard firmware
    $XLoadBin = Join-Path $FirmwareDir "x-load-gen$NestGen.bin"
    $UBootBin = Join-Path $FirmwareDir "u-boot.bin"
    $UImageBin = Join-Path $FirmwareDir "uImage"
}

# Verify firmware files exist
if (-not (Test-Path $XLoadBin)) {
    Write-Host "Error: x-load-gen$NestGen.bin not found at: $XLoadBin"
    exit 1
}

if (-not (Test-Path $UBootBin)) {
    Write-Host "Error: u-boot.bin not found at: $UBootBin"
    exit 1
}

if (-not (Test-Path $UImageBin)) {
    Write-Host "Error: uImage not found at: $UImageBin"
    exit 1
}

Write-Host "Firmware files verified:"
if ($LocalOnlyMode) {
    Write-Host "  Mode: LOCAL-ONLY (Simple Version)"
}
Write-Host "  x-load: $XLoadBin"
Write-Host "  u-boot: $UBootBin"
Write-Host "  uImage: $UImageBin"

# Verify this is the correct firmware variant for local-only mode
if ($LocalOnlyMode) {
    if (($XLoadBin -like "*-simple.bin*") -or ($UImageBin -like "*-simple*")) {
        Write-Host ""
        Write-Host "[+] Verified: Using SIMPLE firmware variant for local-only mode"
    } else {
        Write-Host ""
        Write-Host "[!] Warning: Simple firmware variant not found, using standard firmware"
        Write-Host "    This may include unnecessary features for local-only operation."
        Write-Host "    Consider downloading the local-only firmware package."
    }
}
Write-Host ""

Write-Host "========================================="
Write-Host "Waiting for device to enter DFU mode..."
Write-Host "========================================="
Write-Host ""
Write-Host "Instructions:"
Write-Host "1. Ensure your Nest is charged (50%+ recommended)"
Write-Host "2. Remove the Nest from the wall mount"
Write-Host "3. Connect it to your computer via micro USB"
Write-Host "4. Press and hold the display for 10-15 seconds"
Write-Host "5. The device will reboot and enter DFU mode"
Write-Host ""
Write-Host "IMPORTANT: Make sure you have installed the USB drivers!"
Write-Host "           See README.md for driver installation instructions."
Write-Host ""
Write-Host "The installer will automatically detect the device and begin flashing..."
Write-Host ""

# Load firmware
$Arguments = @(
    "-f", $XLoadBin,
    "-f", $UBootBin,
    "-a", "0x80100000",
    "-f", $UImageBin,
    "-a", "0x80A00000",
    "-v",
    "-j", "0x80100000"
)

$Process = Start-Process -FilePath $OmapLoader -ArgumentList $Arguments -Wait -PassThru -NoNewWindow

# Check if successful
if ($Process.ExitCode -eq 0) {
    Write-Host ""
    Write-Host "========================================="
    Write-Host "Firmware installed successfully!"
    Write-Host "========================================="
    Write-Host ""
    
    if ($LocalOnlyMode) {
        Write-Host "LOCAL-ONLY MODE - Next steps:"
        Write-Host "1. Keep the device plugged in via USB"
        Write-Host "2. Wait 2-3 minutes for the device to boot"
        Write-Host "3. You should see the NoLongerEvil logo"
        Write-Host "4. Device will automatically enter local-only mode"
        Write-Host "5. Display will show: Temperature (F) and Humidity (%)"
        Write-Host ""
        Write-Host "The device is now configured for standalone operation."
        Write-Host "No internet connection or account setup is required."
        Write-Host ""
        Write-Host "Configuration:"
        Write-Host "  * Cloud connectivity: DISABLED"
        Write-Host "  * Wi-Fi: DISABLED (saves power)"
        Write-Host "  * Display: Temperature + Humidity"
        Write-Host "  * Refresh rate: Every 5 seconds"
        Write-Host ""
        Write-Host "To access settings, press and hold the display for 3 seconds."
        Write-Host ""
        Write-Host "For more information, see LOCAL_MODE.md"
        Write-Host ""
    } else {
        Write-Host "Next steps:"
        Write-Host "1. Keep the device plugged in via USB"
        Write-Host "2. Wait 2-3 minutes for the device to boot"
        Write-Host "3. You should see the NoLongerEvil logo"
        Write-Host "4. Visit https://nolongerevil.com to register"
        Write-Host "5. Link your device using the entry code from:"
        Write-Host "   Settings -> Nest App -> Get Entry Code"
        Write-Host ""
    }
} else {
    Write-Host ""
    Write-Host "========================================="
    Write-Host "Installation failed!"
    Write-Host "========================================="
    Write-Host ""
    Write-Host "Please check:"
    Write-Host "- Device is properly connected via USB"
    Write-Host "- Device entered DFU mode correctly"
    Write-Host "- USB drivers are installed (see README.md)"
    Write-Host "- Try running as Administrator"
    Write-Host ""
    exit 1
}
