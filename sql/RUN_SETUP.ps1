# ============================================
# Complete Setup Script - Run Everything
# ============================================
# Run this from PowerShell: .\RUN_SETUP.ps1

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Sports Analytics Database Setup" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$serverInstance = "MSI\SQLEXPRESS"
$scriptPath = "C:\Users\happy\Documents\Projects\ncaab-prediction-tracker\sql"

# Step 1: Create Database
Write-Host "[1/6] Creating database..." -ForegroundColor Yellow
sqlcmd -S $serverInstance -E -i "$scriptPath\01_CreateDatabase.sql"
if ($LASTEXITCODE -eq 0) {
    Write-Host "  Database created successfully!" -ForegroundColor Green
} else {
    Write-Host "  Failed to create database" -ForegroundColor Red
    exit
}

# Step 2: Create Tables
Write-Host "`n[2/6] Creating tables..." -ForegroundColor Yellow
sqlcmd -S $serverInstance -E -d SportsAnalytics -i "$scriptPath\02_CreateTables.sql"
if ($LASTEXITCODE -eq 0) {
    Write-Host "  Tables created successfully!" -ForegroundColor Green
} else {
    Write-Host "  Failed to create tables" -ForegroundColor Red
    exit
}

# Step 3: Insert Reference Data
Write-Host "`n[3/6] Inserting reference data..." -ForegroundColor Yellow
sqlcmd -S $serverInstance -E -d SportsAnalytics -i "$scriptPath\03_InsertReferenceData.sql"
if ($LASTEXITCODE -eq 0) {
    Write-Host "  Reference data inserted successfully!" -ForegroundColor Green
} else {
    Write-Host "  Failed to insert reference data" -ForegroundColor Red
    exit
}

# Step 4: Create Views
Write-Host "`n[4/6] Creating views..." -ForegroundColor Yellow
sqlcmd -S $serverInstance -E -d SportsAnalytics -i "$scriptPath\05_CreateViews.sql"
if ($LASTEXITCODE -eq 0) {
    Write-Host "  Views created successfully!" -ForegroundColor Green
} else {
    Write-Host "  Failed to create views" -ForegroundColor Red
    exit
}

# Step 5: Create Stored Procedures
Write-Host "`n[5/6] Creating stored procedures..." -ForegroundColor Yellow
sqlcmd -S $serverInstance -E -d SportsAnalytics -i "$scriptPath\06_CreateStoredProcedures.sql"
if ($LASTEXITCODE -eq 0) {
    Write-Host "  Stored procedures created successfully!" -ForegroundColor Green
} else {
    Write-Host "  Failed to create stored procedures" -ForegroundColor Red
    exit
}

# Step 6: Import CSV Data
Write-Host "`n[6/6] Importing CSV data..." -ForegroundColor Yellow
Write-Host "  Checking for SqlServer module..." -ForegroundColor Cyan

$moduleName = "SqlServer"
if (-not (Get-Module -ListAvailable -Name $moduleName)) {
    Write-Host "  SqlServer module not found. Installing..." -ForegroundColor Yellow
    try {
        Install-Module -Name $moduleName -AllowClobber -Force -Scope CurrentUser
        Write-Host "  SqlServer module installed!" -ForegroundColor Green
    }
    catch {
        Write-Host "  Failed to install SqlServer module" -ForegroundColor Red
        Write-Host "  Run PowerShell as Administrator and try again" -ForegroundColor Yellow
        exit
    }
}

& "$scriptPath\04_ImportNCAABData.ps1"

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Test your database with sample queries (see SETUP_GUIDE.md)" -ForegroundColor White
Write-Host "2. Download Telerik Reporting: https://www.telerik.com/products/reporting.aspx" -ForegroundColor White
Write-Host "3. Connect Telerik to: MSI\SQLEXPRESS -> SportsAnalytics" -ForegroundColor White
Write-Host ""
Write-Host "Quick test query:" -ForegroundColor Yellow
Write-Host 'sqlcmd -S MSI\SQLEXPRESS -E -d SportsAnalytics -Q "SELECT COUNT(*) as TotalGames FROM dbo.Games"' -ForegroundColor Cyan
