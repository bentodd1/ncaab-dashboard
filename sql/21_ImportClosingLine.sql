-- ============================================
-- Import Closing Line (the 'line' column from CSV)
-- ============================================
USE SportsAnalytics;
GO

-- Clear existing closing lines if any
DELETE FROM dbo.GameLines WHERE LineType = 'CLOSING';
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

-- Import 2021-22
PRINT 'Importing closing lines for 2021-22...';
BULK INSERT dbo.StagingGames FROM 'C:\Users\happy\Documents\Projects\ncaab-prediction-tracker\ncaabb22.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);

DECLARE @S22 INT = (SELECT SeasonID FROM dbo.Seasons WHERE SeasonYear = '2021-22' AND SportID = 1);

INSERT INTO dbo.GameLines (GameID, LineType, Line)
SELECT g.GameID, 'CLOSING', TRY_CAST(MAX(s.line) AS DECIMAL(10,2))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @S22 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
WHERE s.line IS NOT NULL AND s.line <> ''
GROUP BY g.GameID;

PRINT 'Imported ' + CAST(@@ROWCOUNT AS VARCHAR) + ' closing lines for 2021-22';
TRUNCATE TABLE dbo.StagingGames;
GO

-- Import 2022-23
PRINT 'Importing closing lines for 2022-23...';
BULK INSERT dbo.StagingGames FROM 'C:\Users\happy\Documents\Projects\ncaab-prediction-tracker\ncaabb23.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', TABLOCK);

DECLARE @S23 INT = (SELECT SeasonID FROM dbo.Seasons WHERE SeasonYear = '2022-23' AND SportID = 1);

INSERT INTO dbo.GameLines (GameID, LineType, Line)
SELECT g.GameID, 'CLOSING', TRY_CAST(MAX(s.line) AS DECIMAL(10,2))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @S23 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
WHERE s.line IS NOT NULL AND s.line <> ''
GROUP BY g.GameID;

PRINT 'Imported ' + CAST(@@ROWCOUNT AS VARCHAR) + ' closing lines for 2022-23';
TRUNCATE TABLE dbo.StagingGames;
GO

-- Import 2023-24
PRINT 'Importing closing lines for 2023-24...';
BULK INSERT dbo.StagingGames FROM 'C:\Users\happy\Documents\Projects\ncaab-prediction-tracker\ncaabb24.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0A', TABLOCK);

DECLARE @S24 INT = (SELECT SeasonID FROM dbo.Seasons WHERE SeasonYear = '2023-24' AND SportID = 1);

INSERT INTO dbo.GameLines (GameID, LineType, Line)
SELECT g.GameID, 'CLOSING', TRY_CAST(MAX(s.line) AS DECIMAL(10,2))
FROM dbo.StagingGames s
INNER JOIN dbo.Games g ON g.SeasonID = @S24 AND g.GameDate = CONVERT(DATE, s.date, 101) AND g.HomeTeam = s.home AND g.RoadTeam = s.road
WHERE s.line IS NOT NULL AND s.line <> ''
GROUP BY g.GameID;

PRINT 'Imported ' + CAST(@@ROWCOUNT AS VARCHAR) + ' closing lines for 2023-24';
GO

DROP TABLE dbo.StagingGames;

PRINT 'Closing lines imported! Summary:';
SELECT LineType, COUNT(*) AS Count FROM dbo.GameLines GROUP BY LineType;
GO
