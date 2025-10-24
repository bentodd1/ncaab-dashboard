-- ============================================
-- Create Views for Sports Analytics
-- ============================================
-- Run this from sqlcmd: sqlcmd -S MSI\SQLEXPRESS -E -d SportsAnalytics -i 05_CreateViews.sql

USE SportsAnalytics;
GO

-- ============================================
-- View: All Games with Predictions
-- ============================================
IF OBJECT_ID('dbo.vw_GamesWithPredictions', 'V') IS NOT NULL
    DROP VIEW dbo.vw_GamesWithPredictions;
GO

CREATE VIEW dbo.vw_GamesWithPredictions
AS
SELECT
    g.GameID,
    s.SportName,
    sn.SeasonYear,
    g.GameDate,
    g.HomeTeam,
    g.RoadTeam,
    g.HomeScore,
    g.RoadScore,
    g.IsNeutralSite,
    g.RoundNumber,
    -- Calculate actual result
    CASE
        WHEN g.HomeScore IS NOT NULL AND g.RoadScore IS NOT NULL
        THEN g.HomeScore - g.RoadScore
        ELSE NULL
    END AS ActualMargin,
    CASE
        WHEN g.HomeScore > g.RoadScore THEN 'HOME'
        WHEN g.RoadScore > g.HomeScore THEN 'ROAD'
        WHEN g.HomeScore = g.RoadScore THEN 'TIE'
        ELSE NULL
    END AS Winner,
    -- Get consensus line
    (SELECT Line FROM dbo.GameLines WHERE GameID = g.GameID AND LineType = 'CONSENSUS') AS ConsensusLine,
    (SELECT Line FROM dbo.GameLines WHERE GameID = g.GameID AND LineType = 'OPENING') AS OpeningLine,
    (SELECT StandardDeviation FROM dbo.GameLines WHERE GameID = g.GameID AND LineType = 'CONSENSUS') AS LineStdDev,
    -- ESPN prediction
    (SELECT PredictedLine FROM dbo.GamePredictions gp
     INNER JOIN dbo.PredictionModels pm ON gp.ModelID = pm.ModelID
     WHERE gp.GameID = g.GameID AND pm.ModelCode = 'ESPN') AS ESPNLine
FROM dbo.Games g
INNER JOIN dbo.Sports s ON g.SportID = s.SportID
INNER JOIN dbo.Seasons sn ON g.SeasonID = sn.SeasonID;
GO

-- ============================================
-- View: ESPN Favors Underdog Strategy
-- ============================================
IF OBJECT_ID('dbo.vw_ESPNFavorsUnderdog', 'V') IS NOT NULL
    DROP VIEW dbo.vw_ESPNFavorsUnderdog;
GO

CREATE VIEW dbo.vw_ESPNFavorsUnderdog
AS
SELECT
    GameID,
    SportName,
    SeasonYear,
    GameDate,
    HomeTeam,
    RoadTeam,
    HomeScore,
    RoadScore,
    IsNeutralSite,
    ConsensusLine,
    ESPNLine,
    -- Calculate the difference between consensus and ESPN
    ConsensusLine - ESPNLine AS ESPNEdge,
    -- Determine who ESPN thinks is undervalued
    CASE
        WHEN ConsensusLine > 0 AND ESPNLine <= -3 THEN 'ROAD (Strong)'
        WHEN ConsensusLine > 0 AND ESPNLine < 0 THEN 'ROAD (Weak)'
        WHEN ConsensusLine < 0 AND ESPNLine >= 3 THEN 'HOME (Strong)'
        WHEN ConsensusLine < 0 AND ESPNLine > 0 THEN 'HOME (Weak)'
        ELSE 'NONE'
    END AS ESPNFavorsUnderdog,
    ActualMargin,
    Winner,
    -- Did betting on ESPN's underdog cover?
    CASE
        WHEN ActualMargin IS NULL THEN NULL
        -- Road is underdog, ESPN favors road
        WHEN ConsensusLine > 0 AND ESPNLine < ConsensusLine THEN
            CASE WHEN ActualMargin < ConsensusLine THEN 'COVERED' ELSE 'MISSED' END
        -- Home is underdog, ESPN favors home
        WHEN ConsensusLine < 0 AND ESPNLine > ConsensusLine THEN
            CASE WHEN ActualMargin > ConsensusLine THEN 'COVERED' ELSE 'MISSED' END
        ELSE NULL
    END AS CoverResult
FROM dbo.vw_GamesWithPredictions
WHERE ESPNLine IS NOT NULL
  AND ConsensusLine IS NOT NULL
  -- ESPN disagrees with consensus by at least 3 points
  AND ABS(ConsensusLine - ESPNLine) >= 3;
GO

-- ============================================
-- View: Strategy Performance Summary
-- ============================================
IF OBJECT_ID('dbo.vw_ESPNStrategyPerformance', 'V') IS NOT NULL
    DROP VIEW dbo.vw_ESPNStrategyPerformance;
GO

CREATE VIEW dbo.vw_ESPNStrategyPerformance
AS
SELECT
    SeasonYear,
    COUNT(*) AS TotalGames,
    SUM(CASE WHEN CoverResult = 'COVERED' THEN 1 ELSE 0 END) AS Covers,
    SUM(CASE WHEN CoverResult = 'MISSED' THEN 1 ELSE 0 END) AS Misses,
    SUM(CASE WHEN CoverResult IS NULL THEN 1 ELSE 0 END) AS Pending,
    CASE
        WHEN SUM(CASE WHEN CoverResult IN ('COVERED', 'MISSED') THEN 1 ELSE 0 END) > 0
        THEN CAST(SUM(CASE WHEN CoverResult = 'COVERED' THEN 1 ELSE 0 END) AS FLOAT) /
             SUM(CASE WHEN CoverResult IN ('COVERED', 'MISSED') THEN 1 ELSE 0 END) * 100
        ELSE 0
    END AS CoverPercentage,
    AVG(ESPNEdge) AS AvgESPNEdge,
    MIN(ESPNEdge) AS MinESPNEdge,
    MAX(ESPNEdge) AS MaxESPNEdge
FROM dbo.vw_ESPNFavorsUnderdog
GROUP BY SeasonYear;
GO

PRINT 'Views created successfully!';
GO
