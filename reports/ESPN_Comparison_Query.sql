-- ============================================
-- Query for Telerik Report: Strategy Comparison
-- ============================================
-- Use this query as the data source in Telerik Report Designer

-- Compare all three ESPN strategies side-by-side
SELECT
    'ESPN vs Consensus Models' AS Strategy,
    COUNT(*) AS TotalGames,
    SUM(CASE WHEN CoverResult = 'COVERED' THEN 1 ELSE 0 END) AS Wins,
    SUM(CASE WHEN CoverResult = 'MISSED' THEN 1 ELSE 0 END) AS Losses,
    CAST(SUM(CASE WHEN CoverResult = 'COVERED' THEN 1 ELSE 0 END) AS FLOAT) /
        SUM(CASE WHEN CoverResult IN ('COVERED', 'MISSED') THEN 1 ELSE 0 END) * 100 AS WinPercentage,
    (SUM(CASE WHEN CoverResult = 'COVERED' THEN 1 ELSE 0 END) * 100) -
    (SUM(CASE WHEN CoverResult = 'MISSED' THEN 1 ELSE 0 END) * 110) AS ProfitLoss,
    'Best - ESPN beats other models' AS Interpretation,
    1 AS SortOrder
FROM dbo.vw_ESPNFavorsUnderdog
WHERE ABS(ESPNEdge) >= 3 AND CoverResult IS NOT NULL

UNION ALL

SELECT
    'ESPN vs Opening Line' AS Strategy,
    COUNT(*) AS TotalGames,
    SUM(CASE WHEN CoverResult = 'COVERED' THEN 1 ELSE 0 END) AS Wins,
    SUM(CASE WHEN CoverResult = 'MISSED' THEN 1 ELSE 0 END) AS Losses,
    CAST(SUM(CASE WHEN CoverResult = 'COVERED' THEN 1 ELSE 0 END) AS FLOAT) /
        SUM(CASE WHEN CoverResult IN ('COVERED', 'MISSED') THEN 1 ELSE 0 END) * 100 AS WinPercentage,
    (SUM(CASE WHEN CoverResult = 'COVERED' THEN 1 ELSE 0 END) * 100) -
    (SUM(CASE WHEN CoverResult = 'MISSED' THEN 1 ELSE 0 END) * 110) AS ProfitLoss,
    'Marginal - Barely profitable' AS Interpretation,
    2 AS SortOrder
FROM dbo.vw_ESPNvsOpeningLine
WHERE ABS(ESPNEdge) >= 3 AND CoverResult IS NOT NULL

UNION ALL

SELECT
    'ESPN vs Closing Line' AS Strategy,
    COUNT(*) AS TotalGames,
    SUM(CASE WHEN CoverResult = 'COVERED' THEN 1 ELSE 0 END) AS Wins,
    SUM(CASE WHEN CoverResult = 'MISSED' THEN 1 ELSE 0 END) AS Losses,
    CAST(SUM(CASE WHEN CoverResult = 'COVERED' THEN 1 ELSE 0 END) AS FLOAT) /
        SUM(CASE WHEN CoverResult IN ('COVERED', 'MISSED') THEN 1 ELSE 0 END) * 100 AS WinPercentage,
    (SUM(CASE WHEN CoverResult = 'COVERED' THEN 1 ELSE 0 END) * 100) -
    (SUM(CASE WHEN CoverResult = 'MISSED' THEN 1 ELSE 0 END) * 110) AS ProfitLoss,
    'Loss - Cannot beat efficient market' AS Interpretation,
    3 AS SortOrder

ORDER BY SortOrder;
