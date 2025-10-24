# NCAA Basketball Prediction Tracker - Complete Setup Script
# This script sets up the entire database from scratch
# Run this on a fresh SQL Server instance

$ErrorActionPreference = "Stop"

# Configuration
$ServerInstance = "MSI\SQLEXPRESS"
$DatabaseName = "SportsAnalytics"
$ProjectRoot = $PSScriptRoot
$SqlPath = Join-Path $ProjectRoot "sql"

# Find sqlcmd.exe
$sqlcmdPath = "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe"
if (-not (Test-Path $sqlcmdPath)) {
    Write-Host "ERROR: sqlcmd.exe not found at expected location." -ForegroundColor Red
    Write-Host "Please update the sqlcmdPath variable in this script." -ForegroundColor Yellow
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NCAA Basketball Prediction Tracker Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Essential scripts in order
$scripts = @(
    @{Number=1; File="01_CreateDatabase.sql"; Description="Creating database"},
    @{Number=2; File="02_CreateTables.sql"; Description="Creating tables"},
    @{Number=3; File="03_InsertReferenceData.sql"; Description="Inserting reference data"},
    @{Number=4; File="05_CreateViews.sql"; Description="Creating analytical views"},
    @{Number=5; File="06_CreateStoredProcedures.sql"; Description="Creating stored procedures"},
    @{Number=6; File="15_ImportBothSeasons.sql"; Description="Importing game data (3 seasons)"},
    @{Number=7; File="18_ImportPredictionsDeduped.sql"; Description="Importing predictions"},
    @{Number=8; File="19_CreateOpeningLineViews.sql"; Description="Creating opening line views"},
    @{Number=9; File="20_CreateOpeningLineStoredProcs.sql"; Description="Creating opening line procedures"},
    @{Number=10; File="21_ImportClosingLine.sql"; Description="Importing closing line data"},
    @{Number=11; File="22_CreateClosingLineViews.sql"; Description="Creating closing line views"},
    @{Number=12; File="23_AddConferenceData.sql"; Description="Creating conference tables"},
    @{Number=13; File="25_UpdateTeamConferencesCorrect.sql"; Description="Mapping teams to conferences"},
    @{Number=14; File="26_FixConferenceTypes.sql"; Description="Fixing conference classifications"},
    @{Number=15; File="28_AddAllTeamAliases.sql"; Description="Adding team name aliases"},
    @{Number=16; File="29_RecreateGamesWithConferencesView.sql"; Description="Recreating conference view"}
)

$totalSteps = $scripts.Count
$currentStep = 0

foreach ($script in $scripts) {
    $currentStep++
    $scriptPath = Join-Path $SqlPath $script.File

    Write-Host "[$currentStep/$totalSteps] $($script.Description)..." -ForegroundColor Yellow

    if (-not (Test-Path $scriptPath)) {
        Write-Host "  ERROR: Script not found: $scriptPath" -ForegroundColor Red
        exit 1
    }

    try {
        # Run for database creation (no -d parameter)
        if ($script.Number -eq 1) {
            & $sqlcmdPath -S $ServerInstance -E -i $scriptPath -b
        }
        # All other scripts run against the database
        else {
            & $sqlcmdPath -S $ServerInstance -E -d $DatabaseName -i $scriptPath -b
        }

        if ($LASTEXITCODE -ne 0) {
            Write-Host "  ERROR: Script failed with exit code $LASTEXITCODE" -ForegroundColor Red
            exit 1
        }

        Write-Host "  SUCCESS" -ForegroundColor Green
    }
    catch {
        Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Database: $DatabaseName on $ServerInstance" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. cd dashboard" -ForegroundColor White
Write-Host "2. python -m venv venv" -ForegroundColor White
Write-Host "3. .\venv\Scripts\activate" -ForegroundColor White
Write-Host "4. pip install -r requirements.txt" -ForegroundColor White
Write-Host "5. python app.py" -ForegroundColor White
Write-Host ""
Write-Host "Dashboard will be available at: http://localhost:8050" -ForegroundColor Cyan
