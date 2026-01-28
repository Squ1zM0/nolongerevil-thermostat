# Developer Guide - Windows Installer

This guide is for developers who want to understand, maintain, or improve the Windows installer.

## Architecture Overview

The Windows installer system consists of three main components:

### 1. Inno Setup Installer (`setup.iss`)

**Purpose:** Creates the Windows installation package

**Key Features:**
- Downloads firmware during installation
- Installs files to Program Files
- Creates Start Menu and desktop shortcuts
- Supports silent installation
- Handles upgrade scenarios

**Technology:** Pascal-like scripting language (Inno Setup Script)

**Key Sections:**
```pascal
[Setup]        - Installer configuration
[Types]        - Installation types (Full, Local-Only, Custom)
[Components]   - Selectable components
[Files]        - Files to include
[Icons]        - Shortcuts to create
[Code]         - Custom logic (firmware download, mode selection)
```

### 2. GUI Application (`NestFlasher.py`)

**Purpose:** User-friendly interface for flashing firmware

**Key Features:**
- Firmware type and generation selection
- Device detection and status monitoring
- Real-time progress display
- Error handling and troubleshooting
- Console output for debugging

**Technology:** Python 3.8+ with Tkinter

**Architecture:**
```
NestFlasherGUI (Main Class)
├── UI Setup (setup_ui)
│   ├── Title and labels
│   ├── Mode selection (Radio buttons)
│   ├── Generation selection
│   ├── Instructions
│   ├── Action buttons
│   ├── Progress bar
│   └── Console output
├── Prerequisite Check (check_prerequisites)
│   └── Verify omap_loader and firmware files
├── Firmware Management (download_firmware)
│   ├── Check for existing files
│   └── Download and extract if needed
├── Flashing Process (flash_firmware)
│   ├── Prepare firmware paths
│   ├── Build omap_loader command
│   ├── Execute and monitor
│   └── Display results
└── Driver Installation (install_drivers)
    └── Launch Zadig with instructions
```

### 3. Build System

**Components:**
- `build-gui.ps1` - Compiles Python to .exe using PyInstaller
- `build-installer.ps1` - Compiles Inno Setup script
- `verify-build-requirements.ps1` - Checks prerequisites
- `create-release-package.ps1` - Packages for distribution

## Code Organization

```
windows-installer/
├── setup.iss                          # Inno Setup script
├── NestFlasher.py                     # GUI application source
├── build-gui.ps1                      # GUI build script
├── build-installer.ps1                # Installer build script
├── verify-build-requirements.ps1     # Prerequisite checker
├── create-release-package.ps1        # Release packager
├── README.md                          # Technical documentation
├── WINDOWS_INSTALLER_GUIDE.md        # User guide
├── QUICK_REFERENCE.md                # Quick reference
├── TESTING_GUIDE.md                  # Testing procedures
├── DEVELOPER_GUIDE.md                # This file
├── icon.placeholder                   # Icon placeholder
└── drivers/                           # USB drivers (Zadig)
    └── zadig-2.8.exe
```

## Development Workflow

### Setting Up Development Environment

1. **Install Prerequisites:**
   ```powershell
   # Install Python
   winget install Python.Python.3.11
   
   # Install PyInstaller
   pip install pyinstaller
   
   # Install Inno Setup
   # Download from: https://jrsoftware.org/isinfo.php
   ```

2. **Clone Repository:**
   ```powershell
   git clone https://github.com/codykociemba/NoLongerEvil-Thermostat.git
   cd NoLongerEvil-Thermostat
   ```

3. **Build omap_loader:**
   ```powershell
   .\build.ps1
   ```

### Making Changes

#### Modifying the GUI

1. **Edit `NestFlasher.py`:**
   ```python
   # Example: Add a new button
   def setup_ui(self):
       # ... existing code ...
       self.new_button = ttk.Button(button_frame, text="New Feature", 
                                    command=self.new_feature)
       self.new_button.grid(row=0, column=3, padx=5)
   
   def new_feature(self):
       self.log("New feature activated!")
       # Add your code here
   ```

2. **Test changes:**
   ```powershell
   python NestFlasher.py
   ```

3. **Rebuild executable:**
   ```powershell
   .\build-gui.ps1
   ```

#### Modifying the Installer

1. **Edit `setup.iss`:**
   ```pascal
   ; Example: Add a new file to install
   [Files]
   Source: "mynewfile.txt"; DestDir: "{app}"; Flags: ignoreversion
   ```

2. **Test changes:**
   - Compile in Inno Setup Compiler
   - Or run: `.\build-installer.ps1`

3. **Test installer:**
   - Install on test VM
   - Verify all components work

### Testing Changes

1. **Unit Testing (GUI):**
   ```powershell
   # Run GUI manually to test UI
   python NestFlasher.py
   ```

2. **Integration Testing:**
   ```powershell
   # Build GUI
   .\build-gui.ps1
   
   # Test standalone executable
   .\NestFlasher.exe
   ```

3. **Installer Testing:**
   ```powershell
   # Build installer
   .\build-installer.ps1
   
   # Test on clean VM
   # Install, use, uninstall
   ```

## Common Modifications

### Adding a New Firmware Type

1. **Update `setup.iss`:**
   ```pascal
   [Components]
   Name: "firmware_custom"; Description: "Custom Firmware"; Types: custom
   ```

2. **Update `NestFlasher.py`:**
   ```python
   # Add radio button in setup_ui()
   ttk.Radiobutton(type_frame, text="Custom Mode", 
                  variable=self.firmware_type, value="custom")
   
   # Update download_firmware()
   if self.firmware_type.get() == "custom":
       firmware_url = "https://example.com/firmware-custom.zip"
   ```

### Changing Firmware URLs

Update in TWO places:

1. **`setup.iss`:**
   ```pascal
   if FirmwareType = 'standard' then
   begin
     DownloadPage.Add('https://NEW-URL/firmware-files.zip', ...);
   ```

2. **`NestFlasher.py`:**
   ```python
   firmware_url = "https://NEW-URL/firmware-files.zip"
   ```

### Adding Custom Installation Steps

In `setup.iss`:

```pascal
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Your custom code here
    // Example: Register file association
    Exec('cmd.exe', '/c assoc .nest=NestFile', '', SW_HIDE, ...);
  end;
end;
```

### Customizing UI Appearance

In `NestFlasher.py`:

```python
def setup_ui(self):
    # Change window size
    self.root.geometry("1000x700")  # Wider and taller
    
    # Change colors
    self.console = scrolledtext.ScrolledText(
        console_frame, 
        bg='#1e1e1e',      # Dark background
        fg='#00ff00',      # Green text
        font=('Courier New', 10)
    )
    
    # Add custom styling
    style = ttk.Style()
    style.configure('Custom.TButton', 
                   foreground='blue', 
                   font=('Arial', 12, 'bold'))
```

## Advanced Topics

### Adding Auto-Update Functionality

1. **Check for updates:**
   ```python
   import urllib.request
   import json
   
   def check_for_updates(self):
       try:
           response = urllib.request.urlopen(
               'https://api.github.com/repos/owner/repo/releases/latest'
           )
           data = json.loads(response.read())
           latest_version = data['tag_name']
           
           if latest_version > CURRENT_VERSION:
               self.show_update_notification(latest_version)
       except:
           pass  # Silently fail
   ```

2. **Add update button to GUI:**
   ```python
   self.update_button = ttk.Button(button_frame, text="Check for Updates",
                                   command=self.check_for_updates)
   ```

### Implementing Device Auto-Detection

Currently the GUI waits for manual DFU mode entry. To auto-detect:

```python
import usb.core
import usb.util

def detect_nest_device(self):
    """Detect if Nest is in DFU mode"""
    # Texas Instruments OMAP DFU mode
    # Vendor ID: 0x0451, Product ID varies by generation
    
    devices = usb.core.find(find_all=True, idVendor=0x0451)
    
    for device in devices:
        if device.idProduct in [0xD00E, 0xD010]:  # Gen 1/2 DFU PIDs
            return True
    
    return False

# Use in a monitoring thread
def monitor_for_device(self):
    while self.flashing_in_progress:
        if self.detect_nest_device():
            self.log("Device detected in DFU mode!")
            break
        time.sleep(0.5)
```

Note: Requires `pyusb` library

### Adding Logging to File

```python
import logging

def setup_logging(self):
    log_file = Path.home() / "AppData" / "Local" / "NoLongerEvil" / "flasher.log"
    log_file.parent.mkdir(parents=True, exist_ok=True)
    
    logging.basicConfig(
        filename=str(log_file),
        level=logging.DEBUG,
        format='%(asctime)s - %(levelname)s - %(message)s'
    )
    
def log(self, message):
    # Log to both console and file
    self.console.insert(tk.END, message + "\n")
    self.console.see(tk.END)
    logging.info(message)
```

### Digital Signing the Installer

For production releases:

1. **Obtain code signing certificate**
   - From a CA like DigiCert, Sectigo
   - Or use Windows Store certificate

2. **Sign the executable:**
   ```powershell
   # Sign GUI
   signtool sign /f certificate.pfx /p password /t http://timestamp.digicert.com NestFlasher.exe
   
   # Sign installer
   signtool sign /f certificate.pfx /p password /t http://timestamp.digicert.com NoLongerEvil-Thermostat-Setup.exe
   ```

3. **Update Inno Setup to sign:**
   ```pascal
   [Setup]
   SignTool=standard
   SignedUninstaller=yes
   ```

## Troubleshooting Development Issues

### PyInstaller Build Fails

**Issue:** Import errors or missing modules

**Solution:**
```powershell
# Explicitly include modules
pyinstaller --onefile --windowed `
  --hidden-import=tkinter `
  --hidden-import=urllib `
  --collect-all tkinter `
  NestFlasher.py
```

### Inno Setup Compile Errors

**Issue:** File not found during compile

**Solution:**
- Use absolute paths for Source files
- Or ensure paths are relative to script location
- Check that all referenced files exist

### GUI Doesn't Find omap_loader

**Issue:** Path detection fails when compiled

**Solution:**
```python
# Use this instead of __file__ path
if getattr(sys, 'frozen', False):
    # Running as compiled executable
    self.app_dir = Path(sys.executable).parent
else:
    # Running as script
    self.app_dir = Path(__file__).parent
```

## Performance Optimization

### Reducing Installer Size

1. **Compress better:**
   ```pascal
   [Setup]
   Compression=lzma2/ultra64
   SolidCompression=yes
   ```

2. **Exclude unnecessary files:**
   - Don't include debug symbols
   - Exclude test files
   - Use external firmware download instead of bundling

### Faster Firmware Download

```python
# Use chunks for large files
def download_with_progress(url, dest):
    response = urllib.request.urlopen(url)
    file_size = int(response.headers['Content-Length'])
    
    block_size = 8192
    downloaded = 0
    
    with open(dest, 'wb') as f:
        while True:
            chunk = response.read(block_size)
            if not chunk:
                break
            
            downloaded += len(chunk)
            f.write(chunk)
            
            # Update progress
            percent = (downloaded / file_size) * 100
            self.update_progress(percent)
```

## Security Considerations

### Input Validation

```python
def validate_firmware_url(self, url):
    """Ensure firmware URL is from trusted source"""
    allowed_domains = [
        'github.com',
        'raw.githubusercontent.com',
        'nolongerevil.com'
    ]
    
    from urllib.parse import urlparse
    domain = urlparse(url).netloc
    
    return any(domain.endswith(d) for d in allowed_domains)
```

### Secure Firmware Download

```python
import hashlib

def verify_firmware_checksum(self, file_path, expected_hash):
    """Verify downloaded firmware integrity"""
    sha256 = hashlib.sha256()
    
    with open(file_path, 'rb') as f:
        for chunk in iter(lambda: f.read(4096), b''):
            sha256.update(chunk)
    
    actual_hash = sha256.hexdigest()
    
    if actual_hash != expected_hash:
        raise ValueError(f"Checksum mismatch! Expected {expected_hash}, got {actual_hash}")
    
    return True
```

## Contributing

### Pull Request Process

1. **Fork and clone repository**
2. **Create feature branch:**
   ```bash
   git checkout -b feature/improved-gui
   ```

3. **Make changes and test thoroughly**
4. **Update documentation**
5. **Commit with clear messages:**
   ```bash
   git commit -m "Add device auto-detection to GUI"
   ```

6. **Push and create PR:**
   ```bash
   git push origin feature/improved-gui
   ```

### Code Style

**Python:**
- Follow PEP 8
- Use type hints where appropriate
- Add docstrings for functions
- Keep functions focused and small

**PowerShell:**
- Use approved verbs (Get-, Set-, New-, etc.)
- Add comment-based help
- Use meaningful variable names
- Handle errors gracefully

**Inno Setup:**
- Comment complex logic
- Use descriptive variable names
- Follow Inno Setup conventions

## Resources

### Documentation
- [Inno Setup Documentation](https://jrsoftware.org/ishelp/)
- [PyInstaller Manual](https://pyinstaller.org/en/stable/)
- [Tkinter Documentation](https://docs.python.org/3/library/tkinter.html)

### Tools
- [Inno Setup](https://jrsoftware.org/isinfo.php)
- [PyInstaller](https://pyinstaller.org/)
- [Zadig](https://zadig.akeo.ie/)

### Community
- [GitHub Discussions](https://github.com/codykociemba/NoLongerEvil-Thermostat/discussions)
- [Discord](https://discord.gg/hackhouse)

## Maintenance Checklist

### Regular Updates
- [ ] Update firmware URLs when new releases available
- [ ] Update Zadig version when new releases available
- [ ] Test with latest Windows updates
- [ ] Review and update documentation

### Security
- [ ] Review dependencies for vulnerabilities
- [ ] Update Python and libraries
- [ ] Scan compiled executables
- [ ] Renew code signing certificate

### Quality
- [ ] Run test suite before releases
- [ ] Check for UI/UX improvements
- [ ] Monitor user feedback
- [ ] Fix reported bugs promptly
