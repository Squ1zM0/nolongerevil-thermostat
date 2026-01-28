#!/usr/bin/env python3
"""
NoLongerEvil Nest Thermostat Flashing GUI
A user-friendly graphical interface for flashing custom firmware to Nest thermostats
"""

import sys
import os
import subprocess
import threading
import time
from pathlib import Path
import tkinter as tk
from tkinter import ttk, scrolledtext, messagebox
import winreg
import urllib.request
import zipfile
import tempfile

class NestFlasherGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("NoLongerEvil Nest Thermostat Flasher")
        self.root.geometry("800x600")
        self.root.resizable(False, False)
        
        # Set icon if available
        try:
            icon_path = Path(__file__).parent / "icon.ico"
            if icon_path.exists():
                self.root.iconbitmap(str(icon_path))
        except:
            pass
        
        # Variables
        self.firmware_type = tk.StringVar(value="standard")
        self.nest_generation = tk.IntVar(value=2)
        self.flashing_in_progress = False
        self.process = None
        
        # Determine installation paths
        if getattr(sys, 'frozen', False):
            # Running as compiled executable
            self.app_dir = Path(sys.executable).parent
        else:
            # Running as script
            self.app_dir = Path(__file__).parent.parent
        
        self.bin_dir = self.app_dir / "bin"
        self.firmware_dir = self.app_dir / "firmware"
        
        self.setup_ui()
        self.check_prerequisites()
    
    def setup_ui(self):
        """Setup the user interface"""
        # Main container
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Title
        title_label = ttk.Label(main_frame, text="NoLongerEvil Nest Thermostat Flasher", 
                                font=('Arial', 16, 'bold'))
        title_label.grid(row=0, column=0, columnspan=2, pady=(0, 20))
        
        # Firmware Type Selection
        type_frame = ttk.LabelFrame(main_frame, text="1. Select Firmware Type", padding="10")
        type_frame.grid(row=1, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=5)
        
        ttk.Radiobutton(type_frame, text="Full Thermostat Mode (Cloud-connected, full features)", 
                       variable=self.firmware_type, value="standard").grid(row=0, column=0, sticky=tk.W)
        ttk.Radiobutton(type_frame, text="Display-Only Mode (Temperature monitor, NO thermostat)", 
                       variable=self.firmware_type, value="local-only").grid(row=1, column=0, sticky=tk.W)
        
        # Generation Selection
        gen_frame = ttk.LabelFrame(main_frame, text="2. Select Nest Generation", padding="10")
        gen_frame.grid(row=2, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=5)
        
        ttk.Radiobutton(gen_frame, text="Generation 1", 
                       variable=self.nest_generation, value=1).grid(row=0, column=0, sticky=tk.W, padx=(0, 20))
        ttk.Radiobutton(gen_frame, text="Generation 2", 
                       variable=self.nest_generation, value=2).grid(row=0, column=1, sticky=tk.W)
        
        ttk.Label(gen_frame, text="Tip: Check the back plate - green bubble level = Gen 1/2", 
                 font=('Arial', 8, 'italic')).grid(row=1, column=0, columnspan=2, sticky=tk.W, pady=(5, 0))
        
        # Instructions
        inst_frame = ttk.LabelFrame(main_frame, text="3. Prepare Your Device", padding="10")
        inst_frame.grid(row=3, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=5)
        
        instructions = [
            "1. Ensure your Nest is charged (50%+ recommended)",
            "2. Remove the Nest from the wall mount",
            "3. Connect it to your computer via micro USB",
            "4. Press and hold the display for 10-15 seconds to reboot",
            "5. Click 'Start Flashing' below and wait for DFU mode"
        ]
        
        for i, inst in enumerate(instructions):
            ttk.Label(inst_frame, text=inst, font=('Arial', 9)).grid(row=i, column=0, sticky=tk.W, pady=2)
        
        # Action Buttons
        button_frame = ttk.Frame(main_frame)
        button_frame.grid(row=4, column=0, columnspan=2, pady=10)
        
        self.flash_button = ttk.Button(button_frame, text="Start Flashing", 
                                       command=self.start_flashing, width=20)
        self.flash_button.grid(row=0, column=0, padx=5)
        
        self.driver_button = ttk.Button(button_frame, text="Install USB Drivers", 
                                       command=self.install_drivers, width=20)
        self.driver_button.grid(row=0, column=1, padx=5)
        
        self.stop_button = ttk.Button(button_frame, text="Stop", 
                                     command=self.stop_flashing, width=20, state='disabled')
        self.stop_button.grid(row=0, column=2, padx=5)
        
        # Progress bar
        self.progress = ttk.Progressbar(main_frame, mode='indeterminate')
        self.progress.grid(row=5, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=5)
        
        # Status label
        self.status_label = ttk.Label(main_frame, text="Ready to flash", font=('Arial', 10))
        self.status_label.grid(row=6, column=0, columnspan=2, pady=5)
        
        # Output console
        console_frame = ttk.LabelFrame(main_frame, text="Output Log", padding="5")
        console_frame.grid(row=7, column=0, columnspan=2, sticky=(tk.W, tk.E, tk.N, tk.S), pady=5)
        
        self.console = scrolledtext.ScrolledText(console_frame, height=12, width=90, 
                                                 bg='black', fg='green', font=('Consolas', 9))
        self.console.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Configure grid weights
        main_frame.columnconfigure(0, weight=1)
        main_frame.rowconfigure(7, weight=1)
        console_frame.columnconfigure(0, weight=1)
        console_frame.rowconfigure(0, weight=1)
    
    def log(self, message):
        """Add message to console"""
        self.console.insert(tk.END, message + "\n")
        self.console.see(tk.END)
        self.root.update_idletasks()
    
    def check_prerequisites(self):
        """Check if required files exist"""
        self.log("Checking prerequisites...")
        
        # Check for omap_loader
        omap_loader = self.bin_dir / "windows-x64" / "omap_loader.exe"
        if not omap_loader.exists():
            self.log(f"ERROR: omap_loader.exe not found at {omap_loader}")
            self.log("Please ensure the application is installed correctly.")
            self.flash_button.config(state='disabled')
            return False
        else:
            self.log(f"✓ Found omap_loader at {omap_loader}")
        
        # Check for firmware directory
        if not self.firmware_dir.exists():
            self.log(f"WARNING: Firmware directory not found at {self.firmware_dir}")
            self.log("Firmware will be downloaded when flashing starts.")
        else:
            self.log(f"✓ Firmware directory exists")
        
        self.log("\nReady to flash! Select your options and click 'Start Flashing'.\n")
        return True
    
    def download_firmware(self):
        """Download firmware files if needed"""
        self.log("\nChecking firmware files...")
        
        if self.firmware_type.get() == "local-only":
            firmware_url = "https://github.com/codykociemba/NoLongerEvil-Thermostat/releases/download/v1.0.0/firmware-local-only.zip"
        else:
            firmware_url = "https://github.com/codykociemba/NoLongerEvil-Thermostat/releases/download/v1.0.0/firmware-files.zip"
        
        # Check if firmware files already exist
        gen = self.nest_generation.get()
        x_load_file = self.firmware_dir / f"x-load-gen{gen}.bin"
        
        if x_load_file.exists():
            # Check if file is recent (within 1 hour)
            file_age = time.time() - x_load_file.stat().st_mtime
            if file_age < 3600:
                self.log("✓ Using existing firmware files (recently downloaded)")
                return True
        
        # Download firmware
        self.log(f"Downloading firmware from {firmware_url}...")
        self.status_label.config(text="Downloading firmware...")
        
        try:
            # Create firmware directory if it doesn't exist
            self.firmware_dir.mkdir(parents=True, exist_ok=True)
            
            # Download to temp file
            temp_zip = tempfile.mktemp(suffix='.zip')
            urllib.request.urlretrieve(firmware_url, temp_zip)
            
            self.log("✓ Download complete, extracting...")
            
            # Extract firmware
            with zipfile.ZipFile(temp_zip, 'r') as zip_ref:
                zip_ref.extractall(self.firmware_dir)
            
            os.remove(temp_zip)
            self.log("✓ Firmware extracted successfully")
            return True
            
        except Exception as e:
            self.log(f"ERROR downloading firmware: {str(e)}")
            messagebox.showerror("Download Error", 
                               f"Failed to download firmware:\n{str(e)}\n\nPlease check your internet connection.")
            return False
    
    def install_drivers(self):
        """Launch Zadig for driver installation"""
        self.log("\nLaunching USB driver installer...")
        
        zadig_path = self.app_dir / "drivers" / "zadig-2.8.exe"
        
        if not zadig_path.exists():
            messagebox.showinfo("Driver Installation", 
                              "USB drivers are not included in this installation.\n\n"
                              "Please download Zadig from:\n"
                              "https://zadig.akeo.ie/\n\n"
                              "Instructions:\n"
                              "1. Put your Nest in DFU mode first\n"
                              "2. In Zadig, select Options -> List All Devices\n"
                              "3. Find 'Texas Instruments OMAP'\n"
                              "4. Select 'WinUSB' or 'libusb-win32' as driver\n"
                              "5. Click 'Install Driver'")
            return
        
        try:
            subprocess.Popen([str(zadig_path)])
            self.log("✓ Zadig launched")
            messagebox.showinfo("Driver Installation", 
                              "Zadig USB driver installer has been launched.\n\n"
                              "Instructions:\n"
                              "1. Put your Nest in DFU mode first\n"
                              "2. In Zadig, select Options -> List All Devices\n"
                              "3. Find 'Texas Instruments OMAP'\n"
                              "4. Select 'WinUSB' or 'libusb-win32' as driver\n"
                              "5. Click 'Install Driver'")
        except Exception as e:
            self.log(f"ERROR launching Zadig: {str(e)}")
            messagebox.showerror("Error", f"Failed to launch driver installer:\n{str(e)}")
    
    def start_flashing(self):
        """Start the flashing process"""
        if self.flashing_in_progress:
            messagebox.showwarning("Already Flashing", "Flashing is already in progress!")
            return
        
        # Confirm local-only mode
        if self.firmware_type.get() == "local-only":
            response = messagebox.askyesno("Confirm Display-Only Mode",
                                          "You selected Display-Only Mode.\n\n"
                                          "WARNING: Your Nest will NOT control heating or cooling!\n"
                                          "It will ONLY display temperature and humidity.\n\n"
                                          "Continue?")
            if not response:
                return
        
        # Download firmware if needed
        if not self.download_firmware():
            return
        
        # Start flashing thread
        self.flashing_in_progress = True
        self.flash_button.config(state='disabled')
        self.stop_button.config(state='normal')
        self.progress.start()
        
        thread = threading.Thread(target=self.flash_firmware, daemon=True)
        thread.start()
    
    def flash_firmware(self):
        """Flash firmware to the device (runs in separate thread)"""
        try:
            self.log("\n" + "="*60)
            self.log("Starting firmware flashing process...")
            self.log("="*60 + "\n")
            
            self.status_label.config(text="Waiting for device in DFU mode...")
            
            # Prepare firmware paths
            gen = self.nest_generation.get()
            firmware_suffix = "-simple" if self.firmware_type.get() == "local-only" else ""
            
            x_load = self.firmware_dir / f"x-load-gen{gen}{firmware_suffix}.bin"
            if not x_load.exists():
                x_load = self.firmware_dir / f"x-load-gen{gen}.bin"
            
            u_boot = self.firmware_dir / f"u-boot{firmware_suffix}.bin"
            if not u_boot.exists():
                u_boot = self.firmware_dir / "u-boot.bin"
            
            uimage = self.firmware_dir / f"uImage{firmware_suffix}"
            if not uimage.exists():
                uimage = self.firmware_dir / "uImage"
            
            # Verify files exist
            for file in [x_load, u_boot, uimage]:
                if not file.exists():
                    self.log(f"ERROR: Required firmware file not found: {file}")
                    messagebox.showerror("Error", f"Firmware file missing:\n{file.name}")
                    return
            
            self.log(f"Using firmware files:")
            self.log(f"  x-load: {x_load.name}")
            self.log(f"  u-boot: {u_boot.name}")
            self.log(f"  uImage: {uimage.name}")
            self.log("")
            
            # Build command
            omap_loader = self.bin_dir / "windows-x64" / "omap_loader.exe"
            
            cmd = [
                str(omap_loader),
                "-f", str(x_load),
                "-f", str(u_boot),
                "-a", "0x80100000",
                "-f", str(uimage),
                "-a", "0x80A00000",
                "-v",
                "-j", "0x80100000"
            ]
            
            self.log("Executing: " + " ".join([c if ' ' not in c else f'"{c}"' for c in cmd]))
            self.log("\nWaiting for device to enter DFU mode...")
            self.log("(Reboot your Nest now by holding the display for 10-15 seconds)\n")
            
            # Run omap_loader
            self.process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                universal_newlines=True,
                bufsize=1
            )
            
            # Read output
            for line in self.process.stdout:
                self.log(line.rstrip())
            
            self.process.wait()
            
            if self.process.returncode == 0:
                self.log("\n" + "="*60)
                self.log("SUCCESS! Firmware flashed successfully!")
                self.log("="*60 + "\n")
                
                if self.firmware_type.get() == "local-only":
                    self.log("Next steps:")
                    self.log("1. Keep device plugged in via USB")
                    self.log("2. Wait 2-3 minutes for device to boot")
                    self.log("3. Device will show temperature and humidity")
                    self.log("\nNo internet or account setup required!")
                else:
                    self.log("Next steps:")
                    self.log("1. Keep device plugged in via USB")
                    self.log("2. Wait 2-3 minutes for device to boot")
                    self.log("3. Visit https://nolongerevil.com to register")
                    self.log("4. Link device using entry code from:")
                    self.log("   Settings → Nest App → Get Entry Code")
                
                self.status_label.config(text="Flashing complete!")
                messagebox.showinfo("Success", "Firmware flashed successfully!\n\nSee console for next steps.")
            else:
                self.log("\n" + "="*60)
                self.log("ERROR: Flashing failed!")
                self.log("="*60 + "\n")
                self.log("Please check:")
                self.log("- Device is connected via USB")
                self.log("- Device entered DFU mode correctly")
                self.log("- USB drivers are installed")
                self.log("\nTry running this application as Administrator.")
                
                self.status_label.config(text="Flashing failed - see console")
                messagebox.showerror("Error", "Flashing failed!\n\nCheck the console for details.")
        
        except Exception as e:
            self.log(f"\nEXCEPTION: {str(e)}")
            self.status_label.config(text="Error occurred")
            messagebox.showerror("Error", f"An error occurred:\n{str(e)}")
        
        finally:
            self.flashing_in_progress = False
            self.flash_button.config(state='normal')
            self.stop_button.config(state='disabled')
            self.progress.stop()
            self.process = None
    
    def stop_flashing(self):
        """Stop the flashing process"""
        if self.process:
            self.log("\nStopping flashing process...")
            self.process.terminate()
            self.flashing_in_progress = False
            self.status_label.config(text="Flashing stopped")
            self.flash_button.config(state='normal')
            self.stop_button.config(state='disabled')
            self.progress.stop()


def main():
    root = tk.Tk()
    app = NestFlasherGUI(root)
    root.mainloop()


if __name__ == "__main__":
    main()
