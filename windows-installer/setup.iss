; Inno Setup Script for NoLongerEvil Thermostat Windows Installer
; This creates an all-in-one Windows installer with GUI

#define MyAppName "NoLongerEvil Thermostat"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "NoLongerEvil"
#define MyAppURL "https://nolongerevil.com"
#define MyAppExeName "NestFlasher.exe"
#define FirmwareVersion "v1.0.0"

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
  RetryCount: Integer;
  MaxRetries: Integer;
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
    
    // Use the same firmware for both modes - firmware-files.zip is the only available release asset
    DownloadPage.Add('https://github.com/codykociemba/NoLongerEvil-Thermostat/releases/download/{#FirmwareVersion}/firmware-files.zip',
                     'firmware.zip', '');
    
    MaxRetries := 3;
    RetryCount := 0;
    
    while RetryCount < MaxRetries do
    begin
      DownloadPage.Show;
      try
        try
          DownloadPage.Download;
          Result := True;
          break;
        except
          if DownloadPage.AbortedByUser then
          begin
            Log('Download aborted by user.');
            Result := False;
            break;
          end
          else
          begin
            RetryCount := RetryCount + 1;
            if RetryCount >= MaxRetries then
            begin
              if MsgBox('Failed to download firmware files.' + #13#10#13#10 +
                       'You can continue installation and download firmware manually later.' + #13#10#13#10 +
                       'Continue installation?', mbError, MB_YESNO) = IDYES then
              begin
                Result := True;
                break;
              end
              else
              begin
                Result := False;
                break;
              end;
            end
            else
            begin
              if MsgBox('Download failed. Retry?' + #13#10#13#10 +
                       'Attempt ' + IntToStr(RetryCount) + ' of ' + IntToStr(MaxRetries),
                       mbError, MB_YESNO) = IDNO then
              begin
                Result := False;
                break;
              end;
            end;
          end;
        end;
      finally
        DownloadPage.Hide;
      end;
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
  FirmwareZip: String;
  FirmwareDir: String;
  PSCommand: String;
begin
  if CurStep = ssPostInstall then
  begin
    // Extract firmware files using PowerShell with proper path escaping
    FirmwareZip := ExpandConstant('{tmp}\firmware.zip');
    FirmwareDir := ExpandConstant('{app}\firmware');
    
    if FileExists(FirmwareZip) then
    begin
      // Build PowerShell command with proper escaping
      // Use single quotes around paths to prevent injection
      PSCommand := '-ExecutionPolicy Bypass -Command "& {' +
                   'Expand-Archive -LiteralPath ''' + FirmwareZip + ''' ' +
                   '-DestinationPath ''' + FirmwareDir + ''' -Force' +
                   '}"';
      
      Exec('powershell.exe', PSCommand, '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
      
      if ResultCode <> 0 then
      begin
        Log('Firmware extraction failed with code: ' + IntToStr(ResultCode));
        // Not fatal - user can download firmware later
      end;
    end;
  end;
end;

[Run]
; Optionally launch the GUI after installation
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent; Components: gui

[UninstallDelete]
Type: filesandordirs; Name: "{app}\firmware"
Type: filesandordirs; Name: "{app}\bin"
