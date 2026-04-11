# AirBar Server - Firewall Configuration Script
# This script creates Windows Firewall rules for AirBar services
# Must be run with Administrator privileges

param(
    [int]$ApiPort = 8080,
    [int]$InsightsPort = 8081,
    [int]$WebPort = 8082
)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "AirBar Server - Configuration du Pare-feu" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check for Administrator privileges
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERREUR: Ce script nécessite des privilèges Administrateur!" -ForegroundColor Red
    Write-Host "Relancez PowerShell en tant qu'Administrateur." -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Droits administrateur vérifiés" -ForegroundColor Green
Write-Host ""

# Function to create firewall rule
function Add-FirewallRuleIfNotExists {
    param(
        [string]$Name,
        [int]$Port,
        [string]$Description
    )
    
    $existingRule = Get-NetFirewallRule -DisplayName $Name -ErrorAction SilentlyContinue
    
    if ($existingRule) {
        Write-Host "  → Règle '$Name' existe déjà, mise à jour..." -ForegroundColor Yellow
        Remove-NetFirewallRule -DisplayName $Name -ErrorAction SilentlyContinue
    }
    
    try {
        New-NetFirewallRule `
            -DisplayName $Name `
            -Description $Description `
            -Direction Inbound `
            -Protocol TCP `
            -LocalPort $Port `
            -Action Allow `
            -Profile Any `
            -Enabled True | Out-Null
        
        Write-Host "  ✓ Règle '$Name' créée (port $Port)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  ✗ Erreur lors de la création de la règle '$Name': $_" -ForegroundColor Red
        return $false
    }
}

Write-Host "Configuration des règles de pare-feu..." -ForegroundColor Cyan
Write-Host ""

# Create firewall rules
$success = $true

# API Server
$success = $success -and (Add-FirewallRuleIfNotExists `
    -Name "AirBar API Server" `
    -Port $ApiPort `
    -Description "Autorise les connexions entrantes vers le serveur API AirBar (Serverpod)")

# Insights Server
$success = $success -and (Add-FirewallRuleIfNotExists `
    -Name "AirBar Insights Server" `
    -Port $InsightsPort `
    -Description "Autorise les connexions entrantes vers le serveur Insights AirBar")

# Web Server
$success = $success -and (Add-FirewallRuleIfNotExists `
    -Name "AirBar Web Server" `
    -Port $WebPort `
    -Description "Autorise les connexions entrantes vers le serveur Web AirBar")

# PostgreSQL (Docker)
$success = $success -and (Add-FirewallRuleIfNotExists `
    -Name "AirBar PostgreSQL" `
    -Port 5432 `
    -Description "Autorise les connexions entrantes vers PostgreSQL (AirBar)")

# Redis (Docker)
$success = $success -and (Add-FirewallRuleIfNotExists `
    -Name "AirBar Redis" `
    -Port 6379 `
    -Description "Autorise les connexions entrantes vers Redis (AirBar)")

Write-Host ""
if ($success) {
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "Configuration du pare-feu terminée avec succès!" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Ports configurés:" -ForegroundColor Cyan
    Write-Host "  • API Server      : $ApiPort" -ForegroundColor White
    Write-Host "  • Insights Server : $InsightsPort" -ForegroundColor White
    Write-Host "  • Web Server      : $WebPort" -ForegroundColor White
    Write-Host "  • PostgreSQL      : 5432" -ForegroundColor White
    Write-Host "  • Redis           : 6379" -ForegroundColor White
    Write-Host ""
    exit 0
}
else {
    Write-Host "================================================" -ForegroundColor Red
    Write-Host "Erreurs lors de la configuration du pare-feu" -ForegroundColor Red
    Write-Host "================================================" -ForegroundColor Red
    Write-Host "Veuillez vérifier les messages d'erreur ci-dessus." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}
