-- Import 2022-23 season ONLY
USE SportsAnalytics;
GO

IF OBJECT_ID('dbo.StagingGames', 'U') IS NOT NULL DROP TABLE dbo.StagingGames;
GO

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

PRINT 'Importing 2022-23 season...';
GO

BULK INSERT dbo.StagingGames
FROM 'C:\Users\happy\Documents\Projects\ncaab-prediction-tracker\ncaabb23.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);
GO

PRINT 'Rows loaded into staging:';
SELECT COUNT(*) FROM dbo.StagingGames;
GO

PRINT 'Inserting into Games table...';
GO

DECLARE @S23 INT = (SELECT SeasonID FROM dbo.Seasons WHERE SeasonYear = '2022-23' AND SportID = 1);

INSERT INTO dbo.Games (SportID, SeasonID, GameDate, HomeTeam, RoadTeam, HomeScore, RoadScore, IsNeutralSite, RoundNumber)
SELECT 1, @S23, CONVERT(DATE, date, 101), home, road,
    TRY_CAST(MAX(hscore) AS INT), TRY_CAST(MAX(rscore) AS INT),
    MAX(CASE WHEN neutral = '1' THEN 1 ELSE 0 END), TRY_CAST(MAX(lineround) AS INT)
FROM dbo.StagingGames
GROUP BY date, home, road;

PRINT 'Inserted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' games for 2022-23';
GO

PRINT 'Total games by season:';
SELECT s.SeasonYear, COUNT(*) AS GameCount
FROM dbo.Games g
INNER JOIN dbo.Seasons s ON g.SeasonID = s.SeasonID
GROUP BY s.SeasonYear
ORDER BY s.SeasonYear;
GO
