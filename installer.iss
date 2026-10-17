; Himalaya Installer Script for Inno Setup
; Requires Inno Setup 6.3.0 or later (for dark mode support)

#define MyAppName "Himalaya"
#define MyAppPublisher "scobru"
#define MyAppURL "https://github.com/scobru/himalaya"
#define MyAppExeName "Himalaya.exe"

; Version is read from VERSION file during build
#ifndef MyAppVersion
  #define MyAppVersion "1.0.0"
#endif

[Setup]
AppId={{4E2EA4A1-0EA5-4945-A9A5-1CF67973AD7E}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=LICENSE
OutputDir=releases\{#MyAppVersion}
OutputBaseFilename=Himalaya_{#MyAppVersion}_Windows_Setup
SetupIconFile=cmake\icon.ico
UninstallDisplayIcon={uninstallexe}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern dynamic zircon
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64
DisableDirPage=no
DisableWelcomePage=no
DisableReadyPage=no
DisableFinishedPage=no
ShowLanguageDialog=no
UsePreviousAppDir=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Types]
Name: "full"; Description: "Full installation"
Name: "compact"; Description: "Compact installation"
Name: "custom"; Description: "Custom installation"; Flags: iscustom

[Components]
Name: "standalone"; Description: "Standalone Application"; Types: full custom
Name: "vst3"; Description: "VST3 Plugin"; Types: full compact custom
Name: "clap"; Description: "CLAP Plugin"; Types: full compact custom
Name: "aax"; Description: "AAX Plugin (Pro Tools)"; Types: full custom

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Components: standalone; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Components: standalone; Flags: unchecked; OnlyBelowVersion: 6.1

[Files]
; Standalone Application
Source: "build\plugin\Himalaya_artefacts\Release\Standalone\Himalaya.exe"; DestDir: "{code:GetStandalonePath}"; Flags: ignoreversion; Components: standalone
Source: "build\plugin\Himalaya_artefacts\Release\Standalone\*.dll"; DestDir: "{code:GetStandalonePath}"; Flags: ignoreversion skipifsourcedoesntexist; Components: standalone

; VST3 Plugin
Source: "build\plugin\Himalaya_artefacts\Release\VST3\Himalaya.vst3\*"; DestDir: "{code:GetVST3Path}\Himalaya.vst3"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: vst3

; CLAP Plugin â€” å˜ä¸€ãƒ•ã‚¡ã‚¤ãƒ«ï¼ˆ.clap = DLL ã«æ‹¡å¼µå­ã‚’ä»˜ã‘ãŸã‚‚ã®ï¼‰
Source: "releases\{#MyAppVersion}\Windows\Himalaya.clap"; DestDir: "{code:GetCLAPPath}"; Flags: ignoreversion; Components: clap

; AAX Plugin â€” ãƒãƒ³ãƒ‰ãƒ«å…¨ä½“ã‚’ä¸¸ã”ã¨ã‚³ãƒ”ãƒ¼ï¼ˆå…¥ã‚Œå­ã¯ PrepareToInstall ã§äº‹å‰å‰Šé™¤ã«ã‚ˆã‚Šé˜²æ­¢ï¼‰
Source: "releases\{#MyAppVersion}\Windows\Himalaya.aaxplugin\*"; DestDir: "{code:GetAAXPath}\Himalaya.aaxplugin"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: aax


; License and Documentation (install to standalone path if selected, otherwise to program files)
Source: "LICENSE"; DestDir: "{code:GetDocPath}"; Flags: ignoreversion

; Visual C++ Redistributable will be downloaded only if needed

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{code:GetStandalonePath}\{#MyAppExeName}"; Components: standalone
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{code:GetStandalonePath}\{#MyAppExeName}"; Tasks: desktopicon; Components: standalone
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{code:GetStandalonePath}\{#MyAppExeName}"; Tasks: quicklaunchicon; Components: standalone

[Run]
; Install Visual C++ Redistributable only if needed
Filename: "{tmp}\vc_redist.x64.exe"; Parameters: "/quiet /norestart"; StatusMsg: "Installing Microsoft Visual C++ Redistributables..."; Check: NeedsVCRedist; Flags: waituntilterminated

; Optionally run the standalone app after installation (disabled)
; Filename: "{code:GetStandalonePath}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent; Components: standalone

[UninstallDelete]
; Clean up any generated files
Type: filesandordirs; Name: "{code:GetStandalonePath}\logs"
Type: filesandordirs; Name: "{code:GetStandalonePath}\presets"
Type: filesandordirs; Name: "{localappdata}\Himalaya"
Type: filesandordirs; Name: "{userappdata}\Himalaya"

[Registry]
; Register VST3 plugin location
Root: HKLM64; Subkey: "Software\VST3"; ValueType: string; ValueName: "Himalaya"; ValueData: "{code:GetVST3Path}\Himalaya.vst3"; Flags: uninsdeletevalue; Components: vst3

; Register CLAP plugin locationï¼ˆCLAP è¦ç´„ã«åŽ³å¯†ãªãƒ¬ã‚¸ã‚¹ãƒˆãƒªè¦ä»¶ã¯ç„¡ã„ãŒã€å‚ç…§ç”¨ã«åŒã˜ãƒ‘ã‚¿ãƒ¼ãƒ³ã§æ®‹ã™ï¼‰
Root: HKLM64; Subkey: "Software\CLAP"; ValueType: string; ValueName: "Himalaya"; ValueData: "{code:GetCLAPPath}\Himalaya.clap"; Flags: uninsdeletevalue; Components: clap

; Register AAX plugin location
Root: HKLM64; Subkey: "Software\Avid\ProTools\AAX"; ValueType: string; ValueName: "Himalaya"; ValueData: "{code:GetAAXPath}\Himalaya.aaxplugin"; Flags: uninsdeletevalue; Components: aax

[Code]
var
  DownloadPage: TDownloadWizardPage;
  VCRedistNeeded: Boolean;
  PathSelectionPage: TInputDirWizardPage;
  StandalonePath: String;
  VST3Path: String;
  CLAPPath: String;
  AAXPath: String;

function NeedsVCRedist(): Boolean;
var
  Version: String;
begin
  // Check for Visual C++ 2019-2022 Redistributable (14.30 or higher)
  // These versions share the same registry keys
  Result := not (RegQueryStringValue(HKLM64, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Version', Version) or
                 RegQueryStringValue(HKLM64, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\X64', 'Version', Version) or
                 RegQueryStringValue(HKLM64, 'SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Version', Version));

  if not Result then
  begin
    Log('Visual C++ Runtime found: ' + Version);
    // Check if version is 14.30 or higher (VS2019-2022)
    if CompareStr(Version, 'v14.30') < 0 then
    begin
      Result := True;
      Log('Visual C++ Runtime version too old, update needed');
    end;
  end
  else
  begin
    Log('Visual C++ Runtime not found, installation needed');
  end;

  VCRedistNeeded := Result;
end;

function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
begin
  if Progress = ProgressMax then
    Log(Format('Successfully downloaded file to {tmp}: %s', [FileName]));
  Result := True;
end;

procedure InitializeWizard;
begin
  VCRedistNeeded := False;

  // Create download page for Visual C++ Redistributable
  DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), @OnDownloadProgress);

  // Create custom directory selection page (shown after component selection)
  PathSelectionPage := CreateInputDirPage(wpSelectComponents,
    'Select Installation Paths',
    'Where should each component be installed?',
    'Select the installation folders for each component you have chosen to install.',
    False, '');

  // Add input fields for each component
  PathSelectionPage.Add('Standalone Application:');
  PathSelectionPage.Values[0] := ExpandConstant('{autopf}\Himalaya');

  PathSelectionPage.Add('VST3 Plugin:');
  PathSelectionPage.Values[1] := ExpandConstant('{commoncf64}\VST3');

  PathSelectionPage.Add('CLAP Plugin:');
  PathSelectionPage.Values[2] := ExpandConstant('{commoncf64}\CLAP');

  PathSelectionPage.Add('AAX Plugin (Pro Tools):');
  PathSelectionPage.Values[3] := ExpandConstant('{commoncf64}\Avid\Audio\Plug-Ins');
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := False;

  // Skip the default directory page since we use custom path selection
  if PageID = wpSelectDir then
  begin
    Result := True;
  end
  // Skip the path selection page if no components are selected
  else if PageID = PathSelectionPage.ID then
  begin
    Result := not (IsComponentSelected('standalone') or IsComponentSelected('vst3') or IsComponentSelected('clap') or IsComponentSelected('aax'));

    // Dynamically show/hide path inputs based on selected components
    if not Result then
    begin
      PathSelectionPage.Edits[0].Visible := IsComponentSelected('standalone');
      PathSelectionPage.Buttons[0].Visible := IsComponentSelected('standalone');
      PathSelectionPage.PromptLabels[0].Visible := IsComponentSelected('standalone');

      PathSelectionPage.Edits[1].Visible := IsComponentSelected('vst3');
      PathSelectionPage.Buttons[1].Visible := IsComponentSelected('vst3');
      PathSelectionPage.PromptLabels[1].Visible := IsComponentSelected('vst3');

      PathSelectionPage.Edits[2].Visible := IsComponentSelected('clap');
      PathSelectionPage.Buttons[2].Visible := IsComponentSelected('clap');
      PathSelectionPage.PromptLabels[2].Visible := IsComponentSelected('clap');

      PathSelectionPage.Edits[3].Visible := IsComponentSelected('aax');
      PathSelectionPage.Buttons[3].Visible := IsComponentSelected('aax');
      PathSelectionPage.PromptLabels[3].Visible := IsComponentSelected('aax');
    end;
  end
  else if PageID = DownloadPage.ID then
    Result := not VCRedistNeeded;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;

  // Store the selected paths when leaving the path selection page
  if CurPageID = PathSelectionPage.ID then
  begin
    StandalonePath := PathSelectionPage.Values[0];
    VST3Path := PathSelectionPage.Values[1];
    CLAPPath := PathSelectionPage.Values[2];
    AAXPath := PathSelectionPage.Values[3];
  end
  else if CurPageID = wpReady then
  begin
    // Check and download Visual C++ Redistributable only if needed
    if NeedsVCRedist() then
    begin
      if MsgBox('Microsoft Visual C++ Redistributables are required but not installed.' + #13#10 + #13#10 +
                'Would you like to download and install them now?' + #13#10 +
                '(Required for Himalaya to run properly)', mbConfirmation, MB_YESNO) = IDYES then
      begin
        DownloadPage.Clear;
        DownloadPage.Add('https://aka.ms/vs/17/release/vc_redist.x64.exe', 'vc_redist.x64.exe', '');
        DownloadPage.Show;
        try
          DownloadPage.Download;
          Result := True;
        except
          MsgBox('Failed to download Visual C++ Redistributables.' + #13#10 +
                 'Himalaya may not work properly without them.' + #13#10 + #13#10 +
                 'You can download them manually from:' + #13#10 +
                 'https://aka.ms/vs/17/release/vc_redist.x64.exe', mbError, MB_OK);
          Result := True; // Continue installation anyway
        end;
      end
      else
      begin
        MsgBox('Warning: Himalaya may not work without Visual C++ Redistributables.' + #13#10 + #13#10 +
               'You can download them later from:' + #13#10 +
               'https://aka.ms/vs/17/release/vc_redist.x64.exe', mbInformation, MB_OK);
      end;
    end
    else
    begin
      Log('Visual C++ Redistributables already installed, skipping download');
    end;
  end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  TestFile: String;
  FileLocked: Boolean;
  TargetPath: String;
begin
  Result := '';
  FileLocked := False;

  // Check if VST3 plugin file is locked (in use by a DAW)
  if IsComponentSelected('vst3') then
  begin
    // Use the stored path or default
    if VST3Path <> '' then
      TargetPath := VST3Path
    else
      TargetPath := ExpandConstant('{commoncf64}\VST3');

    TestFile := TargetPath + '\Himalaya.vst3\Contents\x86_64-win\Himalaya.vst3';
    if FileExists(TestFile) then
    begin
      FileLocked := not DeleteFile(TestFile);
      if FileLocked then
      begin
        Log('VST3 plugin appears to be in use (file locked)');
        if MsgBox('The VST3 plugin appears to be in use by a DAW.' + #13#10 + #13#10 +
                  'Please close any DAW that might be using Himalaya and try again.' + #13#10 + #13#10 +
                  'Continue anyway? (Installation may fail)', mbConfirmation, MB_YESNO) = IDNO then
        begin
          Result := 'Plugin files are locked. Please close your DAW and try again.';
          Exit;
        end;
      end;
    end;
  end;

  // Check if CLAP plugin file is locked
  if IsComponentSelected('clap') and not FileLocked then
  begin
    if CLAPPath <> '' then
      TargetPath := CLAPPath
    else
      TargetPath := ExpandConstant('{commoncf64}\CLAP');

    TestFile := TargetPath + '\Himalaya.clap';
    if FileExists(TestFile) then
    begin
      FileLocked := not DeleteFile(TestFile);
      if FileLocked then
      begin
        Log('CLAP plugin appears to be in use (file locked)');
        if MsgBox('The CLAP plugin appears to be in use by a DAW.' + #13#10 + #13#10 +
                  'Please close any DAW that might be using Himalaya and try again.' + #13#10 + #13#10 +
                  'Continue anyway? (Installation may fail)', mbConfirmation, MB_YESNO) = IDNO then
        begin
          Result := 'Plugin files are locked. Please close your DAW and try again.';
          Exit;
        end;
      end;
    end;
  end;

  // Check if AAX plugin file is locked
  if IsComponentSelected('aax') and not FileLocked then
  begin
    // Use the stored path or default
    if AAXPath <> '' then
      TargetPath := AAXPath
    else
      TargetPath := ExpandConstant('{commoncf64}\Avid\Audio\Plug-Ins');

    // æ—¢å­˜ã® AAX ãƒãƒ³ãƒ‰ãƒ«ã‚’ä¸¸ã”ã¨å‰Šé™¤ã—ã¦ã‹ã‚‰ã‚¤ãƒ³ã‚¹ãƒˆãƒ¼ãƒ«ï¼ˆå…¥ã‚Œå­é˜²æ­¢ï¼‰
    if DirExists(TargetPath + '\Himalaya.aaxplugin') then
    begin
      Log('Removing existing AAX bundle to avoid nested installation');
      if not DelTree(TargetPath + '\Himalaya.aaxplugin', True, True, True) then
      begin
        Log('Failed to remove existing AAX bundle (possibly in use)');
        if MsgBox('The AAX plugin appears to be in use by Pro Tools.' + #13#10 + #13#10 +
                  'Please close Pro Tools and try again.' + #13#10 + #13#10 +
                  'Continue anyway? (Installation may fail)', mbConfirmation, MB_YESNO) = IDNO then
        begin
          Result := 'Plugin files are locked. Please close Pro Tools and try again.';
          Exit;
        end;
      end;
    end;
  end;

  // Check if Standalone executable is running
  if IsComponentSelected('standalone') and not FileLocked then
  begin
    // Use the stored path or default
    if StandalonePath <> '' then
      TargetPath := StandalonePath
    else
      TargetPath := ExpandConstant('{autopf}\Himalaya');

    TestFile := TargetPath + '\Himalaya.exe';
    if FileExists(TestFile) then
    begin
      FileLocked := not DeleteFile(TestFile);
      if FileLocked then
      begin
        Log('Standalone application appears to be running');
        if MsgBox('Himalaya standalone application appears to be running.' + #13#10 + #13#10 +
                  'Please close it and try again.' + #13#10 + #13#10 +
                  'Continue anyway? (Installation may fail)', mbConfirmation, MB_YESNO) = IDNO then
        begin
          Result := 'Himalaya.exe is running. Please close it and try again.';
          Exit;
        end;
      end;
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
begin
  if CurStep = ssPostInstall then
  begin
    // Post-install messages disabled
  end;
end;

// Helper functions to get installation paths
function GetStandalonePath(Param: String): String;
begin
  if StandalonePath = '' then
    Result := ExpandConstant('{autopf}\Himalaya')
  else
    Result := StandalonePath;
end;

function GetVST3Path(Param: String): String;
begin
  if VST3Path = '' then
    Result := ExpandConstant('{commoncf64}\VST3')
  else
    Result := VST3Path;
end;

function GetCLAPPath(Param: String): String;
begin
  if CLAPPath = '' then
    Result := ExpandConstant('{commoncf64}\CLAP')
  else
    Result := CLAPPath;
end;

function GetAAXPath(Param: String): String;
begin
  if AAXPath = '' then
    Result := ExpandConstant('{commoncf64}\Avid\Audio\Plug-Ins')
  else
    Result := AAXPath;
end;

function GetDocPath(Param: String): String;
begin
  // Install docs to standalone path if it's selected, otherwise to default
  if IsComponentSelected('standalone') then
    Result := GetStandalonePath('')
  else
    Result := ExpandConstant('{autopf}\Himalaya');
end;

procedure DeinitializeUninstall();
begin
  // Clean up any remaining files
  DelTree(ExpandConstant('{localappdata}\Himalaya'), True, True, True);
  DelTree(ExpandConstant('{userappdata}\Himalaya'), True, True, True);
end;
