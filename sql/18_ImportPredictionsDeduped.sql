-- ============================================
-- Import ALL Predictions with Deduplication
-- ============================================
USE SportsAnalytics;
GO

PRINT 'Clearing existing prediction data...';
DELETE FROM dbo.GamePredictions;
DELETE FROM dbo.GameLines;
GO

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
-- 2021-22 Season
-- ============================================
PRINT 'Importing 2021-22...';
BULK INSERT dbo.StagingGames FROM 'C:\Users\happy\Documents\Projects\ncaab-prediction-tracker\ncaabb22.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);

DECLARE @S22 INT = (SELECT SeasonID FROM dbo.Seasons WHERE SeasonYear = '2021-22' AND SportID = 1);

-- Consensus lines (deduplicated with MAX)
INSERT INTO dbo.GameLines (GameID, LineType, Line, StandardDeviation)
SELECT g.GameID, 'CONSENSUS', TRY_CAST(MAX(s.lineavg) AS DECIMAL(10,2)), TRY_CAST(MAX(s.std) AS DECIMAL(10,4))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @S22 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
WHERE s.lineavg IS NOT NULL AND s.lineavg <> ''
GROUP BY g.GameID;

-- Opening lines
INSERT INTO dbo.GameLines (GameID, LineType, Line)
SELECT g.GameID, 'OPENING', TRY_CAST(MAX(s.lineopen) AS DECIMAL(10,2))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @S22 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
WHERE s.lineopen IS NOT NULL AND s.lineopen <> ''
GROUP BY g.GameID;

-- ESPN predictions
INSERT INTO dbo.GamePredictions (GameID, ModelID, PredictedLine)
SELECT g.GameID, pm.ModelID, TRY_CAST(MAX(s.lineespn) AS DECIMAL(10,2))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @S22 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
CROSS JOIN dbo.PredictionModels pm
WHERE pm.ModelCode = 'ESPN' AND s.lineespn IS NOT NULL AND s.lineespn <> ''
GROUP BY g.GameID, pm.ModelID;

-- Sagarin
INSERT INTO dbo.GamePredictions (GameID, ModelID, PredictedLine)
SELECT g.GameID, pm.ModelID, TRY_CAST(MAX(s.linesag) AS DECIMAL(10,2))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @S22 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
CROSS JOIN dbo.PredictionModels pm
WHERE pm.ModelCode = 'SAGARIN' AND s.linesag IS NOT NULL AND s.linesag <> ''
GROUP BY g.GameID, pm.ModelID;

-- Massey
INSERT INTO dbo.GamePredictions (GameID, ModelID, PredictedLine)
SELECT g.GameID, pm.ModelID, TRY_CAST(MAX(s.linemassey) AS DECIMAL(10,2))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @S22 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
CROSS JOIN dbo.PredictionModels pm
WHERE pm.ModelCode = 'MASSEY' AND s.linemassey IS NOT NULL AND s.linemassey <> ''
GROUP BY g.GameID, pm.ModelID;

PRINT '2021-22 done!';
TRUNCATE TABLE dbo.StagingGames;
GO

-- ============================================
-- 2022-23 Season
-- ============================================
PRINT 'Importing 2022-23...';
BULK INSERT dbo.StagingGames FROM 'C:\Users\happy\Documents\Projects\ncaab-prediction-tracker\ncaabb23.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', TABLOCK);

DECLARE @S23 INT = (SELECT SeasonID FROM dbo.Seasons WHERE SeasonYear = '2022-23' AND SportID = 1);

INSERT INTO dbo.GameLines (GameID, LineType, Line, StandardDeviation)
SELECT g.GameID, 'CONSENSUS', TRY_CAST(MAX(s.lineavg) AS DECIMAL(10,2)), TRY_CAST(MAX(s.std) AS DECIMAL(10,4))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @S23 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
WHERE s.lineavg IS NOT NULL AND s.lineavg <> ''
GROUP BY g.GameID;

INSERT INTO dbo.GameLines (GameID, LineType, Line)
SELECT g.GameID, 'OPENING', TRY_CAST(MAX(s.lineopen) AS DECIMAL(10,2))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @S23 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
WHERE s.lineopen IS NOT NULL AND s.lineopen <> ''
GROUP BY g.GameID;

INSERT INTO dbo.GamePredictions (GameID, ModelID, PredictedLine)
SELECT g.GameID, pm.ModelID, TRY_CAST(MAX(s.lineespn) AS DECIMAL(10,2))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @S23 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
CROSS JOIN dbo.PredictionModels pm
WHERE pm.ModelCode = 'ESPN' AND s.lineespn IS NOT NULL AND s.lineespn <> ''
GROUP BY g.GameID, pm.ModelID;

PRINT '2022-23 done!';
TRUNCATE TABLE dbo.StagingGames;
GO

-- ============================================
-- 2023-24 Season
-- ============================================
PRINT 'Importing 2023-24...';
BULK INSERT dbo.StagingGames FROM 'C:\Users\happy\Documents\Projects\ncaab-prediction-tracker\ncaabb24.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', TABLOCK);

DECLARE @S24 INT = (SELECT SeasonID FROM dbo.Seasons WHERE SeasonYear = '2023-24' AND SportID = 1);

INSERT INTO dbo.GameLines (GameID, LineType, Line, StandardDeviation)
SELECT g.GameID, 'CONSENSUS', TRY_CAST(MAX(s.lineavg) AS DECIMAL(10,2)), TRY_CAST(MAX(s.std) AS DECIMAL(10,4))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @S24 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
WHERE s.lineavg IS NOT NULL AND s.lineavg <> ''
GROUP BY g.GameID;

INSERT INTO dbo.GameLines (GameID, LineType, Line)
SELECT g.GameID, 'OPENING', TRY_CAST(MAX(s.lineopen) AS DECIMAL(10,2))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @S24 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
WHERE s.lineopen IS NOT NULL AND s.lineopen <> ''
GROUP BY g.GameID;

INSERT INTO dbo.GamePredictions (GameID, ModelID, PredictedLine)
SELECT g.GameID, pm.ModelID, TRY_CAST(MAX(s.lineespn) AS DECIMAL(10,2))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @S24 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
CROSS JOIN dbo.PredictionModels pm
WHERE pm.ModelCode = 'ESPN' AND s.lineespn IS NOT NULL AND s.lineespn <> ''
GROUP BY g.GameID, pm.ModelID;

PRINT '2023-24 done!';
GO

DROP TABLE dbo.StagingGames;

PRINT '========================================';
PRINT 'COMPLETE! Testing ESPN strategy...';
SELECT COUNT(*) AS ESPNPredictions FROM dbo.GamePredictions gp
INNER JOIN dbo.PredictionModels pm ON gp.ModelID = pm.ModelID
WHERE pm.ModelCode = 'ESPN';

SELECT COUNT(*) AS ConsensusLines FROM dbo.GameLines WHERE LineType = 'CONSENSUS';
PRINT '========================================';
GO
