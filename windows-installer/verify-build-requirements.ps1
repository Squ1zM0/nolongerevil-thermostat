# Build verification script
# Checks that all components are ready for building the Windows installer

Write-Host "========================================="
Write-Host "Windows Installer Build Verification"
Write-Host "========================================="
Write-Host ""

$AllGood = $true
$Warnings = @()

# Check 1: omap_loader.exe
Write-Host "Checking omap_loader.exe..."
if (Test-Path "..\bin\windows-x64\omap_loader.exe") {
    Write-Host "  ✓ Found" -ForegroundColor Green
} else {
    Write-Host "  ✗ NOT FOUND" -ForegroundColor Red
    Write-Host "    Run: ..\build.ps1" -ForegroundColor Yellow
    $AllGood = $false
}

# Check 2: Python
Write-Host "Checking Python..."
if (Get-Command python -ErrorAction SilentlyContinue) {
    $PyVersion = python --version
    Write-Host "  ✓ $PyVersion" -ForegroundColor Green
} else {
    Write-Host "  ✗ NOT FOUND" -ForegroundColor Red
    Write-Host "    Install from: https://www.python.org/" -ForegroundColor Yellow
    $AllGood = $false
}

# Check 3: PyInstaller
Write-Host "Checking PyInstaller..."
$PyInstallerCheck = python -c "import PyInstaller" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Installed" -ForegroundColor Green
} else {
    Write-Host "  ! Not installed" -ForegroundColor Yellow
    Write-Host "    Run: pip install pyinstaller" -ForegroundColor Yellow
    $Warnings += "PyInstaller not installed"
}

# Check 4: Inno Setup
Write-Host "Checking Inno Setup..."
$InnoSetupPaths = @(
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles}\Inno Setup 6\ISCC.exe"
)
$InnoFound = $false
foreach ($path in $InnoSetupPaths) {
    if (Test-Path $path) {
        Write-Host "  ✓ Found at: $path" -ForegroundColor Green
        $InnoFound = $true
        break
    }
}
if (-not $InnoFound) {
    Write-Host "  ✗ NOT FOUND" -ForegroundColor Red
    Write-Host "    Install from: https://jrsoftware.org/isinfo.php" -ForegroundColor Yellow
    $AllGood = $false
}

# Check 5: GUI executables
Write-Host "Checking GUI executables..."
if (Test-Path "NestFlasher.exe") {
    Write-Host "  ✓ NestFlasher.exe found" -ForegroundColor Green
} else {
    Write-Host "  ! NestFlasher.exe not found" -ForegroundColor Yellow
    Write-Host "    Run: .\build-gui.ps1" -ForegroundColor Yellow
    $Warnings += "GUI not built"
}

# Check 6: Zadig (optional)
Write-Host "Checking Zadig..."
if (Test-Path "drivers\zadig-2.8.exe") {
    Write-Host "  ✓ Found" -ForegroundColor Green
} else {
    Write-Host "  ! Not found (optional)" -ForegroundColor Yellow
    Write-Host "    Download from: https://zadig.akeo.ie/" -ForegroundColor Yellow
    $Warnings += "Zadig not included"
}

# Check 7: Icon (optional)
Write-Host "Checking icon..."
if (Test-Path "icon.ico") {
    Write-Host "  ✓ Found" -ForegroundColor Green
} else {
    Write-Host "  ! Not found (optional)" -ForegroundColor Yellow
    Write-Host "    Will use default Windows icon" -ForegroundColor Yellow
    $Warnings += "Custom icon not present"
}

# Check 8: License
Write-Host "Checking LICENSE..."
if (Test-Path "..\LICENSE") {
    Write-Host "  ✓ Found" -ForegroundColor Green
} else {
    Write-Host "  ! Not found" -ForegroundColor Yellow
    $Warnings += "LICENSE file missing"
}

# Summary
Write-Host ""
Write-Host "========================================="
if ($AllGood -and $Warnings.Count -eq 0) {
    Write-Host "✓ ALL CHECKS PASSED" -ForegroundColor Green
    Write-Host "========================================="
    Write-Host ""
    Write-Host "You can now build the installer:"
    Write-Host "  1. Build GUI: .\build-gui.ps1" -ForegroundColor Cyan
    Write-Host "  2. Build installer: .\build-installer.ps1" -ForegroundColor Cyan
} elseif ($AllGood) {
    Write-Host "✓ READY TO BUILD (with warnings)" -ForegroundColor Yellow
    Write-Host "========================================="
    Write-Host ""
    Write-Host "Warnings:" -ForegroundColor Yellow
    foreach ($warning in $Warnings) {
        Write-Host "  • $warning" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "You can still build the installer:"
    Write-Host "  1. Build GUI: .\build-gui.ps1" -ForegroundColor Cyan
    Write-Host "  2. Build installer: .\build-installer.ps1" -ForegroundColor Cyan
} else {
    Write-Host "✗ NOT READY TO BUILD" -ForegroundColor Red
    Write-Host "========================================="
    Write-Host ""
    Write-Host "Please fix the errors above before building."
}
Write-Host ""
