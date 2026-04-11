# AirBar Server - Firewall Cleanup Script
# This script removes Windows Firewall rules created by AirBar
# Must be run with Administrator privileges

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "AirBar Server - Nettoyage du Pare-feu" -ForegroundColor Cyan
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

# Function to remove firewall rule
function Remove-FirewallRuleIfExists {
    param(
        [string]$Name
    )
    
    $existingRule = Get-NetFirewallRule -DisplayName $Name -ErrorAction SilentlyContinue
    
    if ($existingRule) {
        try {
            Remove-NetFirewallRule -DisplayName $Name -ErrorAction Stop
            Write-Host "  ✓ Règle '$Name' supprimée" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Host "  ✗ Erreur lors de la suppression de '$Name': $_" -ForegroundColor Red
            return $false
        }
    }
    else {
        Write-Host "  → Règle '$Name' n'existe pas (ignoré)" -ForegroundColor Gray
        return $true
    }
}

Write-Host "Suppression des règles de pare-feu AirBar..." -ForegroundColor Cyan
Write-Host ""

# Remove firewall rules
$success = $true

$rules = @(
    "AirBar API Server",
    "AirBar Insights Server",
    "AirBar Web Server",
    "AirBar PostgreSQL",
    "AirBar Redis"
)

foreach ($ruleName in $rules) {
    $success = $success -and (Remove-FirewallRuleIfExists -Name $ruleName)
}

Write-Host ""
if ($success) {
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "Nettoyage du pare-feu terminé avec succès!" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    exit 0
}
else {
    Write-Host "================================================" -ForegroundColor Yellow
    Write-Host "Nettoyage du pare-feu terminé avec avertissements" -ForegroundColor Yellow
    Write-Host "================================================" -ForegroundColor Yellow
    Write-Host "Certaines règles n'ont pas pu être supprimées." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}
