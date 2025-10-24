-- ============================================
-- Create Views for ESPN vs Opening Line Strategy
-- ============================================
-- This compares ESPN's prediction to the actual opening betting line
-- instead of the consensus of prediction models

USE SportsAnalytics;
GO

-- ============================================
-- View: ESPN vs Opening Line Strategy
-- ============================================
IF OBJECT_ID('dbo.vw_ESPNvsOpeningLine', 'V') IS NOT NULL
    DROP VIEW dbo.vw_ESPNvsOpeningLine;
GO

CREATE VIEW dbo.vw_ESPNvsOpeningLine
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
    OpeningLine,
    ESPNLine,
    -- Calculate the difference between opening line and ESPN
    OpeningLine - ESPNLine AS ESPNEdge,
    -- Determine who ESPN thinks is undervalued vs the market
    CASE
        WHEN OpeningLine > 0 AND ESPNLine <= -3 THEN 'ROAD (Strong)'
        WHEN OpeningLine > 0 AND ESPNLine < 0 THEN 'ROAD (Weak)'
        WHEN OpeningLine < 0 AND ESPNLine >= 3 THEN 'HOME (Strong)'
        WHEN OpeningLine < 0 AND ESPNLine > 0 THEN 'HOME (Weak)'
        ELSE 'NONE'
    END AS ESPNFavorsUnderdog,
    ActualMargin,
    Winner,
    -- Did betting on ESPN's pick against opening line cover?
    CASE
        WHEN ActualMargin IS NULL THEN NULL
        -- Road is underdog by opening line, ESPN favors road
        WHEN OpeningLine > 0 AND ESPNLine < OpeningLine THEN
            CASE WHEN ActualMargin < OpeningLine THEN 'COVERED' ELSE 'MISSED' END
        -- Home is underdog by opening line, ESPN favors home
        WHEN OpeningLine < 0 AND ESPNLine > OpeningLine THEN
            CASE WHEN ActualMargin > OpeningLine THEN 'COVERED' ELSE 'MISSED' END
        ELSE NULL
    END AS CoverResult
FROM dbo.vw_GamesWithPredictions
WHERE ESPNLine IS NOT NULL
  AND OpeningLine IS NOT NULL
  -- ESPN disagrees with opening line by at least 3 points
  AND ABS(OpeningLine - ESPNLine) >= 3;
GO

-- ============================================
-- View: Opening Line Strategy Performance Summary
-- ============================================
IF OBJECT_ID('dbo.vw_ESPNOpeningLinePerformance', 'V') IS NOT NULL
    DROP VIEW dbo.vw_ESPNOpeningLinePerformance;
GO

CREATE VIEW dbo.vw_ESPNOpeningLinePerformance
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
FROM dbo.vw_ESPNvsOpeningLine
GROUP BY SeasonYear;
GO

PRINT 'Views created successfully!';
GO
