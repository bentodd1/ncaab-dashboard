-- ============================================
-- Create Stored Procedures for Sports Analytics
-- ============================================
-- Run this from sqlcmd: sqlcmd -S MSI\SQLEXPRESS -E -d SportsAnalytics -i 06_CreateStoredProcedures.sql

USE SportsAnalytics;
GO

-- ============================================
-- Stored Procedure: Get ESPN Underdog Picks
-- ============================================
IF OBJECT_ID('dbo.usp_GetESPNUnderdogPicks', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetESPNUnderdogPicks;
GO

CREATE PROCEDURE dbo.usp_GetESPNUnderdogPicks
    @MinEdge DECIMAL(10,2) = 3.0,
    @SeasonYear NVARCHAR(20) = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @IncludePending BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        GameDate,
        HomeTeam,
        RoadTeam,
        ConsensusLine,
        ESPNLine,
        ESPNEdge,
        ESPNFavorsUnderdog,
        HomeScore,
        RoadScore,
        ActualMargin,
        Winner,
        CoverResult,
        SeasonYear
    FROM dbo.vw_ESPNFavorsUnderdog
    WHERE ABS(ESPNEdge) >= @MinEdge
      AND (@SeasonYear IS NULL OR SeasonYear = @SeasonYear)
      AND (@StartDate IS NULL OR GameDate >= @StartDate)
      AND (@EndDate IS NULL OR GameDate <= @EndDate)
      AND (@IncludePending = 1 OR CoverResult IS NOT NULL)
    ORDER BY GameDate DESC, ESPNEdge DESC;
END
GO

-- ============================================
-- Stored Procedure: Calculate Strategy Performance
-- ============================================
IF OBJECT_ID('dbo.usp_CalculateStrategyPerformance', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_CalculateStrategyPerformance;
GO

CREATE PROCEDURE dbo.usp_CalculateStrategyPerformance
    @MinEdge DECIMAL(10,2) = 3.0,
    @SeasonYear NVARCHAR(20) = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Overall performance
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
        -- Assuming -110 odds, calculate profit/loss
        CASE
            WHEN SUM(CASE WHEN CoverResult IN ('COVERED', 'MISSED') THEN 1 ELSE 0 END) > 0
            THEN (SUM(CASE WHEN CoverResult = 'COVERED' THEN 1 ELSE 0 END) * 100) -
                 (SUM(CASE WHEN CoverResult = 'MISSED' THEN 1 ELSE 0 END) * 110)
            ELSE 0
        END AS ProfitLoss_Per100Units,
        AVG(ESPNEdge) AS AvgEdge,
        MIN(ESPNEdge) AS MinEdge,
        MAX(ESPNEdge) AS MaxEdge
    FROM dbo.vw_ESPNFavorsUnderdog
    WHERE ABS(ESPNEdge) >= @MinEdge
      AND (@SeasonYear IS NULL OR SeasonYear = @SeasonYear)
      AND (@StartDate IS NULL OR GameDate >= @StartDate)
      AND (@EndDate IS NULL OR GameDate <= @EndDate)
      AND CoverResult IS NOT NULL

    UNION ALL

    -- By season
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
        AVG(ESPNEdge) AS AvgEdge,
        MIN(ESPNEdge) AS MinEdge,
        MAX(ESPNEdge) AS MaxEdge
    FROM dbo.vw_ESPNFavorsUnderdog
    WHERE ABS(ESPNEdge) >= @MinEdge
      AND (@SeasonYear IS NULL OR SeasonYear = @SeasonYear)
      AND (@StartDate IS NULL OR GameDate >= @StartDate)
      AND (@EndDate IS NULL OR GameDate <= @EndDate)
      AND CoverResult IS NOT NULL
    GROUP BY SeasonYear
    ORDER BY Period;
END
GO

-- ============================================
-- Stored Procedure: Compare Model Performance
-- ============================================
IF OBJECT_ID('dbo.usp_CompareModelAccuracy', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_CompareModelAccuracy;
GO

CREATE PROCEDURE dbo.usp_CompareModelAccuracy
    @SeasonYear NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        pm.ModelName,
        pm.ModelCode,
        COUNT(*) AS TotalPredictions,
        -- Games where model correctly predicted winner
        SUM(CASE
            WHEN gp.PredictedLine > 0 AND g.HomeScore > g.RoadScore THEN 1
            WHEN gp.PredictedLine < 0 AND g.RoadScore > g.HomeScore THEN 1
            ELSE 0
        END) AS CorrectWinnerPicks,
        -- Games where model's line covered
        SUM(CASE
            WHEN gp.PredictedLine > 0 AND (g.HomeScore - g.RoadScore) > gp.PredictedLine THEN 1
            WHEN gp.PredictedLine < 0 AND (g.HomeScore - g.RoadScore) < gp.PredictedLine THEN 1
            ELSE 0
        END) AS Covers,
        -- Accuracy percentages
        CAST(SUM(CASE
            WHEN gp.PredictedLine > 0 AND g.HomeScore > g.RoadScore THEN 1
            WHEN gp.PredictedLine < 0 AND g.RoadScore > g.HomeScore THEN 1
            ELSE 0
        END) AS FLOAT) / COUNT(*) * 100 AS WinnerAccuracy,
        CAST(SUM(CASE
            WHEN gp.PredictedLine > 0 AND (g.HomeScore - g.RoadScore) > gp.PredictedLine THEN 1
            WHEN gp.PredictedLine < 0 AND (g.HomeScore - g.RoadScore) < gp.PredictedLine THEN 1
            ELSE 0
        END) AS FLOAT) / COUNT(*) * 100 AS CoverAccuracy,
        -- Average prediction vs actual
        AVG(gp.PredictedLine) AS AvgPredictedLine,
        AVG(g.HomeScore - g.RoadScore) AS AvgActualMargin,
        AVG(ABS(gp.PredictedLine - (g.HomeScore - g.RoadScore))) AS AvgError
    FROM dbo.GamePredictions gp
    INNER JOIN dbo.PredictionModels pm ON gp.ModelID = pm.ModelID
    INNER JOIN dbo.Games g ON gp.GameID = g.GameID
    INNER JOIN dbo.Seasons sn ON g.SeasonID = sn.SeasonID
    WHERE g.HomeScore IS NOT NULL
      AND g.RoadScore IS NOT NULL
      AND (@SeasonYear IS NULL OR sn.SeasonYear = @SeasonYear)
      AND g.SportID = 1 -- NCAAB only
    GROUP BY pm.ModelName, pm.ModelCode
    ORDER BY CoverAccuracy DESC;
END
GO

PRINT 'Stored procedures created successfully!';
GO
