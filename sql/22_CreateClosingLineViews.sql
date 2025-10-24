-- ============================================
-- Create Views for ESPN vs Closing Line Strategy
-- ============================================
USE SportsAnalytics;
GO

-- First, update the main view to include closing line
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
    (SELECT Line FROM dbo.GameLines WHERE GameID = g.GameID AND LineType = 'CONSENSUS') AS ConsensusLine,
    (SELECT Line FROM dbo.GameLines WHERE GameID = g.GameID AND LineType = 'OPENING') AS OpeningLine,
    (SELECT Line FROM dbo.GameLines WHERE GameID = g.GameID AND LineType = 'CLOSING') AS ClosingLine,
    (SELECT StandardDeviation FROM dbo.GameLines WHERE GameID = g.GameID AND LineType = 'CONSENSUS') AS LineStdDev,
    (SELECT PredictedLine FROM dbo.GamePredictions gp
     INNER JOIN dbo.PredictionModels pm ON gp.ModelID = pm.ModelID
     WHERE gp.GameID = g.GameID AND pm.ModelCode = 'ESPN') AS ESPNLine
FROM dbo.Games g
INNER JOIN dbo.Sports s ON g.SportID = s.SportID
INNER JOIN dbo.Seasons sn ON g.SeasonID = sn.SeasonID;
GO

-- ============================================
-- View: ESPN vs Closing Line Strategy
-- ============================================
IF OBJECT_ID('dbo.vw_ESPNvsClosingLine', 'V') IS NOT NULL
    DROP VIEW dbo.vw_ESPNvsClosingLine;
GO

CREATE VIEW dbo.vw_ESPNvsClosingLine
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
    ClosingLine,
    ESPNLine,
    ClosingLine - ESPNLine AS ESPNEdge,
    CASE
        WHEN ClosingLine > 0 AND ESPNLine <= -3 THEN 'ROAD (Strong)'
        WHEN ClosingLine > 0 AND ESPNLine < 0 THEN 'ROAD (Weak)'
        WHEN ClosingLine < 0 AND ESPNLine >= 3 THEN 'HOME (Strong)'
        WHEN ClosingLine < 0 AND ESPNLine > 0 THEN 'HOME (Weak)'
        ELSE 'NONE'
    END AS ESPNFavorsUnderdog,
    ActualMargin,
    Winner,
    CASE
        WHEN ActualMargin IS NULL THEN NULL
        WHEN ClosingLine > 0 AND ESPNLine < ClosingLine THEN
            CASE WHEN ActualMargin < ClosingLine THEN 'COVERED' ELSE 'MISSED' END
        WHEN ClosingLine < 0 AND ESPNLine > ClosingLine THEN
            CASE WHEN ActualMargin > ClosingLine THEN 'COVERED' ELSE 'MISSED' END
        ELSE NULL
    END AS CoverResult
FROM dbo.vw_GamesWithPredictions
WHERE ESPNLine IS NOT NULL
  AND ClosingLine IS NOT NULL
  AND ABS(ClosingLine - ESPNLine) >= 3;
GO

-- ============================================
-- Stored Procedure: ESPN vs Closing Line Performance
-- ============================================
IF OBJECT_ID('dbo.usp_CalculateClosingLinePerformance', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_CalculateClosingLinePerformance;
GO

CREATE PROCEDURE dbo.usp_CalculateClosingLinePerformance
    @MinEdge DECIMAL(10,2) = 3.0,
    @SeasonYear NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        'Overall' AS Period,
        COUNT(*) AS TotalGames,
        SUM(CASE WHEN CoverResult = 'COVERED' THEN 1 ELSE 0 END) AS Wins,
        SUM(CASE WHEN CoverResult = 'MISSED' THEN 1 ELSE 0 END) AS Losses,
        CASE
            WHEN SUM(CASE WHEN CoverResult IN ('COVERED', 'MISSED') THEN 1 ELSE 0 END) > 0
            THEN CAST(SUM(CASE WHEN CoverResult = 'COVERED' THEN 1 ELSE 0 END) AS FLOAT) /
                 SUM(CASE WHEN CoverResult IN ('COVERED', 'MISSED') THEN 1 ELSE 0 END) * 100
            ELSE 0
        END AS WinPercentage,
        CASE
            WHEN SUM(CASE WHEN CoverResult IN ('COVERED', 'MISSED') THEN 1 ELSE 0 END) > 0
            THEN (SUM(CASE WHEN CoverResult = 'COVERED' THEN 1 ELSE 0 END) * 100) -
                 (SUM(CASE WHEN CoverResult = 'MISSED' THEN 1 ELSE 0 END) * 110)
            ELSE 0
        END AS ProfitLoss_Per100Units,
        AVG(ESPNEdge) AS AvgEdge
    FROM dbo.vw_ESPNvsClosingLine
    WHERE ABS(ESPNEdge) >= @MinEdge
      AND (@SeasonYear IS NULL OR SeasonYear = @SeasonYear)
      AND CoverResult IS NOT NULL

    UNION ALL

    SELECT
        SeasonYear AS Period,
        COUNT(*) AS TotalGames,
        SUM(CASE WHEN CoverResult = 'COVERED' THEN 1 ELSE 0 END) AS Wins,
        SUM(CASE WHEN CoverResult = 'MISSED' THEN 1 ELSE 0 END) AS Losses,
        CASE
            WHEN SUM(CASE WHEN CoverResult IN ('COVERED', 'MISSED') THEN 1 ELSE 0 END) > 0
            THEN CAST(SUM(CASE WHEN CoverResult = 'COVERED' THEN 1 ELSE 0 END) AS FLOAT) /
                 SUM(CASE WHEN CoverResult IN ('COVERED', 'MISSED') THEN 1 ELSE 0 END) * 100
            ELSE 0
        END AS WinPercentage,
        CASE
            WHEN SUM(CASE WHEN CoverResult IN ('COVERED', 'MISSED') THEN 1 ELSE 0 END) > 0
            THEN (SUM(CASE WHEN CoverResult = 'COVERED' THEN 1 ELSE 0 END) * 100) -
                 (SUM(CASE WHEN CoverResult = 'MISSED' THEN 1 ELSE 0 END) * 110)
            ELSE 0
        END AS ProfitLoss_Per100Units,
        AVG(ESPNEdge) AS AvgEdge
    FROM dbo.vw_ESPNvsClosingLine
    WHERE ABS(ESPNEdge) >= @MinEdge
      AND (@SeasonYear IS NULL OR SeasonYear = @SeasonYear)
      AND CoverResult IS NOT NULL
    GROUP BY SeasonYear
    ORDER BY Period;
END
GO

PRINT 'Closing line views and sprocs created!';
GO
