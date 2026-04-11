; AirBar Installer - Inno Setup Configuration
; Installer pour l'application de gestion AirBar Server
; Nécessite Inno Setup 6.0 ou supérieur

#define MyAppName "AirBar Installer"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "AirBar Team"
#define MyAppURL "https://github.com/rorophil/airbar"
#define MyAppExeName "airbar_installer.exe"
#define MyAppId "{{B8F5E3A2-4C7D-4B9E-A1F3-2D8E6C9F4A5B}"

[Setup]
; Application information
AppId={#MyAppId}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}

; Installation directories
DefaultDirName={autopf}\AirBar Installer
DefaultGroupName=AirBar
DisableProgramGroupPage=yes

; Output configuration
OutputDir=build\windows\installer
OutputBaseFilename=AirBar_Installer_Setup_{#MyAppVersion}
SetupIconFile=assets\images\app_icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}

; Compression
Compression=lzma2/max
SolidCompression=yes

; Windows version requirements
MinVersion=10.0.17134
ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64

; Privileges
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog

; Wizard style
WizardStyle=modern
WizardSizePercent=120,100

; Uninstall configuration
UninstallDisplayName={#MyAppName}
UninstallFilesDir={app}\uninstall

; License
LicenseFile=assets\docs\LICENSE.txt

[Languages]
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: "startmenuicon"; Description: "Créer une icône dans le menu Démarrer"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "autostart"; Description: "Démarrer automatiquement avec Windows"; GroupDescription: "Options avancées:"; Flags: unchecked

[Files]
; Main application executable
Source: "build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs
Source: "build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs

; PowerShell scripts
Source: "assets\scripts\*.ps1"; DestDir: "{app}\scripts"; Flags: ignoreversion

; Documentation
Source: "assets\docs\README.txt"; DestDir: "{app}\docs"; Flags: ignoreversion isreadme
Source: "assets\docs\LICENSE.txt"; DestDir: "{app}\docs"; Flags: ignoreversion
Source: "assets\docs\INSTALLATION_GUIDE.txt"; DestDir: "{app}\docs"; Flags: ignoreversion

; Templates and resources
Source: "assets\templates\*"; DestDir: "{app}\templates"; Flags: ignoreversion recursesubdirs

[Icons]
; Start menu icon
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Guide d'installation"; Filename: "{app}\docs\INSTALLATION_GUIDE.txt"
Name: "{group}\Désinstaller {#MyAppName}"; Filename: "{uninstallexe}"

; Desktop icon (optional)
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

; Autostart (optional)
Name: "{userstartup}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: autostart

[Run]
; Launch application after installation
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallRun]
; Cleanup firewall rules on uninstall
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\scripts\firewall-cleanup.ps1"""; Flags: runhidden waituntilterminated
; Note: The actual cleanup of Docker containers and data will be handled by the application itself

[Code]
var
  PrereqCheckPage: TOutputMsgMemoWizardPage;
  PrereqCheckPassed: Boolean;

// Check prerequisites before installation
function CheckPrerequisites(): Boolean;
var
  ResultCode: Integer;
  PrereqOutput: AnsiString;
  ScriptPath: String;
begin
  Result := True;
  ScriptPath := ExpandConstant('{tmp}\check-prerequisites.ps1');
  
  // Extract prerequisites check script to temp
  ExtractTemporaryFile('check-prerequisites.ps1');
  
  // Run PowerShell prerequisites check
  if Exec('powershell.exe', 
          '-NoProfile -ExecutionPolicy Bypass -File "' + ScriptPath + '"', 
          '', 
          SW_HIDE, 
          ewWaitUntilTerminated, 
          ResultCode) then
  begin
    Result := (ResultCode = 0);
  end
  else
  begin
    Result := False;
    MsgBox('Erreur lors de la vérification des prérequis.', mbError, MB_OK);
  end;
end;

// Initialize wizard
procedure InitializeWizard();
begin
  PrereqCheckPassed := False;
  
  // Create prerequisites check page
  PrereqCheckPage := CreateOutputMsgMemoPage(wpWelcome,
    'Vérification des Prérequis',
    'Vérification de la configuration système',
    'Le programme d''installation va maintenant vérifier que votre système répond aux exigences minimales.' + #13#10#13#10 +
    'Cliquez sur Suivant pour continuer.',
    '');
end;

// When entering prerequisites page
function NextButtonClick(CurPageID: Integer): Boolean;
var
  ResultCode: Integer;
  OutputText: String;
begin
  Result := True;
  
  if CurPageID = PrereqCheckPage.ID then
  begin
    if not PrereqCheckPassed then
    begin
      PrereqCheckPage.RichEditViewer.Lines.Add('Vérification en cours...');
      PrereqCheckPage.RichEditViewer.Lines.Add('');
      
      PrereqCheckPassed := CheckPrerequisites();
      
      if PrereqCheckPassed then
      begin
        PrereqCheckPage.RichEditViewer.Lines.Add('✓ Tous les prérequis sont satisfaits !');
        PrereqCheckPage.RichEditViewer.Lines.Add('');
        PrereqCheckPage.RichEditViewer.Lines.Add('Vous pouvez continuer l''installation.');
      end
      else
      begin
        PrereqCheckPage.RichEditViewer.Lines.Add('✗ Certains prérequis ne sont pas satisfaits.');
        PrereqCheckPage.RichEditViewer.Lines.Add('');
        PrereqCheckPage.RichEditViewer.Lines.Add('Veuillez corriger les problèmes et réessayer.');
        PrereqCheckPage.RichEditViewer.Lines.Add('');
        PrereqCheckPage.RichEditViewer.Lines.Add('Requis :');
        PrereqCheckPage.RichEditViewer.Lines.Add('  • Windows 10 ou supérieur (64-bit)');
        PrereqCheckPage.RichEditViewer.Lines.Add('  • 4 GB RAM minimum');
        PrereqCheckPage.RichEditViewer.Lines.Add('  • 10 GB d''espace disque libre');
        PrereqCheckPage.RichEditViewer.Lines.Add('  • PowerShell 5.1 ou supérieur');
        PrereqCheckPage.RichEditViewer.Lines.Add('  • Connexion Internet (pour télécharger Docker et Git)');
        
        Result := False;
        MsgBox('Les prérequis système ne sont pas satisfaits. Veuillez vérifier les détails et corriger les problèmes avant de continuer.', mbError, MB_OK);
      end;
    end;
  end;
end;

// After successful installation
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Nothing to do here - firewall setup will be done by the application itself
    // when user configures the server settings
  end;
end;

// Before uninstallation
function InitializeUninstall(): Boolean;
begin
  Result := True;
  if MsgBox('Voulez-vous désinstaller AirBar Installer ?' + #13#10#13#10 +
            'Note: Cette opération ne supprimera pas automatiquement Docker ou les données du serveur AirBar.' + #13#10 +
            'Utilisez l''option "Désinstaller" dans l''application pour supprimer complètement le serveur.',
            mbConfirmation, MB_YESNO) = IDNO then
  begin
    Result := False;
  end;
end;
