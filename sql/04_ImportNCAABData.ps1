# ============================================
# Import NCAAB CSV Data into SQL Server
# ============================================
# Run this from PowerShell: .\04_ImportNCAABData.ps1

param(
    [string]$ServerInstance = "MSI\SQLEXPRESS",
    [string]$Database = "SportsAnalytics",
    [string]$CsvPath = "C:\Users\happy\Documents\Projects\ncaab-prediction-tracker"
)

# Import SQL Server module
Import-Module SqlServer -ErrorAction SilentlyContinue

# Function to execute SQL command
function Invoke-SqlCommand {
    param(
        [string]$Query
    )
    Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $Query
}

# Mapping of CSV columns to prediction models
$columnModelMapping = @{
    'lineespn' = 'ESPN'
    'linesag' = 'SAGARIN'
    'linemassey' = 'MASSEY'
    'linedunk' = 'DUNKEL'
    'linedok' = 'DOKTER'
    'linemoore' = 'MOORE'
    'linepugh' = 'PUGH'
    'linedonc' = 'DONCHESS'
    'linetalis' = 'TALIS'
    'linepir' = 'PIRATINGS'
    'line7ot' = 'SEVENTIMES'
    'lineer' = 'EFFRATING'
    'linedd' = 'DODDS'
    'linefox' = 'FOX'
}

# CSV files to season mapping
$csvFiles = @{
    'ncaabb22.csv' = '2021-22'
    'ncaabb23.csv' = '2022-23'
    'ncaabb24.csv' = '2023-24'
}

Write-Host "Starting NCAAB data import..." -ForegroundColor Green

foreach ($csvFile in $csvFiles.Keys) {
    $fullPath = Join-Path $CsvPath $csvFile
    $seasonYear = $csvFiles[$csvFile]

    Write-Host "`nProcessing $csvFile for season $seasonYear..." -ForegroundColor Yellow

    if (-not (Test-Path $fullPath)) {
        Write-Host "  File not found: $fullPath" -ForegroundColor Red
        continue
    }

    # Import CSV
    $data = Import-Csv $fullPath

    Write-Host "  Found $($data.Count) games in CSV" -ForegroundColor Cyan

    # Get SeasonID
    $seasonQuery = "SELECT SeasonID FROM dbo.Seasons WHERE SportID = 1 AND SeasonYear = '$seasonYear'"
    $seasonResult = Invoke-SqlCommand -Query $seasonQuery
    $seasonId = $seasonResult.SeasonID

    if (-not $seasonId) {
        Write-Host "  ERROR: Season not found for $seasonYear" -ForegroundColor Red
        continue
    }

    $gameCount = 0
    $predCount = 0

    foreach ($row in $data) {
        try {
            # Parse date
            $gameDate = [DateTime]::Parse($row.date).ToString('yyyy-MM-dd')

            # Clean team names
            $homeTeam = $row.home.Replace("'", "''")
            $roadTeam = $row.road.Replace("'", "''")

            # Parse scores (may be empty for future games)
            $homeScore = if ($row.hscore) { $row.hscore } else { 'NULL' }
            $roadScore = if ($row.rscore) { $row.rscore } else { 'NULL' }

            # Neutral site
            $isNeutral = if ($row.neutral -eq '1') { 1 } else { 0 }

            # Round number
            $roundNum = if ($row.lineround) { $row.lineround } else { 'NULL' }

            # Insert game
            $gameInsert = @"
IF NOT EXISTS (
    SELECT 1 FROM dbo.Games
    WHERE SportID = 1 AND SeasonID = $seasonId
    AND GameDate = '$gameDate' AND HomeTeam = '$homeTeam' AND RoadTeam = '$roadTeam'
)
BEGIN
    INSERT INTO dbo.Games (SportID, SeasonID, GameDate, HomeTeam, RoadTeam, HomeScore, RoadScore, IsNeutralSite, RoundNumber)
    VALUES (1, $seasonId, '$gameDate', '$homeTeam', '$roadTeam', $homeScore, $roadScore, $isNeutral, $roundNum);
END
"@
            Invoke-SqlCommand -Query $gameInsert
            $gameCount++

            # Get GameID
            $gameIdQuery = @"
SELECT GameID FROM dbo.Games
WHERE SportID = 1 AND SeasonID = $seasonId
AND GameDate = '$gameDate' AND HomeTeam = '$homeTeam' AND RoadTeam = '$roadTeam'
"@
            $gameResult = Invoke-SqlCommand -Query $gameIdQuery
            $gameId = $gameResult.GameID

            # Insert consensus line data
            if ($row.lineavg) {
                $lineAvg = $row.lineavg
                $lineStd = if ($row.std) { $row.std } else { 'NULL' }

                $lineInsert = @"
IF NOT EXISTS (SELECT 1 FROM dbo.GameLines WHERE GameID = $gameId AND LineType = 'CONSENSUS')
BEGIN
    INSERT INTO dbo.GameLines (GameID, LineType, Line, StandardDeviation)
    VALUES ($gameId, 'CONSENSUS', $lineAvg, $lineStd);
END
"@
                Invoke-SqlCommand -Query $lineInsert
            }

            # Insert opening line
            if ($row.lineopen) {
                $lineOpen = $row.lineopen

                $lineInsert = @"
IF NOT EXISTS (SELECT 1 FROM dbo.GameLines WHERE GameID = $gameId AND LineType = 'OPENING')
BEGIN
    INSERT INTO dbo.GameLines (GameID, LineType, Line)
    VALUES ($gameId, 'OPENING', $lineOpen);
END
"@
                Invoke-SqlCommand -Query $lineInsert
            }

            # Insert prediction model data
            foreach ($column in $columnModelMapping.Keys) {
                if ($row.$column -and $row.$column -ne '') {
                    $modelCode = $columnModelMapping[$column]
                    $predictedLine = $row.$column

                    # Get ModelID
                    $modelQuery = "SELECT ModelID FROM dbo.PredictionModels WHERE ModelCode = '$modelCode'"
                    $modelResult = Invoke-SqlCommand -Query $modelQuery
                    $modelId = $modelResult.ModelID

                    if ($modelId) {
                        $predInsert = @"
IF NOT EXISTS (SELECT 1 FROM dbo.GamePredictions WHERE GameID = $gameId AND ModelID = $modelId)
BEGIN
    INSERT INTO dbo.GamePredictions (GameID, ModelID, PredictedLine)
    VALUES ($gameId, $modelId, $predictedLine);
END
"@
                        Invoke-SqlCommand -Query $predInsert
                        $predCount++
                    }
                }
            }

        }
        catch {
            Write-Host "  ERROR processing row: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Host "  Imported $gameCount games and $predCount predictions" -ForegroundColor Green
}

Write-Host "`nData import complete!" -ForegroundColor Green
