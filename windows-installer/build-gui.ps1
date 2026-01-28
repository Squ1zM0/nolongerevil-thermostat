# Build script for NoLongerEvil Nest Flasher GUI
# Compiles the Python GUI application into a Windows executable using PyInstaller

param(
    [switch]$Clean,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

if ($Help) {
    Write-Host "Build NoLongerEvil Nest Flasher GUI"
    Write-Host ""
    Write-Host "Usage: .\build-gui.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Clean    Clean build artifacts before building"
    Write-Host "  -Help     Show this help message"
    Write-Host ""
    Write-Host "Requirements:"
    Write-Host "  - Python 3.8 or later"
    Write-Host "  - PyInstaller (pip install pyinstaller)"
    Write-Host ""
    exit 0
}

Write-Host "========================================="
Write-Host "NoLongerEvil Nest Flasher GUI Builder"
Write-Host "========================================="
Write-Host ""

# Check for Python
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Python not found!"
    Write-Host ""
    Write-Host "Please install Python 3.8 or later from:"
    Write-Host "  https://www.python.org/downloads/"
    Write-Host ""
    Write-Host "Make sure to check 'Add Python to PATH' during installation."
    exit 1
}

$PythonVersion = python --version
Write-Host "Found: $PythonVersion"
Write-Host ""

# Check for PyInstaller
Write-Host "Checking for PyInstaller..."
$PyInstallerCheck = python -c "import PyInstaller" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "PyInstaller not found. Installing..."
    python -m pip install --upgrade pip
    python -m pip install pyinstaller
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to install PyInstaller"
        exit 1
    }
    Write-Host "✓ PyInstaller installed successfully"
} else {
    Write-Host "✓ PyInstaller already installed"
}
Write-Host ""

# Clean if requested
if ($Clean) {
    Write-Host "Cleaning build artifacts..."
    Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force dist -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force __pycache__ -ErrorAction SilentlyContinue
    Remove-Item -Force *.spec -ErrorAction SilentlyContinue
    Remove-Item -Force NestFlasher.exe -ErrorAction SilentlyContinue
    Remove-Item -Force FlashingGUI.exe -ErrorAction SilentlyContinue
    Write-Host "✓ Clean complete"
    Write-Host ""
}

# Build the executable
Write-Host "Building NestFlasher.exe..."
Write-Host ""

$PyInstallerArgs = @(
    "--onefile",
    "--windowed",
    "--name", "NestFlasher",
    "--icon", "icon.ico"
)

# Add icon if it exists
if (-not (Test-Path "icon.ico")) {
    Write-Host "Note: icon.ico not found, building without icon"
    $PyInstallerArgs = $PyInstallerArgs | Where-Object { $_ -ne "--icon" -and $_ -ne "icon.ico" }
}

$PyInstallerArgs += "NestFlasher.py"

python -m PyInstaller @PyInstallerArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Build failed!"
    exit 1
}

# Move executable to current directory
if (Test-Path "dist\NestFlasher.exe") {
    Move-Item -Force "dist\NestFlasher.exe" "."
    Write-Host ""
    Write-Host "✓ Build successful!"
    Write-Host ""
    Write-Host "Output: NestFlasher.exe"
} else {
    Write-Host ""
    Write-Host "ERROR: Build completed but executable not found!"
    exit 1
}

# Clean up build artifacts
Write-Host ""
Write-Host "Cleaning up build artifacts..."
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force dist -ErrorAction SilentlyContinue
Remove-Item -Force *.spec -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "========================================="
Write-Host "Build Complete!"
Write-Host "========================================="
Write-Host ""
Write-Host "You can now:"
Write-Host "  1. Test the GUI: .\NestFlasher.exe"
Write-Host "  2. Build the installer: .\build-installer.ps1"
Write-Host ""
