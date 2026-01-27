# NoLongerEvil Build Script for Windows
# Builds omap_loader for Windows using MSYS2/MinGW or Visual Studio

param(
    [switch]$Help,
    [switch]$Clean,
    [string]$Compiler = "auto"
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BinDir = Join-Path $ScriptDir "bin"
$SrcDir = Join-Path $ScriptDir "src\omap_loader"

# Show help
if ($Help) {
    Write-Host "Usage: .\build.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Help        Show this help message"
    Write-Host "  -Clean       Clean build artifacts before building"
    Write-Host "  -Compiler    Specify compiler: 'msys2', 'msvc', or 'auto' (default)"
    Write-Host ""
    Write-Host "This script builds the omap_loader tool for Windows."
    Write-Host ""
    Write-Host "Requirements:"
    Write-Host "  Option 1: MSYS2 with MinGW-w64 (recommended)"
    Write-Host "    - Install MSYS2 from https://www.msys2.org/"
    Write-Host "    - Run: pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-libusb"
    Write-Host ""
    Write-Host "  Option 2: Visual Studio with vcpkg"
    Write-Host "    - Install Visual Studio Build Tools"
    Write-Host "    - Install libusb via vcpkg: vcpkg install libusb:x64-windows"
    Write-Host ""
    exit 0
}

$Arch = if ([Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }
$TargetDir = Join-Path $BinDir "windows-$Arch"
$BinaryName = "omap_loader.exe"

Write-Host "========================================="
Write-Host "OMAP Loader Build Script (Windows)"
Write-Host "========================================="
Write-Host "Detected Architecture: $Arch"
Write-Host ""

# Clean if requested
if ($Clean) {
    Write-Host "Cleaning build artifacts..."
    if (Test-Path $TargetDir) {
        Remove-Item (Join-Path $TargetDir $BinaryName) -Force -ErrorAction SilentlyContinue
    }
    $ObjFiles = Get-ChildItem -Path $SrcDir -Filter "*.o" -ErrorAction SilentlyContinue
    foreach ($obj in $ObjFiles) {
        Remove-Item $obj.FullName -Force
    }
    Write-Host "Clean complete."
    Write-Host ""
}

# Detect available compilers
$MSYS2Path = $null
$MSVCAvailable = $false

# Check for MSYS2
$MSYS2Locations = @(
    "C:\msys64",
    "C:\msys32", 
    "$env:USERPROFILE\msys64",
    "$env:LOCALAPPDATA\msys64"
)

foreach ($loc in $MSYS2Locations) {
    if (Test-Path (Join-Path $loc "mingw64\bin\gcc.exe")) {
        $MSYS2Path = $loc
        break
    }
}

# Check for Visual Studio
$VCVarsPath = $null
$VSLocations = @(
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
)

foreach ($vsPath in $VSLocations) {
    if (Test-Path $vsPath) {
        $VCVarsPath = $vsPath
        $MSVCAvailable = $true
        break
    }
}

# Select compiler based on availability
$UseCompiler = $Compiler
if ($Compiler -eq "auto") {
    if ($MSYS2Path) {
        $UseCompiler = "msys2"
    } elseif ($MSVCAvailable) {
        $UseCompiler = "msvc"
    } else {
        Write-Host "Error: No suitable compiler found!"
        Write-Host ""
        Write-Host "Please install one of the following:"
        Write-Host ""
        Write-Host "Option 1: MSYS2 with MinGW-w64 (recommended)"
        Write-Host "  1. Download from https://www.msys2.org/"
        Write-Host "  2. Install to C:\msys64"
        Write-Host "  3. Open MSYS2 MINGW64 terminal and run:"
        Write-Host "     pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-libusb mingw-w64-x86_64-pkg-config"
        Write-Host ""
        Write-Host "Option 2: Visual Studio with vcpkg"
        Write-Host "  1. Install Visual Studio Build Tools"
        Write-Host "  2. Install vcpkg: https://vcpkg.io/"
        Write-Host "  3. Run: vcpkg install libusb:x64-windows"
        Write-Host ""
        exit 1
    }
}

Write-Host "Using compiler: $UseCompiler"
Write-Host ""

# Create target directory
if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir | Out-Null
}

# Build with selected compiler
if ($UseCompiler -eq "msys2") {
    Write-Host "Building with MSYS2/MinGW-w64..."
    Write-Host ""
    
    if (-not $MSYS2Path) {
        Write-Host "Error: MSYS2 not found!"
        Write-Host "Please install MSYS2 from https://www.msys2.org/"
        exit 1
    }
    
    $MingwBin = Join-Path $MSYS2Path "mingw64\bin"
    $Bash = Join-Path $MSYS2Path "usr\bin\bash.exe"
    
    # Convert Windows paths to Unix paths for MSYS2
    $UnixSrcDir = $SrcDir -replace '\\', '/' -replace '^([A-Za-z]):', '/$1'
    $UnixTargetDir = $TargetDir -replace '\\', '/' -replace '^([A-Za-z]):', '/$1'
    
    # Build command
    $BuildScript = @"
export PATH="/mingw64/bin:`$PATH"
cd "$UnixSrcDir"
make clean
make
cp omap_loader.exe "$UnixTargetDir/"
make clean
"@
    
    # Write build script to temp file
    $TempScript = [System.IO.Path]::GetTempFileName()
    $BuildScript | Out-File -FilePath $TempScript -Encoding utf8 -NoNewline
    
    # Run build
    $Process = Start-Process -FilePath $Bash -ArgumentList "--login", "-c", "`"source $($TempScript -replace '\\', '/' -replace '^([A-Za-z]):', '/$1')`"" -Wait -PassThru -NoNewWindow
    
    Remove-Item $TempScript -Force -ErrorAction SilentlyContinue
    
    if ($Process.ExitCode -ne 0) {
        Write-Host "Error: Build failed!"
        exit 1
    }
    
} elseif ($UseCompiler -eq "msvc") {
    Write-Host "Building with Visual Studio/MSVC..."
    Write-Host ""
    Write-Host "Note: MSVC build requires libusb to be installed via vcpkg."
    Write-Host ""
    
    # Check for vcpkg
    $VcpkgRoot = $env:VCPKG_ROOT
    if (-not $VcpkgRoot) {
        $VcpkgRoot = "C:\vcpkg"
    }
    
    $LibusbInclude = Join-Path $VcpkgRoot "installed\x64-windows\include"
    $LibusbLib = Join-Path $VcpkgRoot "installed\x64-windows\lib"
    
    if (-not (Test-Path (Join-Path $LibusbInclude "libusb-1.0"))) {
        Write-Host "Error: libusb not found in vcpkg!"
        Write-Host ""
        Write-Host "Please install libusb:"
        Write-Host "  vcpkg install libusb:x64-windows"
        Write-Host ""
        exit 1
    }
    
    # Create a build script for MSVC
    $SourceFile = Join-Path $SrcDir "omap_loader.c"
    $OutputFile = Join-Path $TargetDir $BinaryName
    
    # Run cl.exe through vcvars
    $CompileCmd = @"
call "$VCVarsPath"
cl.exe /O2 /W4 /I"$LibusbInclude" /I"$LibusbInclude\libusb-1.0" "$SourceFile" /Fe:"$OutputFile" /link /LIBPATH:"$LibusbLib" libusb-1.0.lib
"@
    
    $TempBat = [System.IO.Path]::GetTempFileName() + ".bat"
    $CompileCmd | Out-File -FilePath $TempBat -Encoding ascii
    
    $Process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $TempBat -Wait -PassThru -NoNewWindow
    
    Remove-Item $TempBat -Force -ErrorAction SilentlyContinue
    
    if ($Process.ExitCode -ne 0) {
        Write-Host "Error: Build failed!"
        exit 1
    }
} else {
    Write-Host "Error: Unknown compiler: $UseCompiler"
    exit 1
}

# Verify build
$OutputBinary = Join-Path $TargetDir $BinaryName
if (Test-Path $OutputBinary) {
    Write-Host ""
    Write-Host "========================================="
    Write-Host "Build Complete!"
    Write-Host "========================================="
    Write-Host "Binary location: $OutputBinary"
    Write-Host ""
    Write-Host "You can now run the firmware installer with:"
    Write-Host "  .\install.ps1"
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "Error: Build completed but binary not found!"
    Write-Host "Expected location: $OutputBinary"
    exit 1
}
