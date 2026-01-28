# Create Release Package Script
# Prepares all files needed for a Windows installer release

param(
    [switch]$Help,
    [string]$OutputDir = "..\releases"
)

$ErrorActionPreference = "Stop"

if ($Help) {
    Write-Host "Create Release Package for Windows Installer"
    Write-Host ""
    Write-Host "Usage: .\create-release-package.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -OutputDir <path>  Output directory for release files (default: ..\releases)"
    Write-Host "  -Help              Show this help message"
    Write-Host ""
    Write-Host "This script:"
    Write-Host "  1. Verifies all required files are built"
    Write-Host "  2. Creates a release package directory"
    Write-Host "  3. Copies installer and documentation"
    Write-Host "  4. Creates checksums"
    Write-Host "  5. Generates release notes"
    Write-Host ""
    exit 0
}

Write-Host "========================================="
Write-Host "Create Release Package"
Write-Host "========================================="
Write-Host ""

# Check if installer exists
$InstallerPath = "..\bin\installer\NoLongerEvil-Thermostat-Setup.exe"
if (-not (Test-Path $InstallerPath)) {
    Write-Host "ERROR: Installer not found at $InstallerPath"
    Write-Host ""
    Write-Host "Please build the installer first:"
    Write-Host "  .\build-installer.ps1"
    Write-Host ""
    exit 1
}

Write-Host "✓ Found installer: $InstallerPath"

# Get installer info
$InstallerSize = (Get-Item $InstallerPath).Length / 1MB
$InstallerHash = (Get-FileHash $InstallerPath -Algorithm SHA256).Hash
Write-Host "  Size: $($InstallerSize.ToString('F2')) MB"
Write-Host "  SHA256: $InstallerHash"
Write-Host ""

# Create output directory
$Timestamp = Get-Date -Format "yyyy-MM-dd"
$ReleaseDir = Join-Path $OutputDir "windows-installer-$Timestamp"

if (Test-Path $ReleaseDir) {
    Write-Host "Release directory already exists: $ReleaseDir"
    $Confirm = Read-Host "Overwrite? (y/n)"
    if ($Confirm -ne 'y') {
        Write-Host "Cancelled."
        exit 0
    }
    Remove-Item -Recurse -Force $ReleaseDir
}

New-Item -ItemType Directory -Path $ReleaseDir -Force | Out-Null
Write-Host "Created release directory: $ReleaseDir"
Write-Host ""

# Copy installer
Write-Host "Copying files..."
Copy-Item $InstallerPath $ReleaseDir
Write-Host "  ✓ Installer"

# Copy documentation
$DocsToInclude = @(
    "README.md",
    "WINDOWS_INSTALLER_GUIDE.md",
    "QUICK_REFERENCE.md",
    "TESTING_GUIDE.md"
)

foreach ($doc in $DocsToInclude) {
    if (Test-Path $doc) {
        Copy-Item $doc $ReleaseDir
        Write-Host "  ✓ $doc"
    } else {
        Write-Host "  ! $doc not found (skipped)"
    }
}

# Copy license
if (Test-Path "..\LICENSE") {
    Copy-Item "..\LICENSE" $ReleaseDir
    Write-Host "  ✓ LICENSE"
}

Write-Host ""

# Create checksums file
Write-Host "Creating checksums..."
$ChecksumsFile = Join-Path $ReleaseDir "CHECKSUMS.txt"
$ChecksumsContent = @"
# NoLongerEvil Thermostat Windows Installer
# Release Date: $Timestamp

SHA256 Checksums:

NoLongerEvil-Thermostat-Setup.exe
$InstallerHash

To verify:
  Get-FileHash NoLongerEvil-Thermostat-Setup.exe -Algorithm SHA256
"@

$ChecksumsContent | Out-File -FilePath $ChecksumsFile -Encoding utf8
Write-Host "  ✓ CHECKSUMS.txt"
Write-Host ""

# Create release notes template
Write-Host "Creating release notes template..."
$ReleaseNotesFile = Join-Path $ReleaseDir "RELEASE_NOTES.md"
$ReleaseNotesContent = @"
# NoLongerEvil Thermostat - Windows Installer
## Release Notes - $Timestamp

### What's New

- Windows all-in-one installer with graphical interface
- Easy firmware flashing for Nest Gen 1 and Gen 2 thermostats
- Auto-download of firmware files
- Integrated USB driver installation
- Support for both Full Thermostat and Display-Only modes

### Features

✅ **User-Friendly GUI**
- Point-and-click interface
- Step-by-step wizard
- Real-time progress tracking
- Clear error messages

✅ **Automatic Setup**
- Downloads firmware automatically
- Detects connected devices
- Guides through USB driver installation

✅ **Two Operating Modes**
- Full Thermostat Mode: Complete smart thermostat functionality
- Display-Only Mode: Temperature/humidity monitoring only

✅ **Comprehensive Documentation**
- Installation guide
- Troubleshooting tips
- Quick reference card

### Installation

1. Download \`NoLongerEvil-Thermostat-Setup.exe\`
2. Run as Administrator
3. Follow the installation wizard
4. Launch the flasher from Start Menu

### Requirements

- Windows 10 (21H2 or later) or Windows 11
- Administrator privileges
- Internet connection (for firmware download)
- Nest Thermostat Gen 1 or Gen 2
- Micro USB cable

### Verification

**SHA256 Checksum:**
\`\`\`
$InstallerHash
\`\`\`

Verify the download:
\`\`\`powershell
Get-FileHash NoLongerEvil-Thermostat-Setup.exe -Algorithm SHA256
\`\`\`

### Documentation

- **[Windows Installer Guide](WINDOWS_INSTALLER_GUIDE.md)** - Complete installation and usage guide
- **[Quick Reference](QUICK_REFERENCE.md)** - Quick start guide
- **[Testing Guide](TESTING_GUIDE.md)** - For developers and testers

### Support

- **GitHub Issues:** https://github.com/codykociemba/NoLongerEvil-Thermostat/issues
- **Discord:** https://discord.gg/hackhouse
- **Documentation:** https://docs.nolongerevil.com

### Known Issues

- USB driver installation requires manual steps with Zadig
- Firmware download requires internet connection
- Some antivirus software may flag the installer (false positive)

### Troubleshooting

See [WINDOWS_INSTALLER_GUIDE.md](WINDOWS_INSTALLER_GUIDE.md#troubleshooting) for common issues and solutions.

### License

See LICENSE file for terms and conditions.

---

**File Information:**
- Filename: \`NoLongerEvil-Thermostat-Setup.exe\`
- Size: $($InstallerSize.ToString('F2')) MB
- SHA256: \`$InstallerHash\`
- Build Date: $Timestamp
"@

$ReleaseNotesContent | Out-File -FilePath $ReleaseNotesFile -Encoding utf8
Write-Host "  ✓ RELEASE_NOTES.md"
Write-Host ""

# Create README for release package
Write-Host "Creating release README..."
$ReleaseReadmeFile = Join-Path $ReleaseDir "README_FIRST.txt"
$ReleaseReadmeContent = @"
=================================================
NoLongerEvil Thermostat - Windows Installer
=================================================

Thank you for downloading the NoLongerEvil Thermostat Windows installer!

QUICK START:
1. Run NoLongerEvil-Thermostat-Setup.exe as Administrator
2. Follow the installation wizard
3. Launch the flasher from the Start Menu
4. Connect your Nest and follow the on-screen instructions

IMPORTANT:
- Requires Windows 10 (21H2+) or Windows 11
- Must be run as Administrator
- Requires internet connection for firmware download
- Works with Nest Gen 1 and Gen 2 only

SECURITY:
Verify the installer checksum before running:
  SHA256: $InstallerHash

DOCUMENTATION:
- RELEASE_NOTES.md - What's included in this release
- WINDOWS_INSTALLER_GUIDE.md - Complete guide
- QUICK_REFERENCE.md - Quick start guide

SUPPORT:
- GitHub: https://github.com/codykociemba/NoLongerEvil-Thermostat
- Discord: https://discord.gg/hackhouse
- Docs: https://docs.nolongerevil.com

LICENSE:
See LICENSE file for terms and conditions.

Enjoy your liberated Nest Thermostat!
=================================================
"@

$ReleaseReadmeContent | Out-File -FilePath $ReleaseReadmeFile -Encoding utf8
Write-Host "  ✓ README_FIRST.txt"
Write-Host ""

# Create .zip archive of release
Write-Host "Creating release archive..."
$ArchiveName = "NoLongerEvil-Thermostat-Windows-$Timestamp.zip"
$ArchivePath = Join-Path $OutputDir $ArchiveName

if (Test-Path $ArchivePath) {
    Remove-Item $ArchivePath -Force
}

Compress-Archive -Path "$ReleaseDir\*" -DestinationPath $ArchivePath
$ArchiveSize = (Get-Item $ArchivePath).Length / 1MB
Write-Host "  ✓ Created $ArchiveName ($($ArchiveSize.ToString('F2')) MB)"
Write-Host ""

# Summary
Write-Host "========================================="
Write-Host "Release Package Complete!"
Write-Host "========================================="
Write-Host ""
Write-Host "Files created in: $ReleaseDir"
Write-Host ""
Write-Host "Package contents:"
Write-Host "  • NoLongerEvil-Thermostat-Setup.exe ($($InstallerSize.ToString('F2')) MB)"
Write-Host "  • Documentation (README, guides, release notes)"
Write-Host "  • CHECKSUMS.txt (SHA256 hashes)"
Write-Host "  • LICENSE"
Write-Host ""
Write-Host "Archive: $ArchivePath ($($ArchiveSize.ToString('F2')) MB)"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Test the installer on clean Windows 10/11 VM"
Write-Host "  2. Update RELEASE_NOTES.md with any additional info"
Write-Host "  3. Upload to GitHub Releases"
Write-Host "  4. Update main README with download link"
Write-Host ""
Write-Host "Upload command for GitHub Release:"
Write-Host "  gh release create v1.0.0-windows \"
Write-Host "    $ArchivePath \"
Write-Host "    $InstallerPath \"
Write-Host "    --title \"Windows Installer v1.0.0\" \"
Write-Host "    --notes-file \"$ReleaseNotesFile\""
Write-Host ""
