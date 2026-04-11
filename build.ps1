# AirBar Installer - Build Script
# This script automates the complete build process
# Must be run from the project root directory

param(
    [switch]$Clean = $false,
    [switch]$SkipTests = $false,
    [switch]$BuildInstaller = $true
)

$ErrorActionPreference = "Stop"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "AirBar Installer - Build Automation" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if running from correct directory
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "ERREUR: Ce script doit être exécuté depuis la racine du projet!" -ForegroundColor Red
    Write-Host "Répertoire actuel: $PWD" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Répertoire de projet détecté" -ForegroundColor Green
Write-Host ""

# Step 1: Clean previous build
if ($Clean) {
    Write-Host "Étape 1: Nettoyage des builds précédents..." -ForegroundColor Cyan
    try {
        flutter clean
        if (Test-Path "build") {
            Remove-Item -Path "build" -Recurse -Force
        }
        Write-Host "✓ Nettoyage terminé" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Erreur lors du nettoyage: $_" -ForegroundColor Red
        exit 1
    }
    Write-Host ""
}

# Step 2: Get dependencies
Write-Host "Étape 2: Récupération des dépendances..." -ForegroundColor Cyan
try {
    flutter pub get
    Write-Host "✓ Dépendances récupérées" -ForegroundColor Green
}
catch {
    Write-Host "✗ Erreur lors de la récupération des dépendances: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 3: Run analyzer
Write-Host "Étape 3: Analyse du code..." -ForegroundColor Cyan
try {
    $analyzeOutput = flutter analyze 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Aucune erreur d'analyse détectée" -ForegroundColor Green
    }
    else {
        Write-Host "⚠ Avertissements d'analyse détectés (continuez quand même)" -ForegroundColor Yellow
        Write-Host $analyzeOutput -ForegroundColor Gray
    }
}
catch {
    Write-Host "⚠ Erreur lors de l'analyse: $_" -ForegroundColor Yellow
}
Write-Host ""

# Step 4: Run tests (optional)
if (-not $SkipTests) {
    Write-Host "Étape 4: Exécution des tests..." -ForegroundColor Cyan
    try {
        flutter test
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Tous les tests passent" -ForegroundColor Green
        }
        else {
            Write-Host "⚠ Certains tests ont échoué (continuez quand même)" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "⚠ Pas de tests trouvés ou erreur lors de l'exécution: $_" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Step 5: Build Windows Release
Write-Host "Étape 5: Compilation de l'application Windows..." -ForegroundColor Cyan
try {
    flutter build windows --release
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Compilation Windows réussie" -ForegroundColor Green
    }
    else {
        Write-Host "✗ Échec de la compilation Windows" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "✗ Erreur lors de la compilation: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 6: Verify build output
Write-Host "Étape 6: Vérification des fichiers de sortie..." -ForegroundColor Cyan
$exePath = "build\windows\x64\runner\Release\airbar_installer.exe"
$dataPath = "build\windows\x64\runner\Release\data"

$allFilesExist = $true

if (Test-Path $exePath) {
    $exeSize = (Get-Item $exePath).Length / 1MB
    Write-Host "  ✓ Exécutable trouvé ($([math]::Round($exeSize, 2)) MB)" -ForegroundColor Green
}
else {
    Write-Host "  ✗ Exécutable introuvable: $exePath" -ForegroundColor Red
    $allFilesExist = $false
}

if (Test-Path $dataPath) {
    Write-Host "  ✓ Dossier data trouvé" -ForegroundColor Green
}
else {
    Write-Host "  ✗ Dossier data introuvable: $dataPath" -ForegroundColor Red
    $allFilesExist = $false
}

if (-not $allFilesExist) {
    Write-Host ""
    Write-Host "✗ Certains fichiers essentiels sont manquants!" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 7: Check icon file
Write-Host "Étape 7: Vérification de l'icône..." -ForegroundColor Cyan
$iconPath = "assets\images\app_icon.ico"
if (Test-Path $iconPath) {
    Write-Host "  ✓ Fichier d'icône trouvé" -ForegroundColor Green
}
else {
    Write-Host "  ⚠ Fichier d'icône introuvable: $iconPath" -ForegroundColor Yellow
    Write-Host "    L'installateur utilisera une icône par défaut" -ForegroundColor Gray
    Write-Host "    Consultez assets\images\ICON_GUIDE.txt pour créer votre icône" -ForegroundColor Gray
    
    # Create a placeholder
    Write-Host "    Création d'un placeholder..." -ForegroundColor Gray
    if (-not (Test-Path "assets\images")) {
        New-Item -ItemType Directory -Path "assets\images" -Force | Out-Null
    }
    # Copy default Flutter icon if available
    if (Test-Path "windows\runner\resources\app_icon.ico") {
        Copy-Item "windows\runner\resources\app_icon.ico" $iconPath
        Write-Host "  ✓ Icône par défaut copiée" -ForegroundColor Green
    }
}
Write-Host ""

# Step 8: Prepare for Inno Setup
if ($BuildInstaller) {
    Write-Host "Étape 8: Préparation pour Inno Setup..." -ForegroundColor Cyan
    
    # Check if Inno Setup is installed
    $innoSetupPaths = @(
        "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
        "C:\Program Files\Inno Setup 6\ISCC.exe",
        "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
        "${env:ProgramFiles}\Inno Setup 6\ISCC.exe"
    )
    
    $innoSetupExe = $null
    foreach ($path in $innoSetupPaths) {
        if (Test-Path $path) {
            $innoSetupExe = $path
            break
        }
    }
    
    if ($innoSetupExe) {
        Write-Host "  ✓ Inno Setup détecté: $innoSetupExe" -ForegroundColor Green
        Write-Host ""
        Write-Host "Étape 9: Compilation de l'installateur..." -ForegroundColor Cyan
        
        try {
            & $innoSetupExe "installer-setup.iss"
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ Installateur créé avec succès!" -ForegroundColor Green
                
                # Find the generated installer
                $installerPath = Get-ChildItem -Path "build\windows\installer" -Filter "*.exe" | Select-Object -First 1
                if ($installerPath) {
                    $installerSize = ($installerPath.Length / 1MB)
                    Write-Host ""
                    Write-Host "================================================" -ForegroundColor Green
                    Write-Host "BUILD TERMINÉ AVEC SUCCÈS!" -ForegroundColor Green
                    Write-Host "================================================" -ForegroundColor Green
                    Write-Host ""
                    Write-Host "Installateur: $($installerPath.FullName)" -ForegroundColor Cyan
                    Write-Host "Taille: $([math]::Round($installerSize, 2)) MB" -ForegroundColor Cyan
                    Write-Host ""
                }
            }
            else {
                Write-Host "  ✗ Échec de la compilation de l'installateur" -ForegroundColor Red
                exit 1
            }
        }
        catch {
            Write-Host "  ✗ Erreur lors de la compilation de l'installateur: $_" -ForegroundColor Red
            exit 1
        }
    }
    else {
        Write-Host "  ⚠ Inno Setup non détecté" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "================================================" -ForegroundColor Yellow
        Write-Host "BUILD DE L'APPLICATION TERMINÉ" -ForegroundColor Yellow
        Write-Host "================================================" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Pour créer l'installateur:" -ForegroundColor Cyan
        Write-Host "1. Installez Inno Setup 6: https://jrsoftware.org/isdl.php" -ForegroundColor White
        Write-Host "2. Ouvrez installer-setup.iss avec Inno Setup" -ForegroundColor White
        Write-Host "3. Cliquez sur Build > Compile" -ForegroundColor White
        Write-Host ""
        Write-Host "OU relancez ce script après avoir installé Inno Setup." -ForegroundColor White
        Write-Host ""
    }
}
else {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "BUILD DE L'APPLICATION TERMINÉ" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Exécutable: $exePath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Pour créer l'installateur, lancez:" -ForegroundColor Cyan
    Write-Host "  .\build.ps1 -BuildInstaller" -ForegroundColor White
    Write-Host ""
}

Write-Host "Pour tester l'application:" -ForegroundColor Cyan
Write-Host "  .\$exePath" -ForegroundColor White
Write-Host ""
