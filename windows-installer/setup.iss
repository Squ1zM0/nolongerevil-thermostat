; Inno Setup Script for NoLongerEvil Thermostat Windows Installer
; This creates an all-in-one Windows installer with GUI

#define MyAppName "NoLongerEvil Thermostat"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "NoLongerEvil"
#define MyAppURL "https://nolongerevil.com"
#define MyAppExeName "NestFlasher.exe"

[Setup]
; Basic application information
AppId={{8B7C9D2E-4F1A-4B3D-9E2C-1D5F6A8B9C0D}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=..\LICENSE
OutputDir=..\bin\installer
OutputBaseFilename=NoLongerEvil-Thermostat-Setup
SetupIconFile=icon.ico
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Types]
Name: "full"; Description: "Full Thermostat Mode (with cloud connectivity)"
Name: "localonly"; Description: "Display-Only Mode (temperature monitor only)"
Name: "custom"; Description: "Custom installation"; Flags: iscustom

[Components]
Name: "core"; Description: "Core Files (omap_loader, firmware)"; Types: full localonly custom; Flags: fixed
Name: "gui"; Description: "Graphical Flashing Tool"; Types: full localonly custom
Name: "drivers"; Description: "USB Drivers (required for flashing)"; Types: full localonly custom
Name: "firmware_standard"; Description: "Standard Firmware (Full Thermostat)"; Types: full; Flags: exclusive
Name: "firmware_local"; Description: "Local-Only Firmware (Display Only)"; Types: localonly; Flags: exclusive

[Files]
; Core executable files
Source: "..\bin\windows-x64\omap_loader.exe"; DestDir: "{app}\bin"; Flags: ignoreversion; Components: core
Source: "NestFlasher.exe"; DestDir: "{app}"; Flags: ignoreversion; Components: gui
Source: "FlashingGUI.exe"; DestDir: "{app}"; Flags: ignoreversion; Components: gui

; Firmware files - will be downloaded during installation
Source: "..\bin\firmware\*.bin"; DestDir: "{app}\firmware"; Flags: ignoreversion external skipifsourcedoesntexist; Components: core
Source: "..\bin\firmware\uImage*"; DestDir: "{app}\firmware"; Flags: ignoreversion external skipifsourcedoesntexist; Components: core

; Configuration files
Source: "..\configs\*"; DestDir: "{app}\configs"; Flags: ignoreversion recursesubdirs; Components: core

; Scripts
Source: "..\install.ps1"; DestDir: "{app}\scripts"; Flags: ignoreversion; Components: core
Source: "..\build.ps1"; DestDir: "{app}\scripts"; Flags: ignoreversion; Components: core

; USB Drivers (Zadig)
Source: "drivers\zadig-2.8.exe"; DestDir: "{app}\drivers"; Flags: ignoreversion; Components: drivers

; Documentation
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion isreadme; Components: core
Source: "..\LOCAL_MODE.md"; DestDir: "{app}"; Flags: ignoreversion; Components: core
Source: "..\LICENSE"; DestDir: "{app}"; Flags: ignoreversion; Components: core

[Icons]
Name: "{group}\{#MyAppName} Flasher"; Filename: "{app}\{#MyAppExeName}"; Components: gui
Name: "{group}\USB Driver Installation"; Filename: "{app}\drivers\zadig-2.8.exe"; Components: drivers
Name: "{group}\Documentation"; Filename: "{app}\README.md"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; Components: gui

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Code]
var
  ModePage: TInputOptionWizardPage;
  DownloadPage: TDownloadWizardPage;
  FirmwareType: String;

procedure InitializeWizard;
begin
  // Create custom page for mode selection
  ModePage := CreateInputOptionPage(wpSelectComponents,
    'Installation Mode', 'Choose how you want to use your Nest Thermostat',
    'Select the mode that best fits your needs:',
    True, False);
  
  ModePage.Add('Full Thermostat Mode (Recommended)');
  ModePage.Add('Display-Only Mode (Temperature Monitor)');
  
  ModePage.Values[0] := True;
  
  // Create download page
  DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), nil);
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  ResultCode: Integer;
begin
  Result := True;
  
  if CurPageID = ModePage.ID then
  begin
    if ModePage.Values[0] then
    begin
      FirmwareType := 'standard';
      WizardForm.TypesCombo.ItemIndex := 0; // Full
    end
    else
    begin
      FirmwareType := 'localonly';
      WizardForm.TypesCombo.ItemIndex := 1; // Local Only
      
      // Show warning for local-only mode
      MsgBox('WARNING: Display-Only Mode will NOT control heating or cooling.' + #13#10#13#10 +
             'Your Nest will only display temperature and humidity.' + #13#10 +
             'It will NOT function as a thermostat!', mbInformation, MB_OK);
    end;
  end;
  
  if CurPageID = wpReady then
  begin
    // Download firmware files before installation
    DownloadPage.Clear;
    
    if FirmwareType = 'localonly' then
    begin
      DownloadPage.Add('https://github.com/codykociemba/NoLongerEvil-Thermostat/releases/download/v1.0.0/firmware-local-only.zip', 
                       'firmware.zip', '');
    end
    else
    begin
      DownloadPage.Add('https://github.com/codykociemba/NoLongerEvil-Thermostat/releases/download/v1.0.0/firmware-files.zip',
                       'firmware.zip', '');
    end;
    
    DownloadPage.Show;
    try
      try
        DownloadPage.Download;
        Result := True;
      except
        if DownloadPage.AbortedByUser then
          Log('Download aborted by user.')
        else
          SuppressibleMsgBox(AddPeriod(GetExceptionMessage), mbCriticalError, MB_OK, IDOK);
        Result := False;
      end;
    finally
      DownloadPage.Hide;
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
  FirmwareZip: String;
  FirmwareDir: String;
begin
  if CurStep = ssPostInstall then
  begin
    // Extract firmware files
    FirmwareZip := ExpandConstant('{tmp}\firmware.zip');
    FirmwareDir := ExpandConstant('{app}\firmware');
    
    if FileExists(FirmwareZip) then
    begin
      // Use PowerShell to extract
      Exec('powershell.exe', 
           '-ExecutionPolicy Bypass -Command "Expand-Archive -Path ''' + FirmwareZip + ''' -DestinationPath ''' + FirmwareDir + ''' -Force"',
           '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    end;
  end;
end;

[Run]
; Optionally launch the GUI after installation
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent; Components: gui

[UninstallDelete]
Type: filesandordirs; Name: "{app}\firmware"
Type: filesandordirs; Name: "{app}\bin"
