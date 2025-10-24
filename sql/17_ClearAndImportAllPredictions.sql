-- ============================================
-- Clear and Import ALL Predictions for All Seasons
-- ============================================
USE SportsAnalytics;
GO

-- Clear existing prediction data
PRINT 'Clearing existing prediction data...';
DELETE FROM dbo.GamePredictions;
DELETE FROM dbo.GameLines;
PRINT 'Cleared!';
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
PRINT 'Processing 2021-22 season...';
BULK INSERT dbo.StagingGames
FROM 'C:\Users\happy\Documents\Projects\ncaab-prediction-tracker\ncaabb22.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);

DECLARE @Season22 INT = (SELECT SeasonID FROM dbo.Seasons WHERE SeasonYear = '2021-22' AND SportID = 1);

-- GameLines
INSERT INTO dbo.GameLines (GameID, LineType, Line, StandardDeviation)
SELECT g.GameID, 'CONSENSUS', TRY_CAST(s.lineavg AS DECIMAL(10,2)), TRY_CAST(s.std AS DECIMAL(10,4))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @Season22 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
WHERE s.lineavg IS NOT NULL AND s.lineavg <> '';

INSERT INTO dbo.GameLines (GameID, LineType, Line)
SELECT g.GameID, 'OPENING', TRY_CAST(s.lineopen AS DECIMAL(10,2))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @Season22 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
WHERE s.lineopen IS NOT NULL AND s.lineopen <> '';

-- Predictions (ESPN, Sagarin, etc.)
INSERT INTO dbo.GamePredictions (GameID, ModelID, PredictedLine)
SELECT g.GameID, pm.ModelID, TRY_CAST(s.lineespn AS DECIMAL(10,2))
FROM dbo.StagingGames s INNER JOIN dbo.Games g ON g.SeasonID = @Season22 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
CROSS JOIN dbo.PredictionModels pm WHERE pm.ModelCode = 'ESPN' AND s.lineespn IS NOT NULL AND s.lineespn <> '';

INSERT INTO dbo.GamePredictions (GameID, ModelID, PredictedLine)
SELECT g.GameID, pm.ModelID, TRY_CAST(s.linesag AS DECIMAL(10,2))
FROM dbo.StagingGames s INNER JOIN dbo.Games g ON g.SeasonID = @Season22 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
CROSS JOIN dbo.PredictionModels pm WHERE pm.ModelCode = 'SAGARIN' AND s.linesag IS NOT NULL AND s.linesag <> '';

INSERT INTO dbo.GamePredictions (GameID, ModelID, PredictedLine)
SELECT g.GameID, pm.ModelID, TRY_CAST(s.linemassey AS DECIMAL(10,2))
FROM dbo.StagingGames s INNER JOIN dbo.Games g ON g.SeasonID = @Season22 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
CROSS JOIN dbo.PredictionModels pm WHERE pm.ModelCode = 'MASSEY' AND s.linemassey IS NOT NULL AND s.linemassey <> '';

INSERT INTO dbo.GamePredictions (GameID, ModelID, PredictedLine)
SELECT g.GameID, pm.ModelID, TRY_CAST(s.linedunk AS DECIMAL(10,2))
FROM dbo.StagingGames s INNER JOIN dbo.Games g ON g.SeasonID = @Season22 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
CROSS JOIN dbo.PredictionModels pm WHERE pm.ModelCode = 'DUNKEL' AND s.linedunk IS NOT NULL AND s.linedunk <> '';

INSERT INTO dbo.GamePredictions (GameID, ModelID, PredictedLine)
SELECT g.GameID, pm.ModelID, TRY_CAST(s.linemoore AS DECIMAL(10,2))
FROM dbo.StagingGames s INNER JOIN dbo.Games g ON g.SeasonID = @Season22 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
CROSS JOIN dbo.PredictionModels pm WHERE pm.ModelCode = 'MOORE' AND s.linemoore IS NOT NULL AND s.linemoore <> '';

PRINT 'Season 2021-22 complete!';
TRUNCATE TABLE dbo.StagingGames;
GO

-- ============================================
-- Process 2022-23 Season
-- ============================================
PRINT 'Processing 2022-23 season...';
BULK INSERT dbo.StagingGames
FROM 'C:\Users\happy\Documents\Projects\ncaab-prediction-tracker\ncaabb23.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', TABLOCK);

DECLARE @Season23 INT = (SELECT SeasonID FROM dbo.Seasons WHERE SeasonYear = '2022-23' AND SportID = 1);

INSERT INTO dbo.GameLines (GameID, LineType, Line, StandardDeviation)
SELECT g.GameID, 'CONSENSUS', TRY_CAST(s.lineavg AS DECIMAL(10,2)), TRY_CAST(s.std AS DECIMAL(10,4))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @Season23 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
WHERE s.lineavg IS NOT NULL AND s.lineavg <> '';

INSERT INTO dbo.GameLines (GameID, LineType, Line)
SELECT g.GameID, 'OPENING', TRY_CAST(s.lineopen AS DECIMAL(10,2))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @Season23 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
WHERE s.lineopen IS NOT NULL AND s.lineopen <> '';

INSERT INTO dbo.GamePredictions (GameID, ModelID, PredictedLine)
SELECT g.GameID, pm.ModelID, TRY_CAST(s.lineespn AS DECIMAL(10,2))
FROM dbo.StagingGames s INNER JOIN dbo.Games g ON g.SeasonID = @Season23 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
CROSS JOIN dbo.PredictionModels pm WHERE pm.ModelCode = 'ESPN' AND s.lineespn IS NOT NULL AND s.lineespn <> '';

INSERT INTO dbo.GamePredictions (GameID, ModelID, PredictedLine)
SELECT g.GameID, pm.ModelID, TRY_CAST(s.linesag AS DECIMAL(10,2))
FROM dbo.StagingGames s INNER JOIN dbo.Games g ON g.SeasonID = @Season23 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
CROSS JOIN dbo.PredictionModels pm WHERE pm.ModelCode = 'SAGARIN' AND s.linesag IS NOT NULL AND s.linesag <> '';

INSERT INTO dbo.GamePredictions (GameID, ModelID, PredictedLine)
SELECT g.GameID, pm.ModelID, TRY_CAST(s.linemassey AS DECIMAL(10,2))
FROM dbo.StagingGames s INNER JOIN dbo.Games g ON g.SeasonID = @Season23 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
CROSS JOIN dbo.PredictionModels pm WHERE pm.ModelCode = 'MASSEY' AND s.linemassey IS NOT NULL AND s.linemassey <> '';

PRINT 'Season 2022-23 complete!';
TRUNCATE TABLE dbo.StagingGames;
GO

-- ============================================
-- Process 2023-24 Season
-- ============================================
PRINT 'Processing 2023-24 season...';
BULK INSERT dbo.StagingGames
FROM 'C:\Users\happy\Documents\Projects\ncaab-prediction-tracker\ncaabb24.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', TABLOCK);

DECLARE @Season24 INT = (SELECT SeasonID FROM dbo.Seasons WHERE SeasonYear = '2023-24' AND SportID = 1);

INSERT INTO dbo.GameLines (GameID, LineType, Line, StandardDeviation)
SELECT g.GameID, 'CONSENSUS', TRY_CAST(s.lineavg AS DECIMAL(10,2)), TRY_CAST(s.std AS DECIMAL(10,4))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @Season24 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
WHERE s.lineavg IS NOT NULL AND s.lineavg <> '';

INSERT INTO dbo.GameLines (GameID, LineType, Line)
SELECT g.GameID, 'OPENING', TRY_CAST(s.lineopen AS DECIMAL(10,2))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @Season24 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
WHERE s.lineopen IS NOT NULL AND s.lineopen <> '';

INSERT INTO dbo.GamePredictions (GameID, ModelID, PredictedLine)
SELECT g.GameID, pm.ModelID, TRY_CAST(s.lineespn AS DECIMAL(10,2))
FROM dbo.StagingGames s INNER JOIN dbo.Games g ON g.SeasonID = @Season24 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
CROSS JOIN dbo.PredictionModels pm WHERE pm.ModelCode = 'ESPN' AND s.lineespn IS NOT NULL AND s.lineespn <> '';

PRINT 'Season 2023-24 complete!';
GO

DROP TABLE dbo.StagingGames;

PRINT '========================================';
PRINT 'All predictions imported!';
PRINT 'Summary:';
SELECT COUNT(*) AS TotalPredictions FROM dbo.GamePredictions;
SELECT COUNT(*) AS TotalGameLines FROM dbo.GameLines;
PRINT '========================================';
GO
