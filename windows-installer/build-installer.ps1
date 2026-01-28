# Build script for NoLongerEvil Thermostat Windows Installer
# Creates the all-in-one Windows installer using Inno Setup

param(
    [switch]$Help,
    [string]$InnoSetupPath = ""
)

$ErrorActionPreference = "Stop"

if ($Help) {
    Write-Host "Build NoLongerEvil Thermostat Windows Installer"
    Write-Host ""
    Write-Host "Usage: .\build-installer.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -InnoSetupPath <path>  Path to Inno Setup Compiler (ISCC.exe)"
    Write-Host "  -Help                  Show this help message"
    Write-Host ""
    Write-Host "Requirements:"
    Write-Host "  - Inno Setup 6.x (https://jrsoftware.org/isinfo.php)"
    Write-Host "  - NestFlasher.exe (run build-gui.ps1 first)"
    Write-Host "  - omap_loader.exe (run ..\build.ps1 first)"
    Write-Host ""
    exit 0
}

Write-Host "========================================="
Write-Host "NoLongerEvil Installer Builder"
Write-Host "========================================="
Write-Host ""

# Find Inno Setup
if ($InnoSetupPath -eq "") {
    $PossiblePaths = @(
        "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
        "${env:ProgramFiles}\Inno Setup 6\ISCC.exe",
        "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
        "C:\Program Files\Inno Setup 6\ISCC.exe"
    )
    
    foreach ($path in $PossiblePaths) {
        if (Test-Path $path) {
            $InnoSetupPath = $path
            break
        }
    }
}

if ($InnoSetupPath -eq "" -or -not (Test-Path $InnoSetupPath)) {
    Write-Host "ERROR: Inno Setup Compiler (ISCC.exe) not found!"
    Write-Host ""
    Write-Host "Please install Inno Setup 6.x from:"
    Write-Host "  https://jrsoftware.org/isinfo.php"
    Write-Host ""
    Write-Host "Or specify the path manually:"
    Write-Host "  .\build-installer.ps1 -InnoSetupPath 'C:\Path\To\ISCC.exe'"
    Write-Host ""
    exit 1
}

Write-Host "Found Inno Setup: $InnoSetupPath"
Write-Host ""

# Check for required files
Write-Host "Checking prerequisites..."
$AllFilesExist = $true

# Check for GUI executable
if (-not (Test-Path "NestFlasher.exe")) {
    Write-Host "✗ NestFlasher.exe not found!"
    Write-Host "  Run: .\build-gui.ps1"
    $AllFilesExist = $false
} else {
    Write-Host "✓ NestFlasher.exe found"
}

if (-not (Test-Path "FlashingGUI.exe")) {
    Write-Host "✗ FlashingGUI.exe not found!"
    Write-Host "  Run: .\build-gui.ps1"
    $AllFilesExist = $false
} else {
    Write-Host "✓ FlashingGUI.exe found"
}

# Check for omap_loader
$OmapLoader = "..\bin\windows-x64\omap_loader.exe"
if (-not (Test-Path $OmapLoader)) {
    Write-Host "✗ omap_loader.exe not found at $OmapLoader"
    Write-Host "  Run: ..\build.ps1"
    $AllFilesExist = $false
} else {
    Write-Host "✓ omap_loader.exe found"
}

# Check for setup script
if (-not (Test-Path "setup.iss")) {
    Write-Host "✗ setup.iss not found!"
    $AllFilesExist = $false
} else {
    Write-Host "✓ setup.iss found"
}

# Check for LICENSE
if (-not (Test-Path "..\LICENSE")) {
    Write-Host "! LICENSE not found (will cause warning)"
}

# Check for icon (optional)
if (-not (Test-Path "icon.ico")) {
    Write-Host "! icon.ico not found (installer will have default icon)"
}

# Check for Zadig (optional)
if (-not (Test-Path "drivers\zadig-2.8.exe")) {
    Write-Host "! drivers\zadig-2.8.exe not found (USB drivers won't be included)"
    Write-Host "  Download from: https://zadig.akeo.ie/"
}

Write-Host ""

if (-not $AllFilesExist) {
    Write-Host "ERROR: Missing required files!"
    Write-Host "Please build missing components first."
    exit 1
}

# Create output directory
$OutputDir = "..\bin\installer"
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    Write-Host "Created output directory: $OutputDir"
    Write-Host ""
}

# Build the installer
Write-Host "========================================="
Write-Host "Building installer..."
Write-Host "========================================="
Write-Host ""

$Process = Start-Process -FilePath $InnoSetupPath -ArgumentList "setup.iss" -Wait -PassThru -NoNewWindow

if ($Process.ExitCode -eq 0) {
    Write-Host ""
    Write-Host "========================================="
    Write-Host "Build Complete!"
    Write-Host "========================================="
    Write-Host ""
    
    $InstallerPath = Join-Path $OutputDir "NoLongerEvil-Thermostat-Setup.exe"
    if (Test-Path $InstallerPath) {
        $InstallerSize = (Get-Item $InstallerPath).Length / 1MB
        Write-Host "Installer created: $InstallerPath"
        Write-Host "Size: $($InstallerSize.ToString('F2')) MB"
        Write-Host ""
        Write-Host "You can now distribute this installer to Windows users!"
        Write-Host ""
        Write-Host "Test the installer:"
        Write-Host "  $InstallerPath"
        Write-Host ""
        Write-Host "Silent install:"
        Write-Host "  $InstallerPath /SILENT"
        Write-Host ""
    } else {
        Write-Host "WARNING: Build succeeded but installer not found at expected location."
        Write-Host "Check the Inno Setup output for the actual location."
    }
} else {
    Write-Host ""
    Write-Host "ERROR: Installer build failed!"
    Write-Host "Exit code: $($Process.ExitCode)"
    Write-Host ""
    Write-Host "Check the Inno Setup output above for details."
    exit 1
}
