-- ============================================
-- Stored Procedures for ESPN vs Opening Line Strategy
-- ============================================

USE SportsAnalytics;
GO

-- ============================================
-- Get ESPN vs Opening Line Picks
-- ============================================
IF OBJECT_ID('dbo.usp_GetESPNvsOpeningLinePicks', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetESPNvsOpeningLinePicks;
GO

CREATE PROCEDURE dbo.usp_GetESPNvsOpeningLinePicks
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
        OpeningLine,
        ESPNLine,
        ESPNEdge,
        ESPNFavorsUnderdog,
        HomeScore,
        RoadScore,
        ActualMargin,
        Winner,
        CoverResult,
        SeasonYear
    FROM dbo.vw_ESPNvsOpeningLine
    WHERE ABS(ESPNEdge) >= @MinEdge
      AND (@SeasonYear IS NULL OR SeasonYear = @SeasonYear)
      AND (@StartDate IS NULL OR GameDate >= @StartDate)
      AND (@EndDate IS NULL OR GameDate <= @EndDate)
      AND (@IncludePending = 1 OR CoverResult IS NOT NULL)
    ORDER BY GameDate DESC, ESPNEdge DESC;
END
GO

-- ============================================
-- Calculate Opening Line Strategy Performance
-- ============================================
IF OBJECT_ID('dbo.usp_CalculateOpeningLinePerformance', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_CalculateOpeningLinePerformance;
GO

CREATE PROCEDURE dbo.usp_CalculateOpeningLinePerformance
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
    FROM dbo.vw_ESPNvsOpeningLine
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
    FROM dbo.vw_ESPNvsOpeningLine
    WHERE ABS(ESPNEdge) >= @MinEdge
      AND (@SeasonYear IS NULL OR SeasonYear = @SeasonYear)
      AND (@StartDate IS NULL OR GameDate >= @StartDate)
      AND (@EndDate IS NULL OR GameDate <= @EndDate)
      AND CoverResult IS NOT NULL
    GROUP BY SeasonYear
    ORDER BY Period;
END
GO

PRINT 'Stored procedures created successfully!';
GO
