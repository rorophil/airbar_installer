# AirBar Installer - Prerequisites Check Script
# This script verifies system requirements before installation
# Returns exit code 0 if all prerequisites are met, 1 otherwise

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "AirBar Installer - Vérification des Prérequis" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$allChecksPassed = $true

# Check 1: Windows Version
Write-Host "1. Vérification de la version Windows..." -ForegroundColor Cyan
$osVersion = [System.Environment]::OSVersion.Version
$isWindows10Plus = $osVersion.Major -ge 10

if ($isWindows10Plus) {
    Write-Host "   ✓ Windows $($osVersion.Major).$($osVersion.Minor) détecté" -ForegroundColor Green
}
else {
    Write-Host "   ✗ Windows 10 ou supérieur requis" -ForegroundColor Red
    $allChecksPassed = $false
}
Write-Host ""

# Check 2: 64-bit Architecture
Write-Host "2. Vérification de l'architecture système..." -ForegroundColor Cyan
$is64Bit = [System.Environment]::Is64BitOperatingSystem

if ($is64Bit) {
    Write-Host "   ✓ Système 64-bit détecté" -ForegroundColor Green
}
else {
    Write-Host "   ✗ Système 64-bit requis" -ForegroundColor Red
    $allChecksPassed = $false
}
Write-Host ""

# Check 3: Available Disk Space
Write-Host "3. Vérification de l'espace disque..." -ForegroundColor Cyan
$systemDrive = $env:SystemDrive
$disk = Get-PSDrive -Name $systemDrive.TrimEnd(':')
$freeSpaceGB = [math]::Round($disk.Free / 1GB, 2)
$requiredSpaceGB = 10

if ($freeSpaceGB -ge $requiredSpaceGB) {
    Write-Host "   ✓ Espace disponible: $freeSpaceGB GB (minimum: $requiredSpaceGB GB)" -ForegroundColor Green
}
else {
    Write-Host "   ✗ Espace insuffisant: $freeSpaceGB GB (minimum: $requiredSpaceGB GB)" -ForegroundColor Red
    $allChecksPassed = $false
}
Write-Host ""

# Check 4: RAM
Write-Host "4. Vérification de la mémoire RAM..." -ForegroundColor Cyan
$totalRamGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
$requiredRamGB = 4

if ($totalRamGB -ge $requiredRamGB) {
    Write-Host "   ✓ RAM installée: $totalRamGB GB (minimum: $requiredRamGB GB)" -ForegroundColor Green
}
else {
    Write-Host "   ✗ RAM insuffisante: $totalRamGB GB (minimum: $requiredRamGB GB)" -ForegroundColor Red
    $allChecksPassed = $false
}
Write-Host ""

# Check 5: PowerShell Version
Write-Host "5. Vérification de PowerShell..." -ForegroundColor Cyan
$psVersion = $PSVersionTable.PSVersion
$minPsVersion = [Version]"5.1"

if ($psVersion -ge $minPsVersion) {
    Write-Host "   ✓ PowerShell $psVersion détecté" -ForegroundColor Green
}
else {
    Write-Host "   ✗ PowerShell 5.1 ou supérieur requis (version actuelle: $psVersion)" -ForegroundColor Red
    $allChecksPassed = $false
}
Write-Host ""

# Check 6: Internet Connection
Write-Host "6. Vérification de la connexion Internet..." -ForegroundColor Cyan
try {
    $connection = Test-Connection -ComputerName "github.com" -Count 1 -Quiet -ErrorAction Stop
    if ($connection) {
        Write-Host "   ✓ Connexion Internet active" -ForegroundColor Green
    }
    else {
        Write-Host "   ⚠ Connexion Internet non détectée" -ForegroundColor Yellow
        Write-Host "      (nécessaire pour télécharger Docker et Git)" -ForegroundColor Gray
    }
}
catch {
    Write-Host "   ⚠ Impossible de vérifier la connexion Internet" -ForegroundColor Yellow
}
Write-Host ""

# Check 7: Administrator Rights
Write-Host "7. Vérification des droits administrateur..." -ForegroundColor Cyan
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    Write-Host "   ✓ Exécution avec privilèges administrateur" -ForegroundColor Green
}
else {
    Write-Host "   ⚠ Non exécuté en tant qu'administrateur" -ForegroundColor Yellow
    Write-Host "      (sera nécessaire pour l'installation de Docker)" -ForegroundColor Gray
}
Write-Host ""

# Final Summary
Write-Host "================================================" -ForegroundColor Cyan
if ($allChecksPassed) {
    Write-Host "✓ Tous les prérequis sont satisfaits!" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    exit 0
}
else {
    Write-Host "✗ Certains prérequis ne sont pas satisfaits" -ForegroundColor Red
    Write-Host "================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Veuillez corriger les problèmes ci-dessus avant de continuer." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}
