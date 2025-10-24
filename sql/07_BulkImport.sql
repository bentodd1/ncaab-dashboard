-- ============================================
-- Bulk Import CSV Data
-- ============================================
-- Run this from VSCode SQL extension or:
-- sqlcmd -S MSI\SQLEXPRESS -E -d SportsAnalytics -i 07_BulkImport.sql

USE SportsAnalytics;
GO

-- Create temporary staging table to hold CSV data
IF OBJECT_ID('dbo.StagingGames', 'U') IS NOT NULL
    DROP TABLE dbo.StagingGames;
GO

CREATE TABLE dbo.StagingGames (
    date VARCHAR(50),
    home VARCHAR(100),
    hscore VARCHAR(10),
    road VARCHAR(100),
    rscore VARCHAR(10),
    line VARCHAR(20),
    lineavg VARCHAR(20),
    linesag VARCHAR(20),
    linesage VARCHAR(20),
    linesagp VARCHAR(20),
    linesaggm VARCHAR(20),
    linemoore VARCHAR(20),
    lineopen VARCHAR(20),
    linedok VARCHAR(20),
    linefox VARCHAR(20),
    std VARCHAR(20),
    linepugh VARCHAR(20),
    linedonc VARCHAR(20),
    neutral VARCHAR(10),
    linetalis VARCHAR(20),
    lineespn VARCHAR(20),
    linepir VARCHAR(20),
    linepiw VARCHAR(20),
    linepib VARCHAR(20),
    line7ot VARCHAR(20),
    lineer VARCHAR(20),
    linedd VARCHAR(20),
    linemassey VARCHAR(20),
    linedunk VARCHAR(20),
    lineround VARCHAR(10),
    lineteamrnks VARCHAR(50)
);
GO

-- Import 2021-22 season
PRINT 'Importing 2021-22 season...';
BULK INSERT dbo.StagingGames
FROM 'C:\Users\happy\Documents\Projects\ncaab-prediction-tracker\ncaabb22.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

-- Process 2021-22 data
PRINT 'Processing 2021-22 season data...';
DECLARE @Season2122 INT = (SELECT SeasonID FROM dbo.Seasons WHERE SeasonYear = '2021-22' AND SportID = 1);

INSERT INTO dbo.Games (SportID, SeasonID, GameDate, HomeTeam, RoadTeam, HomeScore, RoadScore, IsNeutralSite, RoundNumber)
SELECT DISTINCT
    1,
    @Season2122,
    CONVERT(DATE, date, 101),
    home,
    road,
    TRY_CAST(hscore AS INT),
    TRY_CAST(rscore AS INT),
    CASE WHEN neutral = '1' THEN 1 ELSE 0 END,
    TRY_CAST(lineround AS INT)
FROM dbo.StagingGames;

PRINT 'Inserted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' games for 2021-22';
GO

-- Clear staging table for next season
TRUNCATE TABLE dbo.StagingGames;
GO

-- Import 2022-23 season
PRINT 'Importing 2022-23 season...';
BULK INSERT dbo.StagingGames
FROM 'C:\Users\happy\Documents\Projects\ncaab-prediction-tracker\ncaabb23.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

-- Process 2022-23 data
PRINT 'Processing 2022-23 season data...';
DECLARE @Season2223 INT = (SELECT SeasonID FROM dbo.Seasons WHERE SeasonYear = '2022-23' AND SportID = 1);

INSERT INTO dbo.Games (SportID, SeasonID, GameDate, HomeTeam, RoadTeam, HomeScore, RoadScore, IsNeutralSite, RoundNumber)
SELECT DISTINCT
    1,
    @Season2223,
    CONVERT(DATE, date, 101),
    home,
    road,
    TRY_CAST(hscore AS INT),
    TRY_CAST(rscore AS INT),
    CASE WHEN neutral = '1' THEN 1 ELSE 0 END,
    TRY_CAST(lineround AS INT)
FROM dbo.StagingGames;

PRINT 'Inserted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' games for 2022-23';
GO

-- Clear staging table for next season
TRUNCATE TABLE dbo.StagingGames;
GO

-- Import 2023-24 season
PRINT 'Importing 2023-24 season...';
BULK INSERT dbo.StagingGames
FROM 'C:\Users\happy\Documents\Projects\ncaab-prediction-tracker\ncaabb24.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

-- Process 2023-24 data
PRINT 'Processing 2023-24 season data...';
DECLARE @Season2324 INT = (SELECT SeasonID FROM dbo.Seasons WHERE SeasonYear = '2023-24' AND SportID = 1);

INSERT INTO dbo.Games (SportID, SeasonID, GameDate, HomeTeam, RoadTeam, HomeScore, RoadScore, IsNeutralSite, RoundNumber)
SELECT DISTINCT
    1,
    @Season2324,
    CONVERT(DATE, date, 101),
    home,
    road,
    TRY_CAST(hscore AS INT),
    TRY_CAST(rscore AS INT),
    CASE WHEN neutral = '1' THEN 1 ELSE 0 END,
    TRY_CAST(lineround AS INT)
FROM dbo.StagingGames;

PRINT 'Inserted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' games for 2023-24';
GO

-- Clean up
DROP TABLE dbo.StagingGames;
GO

PRINT 'Import complete! Checking totals...';
SELECT COUNT(*) AS TotalGames FROM dbo.Games;
GO
