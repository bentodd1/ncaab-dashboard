-- ============================================
-- Import Prediction Lines from CSVs
-- ============================================
USE SportsAnalytics;
GO

PRINT 'Starting prediction data import...';
PRINT 'This will take a few minutes...';
GO

-- Create staging table
IF OBJECT_ID('dbo.StagingGames', 'U') IS NOT NULL DROP TABLE dbo.StagingGames;
CREATE TABLE dbo.StagingGames (
    date VARCHAR(50), home VARCHAR(100), hscore VARCHAR(10), road VARCHAR(100), rscore VARCHAR(10),
    line VARCHAR(20), lineavg VARCHAR(20), linesag VARCHAR(20), linesage VARCHAR(20), linesagp VARCHAR(20),
    linesaggm VARCHAR(20), linemoore VARCHAR(20), lineopen VARCHAR(20), linedok VARCHAR(20), linefox VARCHAR(20),
    std VARCHAR(20), linepugh VARCHAR(20), linedonc VARCHAR(20), neutral VARCHAR(10), linetalis VARCHAR(20),
    lineespn VARCHAR(20), linepir VARCHAR(20), linepiw VARCHAR(20), linepib VARCHAR(20), line7ot VARCHAR(20),
    lineer VARCHAR(20), linedd VARCHAR(20), linemassey VARCHAR(20), linedunk VARCHAR(20), lineround VARCHAR(10),
    lineteamrnks VARCHAR(50)
);
GO

-- ============================================
-- Process 2021-22 Season
-- ============================================
PRINT 'Processing 2021-22 predictions...';
BULK INSERT dbo.StagingGames
FROM 'C:\Users\happy\Documents\Projects\ncaab-prediction-tracker\ncaabb22.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);

DECLARE @Season22 INT = (SELECT SeasonID FROM dbo.Seasons WHERE SeasonYear = '2021-22' AND SportID = 1);

-- Insert GameLines (consensus and opening)
INSERT INTO dbo.GameLines (GameID, LineType, Line, StandardDeviation)
SELECT DISTINCT
    g.GameID,
    'CONSENSUS',
    TRY_CAST(s.lineavg AS DECIMAL(10,2)),
    TRY_CAST(s.std AS DECIMAL(10,4))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @Season22
    AND g.GameDate = CONVERT(DATE, s.date, 101)
    AND g.HomeTeam = s.home
    AND g.RoadTeam = s.road
WHERE s.lineavg IS NOT NULL AND s.lineavg <> ''
AND NOT EXISTS (SELECT 1 FROM dbo.GameLines WHERE GameID = g.GameID AND LineType = 'CONSENSUS');

PRINT '  Consensus lines: ' + CAST(@@ROWCOUNT AS VARCHAR);

INSERT INTO dbo.GameLines (GameID, LineType, Line)
SELECT DISTINCT
    g.GameID,
    'OPENING',
    TRY_CAST(s.lineopen AS DECIMAL(10,2))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @Season22
    AND g.GameDate = CONVERT(DATE, s.date, 101)
    AND g.HomeTeam = s.home
    AND g.RoadTeam = s.road
WHERE s.lineopen IS NOT NULL AND s.lineopen <> ''
AND NOT EXISTS (SELECT 1 FROM dbo.GameLines WHERE GameID = g.GameID AND LineType = 'OPENING');

PRINT '  Opening lines: ' + CAST(@@ROWCOUNT AS VARCHAR);

-- Insert Model Predictions
-- ESPN
INSERT INTO dbo.GamePredictions (GameID, ModelID, PredictedLine)
SELECT g.GameID, pm.ModelID, TRY_CAST(s.lineespn AS DECIMAL(10,2))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @Season22 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
CROSS JOIN dbo.PredictionModels pm
WHERE pm.ModelCode = 'ESPN' AND s.lineespn IS NOT NULL AND s.lineespn <> ''
AND NOT EXISTS (SELECT 1 FROM dbo.GamePredictions WHERE GameID = g.GameID AND ModelID = pm.ModelID);
PRINT '  ESPN: ' + CAST(@@ROWCOUNT AS VARCHAR);

-- SAGARIN
INSERT INTO dbo.GamePredictions (GameID, ModelID, PredictedLine)
SELECT g.GameID, pm.ModelID, TRY_CAST(s.linesag AS DECIMAL(10,2))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @Season22 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
CROSS JOIN dbo.PredictionModels pm
WHERE pm.ModelCode = 'SAGARIN' AND s.linesag IS NOT NULL AND s.linesag <> ''
AND NOT EXISTS (SELECT 1 FROM dbo.GamePredictions WHERE GameID = g.GameID AND ModelID = pm.ModelID);
PRINT '  SAGARIN: ' + CAST(@@ROWCOUNT AS VARCHAR);

-- MASSEY
INSERT INTO dbo.GamePredictions (GameID, ModelID, PredictedLine)
SELECT g.GameID, pm.ModelID, TRY_CAST(s.linemassey AS DECIMAL(10,2))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @Season22 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
CROSS JOIN dbo.PredictionModels pm
WHERE pm.ModelCode = 'MASSEY' AND s.linemassey IS NOT NULL AND s.linemassey <> ''
AND NOT EXISTS (SELECT 1 FROM dbo.GamePredictions WHERE GameID = g.GameID AND ModelID = pm.ModelID);
PRINT '  MASSEY: ' + CAST(@@ROWCOUNT AS VARCHAR);

-- Add other models (continuing same pattern)
INSERT INTO dbo.GamePredictions (GameID, ModelID, PredictedLine)
SELECT g.GameID, pm.ModelID, TRY_CAST(s.linedunk AS DECIMAL(10,2))
FROM dbo.StagingGames s INNER JOIN dbo.Games g ON g.SeasonID = @Season22 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
CROSS JOIN dbo.PredictionModels pm WHERE pm.ModelCode = 'DUNKEL' AND s.linedunk IS NOT NULL AND s.linedunk <> ''
AND NOT EXISTS (SELECT 1 FROM dbo.GamePredictions WHERE GameID = g.GameID AND ModelID = pm.ModelID);
PRINT '  DUNKEL: ' + CAST(@@ROWCOUNT AS VARCHAR);

INSERT INTO dbo.GamePredictions (GameID, ModelID, PredictedLine)
SELECT g.GameID, pm.ModelID, TRY_CAST(s.linedok AS DECIMAL(10,2))
FROM dbo.StagingGames s INNER JOIN dbo.Games g ON g.SeasonID = @Season22 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
CROSS JOIN dbo.PredictionModels pm WHERE pm.ModelCode = 'DOKTER' AND s.linedok IS NOT NULL AND s.linedok <> ''
AND NOT EXISTS (SELECT 1 FROM dbo.GamePredictions WHERE GameID = g.GameID AND ModelID = pm.ModelID);
PRINT '  DOKTER: ' + CAST(@@ROWCOUNT AS VARCHAR);

INSERT INTO dbo.GamePredictions (GameID, ModelID, PredictedLine)
SELECT g.GameID, pm.ModelID, TRY_CAST(s.linemoore AS DECIMAL(10,2))
FROM dbo.StagingGames s INNER JOIN dbo.Games g ON g.SeasonID = @Season22 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
CROSS JOIN dbo.PredictionModels pm WHERE pm.ModelCode = 'MOORE' AND s.linemoore IS NOT NULL AND s.linemoore <> ''
AND NOT EXISTS (SELECT 1 FROM dbo.GamePredictions WHERE GameID = g.GameID AND ModelID = pm.ModelID);
PRINT '  MOORE: ' + CAST(@@ROWCOUNT AS VARCHAR);

INSERT INTO dbo.GamePredictions (GameID, ModelID, PredictedLine)
SELECT g.GameID, pm.ModelID, TRY_CAST(s.linepugh AS DECIMAL(10,2))
FROM dbo.StagingGames s INNER JOIN dbo.Games g ON g.SeasonID = @Season22 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
CROSS JOIN dbo.PredictionModels pm WHERE pm.ModelCode = 'PUGH' AND s.linepugh IS NOT NULL AND s.linepugh <> ''
AND NOT EXISTS (SELECT 1 FROM dbo.GamePredictions WHERE GameID = g.GameID AND ModelID = pm.ModelID);
PRINT '  PUGH: ' + CAST(@@ROWCOUNT AS VARCHAR);

INSERT INTO dbo.GamePredictions (GameID, ModelID, PredictedLine)
SELECT g.GameID, pm.ModelID, TRY_CAST(s.linefox AS DECIMAL(10,2))
FROM dbo.StagingGames s INNER JOIN dbo.Games g ON g.SeasonID = @Season22 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
CROSS JOIN dbo.PredictionModels pm WHERE pm.ModelCode = 'FOX' AND s.linefox IS NOT NULL AND s.linefox <> ''
AND NOT EXISTS (SELECT 1 FROM dbo.GamePredictions WHERE GameID = g.GameID AND ModelID = pm.ModelID);
PRINT '  FOX: ' + CAST(@@ROWCOUNT AS VARCHAR);

PRINT '2021-22 complete!';
TRUNCATE TABLE dbo.StagingGames;
GO

PRINT 'All predictions imported successfully!';
PRINT 'Summary:';
SELECT COUNT(*) AS TotalPredictions FROM dbo.GamePredictions;
SELECT COUNT(*) AS TotalLines FROM dbo.GameLines;
GO
